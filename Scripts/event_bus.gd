extends Node

signal LoopCreated
signal EnemeyCircled


signal ComboIncreased(count:int)
signal ComboDecreased(count:int)
signal ComboDecaying
signal ComboEnded(max_combo_count:int)
signal ComboSalvaged
signal MaxComboIncreased(combo:int)

signal EnemyCollision
signal ProjectileCollision

signal SetPlayerHealth(current_health:int)

signal GameOver(final_score:int)
signal NewGame

signal UpdateScore(count:int)

func _ready() -> void:
	GameOver.connect(update_final_score)
	pass

var final_score = 0

func update_final_score(score:int):
	print(score)
	final_score = score



#loopcreated ->  (enmey confirms circled)EnemeyCircled -> IncreaseCombo(once enemy circled then we raise combo) -> damange enemy
