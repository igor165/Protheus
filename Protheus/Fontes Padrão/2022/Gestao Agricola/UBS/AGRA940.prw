#INCLUDE "AGRA940.CH"
#Include 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH"

/** {Protheus.doc} AGRA940
Rotina para Atualizar os lotes enviados para EGF

@param: 	Nil
@author: 	Maicol Lange
@since: 	16/12/2013
@Uso: 		UBS - Unidade de beneficiamento de sementes
*/

//View para selecionar quais lotes de semente serão enviados para emprestimo do governo ferederal
//Requisitos: 
//TIPLOT =1 -  Somente lotes do tipo produzido
//EGF    =2 -  Lotes que não foram enviados para emprestimo.
Function AGRA940()
	oMark := FWMarkBrowse():New()
	oMark:SetAlias('NP9')
	oMark:SetFieldMark("NP9_OK")	
	oMark:SetDescription(STR0001)//"Seleção de lotes para envio EGF"
	oMark:SetFilterDefault( "NP9_EGF='2'.and.NP9_TIPLOT='1' .and. NP9_STATUS='2'")// Lote tem que ser produzido = TIPLOT =1 e  não enviado para o governo EGF=2
	oMark:Activate()
Return NIL
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE OemToAnsi(STR0002)   ACTION "LOTEEGR()"   OPERATION 2 ACCESS 0
Return aRotina

//-------------------------------------------------------------------
function LOTEEGR()
	Local aArea := GetArea()
	Local cMarca := oMark:Mark()
	// Altera os lotes para  enviados para o governo
	//NP9_EGF := 1(Sim como enviado)
	NP9->( dbGoTop() )
	While !NP9->( EOF() )
		If oMark:IsMark(cMarca)
			RecLock('NP9',.F.)
			NP9->NP9_EGF := '1'
			MsUnLock()
		EndIf
		NP9->( dbSkip() )
	End
	RestArea( aArea )
Return NIL