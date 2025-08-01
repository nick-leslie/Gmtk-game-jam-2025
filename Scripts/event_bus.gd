extends Node

var combo_count:int = 0

signal LoopCreated
signal EnemeyCircled


signal ComboIncreased(count:int)
signal ComboEnded




#loopcreated ->  (enmey confirms circled)EnemeyCircled -> IncreaseCombo(once enemy circled then we raise combo) -> damange enemy
