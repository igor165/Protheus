#INCLUDE "TMSA492.CH"
#INCLUDE "PROTHEUS.CH"

//-- Pontos de entrada
Static lTM492MNU := ExistBlock("TM492MNU") //-- PE -> Montagem aRotina no MenuDef

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSA492
Geração da fatura com base nos parâmetros de faturamento ou selecionados
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12
@since 06/10/2016
@return Nil Não há retorno
@obs Tabela: DRT - Fatura de Transporte a Receber (Projeto Ellece);
@obs Utilizado apenas quando há integração com o ERP Datasul (MV_TMSERP = '1').
/*/
//-------------------------------------------------------------------------------------------------
Function TMSA492()

Local aArea   := GetArea()
Local nCntFor := 0
Local cTmsERP := SuperGetMV("MV_TMSERP",,'0')

Private cCadastro := STR0001 //--"Faturas a Receber Automática"
Private aRotina   := MenuDef()

If ! IsInCallStack("TMSA492") .Or. cTmsERP !=  '1' //-- ERP Datasul
	Help(" ", 1, "TMSA49201") //-- "Acesso ao programa nao permitido!"
	return Nil
EndIf

If IsBlind() //-- Verifica se possui interface
	TmsLogMsg('INFO',">> [INI] TMSA492 " + STR0009 + " - FILIAL: " + cFilAnt + " - " + Dtoc(Date()) + " " + Time())
	
	//-- "Faturamento Automatico via Schedule"
	BatchProcess(cCadastro, STR0009 , "TMA490" , { || TMSA491Mnt(.F.) } , { || .F. } )

	//-- Se o parametro nao esta definido, envia as mensagens para o console
	If Empty(GetMv("MV_FATMAIL",, "")) .and. Len(aMsgSch) > 0
		For nCntFor := 1 to Len(aMsgSch)
			TmsLogMsg('INFO',aMsgSch[nCntFor])
		Next
	EndIf

	// Processo de envio de e-mail para processamento via schedule
	TM491Mail()
	
	TmsLogMsg('INFO',">> [FIM] TMSA492 " + STR0009 + " - FILIAL: " + cFilAnt + " - " + Dtoc(Date()) + " " + Time())
Else

	MBrowse( ,,,,"DRT",,,,,, TMSA851Leg())

EndIf

RestArea(aArea)

Return Nil

//-------------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Montagem do menu
@type function
@author Guilherme Eduardo Bittencourt (guilherme.eduardo)
@version 12.1.15
@since 20/09/2016
@return aRotina Array com opções da rotina
/*/
//-------------------------------------------------------------------------------------------------
Static Function MenuDef()
						
Private aRotina := {	{ STR0002, "AxPesqui"   , 0, 1, 0, .F.},; // "Pesquisar"
						{ STR0003, "Tmsa850Vis" , 0, 2, 0, Nil},; // "Visualizar"
						{ STR0004, "Tmsa491Mnt" , 0, 3, 0, Nil},; // "Gerar"
						{ STR0011, "Tmsa851Aut" , 0, 4, 0, Nil},; // "ALterar"
						{ STR0006, "Tmsa850Exc" , 0, 5, 0, Nil},; // "Cancelar"
						{ STR0005, "Tmsa851His" , 0, 6, 0, Nil},; // "Historico"
						{ STR0007, "Tmsa851Par" , 0, 7, 0, Nil},; // "Parametros"
						{ STR0008, "Tmsa851Leg" , 0, 8, 0, .F.} } // "Legenda"

If FindFunction("TmsA491Imp")
	aAdd(aRotina, {STR0010, "TmsA491Imp", 0, 9, 0, NIL}) // "Impressão Fatura"
EndIf

//-- PE -> Montagem aRotina no MenuDef
If lTM492MNU
	ExecBlock("TM492MNU",.F.,.F.)
EndIf

Return aRotina