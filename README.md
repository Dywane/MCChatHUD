# MCChatHUD

MatchaSKD中录音波形图实现Demo，并增加新的样式。

[文章地址](https://dywane.github.io/在iOS中绘制录音音频波形图/)

# 效果图
![条状波形图](http://upload-images.jianshu.io/upload_images/4853563-cc1e5ca0e113e99e.gif?imageMogr2/auto-orient/strip)
![线装波形图](http://upload-images.jianshu.io/upload_images/4853563-3cac5c7d7410f808.gif?imageMogr2/auto-orient/strip)


# 实现方式
### 配置AvAudioSession
绘制波形图前首先需要配置好`AVAudioSession`，同时需要建立一个数组去保存音量数据。

#### 相关属性
- **recorderSetting**用于设定录音音质等相关数据。
- **timer**以及**updateFequency**用于定时更新波形图。
- **soundMeter**和**soundMeterCount**用于保存音量表数组。
- **recordTime**用于记录录音时间，可以用于判断录音时间是否达到要求等进一波需求。


```swift
	 /// 录音器
    private var recorder: AVAudioRecorder!
    /// 录音器设置
    private let recorderSetting = [AVSampleRateKey : NSNumber(value: Float(44100.0)),//声音采样率
                                     AVFormatIDKey : NSNumber(value: Int32(kAudioFormatMPEG4AAC)),//编码格式
                             AVNumberOfChannelsKey : NSNumber(value: 1),//采集音轨
                          AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.medium.rawValue))]//声音质量
    /// 录音计时器
    private var timer: Timer?
    /// 波形更新间隔
    private let updateFequency = 0.05
    /// 声音数据数组
    private var soundMeters: [Float]!
    /// 声音数据数组容量
    private let soundMeterCount = 10
    /// 录音时间
    private var recordTime = 0.00

```
#### AvAudioSession相关配置
- **configAVAudioSession**用于配置`AVAudioSession`，其中`AVAudioSessionCategoryRecord`是代表仅仅利用这个session进行录音操作，而需要播放操作的话是可以设置成`AVAudioSessionCategoryPlayAndRecord`或`AVAudioSessionCategoryPlayBlack`,两者区别一个是可以录音和播放，另一个是可以在后台播放（即静音后仍然可以播放语音）。
- **configRecord**是用于配置整个`AVAudioRecoder`，包括权限获取、代理源设置、是否记录音量表等。
- **directoryURL**是用于配置文件保存地址。

```swift
	private func configAVAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do { try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker) }
        catch { print("session config failed") }
    }
    
    
    private func configRecord() {
        AVAudioSession.sharedInstance().requestRecordPermission { (allowed) in
            if !allowed {
                return
            }
        }
        let session = AVAudioSession.sharedInstance()
        do { try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker) }
        catch { print("session config failed") }
        do {
            self.recorder = try AVAudioRecorder(url: self.directoryURL()!, settings: self.recorderSetting)
            self.recorder.delegate = self
            self.recorder.prepareToRecord()
            self.recorder.isMeteringEnabled = true
        } catch {
            print(error.localizedDescription)
        }
        do { try AVAudioSession.sharedInstance().setActive(true) }
        catch { print("session active failed") }
    }
    
    
    private func directoryURL() -> URL? {
        // do something ...
        return soundFileURL
    }
```

### 记录音频数据
在开始录音后，利用我们刚刚配置的定时器不断获取`averagePower`，并保存到数组之中。

- **updateMeters**被定时器调用，不断将recorder中记录的音量数据保存到soundMeter数组中。
- **addSoundMeter**用于完成添加数据的工作。

```swift
	private func updateMeters() {
        recorder.updateMeters()
        recordTime += updateFequency
        addSoundMeter(item: recorder.averagePower(forChannel: 0))
    }
    
    
    private func addSoundMeter(item: Float) {
        if soundMeters.count < soundMeterCount {
            soundMeters.append(item)
        } else {
            for (index, _) in soundMeters.enumerated() {
                if index < soundMeterCount - 1 {
                    soundMeters[index] = soundMeters[index + 1]
                }
            }
            // 插入新数据
            soundMeters[soundMeterCount - 1] = item
            NotificationCenter.default.post(name: NSNotification.Name.init("updateMeters"), object: soundMeters)
        }
    }
```

### 开始绘制波形图
现在我们已经获取了我们需要的所有数据，可以开始绘制波形图了。这时候让我们转到`MCVolumeView.swift`文件中，在上一个步骤中，我们发送了一条叫做`updateMeters`的通知，目的就是为了通知`MCVolumeView`进行波形图的更新。

```swift
	override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        contentMode = .redraw   //内容模式为重绘，因为需要多次重复绘制音量表
        NotificationCenter.default.addObserver(self, selector: #selector(updateView(notice:)), name: NSNotification.Name.init("updateMeters"), object: nil)
    }
    
    @objc private func updateView(notice: Notification) {
        soundMeters = notice.object as! [Float]
        setNeedsDisplay()
    }
```

当`setNeedsDisplay`被调用之后，就会调用`drawRect`方法，在这里我们可以进行绘制波形图的操作。

- **noVoice**和**maxVolume**是用于确保声音的显示范围
- 波形图的绘制使用CGContext进行绘制，当然也可以使用UIBezierPath进行绘制。

```swift
	override func draw(_ rect: CGRect) {
        if soundMeters != nil && soundMeters.count > 0 {
            let context = UIGraphicsGetCurrentContext()
            context?.setLineCap(.round)
            context?.setLineJoin(.round)
            context?.setStrokeColor(UIColor.white.cgColor)
            
            let noVoice = -46.0     // 该值代表低于-46.0的声音都认为无声音
            let maxVolume = 55.0    // 该值代表最高声音为55.0
            
			  // draw the volume...            
			  
            context?.strokePath()
        }
    }
```

### 柱状波形图的绘制

- 根据`maxVolume`和`noVoice`计算出每一条柱状的高度，并移动context所在的点进行绘制
- 另外需要注意的是`CGContext`中坐标点时反转的，所以在进行计算时需要将坐标轴进行反转来计算。

```swift
	case .bar:          
   		context?.setLineWidth(3)
       for (index,item) in soundMeters.enumerated() {
       	let barHeight = maxVolume - (Double(item) - noVoice)    //通过当前声音表计算应该显示的声音表高度
        	context?.move(to: CGPoint(x: index * 6 + 3, y: 40))
        	context?.addLine(to: CGPoint(x: index * 6 + 3, y: Int(barHeight)))
       }
```

### 线状波形图的绘制

- 线状与条状一样使用同样的方法计算“高度”，但是在绘制条状波形图时，是先画线，再移动，而绘制条状波形图时是先移动再画线。

```swift
	case .line:
        context?.setLineWidth(1.5)
        for (index, item) in soundMeters.enumerated() {
            let position = maxVolume - (Double(item) - noVoice)     //计算对应线段高度
            context?.addLine(to: CGPoint(x: Double(index * 6 + 3), y: position))
            context?.move(to: CGPoint(x: Double(index * 6 + 3), y: position))
        }
    }
```

### 进一步完善我们的波形图
在很多时候，录音不单止是需要显示波形图，还需要我们展示目前录音的时间和进度，所以我们可以在波形图上添加录音的进度条，所以我们转向`MCProgressView.swift`文件进行操作。

- 使用`UIBezierPath`配合`CAShapeLayer`进行绘制。
- **maskPath**是作为整个进度路径的蒙版，因为我们的录音HUD不是规则的方形，所以需要使用蒙版进度路径进行裁剪。
- **progressPath**为进度路径，进度的绘制方法为从左到右依次绘制。
- **animation**是进度路径的绘制动画。

```swift
	private func configAnimate() {
        let maskPath = UIBezierPath(roundedRect: CGRect.init(x: 0, y: 0, width: frame.width, height: frame.height), cornerRadius: HUDCornerRadius)
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.clear.cgColor
        maskLayer.path = maskPath.cgPath
        maskLayer.frame = bounds
        
        // 进度路径
        /*
         路径的中心为HUD的中心，宽度为HUD的高度，从左往右绘制
         */
        let progressPath = CGMutablePath()
        progressPath.move(to: CGPoint(x: 0, y: frame.height / 2))
        progressPath.addLine(to: CGPoint(x: frame.width, y: frame.height / 2))
        
        progressLayer = CAShapeLayer()
        progressLayer.frame = bounds
        progressLayer.fillColor = UIColor.clear.cgColor //图层背景颜色
        progressLayer.strokeColor = UIColor(red: 0.29, green: 0.29, blue: 0.29, alpha: 0.90).cgColor   //图层绘制颜色
        progressLayer.lineCap = kCALineCapButt
        progressLayer.lineWidth = HUDHeight
        progressLayer.path = progressPath
        progressLayer.mask = maskLayer 
        
        animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 60 //最大录音时长
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)    //匀速前进
        animation.fillMode = kCAFillModeForwards
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.autoreverses = false
        animation.repeatCount = 1
    }

``` 

# 需求环境
- iOS 10.0
- Swift 4.0

# Contribution
You are welcome to contribute to the project by forking the repo, modifying the code and opening issues or pull requests.
