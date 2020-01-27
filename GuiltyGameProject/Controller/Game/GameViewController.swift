//
//  GameViewController.swift
//  GuiltyGameProject
//
//  Created by Ferraz on 26/11/19.
//  Copyright © 2019 Guilherme Martins Dalosto de Oliveira. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class GameViewController: UIViewController, sendTimerDelegate, randomDelegate, StatisticsProtocol{
    
    var playersInfo: [StatisticsInfo] = []
    
    func sendRandom(one: Int, two: Int) {
        firstSortedForEvent = one
        secondSortedForEvent = two
    }
    
    
    func timeIsOver() {
        print("tempo acabou")
        //changeScene()
    }
    
    @IBOutlet weak var gameView: SKView!
    @IBOutlet weak var pauseView: SKView!
    
    
    let music = Sound()
    var firstSortedForEvent = 9
    var secondSortedForEvent = 9
    var difficulty = UserDefaults.standard.integer(forKey: "difficulty")
    
    // scenes
    /// scene to draw a event to one player for each team
    var drawScene: DrawScene? = nil
    /// scene to say which player will play
    var turnScene: TurnScene? = nil
    /// scene with theme to start the game
    var themeScene: ThemeScene? = nil
    /// main scene of the game
    var gameScene: GameScene? = nil
    /// scene of pause
    var pauseScene: PauseScene? = nil
    
    
    // characters of the game (without judge)
    /// 2 teams that is in the game
    var team = [Team]()
    /// array with all players(excluding the judge)
    var players = [Person]()
    /// player of the turn
    var playerTurn = Person()
    /// array of players colors
    var colors = [NSLocalizedString("blue", comment: ""),NSLocalizedString("green", comment: ""),NSLocalizedString("orange", comment: ""),NSLocalizedString("pink", comment: ""),NSLocalizedString("black", comment: ""),NSLocalizedString("yellow", comment: "")]
    
    // judge
    /// judge that controls the game
    var judge: Judge?
    
    
    // controls
    /// functions of the controll
    
    // Gui: Alterei o UpArrow para select pois estava gerando problemas na identificacao do simulador
    var funcoesControle = ["PlayPause","Menu","Select","Select","LeftArrow","DownArrow","RightArrow","SwipeUp","SwipeLeft","SwipeDown","SwipeRight"];
    /// reporter of control actions
    var report = Report()
    ///Menu button
    let menuPressRecognizer = UITapGestureRecognizer()
    
    
    
    // auxiliar var
    /// number of words played
    var wordsCount: Int = 0
    /// number of events played
    var eventsCount: Int = 0
    /// bool to know if draw scene has passed already
    var drawPassed: Bool = true
    /// number of players in game
    var qtPlayer = UserDefaults.standard.integer(forKey: "numberOfPlayers")
    /// current word at the game
    var currentWord = "" // : String?
    /// current event at the game
    var currentEvent: String? = ""// : String?
    /// current color of the player
    var currentColor = "" // : String?
    /// judge decision about player story
    var judgeDecision = "" // : String?
    /// condition to see which team has lose
    var conditionToFinish : Bool?
    /// team of the time
    var choosenTeam = Team()
    /// bool to know if game still running
    var gameRunning = true
    /// sound player
    let sound = Sound()
    
    // words and events
    // all words
    var wordsRandom =  [String]()
    var wordsHard = [String]()
    var wordsFood = [String]()
    var wordsFoodHard = [String]()
    var wordsMagic = [String]()
    var wordsAnimal = [String]()
    var wordsAnimalHard = [String]()
    var wordsOldWest = [String]()
    var wordsNinja = [String]()
    var wordsChristmas = [String]()
    
    /// all events
    var allEvents = [Event]()
    
    var randomEvent : String? = ""
    var randomWord = ""
    
    override func viewDidLoad() {
//        gameView.addSubview(pauseView)
//        pauseView.sendSubviewToBack(gameView)
        pauseView.alpha = 0.0
        super.viewDidLoad()
//        pauseView.
//        menuPressRecognizer.addTarget(self, action: #selector(GameViewController.Menu(recognizer:)))
//        menuPressRecognizer.allowedPressTypes = [NSNumber(value: UIPress.PressType.menu.rawValue)]
//        self.view.addGestureRecognizer(menuPressRecognizer)
        UserDefaults.standard.set(true, forKey: "flag")
        UserDefaults.standard.set(true, forKey: "flag2")
        
        setupGame()
        startTheme()
    }
    
    /**
     Function to start the game with theme scene
     */
    func startTheme(){
        let size: CGSize = view.bounds.size
        themeScene = ThemeScene(size: size)
        gameView.presentScene(themeScene)
    }
    
    /**
     Setup the game (colors, players, judge, words, team, controller)
     */
    func setupGame(){
        // pegar as cores e adicionar ao array colors
        // PROVISORIO
        
        // instantiate and add teams to team array
        team.append(Team(UserDefaults.standard.integer(forKey: "numberOfPlayers")))
        team.append(Team(UserDefaults.standard.integer(forKey: "numberOfPlayers")))
        choosenTeam = team[0]
        
        // instantiate and add person to players array
        for i in 0...UserDefaults.standard.integer(forKey: "numberOfPlayers") - 1{
            if i < UserDefaults.standard.integer(forKey: "numberOfPlayers")/2{
                players.append(Person(colors[i], team: team[0]))
            } else {
                players.append(Person(colors[i], team: team[1]))
            }
        }
        
        // instantiate
        judge = Judge(team)        
        addAll()
        
        // create class to stored players info
        for i in 0...qtPlayer - 1{
            playersInfo.append(StatisticsInfo(color: players[i].color))
            for _ in 0...9{
                playersInfo[i].addWord(word: "")
            }
        }
    }
    
    /**
     Function to add controller, words and events
     */
    func addAll(){
        addController()
        addWords()
        addEvents()
    }
    
    /**
     Function to add the controller
     */
    func addController(){
        var _ = SiriRemote(self.view)
        for i in 0..<funcoesControle.count{
            self.view.gestureRecognizers?[i].addTarget(self, action: Selector(funcoesControle[i]))
        }
    }
    
    /**
     Function to add words
     */
    
    var ninjaDeck = UserDefaults.standard.bool(forKey: "ninjaDeckOn")
    var foodDeck = UserDefaults.standard.bool(forKey: "foodDeckOn")
    var magicDeck = UserDefaults.standard.bool(forKey: "magicDeckOn")
    var westDeck = UserDefaults.standard.bool(forKey: "oldWestDeckOn")
    var christmasDeck = UserDefaults.standard.bool(forKey: "natalDeckOn")
    var animalDeck = UserDefaults.standard.bool(forKey: "animalDeckOn")
    
    var hardDeck = false
    var normalDeck = false
    
    var actualDeck = [String]()
    
    func addWords(){
        print(ninjaDeck)
        let words = Words()
        let difficulty = UserDefaults.standard.integer(forKey: "difficulty")
        let theme = UserDefaults.standard.integer(forKey: "theme")
//
//        if difficulty == 1{
//            for i in words.strNormalWords{
//                actualDeck.append(i)
//            }
//        } else{
//            for i in words.strHardWords{
//                actualDeck.append(i)
//            }
//        }
        
        if ninjaDeck{
            for i in words.strNinja{
                actualDeck.append(i)
            }
        }
        
        if foodDeck{
            for i in words.strFood{
                actualDeck.append(i)
            }
        }
        
        if magicDeck{
            for i in words.strMagic{
                actualDeck.append(i)
            }
        }
        
        if westDeck{
            for i in words.strOldWest{
                actualDeck.append(i)
            }
        }
        
        if christmasDeck{
            for i in words.strNatal{
                actualDeck.append(i)
            }
        }
        
        if animalDeck{
            for i in words.strAnimal{
                actualDeck.append(i)
            }
        }
    }
    
    /**
     Function to add events
     */
    func addEvents(){
        let events = allEventsSigned()
        
        for element in  events.events{
            allEvents.append(Event(element, difficulty: 0, type: "", duration: 0))
        }
       
    }
    
    /**
     Function to end game by team life or by the judge
     */
    func finishGame(team: Team, judge: Judge){
        if team.lifes != 0{
            judge.deny(team)
        }else{
            judge.endGame()
        }
    }
    
    /**
     Function to report judge decision by control
     */
    func addToReport(){
        report.addTurn(currentWord, color: currentColor)
    }
    
    /**
     Function to pause game
     */
    @objc func PlayPause(){
        print("pause")
    }
    
    /**
     Function to pause game
     */
    @objc func Menu(/*recognizer: UITapGestureRecognizer*/){
        print("menu")
        //Pause o tempo
        //Pausa a cena
        //Se não estiver no menu
        if pauseScene == nil{
            pauseScene = PauseScene(size: CGSize(width: (UIScreen.main.bounds.width)*0.5, height: (UIScreen.main.bounds.height)*0.5))
            gameScene?.endTimer()
            gameScene?.isPaused = true
            pauseView.alpha = 1.0
            pauseView.presentScene(pauseScene)
            let quitGameView = UIView(frame: CGRect(x: (pauseView.frame.size.width)*0.19, y: (pauseView.frame.size.height)*0.15, width: (UIScreen.main.bounds.width)*0.45, height: (UIScreen.main.bounds.height)*0.45))
            quitGameView.backgroundColor = .systemPink
            pauseView.addSubview(quitGameView)
            
        }else{
            //O que fazer quando ele apertar no botão
            pauseScene = nil
            gameScene?.startTimer()
            gameScene?.isPaused = false
            pauseView.alpha = 0.0
        }
        /*
         else{
            let quitGameView = UIView(frame: CGRect(x: (pauseView.frame.size.width)*0.19, y: (pauseView.frame.size.height)*0.15, width: (UIScreen.main.bounds.width)*0.45, height: (UIScreen.main.bounds.height)*0.45))
            quitGameView.backgroundColor = .systemPink
            pauseView.addSubview(quitGameView)
         qui
         }
         */
    }
    
    /**
     functions of the controller (Select)
     */
    @objc func Select(){
        
        //if gameScene?.scene == themeScene{
            changeScene()
        //}
    }
    
    @objc func UpArrow(){
        print("uparrow")
    }
    
    @objc func LeftArrow(){
        print("leftarrow")
    }
    
    @objc func DownArrow(){
        print("downarrow")
    }
    
    @objc func RightArrow(){
        print("rightarrow")
    }
    
    @objc func SwipeUp(){
        print("swipeup")
    }
    
    var vencedor = ""
    @objc func SwipeLeft(){
        
        if (GameScene.turn > 0) && gameView.scene == gameScene{
            sound.play("SwipeLeft", type: ".wav",repeat: 0)
            if choosenTeam == team[0]{
                judge?.deny(team[1])
            } else{
                judge?.deny(team[0])
            }
            
            if team[0].lifes == 0 || team[1].lifes == 0{
                if team[0].lifes == 0{
                    vencedor = "Time 2"
                } else{
                    vencedor = "Time 1"
                }
                
                switch(qtPlayer){
                case 2:
                    self.performSegue(withIdentifier: "endGame3", sender: nil)
                    break
                case 4:
                    self.performSegue(withIdentifier: "endGame5", sender: nil)
                    break
                default:
                    self.performSegue(withIdentifier: "endGame7", sender: nil)
                }
                
            }else{
                changeScene()
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "endGame"{
            if let vc = segue.destination as? ViewController{
                vc.vencedor = vencedor
                vc.delegate = self
            }
        }
    }
    
    
    @objc func SwipeDown(){
        print("swipedown")
    }
    
    @objc func SwipeRight(){
        if gameView.scene == gameScene && GameScene.turn > 0{
            sound.play("SwipeRight", type: ".wav",repeat: 0)
            print("swiperight")
        }
        
        changeScene()
        
    }
    
    var teamTurnA = 0
    
    var teamTurnB = UserDefaults.standard.integer(forKey: "numberOfPlayers")/2
    
    var numberPlayer = 0
    
    func readjustPlayers(){
        teamTurnA = 0
        teamTurnB = players.count/2
        numberPlayer = 0
        definePlayerTurn()
    }
    
    func definePlayerTurn (){
        if (GameScene.turn > -1){
            if (GameScene.turn % 2 == 0)  {
                playerTurn = players[teamTurnA]
                numberPlayer = teamTurnA
                teamTurnA += 1
            } else {
                playerTurn = players[teamTurnB]
                numberPlayer = teamTurnB
                teamTurnB += 1
            }
            
        }
    }
    
    
    func randomStuff(){
        currentWord = actualDeck.randomElement()!
        
        if GameScene.turn % 4 == 0{
            currentEvent = allEvents.randomElement()?.descriptionEvent
        } else{
            currentEvent = ""
        }
        
    }
    var auxFirst = 5
    var auxSecond = 5
    
    func defineEventPlayer(){
        if teamTurnA == firstSortedForEvent{
            randomEvent = allEvents.randomElement()?.descriptionEvent
            auxFirst = firstSortedForEvent
            firstSortedForEvent = 9
            
        } else
            if teamTurnB == secondSortedForEvent{
                randomEvent = allEvents.randomElement()?.descriptionEvent
                auxSecond = secondSortedForEvent
                secondSortedForEvent = 9
                
                
            } else{
                randomEvent = ""
        }
        
    }
    
    
    /**
     Function to change scenes
     */
    func changeScene(){
        let size = view.bounds.size
        
        if GameScene.turn >= 0 {
            randomStuff()
        }
        
        print("Random event -> \(randomEvent!)")
        switch gameView.scene {
        case themeScene:
            gameScene = GameScene(size: size, word: currentWord, team1: team[0], team2: team[1], judge: judge!, players: players)
            gameScene?.delegateSend = self
            gameView.scene?.removeFromParent()
            print("Piru")
            gameView.presentScene(gameScene)
            break
        case gameScene:
            gameScene?.timer?.invalidate()
            gameView.scene?.removeFromParent()            
            if GameScene.turn % qtPlayer != 0 || drawPassed{
                drawPassed = false
                definePlayerTurn()
                defineEventPlayer()
                
                
                turnScene = TurnScene(size: size, player: playerTurn,word: currentWord,event: randomEvent!)
                randomWord = currentWord
                
                gameView.presentScene(turnScene)
            } else {
                // criar a cena do sorteio
                drawScene = DrawScene(size: size, players: players)
                drawScene?.randomDelegate = self
                drawScene?.drawDice()
                readjustPlayers()
                
                
                gameView.presentScene(drawScene)
            }
            break
        case turnScene:
            if choosenTeam == team[0] {
                choosenTeam = team[1]
            } else{
                choosenTeam = team[0]
            }
            gameView.scene?.removeFromParent()
            
            if let event = randomEvent{
                gameScene = GameScene(size: size, word: randomWord, event: event, team1: team[0], team2: team[1], judge: judge!, players: players)
            } else {
                gameScene = GameScene(size: size, word: randomWord, team1: team[0], team2: team[1], judge: judge!, players: players)
                
            }

            if auxFirst == 5{
                gameScene!.sendSortedEvent(auxFirst,auxSecond)
            }
            addWordInfo(color: playerTurn.color, word: randomWord)
            gameScene?.movePlayer(playerNumber: numberPlayer)
            gameScene?.delegateSend = self
            gameView.presentScene(gameScene)
            break
        case drawScene:
            randomStuff()
            randomWord = currentWord
            defineEventPlayer()
            turnScene = TurnScene(size: size,player: playerTurn,word: randomWord,event: randomEvent!)
            gameView.scene?.removeFromParent()
            
            gameView.presentScene(turnScene)
            drawPassed = true
            
            break
        case pauseScene:
            
            break
        default:
            print("None Scene")
        }
        
    }
    
    /**
     Add the actual word to player info class
     */
    func addWordInfo(color: String, word: String){
        for player in playersInfo{
            if player.pinColor == color{
                player.addWord(word: word)
            }
        }
    }
}
