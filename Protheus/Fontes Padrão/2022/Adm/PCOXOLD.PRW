
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PCO_TOT_PARCELA ºAutor³Paulo Carnelossi  º Data ³ 20/09/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao que retorna o valor das parcelas quando o titulo for º±±
±±º          ³desdobramento no contas a pagar                             º±±
±±º          ³utiliza array aParcelas Private dentro do fina050           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PCO_TOT_PARCELA()
Local nRetVlr := 0
Local nX

For nX := 1 TO Len(aParcelas)
	nRetVlr += aParcelas[ nX, 2]  //2o elemento eh o valor da parcela
Next

Return(nRetVlr)

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOXAJLA
Função para ajuste de movimentos do PCO CTBAATF.

@author rodrigo.toledo
@since 14/08/2014
@version P12
/*/
//-------------------------------------------------------------------
Function PCOXAJLA()
Local lRet := .T.

ALI->(dbSetOrder(1))
ALI->(dbGoTop())
While ALI->(!EOF())     
	If Empty(ALI_IDALI)
    	Reclock('ALI',.F.)
       ALI->ALI_IDALI := FWUUIDV4() 
       MsUnlock()  
	EndIf
    ALI->(dbSkip())
EndDo

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOVLDCTA
Função para validação da conta orçamentária superior

@author pedropl
@since 22/08/2014
@version P12
/*/
//-------------------------------------------------------------------
Function PcoVldCta(cConta,cCtaAtu)
Local aArea		:= GetArea()
Local lRet		:= .T.

Default cCtaAtu	:= ""

dbSelectArea("AK5")
dbSetOrder(1)

If !Empty(cConta)
	Do Case
		Case cCtaAtu == cConta			//A conta atual (_CONTA) deve ser diferente da superior
			Help(" ",1,"ENTPAIGUAL")
			lRet := .F.
		Case !MsSeek(xFilial()+cConta)	//A conta digitada (CTASUP) deve existir no Plano de Contas.
			Help("  ", 1, "CADCTAORSU")
			lRet := .F.
		Case AK5->AK5_TIPO != "1"		//A conta superior deve ser sintetica.
			Help(" ",1,"NOCLASSESI")
			lRet := .F.
	EndCase
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ver_CtaSupºAutor  ³Paulo Carnelossi    º Data ³  04/03/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida Conta digitada para compatiblizar com plano de Ctas º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ver_CtaSup(cNivel, cContaOrc, cContaSup)
// A funcionalidade foi transferida para fonte PCOA101
lRet := _VerCtaSup(cNivel, cContaOrc, cContaSup)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PcoMyVal  ºAutor  ³Paulo Carnelossi    º Data ³  31/01/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Recebe um string contendo valores e transforma em numerico  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PcoMyVal(cNum, cPicture)
Local cSepMilhar
Local cSepDecimal
Local cMileUm

//------------------------------------------------------------------------------------
//este trecho de codigo eh somente para descobrir qual o separador decimal e de Milhar 
cMileUm := Alltrim(Transform(1000.01, "@E 999,999.99"))
cSepDecimal := PadR(Right(cMileUm,3),1)
cSepMilhar  := PadR(Right(cMileUm,7),1)
//------------------------------------------------------------------------------------

If cPicture == NIL .OR. Empty(cPicture)
    If (At(cSepDecimal, cNum) > 0 .And. At(cSepMilhar, cNum) > 0) .OR. At(cSepDecimal, cNum) > 0
		cPicture := "@E 999,999,999,999.99"
	Else
		If At(cSepMilhar, cNum) > 0
			cPicture := "999999999999.99"
		Else
			cPicture := "999999999999"
		EndIf	
	EndIf
EndIf

If "@E" $ cPicture
	//primeiro transforma os "." em ""  //separador de milhar
	cNum := StrTran(cNum, cSepMilhar, "")
	//depois transforma as "," em "."  //separador decimal
	cNum := StrTran(cNum, cSepDecimal, ".")
EndIf

If "("$cNum
	cNum := StrTran(cNum,"(","")
	cNum := StrTran(cNum,")","")
	nNum := -Val(cNum)
Else
	nNum := Val(cNum)
EndIf

Return(nNum)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PcoPlanTot³ Autor ³ Edson Maricate        ³ Data ³ 02-09-2004 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao de montagem dos totais por clase do CO                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGAPCO                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PcoPlanTot(cArquivo,cVersao,oGD)

Local ny
Local aAuxArea	:= {}
Local aArea		:= GetArea()
Local nHeadItem	:= aScan(oGD:aHeader,{|x| AllTrim(x[2])=="AK2_CLASSE"})

oGD:aCols	:= {}

dbSelectArea("AK2")
dbSetOrder(1)
If dbSeek(xFilial("AK2") + AK1->AK1_CODIGO + cVersao + (cArquivo)->XK3_CO ) 
	While !Eof() .And. AK2->AK2_FILIAL + AK2->AK2_ORCAME + AK2->AK2_VERSAO + AK2->AK2_CO  == ;
						xFilial("AK2") + AK1->AK1_CODIGO + cVersao + (cArquivo)->XK3_CO
		nPosIt	:= aScan(oGD:aCols,{|x| x[nHeadItem] == AK2->AK2_CLASSE})
		If nPosIt > 0
			nPosHead := aScan(oGD:aHeader,{|x| CTOD(Substr(x[1],1,10))==AK2->AK2_PERIOD})
			If nPosHead > 0
				If oGD:aCols[nPosIt][nPosHead]<> Nil
					oGD:aCols[nPosIt][nPosHead] := PcoPlanCel(AK2->AK2_VALOR+Val(oGD:aCols[nPosIt][nPosHead]),AK2->AK2_CLASSE)
				Else
					oGD:aCols[nPosIt][nPosHead] := PcoPlanCel(AK2->AK2_VALOR,AK2->AK2_CLASSE)
				EndIf
			EndIf
		Else
			aADD(oGD:aCols,Array(Len(oGD:aHeader)+1))
			oGD:aCols[Len(oGD:aCols)][Len(oGD:aHeader)+1] := .F.		
			For ny := 1 to Len(oGD:aHeader)
				Do Case
					Case AllTrim(oGD:aHeader[ny][2])=="AK2_VAL"
						nPosHead := aScan(oGD:aHeader,{|x| CTOD(Substr(x[1],1,10))==AK2->AK2_PERIOD})
						If nPosHead > 0
							oGD:aCols[Len(oGD:aCols)][nPosHead] := PcoPlanCel(AK2->AK2_VALOR,AK2->AK2_CLASSE)
						EndIf
					OtherWise
						If ( oGD:aHeader[ny][10] != "V") 
							oGD:aCols[Len(oGD:aCols)][ny] := FieldGet(FieldPos(oGD:aHeader[ny][2]))
						EndIf   						
				EndCase
			Next
		EndIf
		dbSkip()
	End
Else
	aadd(oGD:aCols,Array(Len(oGD:aHeader)+1))
	For ny := 1 to Len(oGD:aHeader)
		If AllTrim(oGD:aHeader[ny][2])=="AK2_ID"
			oGD:aCols[1][ny] := Padr("*", Len(AK2->AK2_ID))//StrZero(1,LEN(AK2->AK2_ID))
		ElseIf AllTrim(oGD:aHeader[ny][2])=="AK2_VAL"
			//inicializa todos os periodos orcamentarios com CriaVar()
			oGD:aCols[1][nY] := PcoPlanCel(CriaVar(oGD:aHeader[ny][2]))
		Else
			oGD:aCols[1][ny] := CriaVar(oGD:aHeader[ny][2])
		EndIf
	Next ny
	oGD:aCols[1][Len(oGD:aHeader)+1] := .F.
EndIf
oGD:oBrowse:Refresh()
	
RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CTBA001
Ajuste para retirada de RecLock em dicionários

@author Kássia Caregnatto

@since 19/04/2017                           	
@version 1.0
/*/
//-------------------------------------------------------------------

Function PCRFCub()

Local cCubo := &(ReadVar())
Local lRet := .T.

lRet := Pco_ValidaCubo(cCubo)

If lRet
 COD_CUBO := cCubo
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Pco_ValidaCubo ºAutor ³Paulo Carnelossi  º Data ³ 19/06/07  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o cubo selecionado possui estrutura definida    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Pco_ValidaCubo(cCubo)

Local aArea := GetArea()
Local aAreaAKW := AKW->(GetArea())
Local lRet := .F.

dbSelectArea("AKW")
dbSetOrder(1)
lRet := dbSeek(xFilial("AKW")+cCubo)

If !lRet
	//Aviso(STR0007,STR0008,{"Ok"},2)  //"Atencao"###"Estrutura do cubo nao encontrada. Verifique."
	MsgInfo("Atencao ### Estrutura do cubo nao encontrada. Verifique.")
EndIf

RestArea(aAreaAKW)
RestArea(aArea)

Return(lRet)