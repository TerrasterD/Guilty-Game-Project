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

class GameViewController: UIViewController{
    
    @IBOutlet weak var gameView: SKView!
    
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
    var colors = ["Blue","Green","Orange","Purple","Red","Yellow"]

    
    // judge
    /// judge that controls the game
    var judge: Judge?
    
    
    // controls
    /// functions of the controll
    var funcoesControle = ["PlayPause","Menu","Select","UpArrow","LeftArrow","DownArrow","RightArrow","SwipeUp","SwipeLeft","SwipeDown","SwipeRight"];
    /// reporter of control actions
    var report = Report()
    
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGame()
        
        startTheme()

        // fazer o sorteio das palavras e dos eventos
        
//        if let event = currentEvent{
//            gameScene = GameScene(size: size, word: currentWord, event: event, team1: team[0], team2: team[1], judge: judge!, players: players)
//        } else {
//            gameScene = GameScene(size: size, word: currentWord, team1: team[0], team2: team[1], judge: judge!, players: players)
//        }
//
//        gameView.presentScene(gameScene)
//        wordsCount += 1
        
    
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
                print("person color team 0 - \(colors[i])")
            } else {
                players.append(Person(colors[i], team: team[1]))
                print("person color team 1 - \(colors[i])")
            }
        }
        
        print("number of players: \(players.count)")
        // instantiate
        judge = Judge(team)
        
        addAll()
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
    func addWords(){
        let words = Words()
        
        // Fazer a condicao de selecao de deck
        for element in words.str{
            wordsRandom.append(element)
        }
        for element in words.strFood{
            wordsFood.append(element)
        }
        for element in words.strHardFood{
            wordsFoodHard.append(element)
        }
        for element in words.strMagic{
            wordsMagic.append(element)
        }
        for element in words.strAnimal{
            wordsRandom.append(element)
        }
        for element in words.strHardAnimal{
            wordsAnimalHard.append(element)
        }
        for element in words.strOldWest{
            wordsOldWest.append(element)
        }
        for element in words.strNinja{
            wordsNinja.append(element)
        }
        for element in words.strNormalWords{
            wordsRandom.append(element)
        }
        for element in words.strHardWords{
            wordsHard.append(element)
        }
        for element in words.strNatal{
            wordsChristmas.append(element)
        }
        
//        var random = Deck("Random", cards: wordsRandom as! NSMutableArray, hardCards: wordsHard as! NSMutableArray)
//        var food = Deck("Food", cards: wordsFood as! NSMutableArray, hardCards: wordsFoodHard as! NSMutableArray)
//        var magic = Deck("Magic", cards: wordsMagic as! NSMutableArray, hardCards: wordsMagic as! NSMutableArray)
//        var animal = Deck("Animal", cards: wordsRandom as! NSMutableArray, hardCards: wordsAnimalHard as! NSMutableArray)
//        var oldwest = Deck("Old West", cards: wordsOldWest as! NSMutableArray, hardCards: wordsOldWest as! NSMutableArray)
//        var ninja = Deck("Ninja", cards: wordsNinja as! NSMutableArray, hardCards: wordsNinja as! NSMutableArray)
//        var christmas = Deck("Christmas", cards: wordsChristmas as! NSMutableArray, hardCards: wordsChristmas as! NSMutableArray)
//
//
//
//        print(christmas.cards)
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
    @objc func Menu(){
        print("menu")
        //Pause o tempo
        //Pausa a cena
        //Se não estiver no menu
        gameScene?.endTimer()
        gameScene?.isPaused = true
        gameView.presentScene(pauseScene)
    }
    
    /**
     functions of the controller (Select)
     */
    @objc func Select(){
        print("select")
        print(choosenTeam.lifes)
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
    
    @objc func SwipeLeft(){
        print("swipeleft")
        if choosenTeam == team[0]{
            judge?.deny(team[0])
        } else{
            judge?.deny(team[1])
        }
        if choosenTeam.lifes == 0{
            self.performSegue(withIdentifier: "endGame", sender: nil)
        }
        changeScene()
    }
    
    @objc func SwipeDown(){
        print("swipedown")
    }
    
    @objc func SwipeRight(){
        print("swiperight")
        changeScene()
        
    }
    
    /**
     Function to change scenes
     */
    func changeScene(){
        let size = view.bounds.size
        
        switch gameView.scene {
        case themeScene:
            gameScene = GameScene(size: size, word: currentWord, team1: team[0], team2: team[1], judge: judge!, players: players)
            gameView.scene?.removeFromParent()
         //   gameScene?.movePlayer(playerNumber: GameScene.turn % qtPlayer)
            gameView.presentScene(gameScene)
            break
        case gameScene:
            print(GameScene.turn % qtPlayer)
            gameView.scene?.removeFromParent()
            
            if GameScene.turn % qtPlayer != 0 || drawPassed{
                drawPassed = false
                playerTurn = players[(GameScene.turn % qtPlayer)]
                turnScene = TurnScene(size: size, player: playerTurn)
                gameView.presentScene(turnScene)
            } else {
                // criar a cena do sorteio
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
            
            if let event = currentEvent{
                gameScene = GameScene(size: size, word: currentWord, event: event, team1: team[0], team2: team[1], judge: judge!, players: players)
            } else {
                gameScene = GameScene(size: size, word: currentWord, team1: team[0], team2: team[1], judge: judge!, players: players)
            }
            if GameScene.turn == qtPlayer{
                gameScene?.movePlayer(playerNumber: qtPlayer - 1)
            }else{
                gameScene?.movePlayer(playerNumber: (GameScene.turn % qtPlayer) - 1)
            }
            gameView.presentScene(gameScene)
            break
        case drawScene:
            turnScene = TurnScene(size: size, player: players[GameScene.turn % qtPlayer])
            gameView.scene?.removeFromParent()
            gameView.presentScene(turnScene)
            drawPassed = true
            break
        default:
            print("None Scene")
        }

    }
}
