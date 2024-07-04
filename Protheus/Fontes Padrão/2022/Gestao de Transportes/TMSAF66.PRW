#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/* TMSAF66
//Regras para o Inicializador de Campo da Viagem Modelo 3
@author Katia
@since 24/06/2020
@version 1.0
@return xRet
*/
//-------------------------------------------------------------------
Function TMSAF66(cCampo)
Local cRet		:= ""
Local aArea		:= GetArea()

Default cCampo  := ReadVar()

If cCampo $ "DTQ_HORGER"
    cRet:= TMSAF66HOR()
ElseIf cCampo $ "M->DM3_STATUS|M->DM3_STROTA"
	cRet:= TF66StaDUD(cCampo)
ElseIf cCampo $ "M->DM3_NOMREM|M->DM3_NOMDES|M->DM3_BAIRRO|M->DM3_MUN|M->DM3_EST|M->DM3_PRZENT"
	cRet:= TF66Docto(cCampo)  
ElseIf cCampo $ "DTQ_TIPTRA"
    cRet:= TMSF66TTra()
ElseIf cCampo $ "DTQ_DESTPT"
    cRet:= TMSF66DTra()
ElseIf cCampo $ "DUP_ITEDTR"
    cRet:= TMSF66IDTR()
EndIf

RestArea( aArea )
FwFreeArray(aArea)
Return cRet

//-------------------------------------------------------------------
/* Function TMSAF66HOR()
//Inicializador do Campo Hora de Emissao da Viagem 
@author Katia
@since 24/06/2020
@version 1.0
@return cRet
*/
//-------------------------------------------------------------------
Function TMSAF66HOR()
Local cUF 		:= SuperGetMV("MV_ESTADO",.F.,"")
Local lHVerao   := SuperGetMV("MV_TMSHRVR",,.F.)	//-- Define se encontra-se no periodo de horario de verao.
Local cHVerFil  := SuperGetMV("MV_TMSHRFL",,"")	//-- Define Filiais que nao aderiram ao horario de verao e/ou possuem diferenca de fuso.
Local aDataBase := {}
Local cRet     := ""

//-- Busca hora de emissao da viagem
If	!Empty(cHVerFil) .And. cFilAnt $ cHVerFil
	If	FindFunction("FwTimeUF")		
		cUF := IIF(cUF == "BA", "PE", cUF)
		aDataBase := FwTimeUF(cUF,,lHVerao)			
		cRet := StrTran(Left(aDataBase[2],5),':','')
	EndIf
EndIf
If Empty(cRet) 
	cRet := Left(StrTran(Time(),":",""),4)
EndIf

FwFreeArray(aDataBase)
Return cRet

//-------------------------------------------------------------------
/* Function TF66StaDoc()
//Inicializador do Campo Status do Documento / Status Rota (DUD)
@author Katia
@since 24/06/2020
@version 1.0
@return cRet
*/
//-------------------------------------------------------------------
Static Function TF66StaDUD(cCampo)
Local cRet := "1"

If !Empty(DM3->DM3_FILDOC) .And. !Empty(DM3->DM3_DOC) .And. !Empty(DM3->DM3_SERIE)
	If cCampo $ 'M->DM3_STATUS'
		cRet := TF60DudStat(DM3->DM3_FILDOC,DM3->DM3_DOC,DM3->DM3_SERIE,,DTQ->DTQ_VIAGEM,1)
	ElseIf cCampo $ 'M->DM3_STROTA'
		cRet := TF60DudStat(DM3->DM3_FILDOC,DM3->DM3_DOC,DM3->DM3_SERIE,,DTQ->DTQ_VIAGEM,2)
	EndIf
EndIf

Return cRet

//-------------------------------------------------------------------
/* Function TF66StaDoc()
//Inicializador dos campos dos Documentos (DM3)
@author Katia
@since 24/06/2020
@version 1.0
@return cRet
*/
//-------------------------------------------------------------------
Static Function TF66Docto(cCampo)
Local xRet    := ''
Local aAreaDM3:= DM3->(GetArea())
Local aAreaDT6:= DT6->(GetArea())
Local cCampoGat:= ""
Local cTpCampo := ""

//--- Mesma função do Gatilho, necessário remover o M->
cCampoGat:= StrTran(cCampo,"M->","")
cTpCampo := GetSX3Cache(cCampoGat,"X3_TIPO")

If cTpCampo == "D"
	xRet := cTod('')
ElseIf cTpCampo == "N"
	xRet := 0
EndIf

If !Empty(DM3->DM3_FILDOC)	.And. !Empty(DM3->DM3_DOC)	.And. !Empty(DM3->DM3_SERIE)	
	xRet:= TF65GatDoc(cCampoGat,cCampoGat,DM3->DM3_FILDOC,DM3->DM3_DOC,DM3->DM3_SERIE,.T.)
EndIf
	
RestArea(aAreaDM3)
RestArea(aAreaDT6)
FwFreeArray(aAreaDM3)
FwFreeArray(aAreaDT6)
Return xRet

//-------------------------------------------------------------------
/* Function TF66LotVge
// Atribui o numero da Viagem para o campo DTP_VIAGEM
@author Katia
@since 01/09/2020
@version 12.1.31
@return cRet
Função TMSA144Vge() da rotina TMSA144.PRW
*/
//-------------------------------------------------------------------
Function TF66LotVge()
Local cRet    := ''

If DTQ->DTQ_SERTMS $ "23"
	cRet := DTQ->DTQ_VIAGEM
EndIf

Return cRet

/*
Function TMSF66TTra
Atribui o tipo de transporte rodoviário
@author Valdemar Roberto Mognon
@since 05/07/2021
@version 12.1.31
@return cRet
*/
Function TMSF66TTra()
Local cRet := ""

cRet := "1"

Return cRet

/*
Function TMSF66DTra
Atribui a descrição do tipo de transporte rodoviário
@author Valdemar Roberto Mognon
@since 05/07/2021
@version 12.1.31
@return cRet
*/
Function TMSF66DTra()
Local cRet := ""

Private M->DTQ_TIPTRA := "1"

cRet := TMSValField("DTQ_TIPTRA",.F.)

Return cRet

/*Function TMSF66IDTR
Inicializa o campo DUP_ITEDTR
@author Valdemar Roberto Mognon
@since 14/12/2021
@version 12.1.31
@return cRet*/

Function TMSF66IDTR()
Local cRet      := ""
Local oModel    := FwModelActive()
Local oModelDTR := oModel:GetModel("MdGridDTR")
Local nLinAtu   := oModelDTR:GetLine()

cRet := StrZero(nLinAtu,Len(DUP->DUP_ITEDTR))

Return cRet
