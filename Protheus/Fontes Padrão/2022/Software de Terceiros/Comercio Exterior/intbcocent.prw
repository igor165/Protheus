/*
Programa        : IntBcoCent.PRW
Objetivo        : Chamar a Classe AvRetBc para integra��o de arquivos
Autor           : Allan Oliveira Monteiro
Data/Hora       : 26/07/2010 
Obs.            :
*/

Function IntBcoCent

Private oRetBC
Private Fecha := .F.

oRetBC := AvRetBC():New()
oRetBC:Init()
 	

Return NIL
