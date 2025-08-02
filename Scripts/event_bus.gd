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

signal GameOver

signal UpdateScore(count:int)




#loopcreated ->  (enmey confirms circled)EnemeyCircled -> IncreaseCombo(once enemy circled then we raise combo) -> damange enemy
