STATIC oBrwB4Q		:= NIL
STATIC oBrwPro		:= NIL
STATIC oBrwCri		:= NIL
STATIC oEncAut		:= NIL
STATIC aAutFor  		:= {}
STATIC aDadCri  		:= {}
STATIC aCabCri  		:= {}
STATIC aTrbCri  		:= {}
STATIC bImpGuia 		:= {|| PLS09PIm2()  }
STATIC aDadB43     	:= {}
STATIC aCabB43     	:= {}
STATIC aTrbB43     	:= {}
STATIC __cCodMedGen := GetNewPar("MV_PLMEDPT","")
STATIC __cCodMatGen := GetNewPar("MV_PLMATPT","")
STATIC __cCodTaxGen := GetNewPar("MV_PLTAXPT","")
STATIC __cCodOpmGen := GetNewPar("MV_PLOPMPT","")

#include "PROTHEUS.CH"
#include "PLSMGER.CH"
#Include "PLSA09A.CH"
#include "PLSMCCR.CH"
#INCLUDE "COMMON.CH"
#INCLUDE "RWMAKE.CH"

#define  K_Imprimir 	7
#define  K_Copiar		6
#define  K_BCOCON    8

#define __aCdCri187 {"573","Demanda por requerimento"}
#define __aCdCri197 {"09P","Habilita checagem de regra para procedimentos incompatíveis!"}


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA09P

@author  Karine Riquena Limp
@version P12
@since   27.07.16
/*/
//-------------------------------------------------------------------
Function PLSA09P

	LOCAL nI			:= 0
	LOCAL cFiltro    	:= ""

	PRIVATE aRotina   	:= MenuDef()
	PRIVATE cCadastro 	:= "Prorrogação de internação"
	PRIVATE cNumProto   := Space(20)
	PRIVATE cDesQtdAut := ''
	PRIVATE aAutForAnx 	:= {}
	PRIVATE aCodCriHis 	:= {}

	SX3->(DbSetOrder(2))
	SX3->(DbSeek("BQV_QTDPRO"))
	cDesQtdAut := AllTrim(X3Titulo("BQV_QTDPRO"))

	If FindFunction("PLSRESTOP")
		cStrFil := PlsResTop("PI",.f.)
		If !(Empty(cStrFil))
			cFiltro += " .and. "+cStrFil
		EndIf
	EndIf

	B4Q->(DbSetOrder(1))

	If ExistBlock( "PL09AFIL" )
		cFiltro := ExecBlock( "PL09AFIL", .F., .F., {cFiltro} )
	EndIf
	//-------------------------------------------------------------------
	//  Browse
	//-------------------------------------------------------------------
	oBrwB4Q := FWmBrowse():New()
	oBrwB4Q:SetAlias('B4Q')
	oBrwB4Q:SetDescription( cCadastro )
	oBrwB4Q:SetFilterDefault( cFiltro )

	oBrwB4Q:activate()

	//-------------------------------------------------------------------
	//  Fim da Rotina Principal...
	//-------------------------------------------------------------------
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLA09PLIB

@author  Karine Riquena Limp
@version P12
@since   27.07.16
/*/
//-------------------------------------------------------------------
Function PLA09PLIB(cDado,lWeb,aRetorno) // BUSCAR A SOL DE INTERNACAO

	LOCAL cCampo 	:= ReadVar()
	LOCAL lRet      := .F.
	LOCAL cConteudo := ""
	LOCAL dDatAut 	:= cTOD('')
	LOCAL cUsuari 	:= ''
	LOCAL cCidPri 	:= ''
	LOCAL cCidSec 	:= ''
	LOCAL cCidTer 	:= ''
	LOCAL cCidQua 	:= ''
	LOCAL cSenhaPls := ''
	LOCAL aRet    	:= {}
	LOCAL lInterProt:= .F.
	LOCAL lFindBE4  := .F.
	LOCAL nIndBE4	 := 0
	LOCAL cMatric   := ""
	LOCAL cCodRda	  := ""
	LOCAL cNomRda	  := ""
	LOCAL lAvsPrg		:= .f.
	LOCAL dDatRet   := getNewPar("MV_PLPRZLB",30)
	DEFAULT lWeb	:= .f.
	DEFAULT aRetorno:= {}
	//-------------------------------------------------------------------
	//  Somente se o conteudo foi informado
	//-------------------------------------------------------------------
	If !Empty(cDado)

		If (cCampo == "M->B4Q_GUIREF" .or. lWeb) .And. Len(AllTrim(cDado)) >= 9

			BE4->(DbSetORder(2))
			If !(BE4->(dbSeek(xFilial("BE4")+padr(cDado,18))))
				BE4->( DbSetOrder(7) )//BE4_FILIAL+BE4_SENHA
				If Len(AllTrim(cDado)) <= 9 .AND. BE4->(dbSeek(xFilial("BE4")+padr(cDado,9)))
					lFindBE4:= .T.
					nIndBE4 := 7
				EndIf
			Else
				lFindBE4:= .T.
				nIndBE4 := 2
			EndIf

			if lFindBE4

				//-------------------------------------------------------------
				// Verifica status
				//-------------------------------------------------------------
				If BE4->BE4_STATUS == "3"
					Aviso( "Atenção", "A guia nao foi autorizada." , {  "Ok"  }, 2 )
					Return lRet
				EndIf
				//-------------------------------------------------------------
				// Verifica se tem data de internacao
				//-------------------------------------------------------------
				If Empty(BE4->BE4_DATPRO)
					Aviso("Atenção","Data de internação nao informada!",{ "Ok" },2)
					Return lRet
				EndIf
				//-------------------------------------------------------------
				// Verifica validade da guia origem
				//-------------------------------------------------------------
				/*If (BE4->BE4_DATVAL + dDatRet) < dDataBase
				Aviso("Atenção", "Data de validade da Guia foi ultrapassada! ", {'Ok'}, 2)
				Return lRet
				EndIf*/
				//-------------------------------------------------------------
				// Verifica se foi dado alta
				//-------------------------------------------------------------
				lAvsPrg := .F.
				If BAU->(FieldPos("BAU_GRALAU")) > 0

					BAU->(dbSetOrder(1))
					If BAU->(msSeek(xFilial("BAU")+BE4->BE4_CODRDA)) .And. BAU->BAU_GRALAU <> "1" .And. !Empty(BE4->BE4_DTALTA)
						lAvsPrg := .T.
					EndIf

				ElseIf !Empty(BE4->BE4_DTALTA)
					lAvsPrg := .T.
				EndIf

				If lAvsPrg .and. GetNewPar("MV_PLLBALT",.F.) // Parametro que define que mesmo com a data de alta poderá ser feito a inclusão de evolução no periodo.
					lAvsPrg := .F.
				Endif


				If lAvsPrg
					Aviso( "Atenção", "Data da alta já informada, não é permitido incluir uma prorrogação", { "Ok" }, 2 )
					return lRet
				EndIf
				//-------------------------------------------------------------
				// verifica se e online
				//-------------------------------------------------------------
				If BE4->( FieldPos("BE4_NRTROL") ) > 0 .And. BE4->( FieldPos("BE4_NRAOPE") ) > 0 .And. !Empty(BE4->BE4_NRTROL) .And. Empty(BE4->BE4_NRAOPE)
					Aviso( "Atenção", "Guia On-Line, somente disponível para visualização!", { "Ok" }, 2 )
					return lRet
				EndIf

				//-------------------------------------------------------------
				// verifica se está cancelada
				//-------------------------------------------------------------
				If !(BE4->BE4_CANCEL <> '1' .And. BE4->BE4_SITUAC <> '2')
					Aviso('Atenção','Guia cancelada!',{'Ok'},2)
					Return lRet
				Else
					cConteudo := BE4->BE4_CODOPE+BE4->BE4_CODLDP+BE4->BE4_CODPEG+BE4->BE4_NUMERO
					dDatAut := BE4->BE4_DTDIGI //PEGO A DATA DE DIGITACAO POIS O BE4_DATPRO 'E A DATA QUE O PACIENTE FOI INTERNADO
					cUsuari := BE4->(BE4_CODOPE+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)
					cCidPri := BE4->BE4_CID
					cCidSec := BE4->BE4_CIDSEC
					cCidTer := BE4->BE4_CID3
					cCidQua := BE4->BE4_CID4
					cCodRda := BE4->BE4_CODRDA
					cNomRda := BE4->BE4_NOMRDA
					lRet    := .T.
				EndIf
			else
				Aviso('Atenção','Guia não encontrada!' ,{'Ok'},2)
				Return lRet
			endIf

			//Verifica se foi gerado/informado protocolo de atendimento
			If lRet .And. GetNewPar("MV_PLRN395","0") == "1"  .And. Empty(cNumProto)

				cMatric := BE4->(BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO)

				If GetNewPar("MV_PLSUNI","1") == "1" .And. BE4->BE4_CODEMP == GetNewPar("MV_PLSGEIN","0050")
					P773AutInc("B4Q",@cNumProto,nil,.T.,.F.,nil,nil,nil,cMatric,.T.)
					lInterProt := .T.
				Else
					P773AutInc("B4Q",@cNumProto,nil,nil,nil,nil,nil,nil,cMatric,.T.)
				EndIf

				If Empty(cNumProto) .And. !lInterProt
					lRet := .F.
					Return lRet
				Endif
			EndIf

			If !Empty(cConteudo)
				//-------------------------------------------------------------------
				//  Se existir saldo
				//-------------------------------------------------------------------
				If lRet

					BA1->(dbSetOrder(2))
					BA1->(dbSeek(xFilial("BA1")+cUsuari))

					BTS->(dbSetOrder(1))
					BTS->(dbSeek(xFilial("BTS")+BA1->BA1_MATVID))
					If !lWeb
						M->B4Q_DATPRO := ddatabase
						M->B4Q_USUARI := cUsuari
						M->B4Q_OPEUSR := BA1->BA1_CODINT
						M->B4Q_CODEMP := BA1->BA1_CODEMP
						M->B4Q_MATRIC := BA1->BA1_MATRIC
						M->B4Q_TIPREG := BA1->BA1_TIPREG
						M->B4Q_DIGITO := BA1->BA1_DIGITO
						M->B4Q_CIDPRI := cCidPri
						M->B4Q_CIDSEC := cCidSec
						M->B4Q_CIDTER := cCidTer
						M->B4Q_CIDQUA := cCidQua
						M->B4Q_PESO   := round(VAL(BTS->BTS_PESO)/1000,2)
						M->B4Q_ALTURA := VAL(BTS->BTS_ALTURA)
						M->B4Q_IDADE  := Calc_Idade(dDataBase,BTS->BTS_DATNAS)
						M->B4Q_NOMUSR := BA1->BA1_NOMUSR
						M->B4Q_MATANT := BA1->BA1_MATANT
						M->B4Q_SEXO   := BTS->BTS_SEXO
						M->B4Q_CODRDA := cCodRda
						M->B4Q_NOMRDA := cNomRda
						if B4Q->(FieldPos("B4Q_NOMSOC")) > 0
							M->B4Q_NOMSOC := BA1->BA1_NOMSOC
						endIf
					Endif
					aRet := {'',; //[1]
						Posicione("BA0",1,xFilial("B4Q")+BA1->BA1_CODINT,"BA0_SUSEP"),; //[2]
						'',; //[3]
						'',; //[4]
						'',;   //[5]
						'',; //[6]
						'',; //[7]
						'',; //[8]
						'',; //[9]
						'',; //[10]
						'',; //[11]
						'',; //[12]
						'',; //[13]
						'',; //[14]
						'',; //[15]
						dDatAut,; //[16]
						'',; //[17]
						'',; //[18]
						ctod(''),; //[19]
						ctod(''),; //[20]
						'',; //[21]
						'',; //[22]
						'',; //[23]
						'',; //[24]
						'',; //[25]
						'',; //[26]
						'',; //[27]
						'',; //[28]
						'',; //[29]
						'',; //[30]
						'',; //[31]
						'',; //[32]
						'',; //[33]
						'',; //[34]
						'',; //[35]
						'',; //[36]
						'',; //[37]
						'',; //[38]
						cUsuari,; //[39]
						BA1->BA1_NOMUSR,; //[40]
						'',; //[41]
						'',; //[42]
						'',; //[43]
						'',; //[44]
						'',; //[45]
						'',; //[46]
						'',; //[47]
						'',; //[48]
						'',; //[49]
						0,; //[50]
						'',; //[51]
						'',; //[52]
						'',; //[53]
						'',; //[54]
						'',; //[55]
						'',; //[56]
						'',; //[57]
						CTOD(''	),; //[58]
						0,; //[59]
						'',; //[60]
						'',; //[61]
						'',; //[62]
						'',; //[63]
						'',; //[64]
						'',; //[65]
						'',; //[66]
						'',; //[67]
						'',; //[68]
						dDatAut,; //[69]
						CTOD(''),; //[70]
						'',; //[71]
						'',; //[72]
						'',; //[73]
						'',; //[74]
						'',; //[75]
						ctod(''),; //[76]
						'',; //[77]
						'',; //[78]
						'',; //[79]
						0,; //[80]
						'',; //[81]
						alltrim(str(round(VAL(BTS->BTS_PESO)/1000,2))),;//[82]
						BTS->BTS_ALTURA,;//[83]
						alltrim(str(Calc_Idade(dDataBase,BTS->BTS_DATNAS))),;//[84]
						Iif(BTS->BTS_SEXO=='2','3','1')}//[85]
					//monto retorno

					If !lWeb
						aDadUsr := PLSDADUSR(cUsuari,"1",.T.,dDataBase,nil,nil,NIL)
					Endif
				Else
					If !lWeb
						Aviso('Atenção','Guia não encontrada!' ,{'Ok'},2)
					Endif
					lRet:= .F.
				Endif
			Else
				If !lWeb
					Aviso('Atenção','Guia não encontrada!' ,{'Ok'},2)
				Endif
				lRet:= .F.
			Endif
		Else
			If !lWeb
				Aviso('Atenção','Guia não encontrada!' ,{'Ok'},2)
			Endif
			lRet := .F.
		EndIf
	Else
		If !lWeb
			Aviso('Atenção','Guia não encontrada!' ,{'Ok'},2)
		Endif
		lRet := .F.
	EndIf

	aadd(aRetorno,lRet)
	aadd(aRetorno,'')
	aadd(aRetorno,aRet)
	aadd(aRetorno,{})
	aadd(aRetorno,{})

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P09PRETPRO

@description Retorna o browse de procedimentos para validar o procedimento
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function P09PRETPRO()
Return oBrwPro

//-------------------------------------------------------------------
/*/{Protheus.doc} P09PRETCRI

@description Retorna o browse de criticas para validar o procedimento
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function P09PRETCRI()
Return oBrwCri

//-------------------------------------------------------------------
/*/{Protheus.doc} P09PRETENC

@description  Retorna a enchoice para validar o procedimento
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function P09PRETENC()
Return oEncAut

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS09PMov

@description Movimentação
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLS09PMov(cAlias,nReg,nOpc,lAudit, cGuiRef, cNumProTMK)

	LOCAL oSay02
	LOCAL oSay
	LOCAL I__f
	LOCAL nFor
	LOCAL nOpca      := 0
	LOCAL aRetAux    := {}
	LOCAL aCampos    := {}
	LOCAL aButtons   := {}
	LOCAL aRetorno   := {.T.}
	LOCAL aProcAbert := {}
	LOCAL aMatCom	 	:= {}
	LOCAL bOK        := {|| nOpca := 1,If(PLA09PVLDo(@aRetorno,oEncAut:aGets,oEncAut:aTela,oBrwPro,oEncAut,nOpc,nil,oBrwCri,nil,nil,aMatCom)[1],oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
	LOCAL bCancel    := {|| oDlg:End() }
	LOCAL bFilCri    := {|| }
	LOCAL bFilPro    := {|| }
	LOCAL nRegB4Q    := Iif(B4Q->(eof()),0,B4Q->(Recno()))
	LOCAL nOrdB4Q    := B4Q->(IndexOrd())
	LOCAL cFaseGuia := ""
	LOCAL slvinclui := iif(type("inclui")=="l",inclui, .t. )
	LOCAL cOpeMov    := ""
	LOCAL cAnoAut    := ""
	LOCAL cMesAut    := ""
	LOCAL cNumAut    := ""
	LOCAL cSeqPF     := ""
	LOCAL cChave     := B4Q->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT)
	LOCAL cChGui
	LOCAL aCabSint  := {}
	LOCAL aDadSint  := {}
	LOCAL aTrbSint  := {}
	LOCAL bFilEven := {|| }
	LOCAL aCabProc  := {}
	LOCAL aDadProc  := {}
	LOCAL aTrbProc  := {}
	LOCAL lValidVis := .T.
	LOCAL nX := 0
	Local nQtdPro   := 0
	Local nValComp  := 0
	local cChaveAC9 := ""
	local nI := 1
	LOCAL cBenef	 := ""
	LOCAL cTexto	 := ""
	LOCAL ctipoesp := ""
	LOCAL cRda 	 := ""
	LOCAL cLoc 	 := ""
	LOCAL cEsp 	 := ""
	LOCAL cCid     := ""
	LOCAL cRegsol	:= ""
	LOCAL cRegExe	:= ""
	LOCAL I			:=0
	LOCAL x := K_Excluir
	LOCAL nFor		:=0
	local aChaveGen	:= {}

	local lGrvBE2	 := getNewPar("MV_PLPRISL", .f.)

	PRIVATE oDlg
	PRIVATE oFolder
	PRIVATE aMatCBkp := {}

	DEFAULT lAudit:= .F.
	DEFAULT cGuiRef:= ''
	DEFAULT cNumProTMK:= ''  //Protocolo gerado quando vem do Call Center

	//-------------------------------------------------------------------
	//  Se a rotina for chamada para visualizacao pela auditoria
	//-------------------------------------------------------------------
	If lAudit
		SX3->(DbSetOrder(2))
		SX3->(DbSeek("BQV_QTDPRO"))
		cDesQtdAut := AllTrim(X3Titulo("BQV_QTDPRO"))
	EndIf

	DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-017 BOLD
	//-------------------------------------------------------------------
	//  Monta aHeader e aCols Sintetico...
	//-------------------------------------------------------------------
	aAutFor 	 := {}
	aCabCri      := {}
	aDadCri	     := {}
	aTrbCri      := {}
	cSeq		 := ""
	aDadB43 	 := {}
	aCabB43 	 := {}
	aTrbB43 	 := {}

	//-------------------------------------------------------------------
	//  Monta aHeader e aCols Procedimentos...
	//-------------------------------------------------------------------

	aCabProc := PLSA09PHea()
	aDadProc := PLS09PACLB(aCabProc)

	//-------------------------------------------------------------------
	//  Se for exclusao testa se pode ser excluida (no caso de exclusao)
	//-------------------------------------------------------------------
	If nOpc == K_Excluir

		//-------------------------------------------------------------------
		//  Verifica se a Guia esta em análise pela auditoria antes da exclusão
		//-------------------------------------------------------------------
		If !PL09VLAUDP("B4Q")
			Return
		EndIf

		If B4Q->B4Q_CANCEL == '1'
			Aviso( "Não foi possível a exclusão","A guia ja encontra-se cancelada. Não poderá ser excluida.",{ 'Ok'}, 2 )
			return
		Endif
	EndIf

	If nOpc <> K_Incluir

		Copy "B4Q" TO Memory

		cOpeMov    := B4Q->B4Q_OPEMOV
		cAnoAut    := If(nOpc <> K_Copiar,B4Q->B4Q_ANOAUT,Alltrim(Str(Year(dDatabase))))
		cMesAut    := If(nOpc <> K_Copiar,B4Q->B4Q_MESAUT,Alltrim(Str(Month(dDatabase))))
		cNumAut    := B4Q->B4Q_NUMAUT
		cChave     := B4Q->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT)

		If nOpc ==  K_Copiar
			M->B4Q_ANOAUT:=cAnoAut
			M->B4Q_MESAUT:=cMesAut
		Endif

		If ! PLS09MPao(cChave,"1",aCabProc,aTrbProc,aDadProc,"BQV")
			Return
		Endif

		If nOpc == K_Visualizar  .Or.  nOpc == K_Excluir
			lValidVis := .F.
		Endif

		PLSA090USR(B4Q->(B4Q_OPEUSR+B4Q_CODEMP+B4Q_MATRIC+B4Q_TIPREG+B4Q_DIGITO),B4Q->B4Q_DATPRO,'',;
			"B01",.F.,nil,nil,nil,nil,nil,nil,nil,nil,nil,;
			nil,nil,nil,lValidVis,Iif(nOpc == K_Incluir ,.T.,.F.))

		nPos1 := PLRETPOS("BQV_IMGSTA",aCabProc)
		nPos2 := PLRETPOS("BQV_STATUS",aCabProc)

		For nFor := 1 To Len(aDadProc)
			aDadProc[nFor,nPos1] := If(aDadProc[nFor,nPos2]=="1","ENABLE","DISABLE")
		Next
		//-------------------------------------------------------------------
		//  Monta as criticas relacionadas ao procedimento...
		//-------------------------------------------------------------------
		BQZ->(DbCloseArea())
		Store Header "BQZ" TO aCabCri For .T.

		BQZ->(DbSetOrder(1))
		If ! BQZ->(MsSeek(xFilial("BQZ")+cChave))
			Store COLS Blank "BQZ" TO aDadCri FROM aCabCri
		Else
			Store COLS "BQZ" TO aDadCri FROM aCabCri VETTRAB aTrbCri While ;
				xFilial("BQZ")+cChave == BQZ->(BQZ_FILIAL+BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT)
		Endif

		If PLSALIASEXI("B43")
			Store Header "B43" TO aCabB43 For ( alltrim(SX3->X3_CAMPO) $ PRetHeaPac() )
			B43->(DbSetOrder(2))
			If B43->(MsSeek(xFilial("B43")+cChave))
				Store COLS "B43" TO aDadB43 FROM aCabB43 VETTRAB aTrbB43 While B43->(B43_FILIAL+B43_OPEMOV+B43_ANOAUT+B43_MESAUT+B43_NUMAUT) == xFilial("B43")+cChave
			Else
				Store COLS Blank "B43" TO aDadB43 FROM aCabB43
			EndIf
		EndIf

	Elseif nOpc == K_Incluir

		Inclui 	  := .T.

		If(!empty(cNumProTMK))
			cNumProto := cNumProTMK
		Else
			cNumProto := Space(20)
		EndIf

		//-------------------------------------------------------------------
		//  Valida calendario pagto...
		//-------------------------------------------------------------------
		aRetAux := PLSXVLDCAL(dDataBase,PLSINTPAD(),.T.,"","")

		If ! aRetAux[1]
			Return
		Endif

		Store Header "BQZ" TO aCabCri For .T.
		Store COLS Blank "BQZ" TO aDadCri FROM aCabCri

		If PLSALIASEXI("B43")
			Store Header "B43" TO aCabB43 For ( AllTrim(SX3->X3_CAMPO) $ PRetHeaPac() )
			Store COLS Blank "B43" TO aDadB43 FROM aCabB43
		EndIf

		Copy "B4Q" TO Memory Blank

		If !Empty(Alltrim(cBenef))

			SX3->(DbSetOrder(2))
			SX3->(MsSeek("B4Q_USUARI"))

			M->B4Q_USUARI := cBenef
			If Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .And. Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }"))
				RunTrigger(1)
			Endif
		EndIf

		If !Empty(cCid)

			SX3->(DbSetOrder(2))
			SX3->(MsSeek("B4Q_CIDPRI"))

			M->B4Q_CIDPRI := cCid

			If Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .And. Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }"))
				RunTrigger(1)
			Endif
		Endif

		//Se o parametro cGuiRef nao for vazio, significa que esta vindo com o parametro
		//da Guia de Referencia ja setado, vamos fazer a tela pesquisar os dados
		//assim que o usuario entrar nela, sem precisar utilizar o "focus out" do campo.
		If !Empty(cGuiRef)

			SX3->(DbSetOrder(2))
			SX3->(MsSeek("B4Q_GUIREF"))

			M->B4Q_GUIREF := cGuiRef
			__readvar := "M->B4Q_GUIREF"

			If (Eval(&(" { || "+AllTrim(SX3->X3_VALID)+" }")) .Or. Empty(SX3->X3_VALID)) .And. (Eval(&(" { || "+AllTrim(SX3->X3_VLDUSER)+" }")) .Or. Empty(SX3->X3_VLDUSER))
				RunTrigger(1)
			Endif

			If !Empty(cNumProto)
				M->B4Q_PROATE := cNumProto
			EndIf
		Endif
	Endif

	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 001, Iif(GetNewPar("MV_PLSMODA","1") == "0",020,Iif(nOpc == K_Incluir ,000,020)), .T., .F.,.F. } )
	AAdd( aObjects, { 001, 000, .T., .T.,.F. } )
	AAdd( aObjects, { 001, 100, .T., .F.,.T. } )

	aInfo := { aSize[1],aSize[2],aSize[3],aSize[4], 5, 5 }
	aPosObj := MsObjSize( aInfo, aObjects )

	aPosObj[1][2]+=15
	aPosObj[2][2]+=15
	aPosObj[3][2]+=15
	aPosObj[3][3]-=15


	//-------------------------------------------------------------------
	//  Cria Dialog...
	//-------------------------------------------------------------------
	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSize[7],0 To aSize[6],aSize[5]  of oMainWnd PIXEL//OF GetWndDefault()

	//-------------------------------------------------------------------
	//  Cria Enchoice...
	//-------------------------------------------------------------------
	cTexto := "Procedimentos"
	STORE FIELD "B4Q" TO aCampos For  (alltrim(SX3->X3_CAMPO) $ RetCamp()[1]+RetCamp()[2]) .And. cNivel >= SX3->X3_NIVEL .And. X3Uso(SX3->X3_USADO)
	oEncAut := B4Q->(MSMGet():New('B4Q',B4Q->(Recno()),nOpc,,,,aCampos,aPosObj[2],,,,,,oDlg,,,.F.,,,If(IsInCallStack("PL09PGREF"),.T.,.F.)))
	If nOpc == K_Incluir
		If(!empty(M->B4Q_GUIREF) .AND. empty(M->B4Q_USUARI) .AND. !empty(M->(B4Q_OPEMOV+B4Q_CODEMP+B4Q_MATRIC+B4Q_TIPREG+B4Q_DIGITO)))
			M->B4Q_USUARI := M->(B4Q_OPEMOV+B4Q_CODEMP+B4Q_MATRIC+B4Q_TIPREG+B4Q_DIGITO)
		EndIf
		M->B4Q_MESPAG := aRetAux[5]
		M->B4Q_ANOPAG := aRetAux[4]
	Else
		If nOpc <> K_Copiar
			//-------------------------------------------------------------------
			//  Exibe say...
			//-------------------------------------------------------------------
			@ aPosObj[1,1]+6,aPosObj[1,2]+5  SAY oSay PROMPT "Prorrogação de internação Número  "  SIZE 300,010 OF oDlg PIXEL FONT oFontAutor
			@ aPosObj[1,1]+6,aPosObj[1,2]+180 SAY oSay PROMPT TransForm(B4Q->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT),PesqPict("B4Q","B4Q_NUMLIB")) SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED FONT oFontAutor
		Else
			aCampoLimp:=B4Q->(Dbstruct())
			For i:=1 to Len(aCampoLimp)
				If !aCampoLimp[i,1]$ ("B4Q_FILIA","B4Q_OPEMOV","B4Q_STATUS","B4Q_AUDITO")
					If Valtype((M->&(aCampoLimp[i,1])))="C"
						If Alltrim(aCampoLimp[i,1]) == "B4Q_ANOPAG"
							M->&(aCampoLimp[i,1]):=Alltrim(Str(Year(dDatabase)))
						ElseIf Alltrim(aCampoLimp[i,1]) =="B4Q_MESPAG"
							M->&(aCampoLimp[i,1]):=Alltrim(Str(Month(dDatabase)))
						Else
							M->&(aCampoLimp[i,1]):=Space(TamSX3(aCampoLimp[i,1])[1])
						Endif
					ElseIf  Valtype((M->&(aCampoLimp[i,1])))="N"
						M->&(aCampoLimp[i,1]):=0
					Else
						M->&(aCampoLimp[i,1]):=dDataBase
					Endif
				Endif
			next i

		Endif
	Endif
	//-------------------------------------------------------------------
	//  Define folder...
	//-------------------------------------------------------------------
	AaDd(aProcAbert,{"BMPVISUAL",{|| P090Pacote("BQV",aDadB43,aCabB43,aTrbB43)},"Visualizar procedimentos contidos no pacote","Pacote"})

	oFolder 		:= TFolder():New(aPosObj[3,1],aPosObj[3,2],{cTexto,'Criticas'},{"",""},oDlg,,,,.T.,.F.,aPosObj[3,3],aPosObj[3,4])
	oFolder:bChange := {|nFolder| oBrwPro:oBrowse:oBrowse:Refresh(), oBrwCri:ForceRefresh(oBrwPro), P09PSEQCRI() }

	//-------------------------------------------------------------------
	//  Cria Eventos
	//-------------------------------------------------------------------
	oBrwPro 			:= TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil,  oFolder:aDialogs[1],nil,nil ,nil,nil,nil,.T.,nil,.T.,nil,aCabProc,aDadProc,.F.,"BQV",IIf(nOpc = K_Excluir,K_Visualizar,nOpc),"Eventos da Liberação",nil,nil,nil,aTrbProc,nil,'PL09PDELPR',nil,{|a,b,c| PLSA090CP(a,b,c)},aProcAbert,nil,{|| PLSCANCEL(), Iif(oBrwPro:nOpcX==K_Incluir .And. FindFunction("PLSLIMSTA"),PLSLIMSTA(M->BQV_SEQUEN+M->BQV_CODPAD+M->BQV_CODPRO),nil) },nil)
	oBrwPro:bLostFocus 	:= {|| P09PSEQCRI(),lRefresh := .T. }
	oBrwPro:bChange    	:= {|| Eval(oBrwPro:bLostFocus),  oBrwCri:ForceRefresh(oBrwPro) }

	//-------------------------------------------------------------------
	//  Cria Criticas
	//-------------------------------------------------------------------
	bFilCri         := {|nLine,aCols,aHeader| aCols[nLine,PLRETPOS("BQZ_SEQUEN",aHeader)] == oBrwPro:FieldGet("BQV_SEQUEN") }
	oBrwCri 		:= TPLSBrw():New(2,2,aPosObj[3,3]-6,aPosObj[3,4]-15,nil  ,oFolder:aDialogs[2],nil    ,  ,nil    ,nil   ,nil, .T.   ,nil  ,.T.   ,nil   ,aCabCri,aDadCri,.F.,"BQZ",K_Visualizar,"Criticas da Liberação",nil,nil,nil,aTrbCri,,,bFilCri) //"Criticas da Liberação"
	oBrwCri:oPai    := oBrwPro
	oBrwCri:aOrigem := {"BQV_SEQUEN"}
	oBrwCri:aRelac  := {"BQZ_SEQUEN"}
	//-------------------------------------------------------------------
	//  Starta funcao padrao para montar botoes padrao...
	//-------------------------------------------------------------------

	If nOpc == K_Copiar
		M->B4Q_USUARI:=""
	Endif

	PLS09PBot(nOpc,"B4Q",oEncAut,oBrwPro,"B4Q",{ || M->B4Q_USUARI },aButtons,oFolder,oDlg,oSay02,"Autorização",oBrwCri)

	If existblock("PLSAADIA")
		execblock("PLSAADIA", .f. , .f. )
	Endif

	//-------------------------------------------------------------------
	//  Ativa Dialog...
	//-------------------------------------------------------------------
	ACTIVATE MSDIALOG oDlg ON INIT Eval( { || EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons), oEncAut:SetFocus() })
	//-------------------------------------------------------------------
	//  Busca retorno contido no aRetorno...
	//-------------------------------------------------------------------
	If nOpca == K_OK
		cOpeMov := aRetorno[2]
		cAnoAut := If(nOpc<>K_Copiar,aRetorno[3],cAnoAut)
		cMesAut := If(nOpc<>K_Copiar,aRetorno[4],cMesAut)
		cNumAut := aRetorno[5]
		lAuditoria := aRetorno[9]

		If nOpc == K_Copiar
			aRetorno[3]:=cAnoAut
			aRetorno[4]:=cMesAut
		Endif

		If nOpc == K_Incluir  .or. nOpc == K_Copiar

			//-------------------------------------------------------------------
			//  Conclui um protocolo
			//-------------------------------------------------------------------
			If GetNewPar("MV_PLRN395","0") == "1" .And. !Empty(cNumProto)
				P773AutCon("B4Q",cNumProto,cOpeMov+cAnoAut+cMesAut+cNumAut)
			EndIf

			// Grava BEA para futuras pesquisas de Relatorios e aplicação tais como recurso de glosa

			A090FinaA(cOpeMov,cAnoAut,cMesAut,cNumAut,aRetorno,oBrwPro,lAuditoria)

		ElseIf nOpc == K_Excluir

			B53->(dbSetOrder(1))

			If B53->(dbSeek(xFilial("B53")+B4Q->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT)))
				B53->(RecLock("B53",.F.))
				B53->(DbDelete())
				B53->(MsUnLock())
			EndIf
		Endif
	Endif
	//-------------------------------------------------------------------
	//  Exclui os registros no banco de conhecimento relacionados com a guia excluida //
	//-------------------------------------------------------------------
	If nOpca == K_OK .AND. FindFunction("PLSA092EBC")
		PLSA092EBC(cOpeMov, cAnoAut, cMesAut, cNumAut)
	EndIf

	//-------------------------------------------------------------------
	//  Limpa DADUSR
	//-------------------------------------------------------------------
	PLSCLEAUSR()
	//-------------------------------------------------------------------
	//  Desativa Sets Keys...
	//-------------------------------------------------------------------
	SET KEY VK_F5 TO
	SET KEY VK_F6 TO
	SET KEY VK_F7 TO
	SET KEY VK_F8 TO
	SET KEY VK_F9 TO
	SET KEY VK_F10 TO
	SET KEY VK_F11 TO
	SET KEY VK_F12 TO

return

//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF

@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Static Function MENUDEF()

	Local aPtoEntrada
	Local cIntProrro	:= "PLSAINTE('BQV','11', 'B4Q->B4Q_OPEMOV' , 'B4Q->B4Q_ANOAUT' , 'B4Q->B4Q_MESAUT' , 'B4Q->B4Q_NUMAUT' )"
	Local cIntGuiRef	:= "PLSAINTE(,'GR','Substr(B4Q->B4Q_GUIREF,1,4)','Substr(B4Q->B4Q_GUIREF,5,4)', 'Substr(B4Q->B4Q_GUIREF,9,2)' , 'Substr(B4Q->B4Q_GUIREF,11,8)')"
	Local aRotConh    	:= 	{{"Guia", "Pls09PBco('C')", 0, 0}, ;
		{"Item", "Pls09PBco('I')", 0, 0}}
	Local aRotInte     	:= 	{{ STR0067 ,cIntProrro, 0, 0}, ; // "Prorr.Internação"
		{ STR0068 ,cIntGuiRef, 0, 0}} 	 // "Guia Referência"

	Local aRotina := {}

	PRIVATE aAutForAnx 	:= {}
	PRIVATE aCodCriHis 	:= {}




	If GetNewPar("MV_PLALTPR","1") == "1"
		aRotina := {	{"Pesquisar" ,'AxPesqui'		,0 ,K_Pesquisar	,0 ,.F. },;
			{"Visualizar",'PLS09PMov'	,0 ,K_Visualizar	,0 ,Nil },;
			{"Incluir" ,'PLS09PMov'		,0 ,K_Incluir		,0 ,Nil },;
			{"Alterar",'PLS09PMov',0,K_Alterar		,0 ,.F. },;
			{"Excluir",'PLS09PMov'		,0 ,K_Excluir		,0 ,Nil },;
			{"Copiar",'PLS09PMov'		,0 ,K_Copiar		,0 ,Nil },;
			{"Imp.Guia",'PLS09PIm2'		,0 ,K_Imprimir	,0 ,Nil },;
			{"Cancelar Prorrogação"  ,'PLSP02CAN()'	,0 ,K_Visualizar	,0 ,Nil },;
			{"Conhecimento"  ,aRotConh			,0 ,K_BCOCON		,0 ,Nil },;
			{"Interação"	,	aRotInte				,0 ,K_Incluir		,0 ,Nil }}
	else
		aRotina := {	{"Pesquisar" ,'AxPesqui'		,0 ,K_Pesquisar	,0 ,.F. },;
			{"Visualizar",'PLS09PMov'	,0 ,K_Visualizar	,0 ,Nil },;
			{"Incluir" ,'PLS09PMov'		,0 ,K_Incluir		,0 ,Nil },;
			{"","",0,5,0,Nil},;
			{"Excluir",'PLS09PMov'		,0 ,K_Excluir		,0 ,Nil },;
			{"Copiar",'PLS09PMov'		,0 ,K_Copiar		,0 ,Nil },;
			{"Imp.Guia",'PLS09PIm2'		,0 ,K_Imprimir	,0 ,Nil },;
			{"Cancelar Prorrogação"  ,'PLSP02CAN()'	,0 ,K_Visualizar	,0 ,Nil },;
			{"Conhecimento"  ,aRotConh			,0 ,K_BCOCON		,0 ,Nil },;
			{"Interação"	,	aRotInte				,0 ,K_Incluir		,0 ,Nil }}
	endif


	//Protocolo de Atendimento
	If GetNewPar("MV_PLRN395","0") == "1"
		AaDd( aRotina,{ "Informar Protoc." ,'PL9PInfPro()' , 0 , K_Alterar , 0 , Nil} )
	EndIf

	//"Anexos HAT"
	if GetNewPar("MV_PLSHAT","0") == "1"
		aAdd( aRotina, { STR0066 , 'PLSVERARQ(B4Q->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT), "B4Q") '   , 0, Nil} )
	endIf
	//-------------------------------------------------------------------
	//  Para ponto de entrada
	//-------------------------------------------------------------------
	If ExistBlock("PLS09AM1")
		aPtoEntrada := ExecBlock("PLS09AM1",.F.,.F.)
		AaDd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Imprimir , 0 , Nil} )
	Endif
	//-------------------------------------------------------------------
	//  Para ponto de entrada
	//-------------------------------------------------------------------
	If ExistBlock("PLS09AM2")
		aPtoEntrada := ExecBlock("PLS09AM2",.F.,.F.)
		AaDd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Imprimir , 0 , Nil} )
	Endif
	//-------------------------------------------------------------------
	//  Para ponto de entrada
	//-------------------------------------------------------------------
	If ExistBlock("PLS09AM3")
		aPtoEntrada := ExecBlock("PLS09AM3",.F.,.F.)
		AaDd( aRotina,{ aPtoEntrada[1] ,aPtoEntrada[2] , 0 , K_Imprimir , 0 , Nil} )
	Endif

Return(aRotina)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS09PHCHe

@description Header críticas
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLS09PHCHe()

	LOCAL aCab1 := {}

	Store Header "BQZ" TO aCab1 For .T.

Return  aCab1

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS09PHCLB

@description aCols das críticas
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLS09PHCLB(aCab2)

	LOCAL aCab1 := {}

	Store COLS Blank "BQZ" TO aCab1 FROM aCab2

Return aCab1

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA09PHea

@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLSA09PHea(cTipo,cTpTipo,nOpc)

	LOCAL nPosPro     := 0 //Procedimento
	LOCAL nPos     := 0
	LOCAL cCampos  	:= PLSA09PFld()
	LOCAL aCabProc 	:= {}

	DEFAULT nOpc	:= K_Visualizar

	Store Header "BQV" TO aCabProc For ( alltrim(SX3->X3_CAMPO) $ cCampos )

Return(aCabProc)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA09PFld

@description Monta campos padroes para a getDados do Procedimentos
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLSA09PFld()

	//CAMPOS GERAIS QUE SEMPRE DEVEM APARECER
	LOCAL cCampos := "BQV_CODPAD,BQV_SEQUEN,BQV_NIVEL ,BQV_CODPRO,BQV_DESPRO,BQV_QTD   ,BQV_STATUS,"
	cCampos += "BQV_QTDPRO,BQV_IMGSTA,BQV_NIVAUT,BQV_CHVNIV,BQV_NIVCRI,BQV_VLPGMA,BQV_AUDITO,BQV_VIA   ,"
	cCampos += "BQV_PERVIA,BQV_PROCCI,BQV_CDPDRC,BQV_PROREL,BQV_PRPRRL,BQV_VLCOMP,BQV_LIBESP,BQV_PEREVC,
	cCampos += "BQV_VLRAPR,BQV_BLOCPA,BQV_BLOPAG,BQV_DNIVCR,BQV_DNIVAU,BQV_SOLREV,BQV_COMUNI,BQV_NRAOPE, "
	cCampos += "BQV_GUIACO,BQV_QUACOB,BQV_VALORI,BQV_CODAUD,BQV_SALDO, "
	cCampos += "BQV_DATPRO,BQV_HORPRO,BQV_QTDSOL,BQV_NRTROL,BQV_NRAOPE,BQV_COMUNI,BQV_REGANV "

	If  ExistBlock("PL09AFL1")
		cCampos := ExecBlock("PL09AFL1",.F.,.F.,{cCampos})
	EndIf

Return(cCampos)

//-------------------------------------------------------------------
/*/{Protheus.doc} RetCamp

@description Configuração de campos da BCM
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Static Function RetCamp()

	//campos que vou mostrar na tela que sao obrigatorios
	LOCAL cCampOb := ''
	//campos que vou mostrar na tela que nao sao obrigatorios
	LOCAL cCamNOb := ''
	LOCAL cTipGui := ''

	cTipGui := "11"

	BCM->(DbSetOrder(1))
	If BCM->(MsSeek(xFilial('BCM')+PlsIntPad()+cTipGui))
		While !BCM->(Eof()) .and. BCM->BCM_TIPGUI == cTipGui
			cCampOb += BCM->BCM_CAMPO
			BCM->(DbSkip())
		Enddo
	Endif
	If GetNewPar("MV_PLRN395","0") == "1"
		cCamNOb += ",B4Q_PROATE"
	EndIf

	If B4Q->(FieldPos("B4Q_NRAEMP")) > 0
		cCamNOb += ",B4Q_NRAEMP"
	EndIf

	If ExistBlock("PLS09ACP")
		aCampOb := ExecBlock("PLS09ACP",.F.,.F.,{cCampOb,cTp,cCamNOb})
		aCampOb := aCampOb[1]
		cCamNOb := aCampOb[2]
	Endif

Return {cCampOb,cCamNOb}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS09PACLB

@description Monta aCols Blank padrão
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLS09PACLB(aCabProc)

	LOCAL aDadProc := {}

	Store COLS Blank "BQV" TO aDadProc FROM aCabProc

Return(aDadProc)

//-------------------------------------------------------------------
/*/{Protheus.doc} P09PSEQCRI

@description Sequência dos procedimentos
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function P09PSEQCRI(nTipo)
	LOCAL cRet := "001"
	DEFAULT nTipo := 0

	If nTipo == 0
		If ValType(oBrwPro) == "O"
			cRet := oBrwPro:FieldGet("BQV_SEQUEN")
		EndIf
	Else
		If BQZ->( FieldPos("BQZ_SEQCRI") ) > 0
			If ValType(oBrwCri) == "O"
				If !(oBrwCri:aCols[Len(oBrwCri:aCols),Len(oBrwCri:aHeader)+1])
					cRet := PLSINCRE("BQZ_SEQCRI",oBrwCri)
				EndIf
			Else
				cRet := PLSINCRE("BQZ_SEQCRI")
			Endif
		Endif
	Endif

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA09PSEQ

@description Sequência dos procedimentos
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLSA09PSEQ

	LOCAL cRet
	If ValType(oBrwPro) == "O"
		If oBrwPro:aCols[Len(oBrwPro:aCols),Len(oBrwPro:aHeader)+1]
			cRet := Soma1(oBrwPro:FieldGet("BQV_SEQUEN"))
		Else
			cRet := PLSINCRE("BQV_SEQUEN",oBrwPro)
		EndIf
	Else
		cRet := PLSINCRE("BQV_SEQUEN")
	Endif

Return(cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLA09PUSU

@description Carrega alguns campos do usuário
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLA09PUSU

	LOCAL lRet := .F.

	If Empty(M->B4Q_USUARI)
		return .T.
	Endif
	If PLSA090USR(M->B4Q_USUARI,M->B4Q_DATSOL,NIL,"B4Q")
		//M->B4Q_PESO   := round(VAL(BTS->BTS_PESO)/1000,2)
		M->B4Q_ALTURA := VAL(BTS->BTS_ALTURA)
		M->B4Q_IDADE  := Calc_Idade(dDataBase,BTS->BTS_DATNAS)
		lRet := .T.
	Endif

RETURN lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA09PBot

@description Monta botoes e keys
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLS09PBot(nOpc,cAliasEnc,oEncAut,oBrwPro,cAliasPro,bMatUsr,aButtons,oFolder,oDlg,oSay02,cDescri,oBrwCri,lBtnOn)

	LOCAL lAnt
	LOCAL bBotao01 := {|| A09PLimpa(cAliasEnc,oEncAut,oBrwPro,"B4Q",,,.T.)}
	LOCAL bBotao02 := {|| PLPOSFIN(Eval(bMatUsr),.T.,.T.) }
	LOCAL bBotao03 := {|| PLHISMOV(Eval(bMatUsr)) }
	LOCAL bBotao04 := {|| PLAltCli(Eval(bMatUsr), .T.) }
	LOCAL bBotao05 := {|| BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+&("M->"+cAliasEnc+"_USUARI"))), If(BA1->(Found()),PLSVLRCOB(,,.T.),Help("",1,"PLSA090USR")) }
	LOCAL bBotao06 := {|| lAnt := Inclui,Inclui := .F., BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+&("M->"+cAliasEnc+"_USUARI"))), If(BA1->(Found()),PLSA260MOV("BA1",BA1->(RECNO()),K_Visualizar),Help("",1,"PLSA090USR")), Inclui := lAnt}
	LOCAL bBotao07 := {|| BA1->(DbSetOrder(2)), BA1->(MsSeek(xFilial("BA1")+&("M->"+cAliasEnc+"_USUARI"))), If(BA1->(Found()),AxVisual("BA1",BA1->(RECNO()),K_Visualizar),Help("",1,"PLSA090USR")) }
	LOCAL bBotao08 := {|| PLSA090ACO(cAliasEnc,oEncAut,oBrwCri,oBrwPro) }
	LOCAL bBotao09 := {|| PLSA090CPR(cAliasEnc,oEncAut,oBrwCri,nil,oBrwPro) }
	LOCAL bBotao10 := {|| BA3->(DbSetOrder(1)), BA3->(MsSeek(xFilial("BA3")+Subs(&("M->"+cAliasEnc+"_USUARI"),1,14))), If(BA3->(Found()),ExeQuest(),Help("",1,"PLSA090QUE")) }
	LOCAL bBotao13 := {|| PLSA096(SUBSTR(&("M->"+cAliasEnc+"_USUARI"),1,4),SUBSTR(&("M->"+cAliasEnc+"_USUARI"),5,4),SUBSTR(&("M->"+cAliasEnc+"_USUARI"),9,6),SUBSTR(&("M->"+cAliasEnc+"_USUARI"),15,2),SUBSTR(&("M->"+cAliasEnc+"_USUARI"),17,1)) }
	LOCAL bBotao11 := {|| PLSMSGCA(Eval(bMatUsr)) }
	LOCAL bBotao17 := {|| PLSA09AMTC(cAliasEnc,oEncAut,oBrwCri,,oBrwPro, ,B4Q->(RECNO()), "B4Q", Inclui) }
	LOCAL aDadRda  := PLSGETRDA()
	LOCAL aPTBot	  := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.}
	LOCAL oBotao
	LOCAL aPtoEntrB1
	LOCAL aPtoEntrB2
	LOCAL cCodCri
	LOCAL J
	LOCAL nTamArray

	DEFAULT cDescri  := __cDescri
	DEFAULT lBtnOn  := .F.

	//-------------------------------------------------------------------
	//  Verifica
	//-------------------------------------------------------------------
	If nOpc == K_Incluir
		aadd(aButtons,{"S4WB004N",bBotao01,"Limpar Tela - <F5>","Limpa"})
		SetKey(VK_F5,bBotao01)
	Endif
	//-------------------------------------------------------------------
	//  Ponto de entrada para desabilitar BOTOES PARA um grupo de operadores
	//-------------------------------------------------------------------
	If ExistBlock("PLSAUTOP")
		aPTBot := ExecBlock("PLSAUTOP",.F.,.F.,{"PLSA090"})
		nTamArray:= Len(aPTBot)
		If nTamArray < 16
			For j:=(nTamArray+1) to 16
				aadd(aPTBot,.T.)
			Next
		EndIf
	EndIf
	//-------------------------------------------------------------------
	//  Botoes
	//-------------------------------------------------------------------
	If aPTBot[1]
		aadd(aButtons,{"SALARIOS",bBotao02,"Posicao Financeira - <F6>","Financ" })
		SetKey(VK_F6,bBotao02)
	EndIf

	If aPTBot[2]
		aadd(aButtons,{"POSCLI",bBotao04,"Alterar Dados do Cliente - <F8>","Cliente"})
		SetKey(VK_F8,bBotao04)
	EndIf

	If aPTBot[3]
		aadd(aButtons,{"PLNPROP",bBotao05,"Composicao de Cobranca - <F9>","Cobranca" })
		SetKey(VK_F9,bBotao05)
	EndIf

	If aPTBot[4]
		aadd(aButtons,{"GROUP",bBotao06,"Dados da Familia - <F10>","Familia"})
		SetKey(VK_F10,bBotao06)
	EndIf

	If aPTBot[5]
		aadd(aButtons,{"RELATORIO",bBotao03,"Historico de Movimentacao - <F7>","Historico"})
		SetKey(VK_F7,bBotao03)
	EndIf

	If aPTBot[6]
		aadd(aButtons,{"RESPONSA",bBotao07,"Dados da vida do beneficiario - <F11>","Benef."  })
		SetKey(VK_F11,bBotao07)
	EndIf

	If aPTBot[7]
		aadd(aButtons,{"S4WB007N",{ || A090INTGER(cAliasEnc) },"Usuarios de Outros Intercambios","Usuarios de intercâmbio"})
	EndIf

	If aPTBot[8]
		aadd(aButtons,{"S4WB009N",{ || A09AMovPOS() },"Consultar Movimentacoes Negadas em POS/Internet/Outros","Mov.Neg."})
	EndIf

	//-------------------------------------------------------------------
	//  Botao Hist Criticas Forcadas
	//-------------------------------------------------------------------
	If nOpc == K_Visualizar
		aadd(aButtons,{"S4WB010N",{ || PLS090FOR("B4Q","BQV",oBrwPro) },"Hist. Criticas Forçadas","Crit. Forçadas"})
	Endif

	//************************
	If aPTBot[17]
		aadd(aButtons,{"S4WB009N",bBotao17,"Motivo Neg. Auditoria","Motivo Neg. Auditoria"}) //"Consultar Movimentacoes Negadas em POS/Internet/Outros"###"Mov.Neg."
	EndIf
	//************************

	//-------------------------------------------------------------------
	//  Monta outros botoes de apoio...
	//-------------------------------------------------------------------
	If aPTBot[11]
		@ 030,002 BTNBMP oBotao RESOURCE "VERNOTA" SIZE 030 ,030 OF oDlg PIXEL MESSAGE "Grupo de carencia" ACTION Eval(bBotao11)
	Endif
	If aPTBot[12]
		@ 065,002 BTNBMP oBotao RESOURCE "NOTE" SIZE 030 ,030 OF oDlg PIXEL MESSAGE "Grupos de Cobertura" ACTION PLSRTGCUSR(&("M->"+cAliasEnc+"_USUARI"))
	Endif
	If aPTBot[13]
		@ 100,002 BTNBMP oBotao RESOURCE "RELATORIO" SIZE 030 ,030 OF oDlg PIXEL MESSAGE "Visualizar Entrevista Qualificada do Usuario" ACTION Eval(bBotao10)
	Endif

	nLin := 135
	If FindFunction("PLSC005")
		If aPTBot[15]
			nLin += 35
			@ nLin,002 BTNBMP oBotao RESOURCE "S4WB016N" SIZE 030 ,030 OF oDlg PIXEL MESSAGE "Consultar Cobertura/Carencia" ACTION Eval( {||  BA1->(DbSetOrder(2)),;
				PLSC005()} )
		Endif
	Endif
	If FindFunction("PL169HIST")
		If aPTBot[16]
			nLin += 35
			@ nLin,002 BTNBMP oBotao RESOURCE "HISTORIC" SIZE 030 ,030 OF oDlg PIXEL MESSAGE "Historico Transferencia" ACTION PL169HIST()
		Endif
	Endif

	If GetNewPar("MV_PLRN395","0") == "1"
		If nOpc == K_Visualizar
			cNumProto := B4Q->B4Q_PROATE
		EndIf
		nLin += 35
		@ nLin,002 BTNBMP oBotao RESOURCE "USER" SIZE 030 ,030 OF oDlg PIXEL MESSAGE "Protocolo de Atendimento" ACTION P773AutInc("B4Q",@cNumProto,NIL,NIL,.T.,nOpc)
	EndIf

	If ExistBlock("PLS09AB1")
		aPtoEntrB1 := ExecBlock("PLS09AB1",.F.,.F.)
		nLin += 35
		@ nLin,002 BTNBMP oBotao RESOURCE aPtoEntrB1[1] SIZE 030 ,030 OF oDlg PIXEL MESSAGE aPtoEntrB1[2] ACTION Eval(aPtoEntrB1[3])
	Endif

	If ExistBlock("PLS09AB2")
		aPtoEntrB2 := ExecBlock("PLS09AB2",.F.,.F.)
		nLin += 35
		@ nLin,002 BTNBMP oBotao RESOURCE aPtoEntrB2[1] SIZE 030 ,030 OF oDlg PIXEL MESSAGE aPtoEntrB2[2] ACTION Eval(aPtoEntrB2[3])
	Endif

	If ExistBlock("PLS09AB3") .and. nOpc == K_Incluir
		cCodCri := ExecBlock("PLS09AB3",.F.,.F.)
		BCT->( DbSetOrder(1) ) //BCT_FILIAL + BCT_CODOPE + BCT_PROPRI + BCT_CODGLO
		If BCT->( MsSeek( xFilial( 'BCT' )+PLSINTPAD()+cCodCri )  )// Trocar o 701 pelo codigo da sua critica
			nLin += 35
			@ nLin,002 BTNBMP oBotao RESOURCE "AFASTAMENTO" SIZE 030 ,030 OF oDlg PIXEL MESSAGE "Negar Autorização" ACTION PL090CRINE(cCodCri)
		EndIf
	Endif

	If SuperGetMv("MV_BIOCONF",,.F.) .And. ("PLSA315" $ UPPER( Alltrim( Funname() ) ) .OR. SuperGetMv("MV_BIOATEN",,.F.) )
		nLin += 35
		@ nLin,002 BTNBMP oBotao RESOURCE "OBJETIVO" SIZE 030 ,030 OF oDlg PIXEL MESSAGE "Biometria" ACTION PL090BIO(cAliasEnc,.F.)
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A09AMovPOS

@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Static Function A09AMovPOS()

	LOCAL cOldCad := cCadastro

	PLSA086()
	cCadastro := cOldCad

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A09PLimpa

@description Limpa a guia ou somente os eventos e criticas
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function A09PLimpa(cAlias,oEnchoice,oBrowse,cAliasGetd,lItens,lUsr,lPerg,cAliCri,oGet01,cGet01)

	//-------------------------------------------------------------------
	//  Define variaveis...
	//-------------------------------------------------------------------
	LOCAL cField
	LOCAL cCpoUsr  := cAlias+"_USUARI,"+cAlias+"_MATANT,"+cAlias+"_NOMUSR,"+cAlias+"_TIPUSR"

	DEFAULT lItens := .T.
	DEFAULT lUsr   := .T.
	DEFAULT lPerg  := .F.
	DEFAULT cAliCri := "BQZ"
	DEFAULT oGet01  := nil
	DEFAULT cGet01  := ""

	//-------------------------------------------------------------------
	//  Para escolha do usuario se limpa a guia ou somente os eventos e criticas
	//-------------------------------------------------------------------
	If lPerg
		If  Aviso(	"Atenção", "Deseja limpar os campos de todos os folders?",{ 'Sim', 'Nao'}, 2 ) == 1
			lPerg := .F.
		Else
			lPerg := .T.
		EndIf
	EndIf
	If !lPerg
		//-------------------------------------------------------------------
		//  Em todos os campo da enchoice zera conteudo...
		//-------------------------------------------------------------------
		SX3->(DbSetOrder(1))
		IF SX3->(MsSeek(cAlias))
			While ! SX3->(Eof()) .And. SX3->X3_ARQUIVO == cAlias

				cField := AllTrim(SX3->X3_CAMPO)

				If ! (cField $ cAlias+"_ANOPAG,"+cAlias+"_MESPAG")
					If     cField $ cCpoUsr
						If lUsr
							M->&(cField) := CriaVar(cField)
						Endif
					Else
						M->&(cField) := CriaVar(cField)
					Endif
				Endif

				SX3->(DbSkip())
			Enddo
		Endif
	EndIF
	//-------------------------------------------------------------------
	//  Limpa itens...
	//-------------------------------------------------------------------
	If lItens
		A090Clr(cAliCri,oBrwCri)
		A090Clr(cAliasGetd,oBrowse)
		If !Empty(cGet01)
			A090Clr(cGet01,oGet01)
		Endif
	Endif
	//-------------------------------------------------------------------
	//  Atualiza Enchoice...
	//-------------------------------------------------------------------
	lRefresh := .T.
	oEnchoice:oBox:Refresh()
	oEnchoice:oBox:SetFocus()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Pls09PBco

@description Banco de conhecimento dos itens
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function Pls09PBco(cOp)

	Local aArea		:= GetArea()
	Local aAreaB4Q	:= B4Q->(GetArea())
	Local aRotBack  := aRotina
	Local cQuery	:= ""
	Local cIndex	:= ""
	LOCAL cChaveInt  	:= B4Q->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT)
	LOCAL cChaveAC9 := B4Q->B4Q_FILIAL+cChaveInt

	Default cOp		:= "I" // C = Anexo vinculado ao cabeçalho  I = Anexo vinculado ao item

	aRotina := {{'Conhecimento','MsDocument',0,3},{"Inclusão Rápida",'PLSDOcs',0,3}} //"Conhecimento"
	B4Q->( DbSetOrder(1) ) //B4Q_FILIAL + B4Q_OPEMOV + B4Q_ANOAUT + B4Q_MESAUT + B4Q_NUMAUT + DTOS(B4Q_DATPRO) + B4Q_HORPRO
	B4Q->( MsSeek( xFilial("B4Q") + cChaveInt ) )

	If cOp == "I" // inclusão nos itens
		DbSelectArea("BQV")
		cIndex := CriaTrab(NIL,.F.)
		cQuery := "BQV_FILIAL == '" + xFilial("BQV") + "' "
		cQuery += " .And. BQV_CODOPE == '" + B4Q->B4Q_OPEMOV + "'"
		cQuery += " .And. BQV_ANOINT == '" + B4Q->B4Q_ANOAUT + "'"
		cQuery += " .And. BQV_MESINT == '" + B4Q->B4Q_MESAUT + "'"
		cQuery += " .And. BQV_NUMINT == '" + B4Q->B4Q_NUMAUT + "'"
		IndRegua("BQV",cIndex,BQV->(IndexKey()),,cQuery)
		If BQV->(!Eof())
			MaWndBrowse(0,0,300,600,"Retorno de Doctos. de Saida","BQV",,aRotina,,,,.T.,,,,,,.F.) //"Retorno de Doctos. de Saida"
		EndIf

		If PLSALIASEX("B53")

			AC9->(DbSetOrder(2))//AC9_FILIAL, AC9_ENTIDA, AC9_FILENT, AC9_CODENT, AC9_CODOBJ, R_E_C_N_O_, D_E_L_E_T_

			If AC9->(dbSeek( xFilial("AC9") + "BQV" +xfilial('BQV')+cChaveAC9))
				dbSelectArea("B53")
				If B53->(dbSeek(xFilial("B53")+cChaveInt))
					If B53->B53_BANCON != '1'
						B53->(Reclock("B53",.F.))
						B53->B53_BANCON := '1'
						B53->(MsUnlock())
					EndIf
				EndIf
			else
				dbSelectArea("B53")
				If B53->(dbSeek(xFilial("B53")+cChaveInt))
					If B53->B53_BANCON != '0'
						B53->(Reclock("B53",.F.))
						B53->B53_BANCON := '0'
						B53->(MsUnlock())
					EndIf
				EndIf
			EndIf
		EndIf

		RetIndex( "BQV" )
		dbClearFilter()
		FErase( cIndex+OrdBagExt() )
	Else
		MsDocument( "B4Q", B4Q->( RecNo() ), 2 )
		PLSATUB53(cChaveAC9, cChaveInt, "B4Q")
	EndIf

	aRotina := aRotBack

	dbSelectArea("BQV")
	dbSetOrder(1)

	B4Q->( RestArea(aAreaB4Q) )
	RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PL09PESAUT

@description Pesquisa generica de Procedimentos
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PL09PESAUT(cNroGui)

	Static objCENFUNLGP := CENFUNLGP():New()

	LOCAL nReg          := 0
	LOCAL nLin       	:= 1
	LOCAL nOpca      	:= 0
	LOCAL nSaldo		:= 0
	LOCAL nOrdem     	:= 1
	LOCAL cChave     	:= Space(40)
	LOCAL cTipoPes   	:= ""
	LOCAL cCabec		:= ""
	LOCAL cSQL 			:= ""
	LOCAL cSetFocus 	:= ""
	LOCAL oDlgPesPro    := NIL
	LOCAL oTipoPes		:= NIL
	LOCAL oSayPro       := NIL
	LOCAL oBrowPro		:= NIL
	LOCAL oGetChave		:= NIL
	LOCAL oChkChk		:= NIL
	LOCAL oPanel 		:= NIL
	LOCAL oFont			:= NIL
	LOCAL aBrowPro   	:= {}
	LOCAL aVetPad    	:= { {"","",0,"","","","","","",""} }
	LOCAL bRefresh   	:= { || If(!Empty(cChave),PLSAPAUTPQ(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowPro,aVetPad,oBrowPro,cVarRead),.T.), If( Empty(aBrowPro[1,1]) .And. !Empty(cChave),.F.,.T. )  }
	LOCAL cValid     	:= "{|| Eval(bRefresh) }"
	LOCAL bOK        	:= { || If(!Empty(cChave),(nLin := oBrowPro:nAt,nOpca := 1,lOk:=.T.,oDlgPesPro:End()),Help("",1,"PLSMCON")) }
	LOCAL bCanc      	:= { || nOpca := 3,oDlgPesPro:End() }
	LOCAL aTipoPes   	:= {}
	LOCAL lChkChk    	:= .F.
	LOCAL lRet		 	:= .F.
	LOCAL aButtons   	:= {}
	LOCAL dDatAnalise	:= dDataBase
	LOCAL dDatPro		:= dDataBase
	LOCAL aDadUsr		:= PLSGETUSR()
	LOCAL aItensPac     := {}
	LOCAL cVarRead		:= ReadVar()
	LOCAL lAvsPrg		:= .f.

	PRIVATE aOpcoes   	:= {}
	PRIVATE cCadastro 	:= ""

	If ExistBlock("PLSPESPR")
		lRet := ExecBlock("PLSPESPR",.F.,.F.,{})
	Else
		aBrowPro := aClone(aVetPad)
		aTipoPes := {'1-Nome Beneficiario','2-Nro da Liberação','3-Matricula','4-Nome Social'}

		//-------------------------------------------------------------------
		//  Define dialogo...
		//-------------------------------------------------------------------
		DEFINE MSDIALOG oDlgPesPro TITLE "Pesquisa de Liberações" FROM 008.2,000 TO 030,ndColFin OF GetWndDefault()

		//-------------------------------------------------------------------
		//  Monta objeto que recebera o a chave de pesquisa  ...
		//-------------------------------------------------------------------
		oGetChave := TGet():New(040,085,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesPro,210,008 ,"@!",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
		@ 040,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 070,010 OF oDlgPesPro PIXEL COLOR CLR_HBLUE
		@ 040,315 CHECKBOX oChkChk   Var lChkChk PROMPT "Pesquisar Palavra Chave" PIXEL SIZE 080, 010 OF oDlgPesPro

		//-------------------------------------------------------------------
		//  Monta Browse...
		//-------------------------------------------------------------------
		oBrowPro := TcBrowse():New( 060, 008, 390, 075,,,, oDlgPesPro,,,,,,,,,,,, .F.,, .T.,, .F., )

		oBrowPro:AddColumn(TcColumn():New("Nro Liberação",nil,;
			nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
		oBrowPro:ACOLUMNS[1]:BDATA := { || aBrowPro[oBrowPro:nAt,4] }

		oBrowPro:AddColumn(TcColumn():New("Mat. Beneficiario",nil,;
			nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
		oBrowPro:ACOLUMNS[2]:BDATA := { || aBrowPro[oBrowPro:nAt,1] }

		oBrowPro:AddColumn(TcColumn():New("Mat. Antiga",nil,;
			nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))
		oBrowPro:ACOLUMNS[3]:BDATA := { || aBrowPro[oBrowPro:nAt,9] }

		oBrowPro:AddColumn(TcColumn():New("Nome Beneficiario",nil,;
			nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil))
		oBrowPro:ACOLUMNS[4]:BDATA := { || aBrowPro[oBrowPro:nAt,2] }

		oBrowPro:AddColumn(TcColumn():New("Nome Social",nil,;
			nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil))
		oBrowPro:ACOLUMNS[5]:BDATA := { || aBrowPro[oBrowPro:nAt,10] }

		oBrowPro:AddColumn(TcColumn():New("Plano",nil,;
			nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))
		oBrowPro:ACOLUMNS[6]:BDATA := { || aBrowPro[oBrowPro:nAt,7] }

		oBrowPro:AddColumn(TcColumn():New("Descrição",nil,;
			nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil))
		oBrowPro:ACOLUMNS[7]:BDATA := { || aBrowPro[oBrowPro:nAt,6] }

		oBrowPro:AddColumn(TcColumn():New("Nome RDA",nil,;
			nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil))
		oBrowPro:ACOLUMNS[8]:BDATA := { || aBrowPro[oBrowPro:nAt,5] }

		oBrowPro:AddColumn(TcColumn():New("Codigo RDA",nil,;
			nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))
		oBrowPro:ACOLUMNS[9]:BDATA := { || aBrowPro[oBrowPro:nAt,8] }

		//-------------------------------------------------------------------
		//  LGPD
		//-------------------------------------------------------------------
		if objCENFUNLGP:isLGPDAt()
			aCampos := {"BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT",;
				"BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG",;
				"BA1_MATANT",;
				"BE4_NOMUSR",;
				"BA3_CODPLA",;
				"BI3_DESCRI",;
				"BE4_NOMRDA",;
				"BE4_CODRDA"}
			aBls := objCENFUNLGP:getTcBrw(aCampos)

			oBrowPro:aObfuscatedCols := aBls
		endif

		oBrowPro:SetArray(aBrowPro)
		oBrowPro:BLDBLCLICK := bOK
		oTipoPes:bLostFocus := { || cSetFocus := "{ || oGetChave:Refresh(),oGetChave:SetFocus(),.T.}", &(cSetFocus) }

		//Inclui botão visualizar
		oPanel := TPanel():New(30,0,'', oDlgPesPro,, .T., .T.,, ,315,20,.T.,.T. )
		oFont := TFont():New('Times New Roman',,-18,.T.)

		@	003, 335 BUTTON STR0026 SIZE 060, 015 ACTION PL09PGRef("BE4", &("oBrowPro:aArray[oBrowPro:nAt, 4]")) OF oPanel PIXEL

		// Evento de duplo click na celula
		oBrowPro:bLDblClick := {|| PL09PGRef("BE4", &("oBrowPro:aArray[oBrowPro:nAt, 4]"))  }

		//-------------------------------------------------------------------
		//  Ativa o Dialogo...
		//-------------------------------------------------------------------
		ACTIVATE MSDIALOG oDlgPesPro ON INIT Eval({ || oGetChave:SetFocus(), EnChoiceBar(oDlgPesPro,bOK,bCanc,.F.,aButtons), oPanel:Align:=CONTROL_ALIGN_BOTTOM  }) CENTERED

		//-------------------------------------------------------------------
		//  OK
		//-------------------------------------------------------------------
		If nOpca == K_OK

			BE4->(DbSetORder(2))
			BE4->(dbSeek(xFilial("BE4")+STRTRAN(aBrowPro[nLin,4], ".", "")))
			//-------------------------------------------------------------
			// Verifica status
			//-------------------------------------------------------------
			If BE4->BE4_STATUS == "3"
				Aviso( "Atenção", "A guia nao foi autorizada." , {  "Ok"  }, 2 )
				Return lRet
			EndIf

			//-------------------------------------------------------------
			// Verifica se tem data de internacao
			//-------------------------------------------------------------
			If Empty(BE4->BE4_DATPRO)
				Aviso("Atenção","Data de internação nao informada!",{ "Ok" },2)
				Return lRet
			EndIf

			//-------------------------------------------------------------
			// Verifica se foi dado alta
			//-------------------------------------------------------------
			lAvsPrg := .F.
			If BAU->(FieldPos("BAU_GRALAU")) > 0

				BAU->(dbSetOrder(1))
				If BAU->(msSeek(xFilial("BAU")+BE4->BE4_CODRDA)) .And. BAU->BAU_GRALAU <> "1" .And. !Empty(BE4->BE4_DTALTA)
					lAvsPrg := .T.
				EndIf

			ElseIf !Empty(BE4->BE4_DTALTA)
				lAvsPrg := .T.
			EndIf

			If lAvsPrg .and. GetNewPar("MV_PLLBALT",.F.) // Parametro que define que mesmo com a data de alta poderá ser feito a inclusão de evolução no periodo.
				lAvsPrg := .F.
			Endif


			If lAvsPrg
				Aviso( "Atenção", "Data da alta já informada", { "Ok" }, 2 )
				return lRet
			EndIf

			//-------------------------------------------------------------
			// verifica se e online
			//-------------------------------------------------------------
			If BE4->( FieldPos("BE4_NRTROL") ) > 0 .And. BE4->( FieldPos("BE4_NRAOPE") ) > 0 .And. !Empty(BE4->BE4_NRTROL) .And. Empty(BE4->BE4_NRAOPE)
				Aviso( "Atenção", "Guia On-Line", { "Ok" }, 2 )
				return lRet
			EndIf

			//-------------------------------------------------------------
			// verifica se está cancelada
			//-------------------------------------------------------------
			If !(BE4->BE4_CANCEL <> '1' .And. BE4->BE4_SITUAC <> '2')
				Aviso('Atenção','Guia cancelada!',{'Ok'},2)
				Return lRet
			EndIf

			M->B4Q_GUIREF := strtran(strtran(aBrowPro[nLin,4],'-',''),'.','')
			M->B4Q_CODRDA := aBrowPro[nLin,8]
			M->B4Q_NOMRDA := aBrowPro[nLin,5]

			lRet := .T.

		EndIf

	EndIf

	//-------------------------------------------------------------------
	// Retorno da Funcao...
	//-------------------------------------------------------------------
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSAPAUTPQ

@description Pesquisa o liberacoes na base de dados
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Static Function PLSAPAUTPQ(cChave,cTipoPes,lChkChk,aBrowPro,aVetPad,oBrowPro,cVarRead)

	LOCAL aArea   	:= GetArea()
	LOCAL lRet		:= .F.
	LOCAL cSQL      := ""
	LOCAL nRecno    := 0
	LOCAL cNomUsr	:= ""
	LOCAL cNomRda	:= ""
	LOCAL cCodRda	:= ""
	LOCAL cNomSoc   := ""


	LOCAL cExp		:= Iif(AllTrim(TcGetDB()) $ "DB2/ORACLE/POSTGRES","||","+")

	DEFAULT cVarRead := ""

	If '"' $ cChave .Or. "'" $ cChave
		Aviso( "Caracter Invalido","Existem caracteres invalidos em sua pesquisa.",{ 'Ok'}, 2 )
		Return(.F.)
	EndIf

	//-------------------------------------------------------------------
	//  Limpa resultado...
	//-------------------------------------------------------------------
	aBrowPro := {}

	//-------------------------------------------------------------------
	//  Veio de uma liberacao ou foi informado participacao
	//-------------------------------------------------------------------

	//-------------------------------------------------------------------
	//  BR8
	//-------------------------------------------------------------------

	cSQL := " SELECT '2' TIPO,BE4_CODOPE" + cExp + "BE4_ANOINT" + cExp + "BE4_MESINT" + cExp + "BE4_NUMINT NUMLIB,BE4_NOMUSR NOMEUSR,BE4_OPEUSR" + cExp + "BE4_CODEMP" + cExp + "BE4_MATRIC" + cExp + "BE4_TIPREG" + cExp + "BE4_DIGITO MATRICULA, "
	cSQL += " BE4_NOMRDA NOMRED, "
	cSQL += " BE4_CODRDA CODRDA, "
	cSQL += " BA1.BA1_NOMSOC NOMSOC, "


	cSQL += " BE4.R_E_C_N_O_ AS RECNES "
	cSQL += " FROM "+ BE4->(RetSQLName("BE4")) + " BE4 "
	cSQL += " INNER JOIN "+RetSqlName("BA1")+"  BA1 ON BA1.BA1_FILIAL = BE4_FILIAL AND BA1.BA1_MATVID = BE4_MATVID AND BA1.D_E_L_E_T_ = ' ' "

	If cTipoPes == '4'
		cSQL += " AND BA1.BA1_NOMSOC LIKE  '"+cChave+"%' "
	EndIf

	cSQL += " WHERE BE4.BE4_FILIAL = '"+xFilial("BE4")+"' "

	If cTipoPes == '2' //numero
		cSQL += " AND BE4.BE4_CODOPE = '"+substr(cChave,1,4)+"' "
		cSQL += " AND BE4.BE4_ANOINT = '"+substr(cChave,5,4)+"' "
		cSQL += " AND BE4.BE4_MESINT = '"+substr(cChave,9,2)+"' "
		cSQL += " AND BE4.BE4_NUMINT = '"+substr(cChave,11,8)+"' "

	ElseIf cTipoPes == '1' //nome
		cSQL += " AND BE4.BE4_NOMUSR LIKE '"+cChave+"%'"

	ElseIf cTipoPes == '3' //matricula
		cSQL += " AND BE4.BE4_OPEUSR = '"+substr(cChave,1,4)+"' "
		cSQL += " AND BE4.BE4_CODEMP = '"+substr(cChave,5,4)+"' "
		cSQL += " AND BE4.BE4_MATRIC = '"+substr(cChave,9,6)+"' "
		cSQL += " AND BE4.BE4_TIPREG = '"+substr(cChave,15,2)+"' "
	Endif

	cSQL += "   AND BE4.BE4_CANCEL <> '1' "
	cSQL += "   AND BE4.BE4_SITUAC <> '2' "
	cSQL += "   AND BE4.D_E_L_E_T_ = ' ' "
	cSQL += "   ORDER BY NUMLIB "
	//-------------------------------------------------------------------
	//  executa a query
	//-------------------------------------------------------------------
	cSQL := ChangeQuery(cSQL)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbPes",.F.,.T.)

	//-------------------------------------------------------------------
	//  While na area de trabalho
	//-------------------------------------------------------------------
	TrbPes->( DbGoTop() )
	While !TrbPes->( Eof() )
		cTp     := TrbPes->TIPO
		cNumLib := transform(TrbPes->NUMLIB,"@R !!!!.!!!!.!!.!!!!!!!!")
		cMatric := transform(TrbPes->MATRICULA,"@R !!!!.!!!!.!!!!!!-!!")
		nRecno  := TrbPes->RECNES
		cNomUsr	:= TrbPes->NOMEUSR
		cNomRda	:= TrbPes->NOMRED
		cCodRda	:= TrbPes->CODRDA
		cNomSoc := TrbPes->NOMSOC

		cSQL := " SELECT BA1_MATANT,BA1_CODPLA,BA3_CODPLA FROM "+RetSqlName('BA1')+' BA1,'+RetSqlName('BA3')+' BA3'
		cSQL += " WHERE BA1.BA1_FILIAL =  '"+xFilial('BA1')+"'"
		cSQL += " AND BA1.BA1_CODINT = '"+substr(TrbPes->MATRICULA,1,4)+"' "
		cSQL += " AND BA1.BA1_CODEMP = '"+substr(TrbPes->MATRICULA,5,4)+"' "
		cSQL += " AND BA1.BA1_MATRIC = '"+substr(TrbPes->MATRICULA,9,6)+"' "
		cSQL += " AND BA1.BA1_TIPREG = '"+substr(TrbPes->MATRICULA,15,2)+"' "
		cSQL += " AND BA1.D_E_L_E_T_ = ' ' "
		cSQL += " AND BA3.BA3_FILIAL = BA1.BA1_FILIAL "
		cSQL += " AND BA3.BA3_CODINT = BA1.BA1_CODINT "
		cSQL += " AND BA3.BA3_CODEMP = BA1.BA1_CODEMP "
		cSQL += " AND BA3.BA3_MATRIC = BA1.BA1_MATRIC "
		cSQL += " AND BA3.D_E_L_E_T_ = ' ' "

		// Codigo do Plano.
		cSQL := ChangeQuery(cSQL)
		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSQL),"TrbPes1",.F.,.T.)

		cCodPla := IIF(EMPTY(TrbPes1->BA1_CODPLA),TrbPes1->BA3_CODPLA,TrbPes1->BA1_CODPLA)
		cMatAnt := TrbPes1->BA1_MATANT
		If BI3->( dbSeek(xFilial("BI3") + substr(TrbPes->MATRICULA,1,4) + cCodPla) )
			cNomePla := BI3->BI3_DESCRI
		Else
			cNomePla := " "
		Endif
		TrbPes1->( DbCloseArea() )
		TrbPes->( AaDd( aBrowPro,{ cMatric,cNomUsr,nRecno,cNumLib,cNomRda,cNomePla,cCodPla,cCodRda,cMatAnt,cNomSoc } ) )
		TrbPes->( DbSkip() )
	EndDo

	//-------------------------------------------------------------------
	//  fecha area
	//-------------------------------------------------------------------
	TrbPes->( DbCloseArea() )
	RestArea(aArea)

	//-------------------------------------------------------------------
	//  Testa resultado da pesquisa...
	//-------------------------------------------------------------------
	If Len(aBrowPro) == 0
		aBrowPro := aClone(aVetPad)
	EndIf

	//-------------------------------------------------------------------
	//  Atualiza browse...
	//-------------------------------------------------------------------
	oBrowPro:nAt := 1 // Configuro nAt para um 1 pois estava ocorrendo erro de "array out of bound" qdo se fazia
	// uma pesquisa mais abrangante e depois uma uma nova pesquisa menos abrangente
	// Exemplo:
	// 1a. Pesquisa: "A" - Tecle <END> para ir ao final e retorne ate a primeira linha do browse
	// (via seta para cima ou clique na primeira linha)
	// 2a. Pesquisa: "AV" - Ocorria o erro
	oBrowPro:SetArray(aBrowPro)
	oBrowPro:Refresh()
	oBrowPro:SetFocus()

	//-------------------------------------------------------------------
	//  Fim da Rotina...
	//-------------------------------------------------------------------
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA090CP

@description Muda a cor do browse de acordo com a autorizacao
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLSA090CP(nLinha,aHeaderEd,aColsEd)
	Local lDifCod	:= NIL
	LOCAL nPos 		:= PLRETPOS("BQV_IMGSTA",aHeaderEd,.F.)
	LOCAL nPosCdPad := PLRETPOS("BQV_CODPAD",aHeaderEd,.F.)
	LOCAL nPosCdPro := PLRETPOS("BQV_CODPRO",aHeaderEd,.F.)
	LOCAL nI 		:= 1
	Local nPosPad	:= 0
	Local nPosCod 	:= 0
	Local nPosQtP 	:= 0
	Local nPosQtS 	:= 0
	Local nPosSta	:= 0
	Local nAux1		:= 0
	Local nAux2		:= 0
	Local cStatus	:= ""
	LOCAL aArea 	:= getArea()
	If nPos > 0
		aColsEd[nLinha,nPos] := If(M->BQV_STATUS=="1","ENABLE","DISABLE")
	Endif
	//-----------------------------------------------------------
	// Diarias autorizadas
	//-----------------------------------------------------------
	If ValType(oBrwPro) <> 'U'

		if (nPosCdPad * nPosCdPro > 0)

			nPosPad := aScan(aHeaderEd, { |x| x[2] == AllTrim("BQV_CODPAD") } )
			nPosCod := aScan(aHeaderEd, { |x| x[2] == AllTrim("BQV_CODPRO") } )
			nPosQtP	:= aScan(aHeaderEd, { |x| x[2] == AllTrim("BQV_QTDPRO") } )
			nPosQtS	:= aScan(aHeaderEd, { |x| x[2] == AllTrim("BQV_QTDSOL") } )
			nPosSta	:= aScan(aHeaderEd, { |x| x[2] == AllTrim("BQV_STATUS") } )
			BR8->( DbSetOrder(1) )
			For nI := 1 to Len(aColsEd)
				If BR8->( MsSeek( xFilial("BR8")+Iif( !Empty(aColsEd[nI][nPosCod]), AllTrim(aColsEd[nI][nPosPad])+AllTrim(aColsEd[nI][nPosCod]), M->BQV_CODPAD+M->BQV_CODPRO) ) ) .And. BR8->BR8_TPPROC == "4"
					lDifCod := AllTrim(aColsEd[nI][nPosCod]) == Alltrim(M->BQV_CODPRO)
					cStatus := Iif(lDifCod, M->BQV_STATUS, Iif((nI == 1 .Or. Len(aColsEd) == nI) .And. Empty(AllTrim(aColsEd[nI][nPosCod])), M->BQV_STATUS, aColsEd[nI][nPosSta] ))

					If lDifCod .And. cStatus == "1"
						If nI > 1 .And. Len(aColsEd) != nI
							nAux1 += M->BQV_QTDPRO
							nAux2 += M->BQV_QTDSOL
						ElseIf nI == 1 .Or. Len(aColsEd) == nI
							nAux1 += M->BQV_QTDPRO
							nAux2 += M->BQV_QTDSOL
						EndIf
					ElseIf !lDifCod .And. cStatus == "1"
						If nI > 1 .And. Len(aColsEd) != nI
							nAux1 += aColsEd[nI][nPosQtP]
							nAux2 += aColsEd[nI][nPosQtS]
						ElseIf nI == 1 .Or. Len(aColsEd) == nI
							If Empty(AllTrim(aColsEd[nI][nPosCod]) )
								nAux1 += M->BQV_QTDPRO
								nAux2 += M->BQV_QTDSOL
							Else
								nAux1 += aColsEd[nI][nPosQtP]
								nAux2 += aColsEd[nI][nPosQtS]
							EndIf
						EndIf
					ElseIf cStatus == "0"
						If lDifCod
							If nI > 1 .And. Len(aColsEd) != nI
								nAux2 += M->BQV_QTDSOL
							ElseIf nI == 1 .Or. Len(aColsEd) == nI
								nAux2 += M->BQV_QTDSOL
							EndIf
						ElseIf !lDifCod
							If nI > 1 .And. Len(aColsEd) != nI
								nAux2 += aColsEd[nI][nPosQtS]
							ElseIf nI == 1 .Or. Len(aColsEd) == nI
								If Empty(AllTrim(aColsEd[nI][nPosCod]) )
									nAux2 += M->BQV_QTDSOL
								Else
									nAux2 += aColsEd[nI][nPosQtS]
								EndIf
							EndIf
						EndIf
					EndIf

				EndIf

			Next nI++

			M->B4Q_QTDADA := nAux1
			M->B4Q_QTDADD := nAux2

			oEncAut:oBox:Refresh()
			oEncAut:Refresh()

		endIf

	EndIf
	//-------------------------------------------------------------------
	//  Bkp do browse criticas
	//-------------------------------------------------------------------
	aMatCBkp := aClone(oBrwCri:aCols)

	restArea(aArea)
	//-------------------------------------------------------------------
	//  Fim da rotina
	//-------------------------------------------------------------------
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSCANCEL

@description Se cancelar na EditRecord retorna para o original
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Static Function PLSCANCEL()

	Local ni:=0

	//-------------------------------------------------------------------
	//  Se cancelado retorna original													 |
	//-------------------------------------------------------------------
	If ValType(aMatCBkp) <> 'U'
		If Len(aMatCBkp)>0
			oBrwCri:aCols := aClone(aMatCBkp)
			oBrwCri:oBrowse:oBrowse:nAt := Len(aMatCBkp)
		Else
			oBrwCri:aCols:={Array(Len(oBrwCri:AHEADER)+1)}


			For nI := 1 To Len(oBrwCri:AHEADER)
				cX3Campo := AlLTrim( oBrwCri:AHEADER[nI][2] )
				oBrwCri:aCols[1,nI]:=CriaVar( cX3Campo, .T. )
			Next

			oBrwCri:aCols[1,(Len(oBrwCri:AHEADER)+1)]:=.F.
			oBrwCri:OBROWSE:ForceRefresh()

		Endif
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLA09PVLDo

@description Funcao que confirma uma autorizacao retornando o seu numero
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLA09PVLDo(aRetorno,aGets,aTela,oBrwPro,oEncAut,nOpc,cTipo,oBrwCri,cNaoUsado,lNMudFase,aMatCom)
	LOCAL nI
	LOCAL nFor
	LOCAL cOpeOri
	LOCAL nOrdBA0
	LOCAL nRecBA0
	LOCAL aDadB4Q    	:= {}
	LOCAL aDadUsr    	:= PLSGETUSR()
	LOCAL aDadRDA    	:= PLSGETRDA()
	LOCAL aChaveGen  	:= {}
	LOCAL lUmVld	 	:= .F.
	LOCAL lRet 			:= .T.
	LOCAL lPossuiIt		:= .F.
	LOCAL lCompra    	:= .F.
	LOCAL lIndCli    	:= .F.
	LOCAL lConsulta 	:= (PLSISCON(oBrwPro:FieldGet("BQV_CODPAD"),oBrwPro:FieldGet("BQV_CODPRO")) .And. Len(oBrwPro:aCols) == 1)
	LOCAL nVlrCom    	:= 0
	LOCAL aRet   		:= {}
	LOCAL cChaveSE1		:= ""
	LOCAL cProcIndCli	:= ""
	LOCAL lUnimeds   	:= IF(AllTrim(GETNEWPAR("MV_PLSUNI","1"))=="1",.T.,.F.)
	LOCAL nOpc2			:= 0
	LOCAL lLote      	:= GETNEWPAR("MV_PLSLOTE",.F.)
	LOCAL lEvoluSADT 	:= GetNewPar("MV_PLEVSAD","0") == "1" .And. FunName() $ "PLSA094A"
	LOCAL aCodProcs		:={}
	LOCAL cCodUsr 		:= RetCodUsr()
	LOCAL cSenhaPLS     := ""

	DEFAULT aMatCom	:= {}
	DEFAULT cNaoUsado:= ""

	//-------------------------------------------------------------------
	//  Verifica se foi informado algum procedimento
	//-------------------------------------------------------------------
	For nI := 1 To Len(oBrwPro:aCols)
		If !oBrwPro:aCols[nI,Len(oBrwPro:aHeader)+1]
			lUmVld := .T.
		EndIf
	Next nI
	//-------------------------------------------------------------------
	//  Exibe msg se nao for informado
	//-------------------------------------------------------------------
	If !lUmVld
		Aviso(	"Atencao",; 				//"Atencao"
			"Nenhum procedimento informado!",; 				//"Nenhum procedimento informado!"
			{ "ok" }, 2 ) 		//"ok"
		Return(.F.)
	EndIf
	//-------------------------------------------------------------------
	//  Nao e preciso validacao para visualizacao
	//-------------------------------------------------------------------
	If nOpc == K_Visualizar
		aRetorno := {.T.,B4Q->B4Q_OPEMOV,B4Q->B4Q_ANOAUT,B4Q->B4Q_MESAUT,B4Q->B4Q_NUMAUT,.T.,"","",.F.,""}
		Return(aRetorno)
	Endif
	//-------------------------------------------------------------------
	//  Verifica Campos Obrigatorios
	//-------------------------------------------------------------------
	If  !Obrigatorio(oEncAut:aGets,oEncAut:aTela).Or.!oBrwPro:TudoOK()
		aRetorno := {.F.,'',.T.,"","",.F.,""}
		Return(aRetorno)
	Endif

	//-------------------------------------------------------------------
	// Verifica se existem itens ativos na getdados
	//-------------------------------------------------------------------
	For nFor := 1 To Len(oBrwPro:aCols)
		if !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1]
			lPossuiIt := .T.
			Exit
		Endif
	Next
	//-------------------------------------------------------------------
	// lPossuiIt
	//-------------------------------------------------------------------
	If !lPossuiIt
		Help(" ",1,"OBRIGAT")
		aRetorno := {.F.,'',.T.,"","",.F.,""}
		Return(aRetorno)
	Endif

	//-------------------------------------------------------------------
	//  Analiso procedimentos incompativeis e cids incompativeis...
	//-------------------------------------------------------------------
	For nFor := 1 To Len(oBrwPro:aCols)
		If (oBrwPro:FieldGet("BQV_STATUS",nFor) == "1" .And. !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1]) .or.  (cTipo =='2' .And. oBrwPro:FieldGet("BQV_AUDITO",nFor) == "1" .And. !oBrwPro:aCols[nFor,Len(oBrwPro:aHeader)+1])// quando se tratar de auditoria teremos que analisar os procedimento incompativeis

		AaDd(aCodProcs,{oBrwPro:FieldGet("BQV_CODPAD",nFor),;
			oBrwPro:FieldGet("BQV_CODPRO",nFor),;
			"",;
			"",;
			"",;
			oBrwPro:FieldGet("BQV_QTDPRO",nFor),;
			"",;
			oBrwPro:FieldGet("BQV_SEQUEN",nFor)})


	Endif
	Next

	If PLSPOSGLO(PLSINTPAD(),__aCdCri197[1],__aCdCri197[2],'1','1')
		aOldCodCri  := PLLimpCCri(.F.)
		If aOldCodCri == nil
			aOldCodCri  := {}
		Endif
		PLLimpCCri(.T.)

		If ( nOpc == K_Incluir ) .And. Len(aCodProcs) > 0
			For ni:=1 to len(aCodProcs)
				aRetFun := PLSVLDPRI(M->B4Q_CIDPRI,"1",aCodProcs,aDadUsr,M->B4Q_DATPRO,,,,aCodProcs[ni,1],aCodProcs[ni,2],aCodProcs[ni,8]) // CHAMANDO O PROCEDIMENTOS INCOMPATIVEIS

				If ! aRetFun[1]

					lForcar := BCT->(Posicione("BCT",1,xFilial("BCT")+PlsIntPad()+aRetFun[2][1][1],"BCT_PERFOR")) == "1"
					lForcou := PLSMOVCRI("2",{},aRetFun[2],lForcar)

					If  lForcar .And. lForcou
						aadd(aAutFor,{.T.,"","","","","","",0,BCS->(cCodUsr),Date(),Time()})
						Exit
					Else
						aRetorno := {.F.,'',.T.,"","",.F.,""}
						Return(aRetorno)
					Endif
				Endif
			Next ni
		Endif
		PLLimpCCri(.F.,.T.,aOldCodCri)
	Endif

	//-------------------------------------------------------------------
	//  Ponto de entrada referente ao BOPS 114367/116047
	//-------------------------------------------------------------------
	If ExistBlock("PLS09AOK")
		If !ExecBlock("PLS09AOK",.F.,.F., {nOpc,oBrwPro})
			aRetorno := {.F.,'',.T.,"","",.F.,""}
			Return(aRetorno)
		Endif
	Endif
	aRetAux := PLSXVLDCAL(dDataBase,PLSINTPAD(),.T.,"","")

	aadd(aDadB4Q,{"B4Q_MATANT",BA1->BA1_MATANT })
	aadd(aDadB4Q,{"B4Q_OPEUSR",BA1->BA1_CODINT })
	aadd(aDadB4Q,{"B4Q_CODEMP",BA1->BA1_CODEMP })
	aadd(aDadB4Q,{"B4Q_CONEMP",BA1->BA1_CONEMP })
	aadd(aDadB4Q,{"B4Q_SUBCON",BA1->BA1_SUBCON })
	aadd(aDadB4Q,{"B4Q_VERCON",BA1->BA1_VERCON })
	aadd(aDadB4Q,{"B4Q_VERSUB",BA1->BA1_VERSUB })
	aadd(aDadB4Q,{"B4Q_MATRIC",BA1->BA1_MATRIC })
	aadd(aDadB4Q,{"B4Q_TIPREG",BA1->BA1_TIPREG })
	aadd(aDadB4Q,{"B4Q_DIGITO",BA1->BA1_DIGITO })
	aadd(aDadB4Q,{"B4Q_NOMUSR",BA1->BA1_NOMUSR })
	aadd(aDadB4Q,{"B4Q_CANCEL",'0' })
	aadd(aDadB4Q,{"B4Q_ANOPAG",aRetAux[4] })
	aadd(aDadB4Q,{"B4Q_MESPAG",aRetAux[5] })

	aadd(aDadB4Q,{"B4Q_INDCLI", M->B4Q_INDCLI })
	aadd(aDadB4Q,{"B4Q_JUSOPE", M->B4Q_JUSOPE })
	aadd(aDadB4Q,{"B4Q_JUSOBS", M->B4Q_JUSOBS })

	If B4Q->( FieldPos("B4Q_ESPSOL") ) > 0
		aadd(aDadB4Q,{"B4Q_ESPSOL", M->B4Q_ESPSOL })
	EndIf

	//Caso a Operadora trabalhe com senha para prorrogação de internação, gera a senha
	If GetnewPar("MV_PLPRGSN", .F.)
		If ExistBlock("PLS090L1")
			cSenhaPLS := ExecBlock("PLS090L1",.F.,.F.,{"11",.F.,dDataBase})
		Else
			cSenhaPLS := PLSSenAut(dDataBase)
		Endif
		AaDd(aDadB4Q,{"B4Q_SENHA",cSenhaPLS})
	EndIf

	aRetorno := PLSA09PGRV(nOpc,PlsIntPad(),'BQV','B4Q','BQZ',aDadB4Q,oBrwPro:aHeader,oBrwPro:aCols,oBrwPro:aVetTrab,oBrwCri:aHeader,oBrwCri:aCols,oBrwCri:aVetTrab,;
		"11",dDataBase,aRetAux[4],aRetAux[5],aChaveGen)

Return(aRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA09PGRV

@description Gravacao
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLSA09PGRV(nOpc,cOpeMov,cAliasIte,cAliasCab,cAliasCri,aDadCab,aHeadIten,aColsIten,aVetTrIten,aCabCri,aDadCri,aTrbCri,;
		cTp,dData,cAnoPag,cMesPag,aChaveGen, pQtDiaria, lNovGAud, pQtAutDia)

	LOCAL nFor   	 := 0
	LOCAL nPos   	 := 0
	LOCAL nPos2  	 := 0
	LOCAL nPos01 	 := 0
	LOCAL nPos02 	 := 0
	LOCAL nPos03 	 := 0
	LOCAL nPos04 	 := 0
	LOCAL nPos05 	 := 0
	LOCAL nQtdSol  := 0
	LOCAL nQtdAut  := 0
	LOCAL nItensAut  := 0
	LOCAL nItensNeg  := 0
	LOCAL nAuditAut  := 0
	LOCAL nAuditNeg  := 0
	LOCAL cRetOpe    := alltrim(PLRETOPE())
	LOCAL lPortal    := If(FunName()="RPC",.t.,.f.)
	LOCAL lAuditoria := .F.
	LOCAL lGerSenha  := .F.
	LOCAL lRet       := .T.
	LOCAL cSenhaPLS  := ''
	LOCAL cStatus    := ''
	LOCAL cTpGrv	 := '1' //1=Remote Protheus;2=Web;3=POS;4=Importacao Manual
	LOCAL bOpeMov    	:= { || IF(nOpc == K_Incluir,PLSINTPAD(),&(cAliasCab+"->"+cAliasCab+"_OPEMOV")   ) }
	LOCAL bAnoAut    	:= { || IF(nOpc == K_Incluir,cAnoPag ,&(cAliasCab+"->"+cAliasCab+"_ANOAUT") ) }
	LOCAL bMesAut    	:= { || IF(nOpc == K_Incluir,cMesPag ,&(cAliasCab+"->"+cAliasCab+"_MESAUT")) }
	LOCAL bNumAut    	:= { || IF(nOpc == K_Incluir,PLNUMAUT(Eval(bOpeMov),Eval(bAnoAut),Eval(bMesAut)),&(cAliasCab+"->"+cAliasCab+"_NUMAUT")) }
	LOCAL aCpoChv    	:= { "B4Q_FILIAL","B4Q_OPEMOV","B4Q_ANOAUT","B4Q_MESAUT","B4Q_NUMAUT",'B4Q_STATUS'}
	LOCAL aDadBE2		:= {}
	LOCAL aDadBEA		:={}
	local aTmp			:= {}
	LOCAL nI 			:= 0
	LOCAL cCPFRda		:= ""

	DEFAULT pQtDiaria := 0
	DEFAULT pQtAutDia := 0
	DEFAULT lNovGAud := .F.
	DEFAULT aChaveGen := {}

	aStrucCab := &(cAliasCab+"->(DbStruct())")

	If nOpc <> K_Excluir

		nPos   := PLRETPOS(cAliasIte+"_STATUS",aHeadIten,.F.)
		nPos2  := PLRETPOS(cAliasIte+"_AUDITO",aHeadIten,.F.)
		nPos01 := PLRETPOS(cAliasIte+"_SEQUEN",aHeadIten,.F.)
		nPos02 := PLRETPOS(cAliasIte+"_QTDPRO",aHeadIten,.F.)
		nPos03 := PLRETPOS(cAliasIte+"_QTDSOL",aHeadIten,.F.)
		nPos04 := PLRETPOS(cAliasIte+"_CODPAD",aHeadIten,.F.)
		nPos05 := PLRETPOS(cAliasIte+"_CODPRO",aHeadIten,.F.)
		//-------------------------------------------------------------------
		// Verifica itens autorizados e negados e quando for diaria atualiza o cabeçalho
		//-------------------------------------------------------------------
		For nFor := 1 To Len(aColsIten)

			If ! aColsITEn[nFor,Len(aHeadIten)+1]

				If nPos > 0
					If  aColsITEn[nFor,nPos] == "1"
						nItensAut ++
					Else
						nItensNeg ++
					EndIf
				EndIf

				If nPos2 > 0
					If  aColsITEn[nFor,nPos2] == "1"
						nAuditAut ++
					Else
						nAuditNeg ++
					EndIf
				EndIf

				If nPos02 > 0 .and. nPos03 > 0 .and. nPos04 > 0 .and. nPos05 > 0

					BR8->( DbSetOrder(1) )
					If BR8->( MsSeek( xFilial("BR8")+aColsITEn[nFor,nPos04]+aColsITEn[nFor,nPos05] ) )

						If BR8->BR8_TPPROC == "4" //Se é uma diaria

							nQtdAut += aColsITEn[nFor,nPos02] //diarias autorizadas
							nQtdSol += aColsITEn[nFor,nPos03] //diarias solicitadas

						EndIf

					EndIf

				EndIf


			EndIf
		Next

		If nOpc == K_Incluir  .or. nOpc == K_Copiar

			if pQtDiaria > 0
				nQtdSol := pQtDiaria
				nQtdAut := pQtAutDia
			endif

			If nAuditAut > 0 .And.  &(cAliasCab+"->(FieldPos('"+cAliasCab+"_AUDITO"+"'))") > 0
				aadd(aDadCab,{cAliasCab+"_AUDITO","1"})
				lAuditoria := .T.
			Else
				aadd(aDadCab,{cAliasCab+"_AUDITO","0"})
				lAuditoria := .F.
			Endif
		Else
			lAuditoria := (&(cAliasCab+"->"+cAliasCab+"_AUDITO")=="1")
		Endif

		If nOpc == K_Incluir .And. lGerSenha   .or. 	nOpc == K_Copiar .and. lGerSenha
			If ExistBlock("PLS09AL1")
				cSenhaPLS := ExecBlock("PLS09AL1",.F.,.F.,{cTp,.F.,dData})
			Else
				cSenhaPLS := PLSSenAut(dData)
			Endif
			AaDd(aDadCab,{cAliasCab+"_SENHA",cSenhaPLS})
		Endif

		If Empty(cStatus) .AND. !lAuditoria
			If ( nItensNeg == 0 .And. nItensAut >= 1 )
				cStatus := "1" //Autorizada
			ElseIf ( nItensNeg > 0  .And. nItensAut >= 1 )
				cStatus := "2" //Autorizada parcialmente
			ElseIf ( nItensNeg > 0 .And. nItensAut == 0 )
				cStatus := "3" //nao autorizada
			Endif

		ElseIf lAuditoria
			cStatus := "6" //Em análise pela auditoria
		Endif
	Endif

	If nOpc <> K_Visualizar

		If Empty(Eval(bOpeMov))
			bOpeMov := { || PLSINTPAD() }
		Endif

		If cStatus == "3"
			If (nPos := Ascan(aDadCab,{|x| x[1] == cAliasCab+"_SENHA"})) == 0
				AaDd(aDadCab,{cAliasCab+"_SENHA",""})
			Else
				aDadCab[nPos,2] := ""
			Endif
		EndIf


		If nOpc <> K_Copiar
			cOpeMov := &(cAliasCab+"->"+cAliasCab+"_OPEMOV")
			cAnoAut := &(cAliasCab+"->"+cAliasCab+"_ANOAUT")
			cMesAut := &(cAliasCab+"->"+cAliasCab+"_MESAUT")
			cNumAut := &(cAliasCab+"->"+cAliasCab+"_NUMAUT")
		Endif

		If nOpc <> K_Excluir
			cOpeMov := Eval(bOpeMov)
			cAnoAut := Eval(bAnoAut)
			cMesAut := Eval(bMesAut)
			If nOpc <> K_Copiar
				cNumAut := PlNewNAut(cAliasCab,cOpeMov,cAnoAut,cMesAut,nOpc)
			Endif
		EndIf

		If nOpc == K_Copiar
			cAnoAut := cAnoPag
			cMesAut := cMesPag
			cNumAut := PlNewNAut(cAliasCab,cOpeMov,cAnoAut,cMesAut,nOpc)
		Endif

		// O PlNewNAut deve estar fora do Begin Transaction para
		// evitar que o sistema utilize a mesma numeracao para
		// guias distintas
		Begin Transaction

			nPos   := PLRETPOS(cAliasIte+"_STATUS",aHeadIten,.F.)
			nPos2  := PLRETPOS(cAliasIte+"_AUDITO",aHeadIten,.F.)
			nPos01 := PLRETPOS(cAliasIte+"_SEQUEN",aHeadIten,.F.)
			nPos02 := PLRETPOS(cAliasIte+"_QTDPRO",aHeadIten,.F.)
			nPos03 := PLRETPOS(cAliasIte+"_CODPAD",aHeadIten,.F.)
			nPos04 := PLRETPOS(cAliasIte+"_CODPRO",aHeadIten,.F.)

			If nOpc == K_Incluir .or. 	nOpc == K_Copiar

				If nAuditAut > 0 .And.  &(cAliasCab+"->(FieldPos('"+cAliasCab+"_AUDITO"+"'))") > 0
					aadd(aDadCab,{cAliasCab+"_AUDITO","1"})
					lAuditoria := .T.
				Else
					aadd(aDadCab,{cAliasCab+"_AUDITO","0"})
					lAuditoria := .F.
				Endif
			Else
				lAuditoria := (&(cAliasCab+"->"+cAliasCab+"_AUDITO")=="1")
			Endif

			//-------------------------------------------------------------------
			//  Exclusao
			//-------------------------------------------------------------------
			If nOpc == K_Excluir

				cChaveAut := &(cAliasCab+"->("+cAliasCab+"_OPEMOV+"+cAliasCab+"_ANOAUT+"+cAliasCab+"_MESAUT+"+cAliasCab+"_NUMAUT)")

				If PLSALIASEXI("B43")
					B43->(DbSetOrder(2))//B43_FILIAL + B43_OPEMOV + B43_ANOAUT + B43_MESAUT + B43_NUMAUT + B43_SEQUEN
					While B43->(MsSeek(xFilial("B43")+cChaveAut))
						B43->(RecLock("B43",.F.))
						B43->(DbDelete())
						B43->(MsUnLock())
					Enddo
				Endif

				BEA->(DbSetOrder(1))
				While BEA->(MsSeek(xFilial("BEA")+cChaveAut))
					BEA->(RecLock("BEA",.F.))
					BEA->(DbDelete())
					BEA->(MsUnLock())
				Enddo

				BE2->(DbSetOrder(1))
				While BE2->(MsSeek(xFilial("BE2")+cChaveAut))
					BE2->(RecLock("BE2",.F.))
					BE2->(DbDelete())
					BE2->(MsUnLock())
				Enddo

			Endif


			//gravacao do cabecalho
			B4Q->( RecLock("B4Q",(nOpc == K_Incluir) .or. nOpc == K_Copiar ) )
			If nOpc <> K_Excluir
				For nFor := 1 To Len(aDadCab)
					If AsCan(aCpoChv,{|x| x == aDadCab[nFor,1]}) == 0 .And. &( "B4Q->( FieldPos('"+aDadCab[nFor,1]+"') )" ) > 0
						&("B4Q->"+aDadCab[nFor,1]) := aDadCab[nFor,2]
					Endif
				Next
				If nOpc == K_Incluir .or.  nOpc == K_Copiar
					B4Q->B4Q_FILIAL := xFilial("B4Q")
					B4Q->B4Q_OPEMOV := cOpeMov
					B4Q->B4Q_ANOAUT := cAnoAut
					B4Q->B4Q_MESAUT := cMesAut
					B4Q->B4Q_NUMAUT := cNumAut
					B4Q->B4Q_STATUS := cStatus
					If !lNovGAud
						B4Q->B4Q_QTDADD := nQtdSol
						B4Q->B4Q_QTDADA := nQtdAut
					EndIf
					SX3->(DbsetOrder(1))
					If SX3->( MsSeek('B4Q') )
						SX3->( DbSkip() )
						While ! SX3->( Eof() ) .And. SX3->X3_ARQUIVO == 'B4Q'
							cFldTrbB4Q := SX3->X3_CAMPO
							If AsCan(aCpoChv  ,{|x| alltrim(x)		== alltrim(cFldTrbB4Q)})	== 0 .And. ;
									AsCan(aDadCab  ,{|x| alltrim(x[1])	== alltrim(cFldTrbB4Q)})	== 0 .And. ;
									AsCan(aStrucCab,{|x| alltrim(x[1])	== alltrim(cFldTrbB4Q)})	 > 0 .And. ;
									ValType("M->"+AllTrim(SX3->X3_CAMPO)) <> "U" .And. ValType(cAliasCab+"->"+cFldTrbB4Q) <> "U"

								&(cAliasCab+"->"+cFldTrbB4Q) := &("M->"+AllTrim(SX3->X3_CAMPO))

							Endif
							SX3->(DbSkip())
						Enddo
					Endif
					B4Q->B4Q_DATPRO := DDATABASE //gravo a data atual nesse campo

					If B4Q->( FieldPos("B4Q_STTISS") ) > 0
						B4Q->B4Q_STTISS := PLSANLSTIG(cStatus)
					EndIf

					//gravacao da descricao Operador
					If(B4Q->(FieldPos("B4Q_DESOPE")))>0
						if ((empty(PLRETOPE())) .And. (lPortal))
							B4Q->B4Q_DESOPE := "ELETRONICA"
						else
							B4Q->B4Q_DESOPE := cRetOpe
						EndIf
					EndIf
				Endif
			Else
				B4Q->( DbDelete() )
			Endif
			B4Q->( MsUnLock() )

			//gravo itens
			For nFor := 1 To Len(aStrucCab)
				cCpoAux := cAliasIte+"_"+Subs(aStrucCab[nFor,1],5,10)
				If (nPos := Ascan(aChaveGen,{|x| x[1] == cCpoAux})) == 0 .And. ValType(cAliasIte+"->"+cCpoAux) <> "U" .and. aStrucCab[nFor,2] <> 'N'
					aadd(aChaveGen,{cCpoAux,&(cAliasCab+"->"+cAliasCab+"_"+Subs(cCpoAux,5,10))})
				Endif
			Next

			If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_CODOPE"})) == 0
				aadd(aChaveGen,{cAliasIte+"_CODOPE", &(cAliasCab+"->"+cAliasCab+"_OPEMOV") })
			Else
				aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_OPEMOV")
			EndIf

			If nOpc == K_Copiar

				If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_ANOINT"})) == 0
					aadd(aChaveGen,{cAliasIte+"_ANOINT",cAnoAut})
				Else
					aChaveGen[nPos,2] := cAnoAut
				EndIf

				If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_MESINT"})) == 0
					aadd(aChaveGen,{cAliasIte+"_MESINT",cMesAut})
				Else
					aChaveGen[nPos,2] := cMesAut
				EndIf

				If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_NUMINT"})) == 0
					aadd(aChaveGen,{cAliasIte+"_NUMINT",cNumAut})
				else
					aChaveGen[nPos,2] := cNumAut
				EndIf
			Else
				If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_ANOINT"})) == 0
					aadd(aChaveGen,{cAliasIte+"_ANOINT",&(cAliasCab+"->"+cAliasCab+"_ANOAUT")})
				Else
					aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_ANOAUT")
				EndIf

				If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_MESINT"})) == 0
					aadd(aChaveGen,{cAliasIte+"_MESINT",&(cAliasCab+"->"+cAliasCab+"_MESAUT")})
				Else
					aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_MESAUT")
				EndIf

				If (nPos := Ascan(aChaveGen,{|x| x[1] == cAliasIte+"_NUMINT"})) == 0
					aadd(aChaveGen,{cAliasIte+"_NUMINT",&(cAliasCab+"->"+cAliasCab+"_NUMAUT")})
				else
					aChaveGen[nPos,2] := &(cAliasCab+"->"+cAliasCab+"_NUMAUT")
				EndIf

			Endif

			PLUPTCOLS(cAliasIte,aColsIten,aHeadIten,aVetTrIten,If(nOpc=K_Copiar,3,nOpc),aChaveGen)

			//gravo criticas
			If Len(aDadCri) > 0
				//tiro as criticas sem descricao
				PLSAJUMAT(aCabCri,aDadCri,cAliasCri+"_DESGLO")

				aChaveGen := {}
				aadd(aChaveGen,{cAliasCri+"_CODOPE",&(cAliasCab+"->"+cAliasCab+"_OPEMOV")})
				aadd(aChaveGen,{cAliasCri+"_ANOINT",&(cAliasCab+"->"+cAliasCab+"_ANOAUT")})
				aadd(aChaveGen,{cAliasCri+"_MESINT",&(cAliasCab+"->"+cAliasCab+"_MESAUT")})
				aadd(aChaveGen,{cAliasCri+"_NUMINT",&(cAliasCab+"->"+cAliasCab+"_NUMAUT")})

				BQZ->(DbSetOrder(1))//BQZ_FILIAL+BQZ_OPEMOV+BQZ_ANOAUT+BQZ_MESAUT+BQZ_NUMAUT+BQZ_SEQUEN
				If BQZ->(DbSeek(xFilial("BQZ")+&(cAliasCab+"->"+cAliasCab+"_OPEMOV")+;
						&(cAliasCab+"->"+cAliasCab+"_ANOAUT")+;
						&(cAliasCab+"->"+cAliasCab+"_MESAUT")+;
						&(cAliasCab+"->"+cAliasCab+"_NUMAUT")))

					cKeyCri := BQZ->(BQZ_FILIAL+BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT)
					While !BQZ->(Eof()) .and. xFilial("BQZ")+BQZ->(BQZ_CODOPE+BQZ_ANOINT+BQZ_MESINT+BQZ_NUMINT) == cKeyCri

						BQZ->(RecLock("BQZ",.F.))
						BQZ->(DbDelete())
						BQZ->(MsUnLock())

						BQZ->(DbSkip())
					EndDo
				Endif

				If Len(aDadCri)>0
					PLUPTCOLS(cAliasCri,aDadCri,aCabCri,aTrbCri,nOpc,aChaveGen,.T.)
				EndIf
			EndIf

			//Historico de autorizacao forcada
			If ValType(aAutForAnx) == "A" .And. Len(aAutForAnx) > 0
				PLSFORHIS(nOpc,"B",cAliasCab,aAutForAnx,aCodCriHis)
			EndIf



			If nOpc == K_Incluir  .or. nOpc == K_Copiar
				If lAuditoria
					//-------------------------------------------------------------------
					//  manda para a auditoria
					//-------------------------------------------------------------------
					o790C := PLSA790C():New(.T.)
					o790C:SetAuditoria(lAuditoria,.f.,.f.,.f.,.f.,aDadCri,aCabCri,__aCdCri187[1],"0","BQZ",aColsIten,aHeadIten,"BQV", .F., .T.)
					o790C:Destroy()
				EndIf
			EndIf

			If K_Excluir == nOpc
				B43->(DbSetOrder(2))//B43_FILIAL + B43_OPEMOV + B43_ANOAUT + B43_MESAUT + B43_NUMAUT + B43_SEQUEN
				While B43->(MsSeek(xFilial("B43")+cChaveAut))
					B43->(RecLock("B43",.F.))
					B43->(DbDelete())
					B43->(MsUnLock())
				Enddo
			EndIf

			//Atualiza diarias na BE4
			PUPDIAINT(nOpc)

		End Transaction
		//B4Q->(dbSetOrder(1))
		//B4Q->(MsSeek(xFilial("B4Q") + cOpeMov + cAnoAut + cMesAut + cNumAut))

		if(nOpc == K_Incluir .or. nOpc == K_Copiar)
			BE4->(dbSetOrder(2))
			BE4->(MsSeek(xFilial("BE4") + B4Q->B4Q_GUIREF))
			BA1->(dbSetOrder(2))
			BA1->(MsSeek(xFilial("BA1") + B4Q->(B4Q_OPEUSR+B4Q_CODEMP+B4Q_MATRIC+B4Q_TIPREG+B4Q_DIGITO)))
			AaDd(aDadBEA,{"BEA_FILIAL",xFilial("BEA")})
			AaDd(aDadBEA,{"BEA_OPEMOV",B4Q->B4Q_OPEMOV})
			AaDd(aDadBEA,{"BEA_CANCEL",'0'})
			AaDd(aDadBEA,{"BEA_AUDITO",If(lAuditoria,'1','0')})
			AaDd(aDadBEA,{"BEA_TIPADM"	,'1'})
			AaDd(aDadBEA,{"BEA_TIPO"		,'3'})
			AaDd(aDadBEA,{"BEA_ANOAUT"	,B4Q->B4Q_ANOAUT})
			AaDd(aDadBEA,{"BEA_MESAUT"	,B4Q->B4Q_MESAUT})
			AaDd(aDadBEA,{"BEA_NUMAUT"	,B4Q->B4Q_NUMAUT})
			AaDd(aDadBEA,{"BEA_USUOPE"	,RetCodUsr()})
			AaDd(aDadBEA,{"BEA_OPERDA"	,B4Q->B4Q_OPEMOV})
			AaDd(aDadBEA,{"BEA_CODRDA"	,B4Q->B4Q_CODRDA})
			AaDd(aDadBEA,{"BEA_NOMRDA"	,B4Q->B4Q_NOMRDA})
			AaDd(aDadBEA,{"BEA_NOMUSR"	,B4Q->B4Q_NOMUSR})
			AaDd(aDadBEA,{"BEA_CODLOC"	,BE4->BE4_CODLOC})
			AaDd(aDadBEA,{"BEA_LOCAL"	,BE4->BE4_LOCAL})
			AaDd(aDadBEA,{"BEA_DESLOC"	,Posicione("BB8",1,xFilial("BB8")+B4Q->B4Q_CODRDA+B4Q->B4Q_OPEMOV+BE4->BE4_CODLOC+BE4->BE4_LOCAL, "BB8_DESLOC" )})
			aadd(aDadBEA,{"BEA_ENDLOC"	,AllTrim(BB8->BB8_END)+"+"+AllTrim(BB8->BB8_NR_END)+"-"+AllTrim(BB8->BB8_COMEND)+"-"+AllTrim(BB8->BB8_BAIRRO)})
			AaDd(aDadBEA,{"BEA_CODESP"	,BE4->BE4_CODESP})
			aadd(aDadBEA,{"BEA_DESESP"	,BAQ->(Posicione("BAQ",1,xFilial("BAQ")+B4Q->B4Q_OPEMOV+BE4->BE4_CODESP,"BAQ_DESCRI"))})
			AaDd(aDadBEA,{"BEA_DATPRO"	,B4Q->B4Q_DATPRO})
			AaDd(aDadBEA,{"BEA_HORPRO"	,BE4->BE4_HORPRO})
			AaDd(aDadBEA,{"BEA_HHDIGI"	,TIME()})
			AaDd(aDadBEA,{"BEA_OPEUSR"	,B4Q->B4Q_OPEMOV})
			AaDd(aDadBEA,{"BEA_CODEMP"	,B4Q->B4Q_CODEMP})
			AaDd(aDadBEA,{"BEA_MATRIC"	,B4Q->B4Q_MATRIC})
			AaDd(aDadBEA,{"BEA_TIPREG"	,B4Q->B4Q_TIPREG})
			AaDd(aDadBEA,{"BEA_MATVID"	,BE4->BE4_MATVID})
			AaDd(aDadBEA,{"BEA_OPEINT"	,BE4->BE4_CODOPE})
			AaDd(aDadBEA,{"BEA_ANOINT"	,BE4->BE4_ANOINT})
			AaDd(aDadBEA,{"BEA_MESINT"	,BE4->BE4_MESINT})
			AaDd(aDadBEA,{"BEA_NUMINT"	,BE4->BE4_NUMINT})

			AaDd(aDadBEA,{"BEA_SIGLA"	,B4Q->B4Q_SIGLA})
			AaDd(aDadBEA,{"BEA_ESTSOL"	,B4Q->B4Q_ESTSOL})
			AaDd(aDadBEA,{"BEA_REGSOL"	,B4Q->B4Q_REGSOL})
			AaDd(aDadBEA,{"BEA_NOMSOL"	,B4Q->B4Q_NOMSOL})
			AaDd(aDadBEA,{"BEA_CDPFSO"	,B4Q->B4Q_CDPFSO})
			AaDd(aDadBEA,{"BEA_NOMTIT"	,B4Q->B4Q_NOMUSR})
			AaDd(aDadBEA,{"BEA_ATEAMB"	,'1'})
			AaDd(aDadBEA,{"BEA_ANOPAG"	,B4Q->B4Q_AnoAut})
			AaDd(aDadBEA,{"BEA_MESPAG"	,cMesAut})
			AaDd(aDadBEA,{"BEA_OPEPEG"	,B4Q->B4Q_OPEMOV})
			AaDd(aDadBEA,{"BEA_DTDIGI"	,date()})
			AaDd(aDadBEA,{"BEA_CONEMP"	,B4Q->B4Q_CONEMP})
			AaDd(aDadBEA,{"BEA_VERCON"	,B4Q->B4Q_VERCON})
			AaDd(aDadBEA,{"BEA_SUBCON"	,B4Q->B4Q_SUBCON})
			AaDd(aDadBEA,{"BEA_VERSUB"	,B4Q->B4Q_VERSUB})
			AaDd(aDadBEA,{"BEA_DIGITO"	,B4Q->B4Q_DIGITO})
			AaDd(aDadBEA,{"BEA_CPFUSR"	,BA1->BA1_CPFUSR})
			AaDd(aDadBEA,{"BEA_DATNAS"	,BE4->BE4_DATNAS})
			AaDd(aDadBEA,{"BEA_MATANT"	,B4Q->B4Q_MATANT})
			AaDd(aDadBEA,{"BEA_MATUSA"	,'2'})
			AaDd(aDadBEA,{"BEA_SENHA"	,B4Q->B4Q_SENHA})
			AaDd(aDadBEA,{"BEA_OPESOL"	,B4Q->B4Q_OPESOL})
			AaDd(aDadBEA,{"BEA_GUIACO"	,'0'})
			AaDd(aDadBEA,{"BEA_PACOTE"	,'0'})
			AaDd(aDadBEA,{"BEA_STATUS"	,B4Q->B4Q_STATUS })
			AaDd(aDadBEA,{"BEA_TIPUSR"	,'99'})
			AaDd(aDadBEA,{"BEA_ORIMOV"	,'2'})
			AaDd(aDadBEA,{"BEA_TIPGUI"	,'11'})
			AaDd(aDadBEA,{"BEA_ORIGEM"	,'2'})
			AaDd(aDadBEA,{"BEA_LIBERA"	,'1'})
			AaDd(aDadBEA,{"BEA_TPGRV"	,If(FunName()="RPC",'2','1')})
			AaDd(aDadBEA,{"BEA_TIPPRE"	,BE4->BE4_TIPPRE})
			AaDd(aDadBEA,{"BEA_GUIIMP"	,'0'})
			AaDd(aDadBEA,{"BEA_OPEEXE"	,B4Q->B4Q_OPEMOV})
			AaDd(aDadBEA,{"BEA_VIACAR"	,0})
			AaDd(aDadBEA,{"BEA_COMUNI"	,'0'})
			AaDd(aDadBEA,{"BEA_TRACON"	,'0'})
			AaDd(aDadBEA,{"BEA_PROATE"	,B4Q->B4Q_PROATE })
			If B4Q->( FieldPos("B4Q_ESPSOL") ) > 0
				AaDd(aDadBEA,{"BEA_ESPSOL"	,B4Q->B4Q_ESPSOL})
			Else
				AaDd(aDadBEA,{"BEA_ESPSOL"	,BE4->BE4_ESPSOL})
			EndIf
			AaDd(aDadBEA,{"BEA_CODLDP"	,BE4->BE4_CODLDP})
			AaDd(aDadBEA,{"BEA_STTISS"	,B4Q->B4Q_STTISS})

			BEA->(RecLock("BEA",.T.))
			For nFor := 1 To Len(aDadBEA)
				If  &( "BEA->( FieldPos('"+aDadBEA[nFor,1]+"') )" ) > 0
					&("BEA->"+aDadBEA[nFor,1]) := aDadBEA[nFor,2]
				Endif
			Next
			BEA->(MsUnLock())

			// fim da Gravacao da BEA

			//gravação BE2 Saldo, caso o parâmetro MV_PLPRISL estiver ativo.

			BQV->( DbSetOrder(1) ) //BQV_FILIAL + BQV_CODOPE + BQV_ANOIN + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN
			BQV->(dbgotop())
			if BQV->( MsSeek( xFilial("BQV")+B4Q->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT) ) )

				BAU->(DbSetOrder(1))
				iif (BAU->(MsSeek(xFilial("BAU")+B4Q->B4Q_CODRDA)) .And. BAU->BAU_TIPPE == 'F',cCPFRda := BAU->BAU_CPFCGC,cCPFRda := "")

				While !BQV->(Eof()) .And. B4Q->(B4Q_FILIAL+B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT) == BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT)
					aDadBE2 := {}
					AaDd(aDadBE2,{"BE2_FILIAL", xFilial("BE2")})
					aadd(aDadBE2,{"BE2_SEQUEN", BQV->BQV_SEQUEN})
					aadd(aDadBE2,{"BE2_CODPAD", BQV->BQV_CODPAD})
					aadd(aDadBE2,{"BE2_CODPRO", BQV->BQV_CODPRO})
					aadd(aDadBE2,{"BE2_DESPRO", BQV->BQV_DESPRO})
					aadd(aDadBE2,{"BE2_QTDSOL", BQV->BQV_QTDSOL})
					aadd(aDadBE2,{"BE2_QTDPRO", BQV->BQV_QTDPRO})
					aadd(aDadBE2,{"BE2_DATPRO", BQV->BQV_DATPRO})
					aadd(aDadBE2,{"BE2_HORPRO", BQV->BQV_HORPRO})
					aadd(aDadBE2,{"BE2_NIVAUT", BQV->BQV_NIVAUT})
					aadd(aDadBE2,{"BE2_NIVCRI", BQV->BQV_NIVCRI})
					aadd(aDadBE2,{"BE2_SALDO",  BQV->BQV_QTDPRO})
					aadd(aDadBE2,{"BE2_AUDITO", BQV->BQV_AUDITO})
					aadd(aDadBE2,{"BE2_STATUS", BQV->BQV_STATUS})
					aadd(aDadBE2,{"BE2_TPPROC", Posicione("BR8",1,xFilial("BR8")+BQV->(BQV_CODPAD+BQV_CODPRO),"BR8_TPPROC")})
					aadd(aDadBE2,{"BE2_CDPFSO", B4Q->B4Q_CDPFSO})
					aadd(aDadBE2,{"BE2_NOMUSR", B4Q->B4Q_NOMUSR})
					aadd(aDadBE2,{"BE2_DESLOC", Posicione("BB8",1,xFilial("BB8")+B4Q->B4Q_CODRDA+cOpeMov+BE4->BE4_CODLOC+BE4->BE4_LOCAL, "BB8_DESLOC" )})
					aadd(aDadBE2,{"BE2_ENDLOC", AllTrim(BB8->BB8_END)+"+"+AllTrim(BB8->BB8_NR_END)+"-"+AllTrim(BB8->BB8_COMEND)+"-"+AllTrim(BB8->BB8_BAIRRO)})
					aadd(aDadBE2,{"BE2_ATEAMB", '1'})
					aadd(aDadBE2,{"BE2_CID", BE4->BE4_CID})
					aadd(aDadBE2,{"BE2_DATNAS", BE4->BE4_DATNAS})
					aadd(aDadBE2,{"BE2_CPFRDA", cCPFRda})
					aadd(aDadBE2,{"BE2_GUIACO", '0'})
					aadd(aDadBE2,{"BE2_NUMAUT", BQV->BQV_NUMINT})
					aadd(aDadBE2,{"BE2_MESAUT", BQV->BQV_MESINT})
					aadd(aDadBE2,{"BE2_ANOAUT", BQV->BQV_ANOINT})
					aadd(aDadBE2,{"BE2_OPEMOV", BQV->BQV_CODOPE})
					AaDd(aDadBE2,{"BE2_TIPGUI",'11'})
					aadd(aDadBE2,{"BE2_NRAOPE", BQV->BQV_NRAOPE})
					aadd(aDadBE2,{"BE2_OPEUSR", BQV->BQV_OPEUSR})
					aadd(aDadBE2,{"BE2_CODEMP", BQV->BQV_CODEMP})
					aadd(aDadBE2,{"BE2_MATRIC", BQV->BQV_MATRIC})
					aadd(aDadBE2,{"BE2_TIPREG", BQV->BQV_TIPREG})
					aadd(aDadBE2,{"BE2_CONEMP", B4Q->B4Q_CONEMP})
					aadd(aDadBE2,{"BE2_VERCON", B4Q->B4Q_VERCON})
					aadd(aDadBE2,{"BE2_SUBCON", B4Q->B4Q_SUBCON})
					aadd(aDadBE2,{"BE2_VERSUB", B4Q->B4Q_VERSUB})
					aadd(aDadBE2,{"BE2_MATVID", BE4->BE4_MATVID})
					aadd(aDadBE2,{"BE2_DIGITO", B4Q->B4Q_DIGITO})
					aadd(aDadBE2,{"BE2_MATANT", B4Q->B4Q_MATANT})
					aadd(aDadBE2,{"BE2_OPERDA", B4Q->B4Q_OPEMOV})
					aadd(aDadBE2,{"BE2_CODRDA", B4Q->B4Q_CODRDA})
					aadd(aDadBE2,{"BE2_CODLOC", BE4->BE4_CODLOC})
					aadd(aDadBE2,{"BE2_LOCAL ", BE4->BE4_LOCAL})
					aadd(aDadBE2,{"BE2_CODESP", BE4->BE4_CODESP})
					aAdd(aDadBE2,{"BE2_ TIPO ", '3'})
					AaDd(aDadBE2,{"BEA_OPERDA"	,B4Q->B4Q_OPEMOV})
					AaDd(aDadBE2,{"BEA_ANOINT"	,BE4->BE4_ANOINT})
					AaDd(aDadBE2,{"BEA_MESINT"	,BE4->BE4_MESINT})
					AaDd(aDadBE2,{"BEA_NUMINT"	,BE4->BE4_NUMINT})
					aadd(aTmp, aDadBE2)
					BQV->( DbSkip() )
				EndDo
				For nFor := 1 To Len(aTmp)
					BE2->(RecLock("BE2",.T.))
					for nI := 1 To Len(aTmp[nFor])
						If  &( "BE2->( FieldPos('"+aTmp[nFor,nI,1]+"') )" ) > 0
							&("BE2->"+aTmp[nFor,nI,1]) := aTmp[nFor,nI,2]
						Endif
					next
					BE2->(MsUnLock())
				Next
			Endif
		EndIf


		If nOpc == K_Incluir
			// Icluindo Pacote caso Houver
			BEA->(DbSetOrder(1))
			If BEA->(MsSeek(xFilial("BEA")+ &(cAliasCab+"->"+cAliasCab+"_OPEMOV")+ &(cAliasCab+"->"+cAliasCab+"_ANOAUT")+ &(cAliasCab+"->"+cAliasCab+"_MESAUT")+ &(cAliasCab+"->"+cAliasCab+"_NUMAUT")))
				//  O array aDadB43 é preenchido pela função PlAliPac tendo itens nesse arrat é um pacote e temos que prrencher b43
				If Len(aDadB43) > 0
					B43->(DbSetOrder(1))
					aChaveGen := {}
					aadd(aChaveGen,{"B43_CODOPE",BEA->BEA_OPEMOV})
					aadd(aChaveGen,{"B43_CODLDP",BEA->BEA_CODLDP})
					aadd(aChaveGen,{"B43_CODPEG",BEA->BEA_CODPEG})
					aadd(aChaveGen,{"B43_NUMERO",BEA->BEA_NUMGUI})
					aadd(aChaveGen,{"B43_OPEMOV",BEA->BEA_OPEMOV})
					aadd(aChaveGen,{"B43_ANOAUT",BEA->BEA_ANOAUT})
					aadd(aChaveGen,{"B43_MESAUT",BEA->BEA_MESAUT})
					aadd(aChaveGen,{"B43_NUMAUT",BEA->BEA_NUMAUT})

					PLUPTCOLS("B43",aDadB43,aCabB43,aTrbB43,nOpc,aChaveGen,.T.)
				EndIf

			EndIf
		Endif
	Endif

Return({lRet,&(cAliasCab+"->"+cAliasCab+"_OPEMOV"),&(cAliasCab+"->"+cAliasCab+"_ANOAUT"),&(cAliasCab+"->"+cAliasCab+"_MESAUT"),;
	&(cAliasCab+"->"+cAliasCab+"_NUMAUT"),NIL,NIL,NIL,lAuditoria,cStatus,NIL,&(cAliasCab+"->"+cAliasCab+"_SENHA")})

//-------------------------------------------------------------------
/*/{Protheus.doc} A090FinaA

@description Exibir dados da autorizacao/liberacao efetuada
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Static Function A090FinaA(cOpeMov,cAnoAut,cMesAut,cNumAut,cCodOpeG,oBrwPro,lAuditoria)
	LOCAL cNomUser
	LOCAL cSIM
	LOCAL cNAO
	LOCAL cNomRDA
	LOCAL oDlg
	LOCAL cDescSimb := GetNewPar("MV_SIMB1","R$")
	LOCAL oFontNum
	LOCAL oFontAutor
	LOCAL oFontTit
	LOCAL oSay
	LOCAL nItensSIM := 0
	LOCAL nItensNAO := 0
	LOCAL nVlrPF
	LOCAL nVlrBPF
	LOCAL nVlrTPF
	LOCAL nVlrTAD
	LOCAL nPercPF
	LOCAL aVlrPF
	LOCAL nColAut
	LOCAL oBot01,oBot02,oBot03
	LOCAL cMsgObs := ""
	//-------------------------------------------------------------------
	//  Define fontes utilizadas somente nesta funcao...
	//-------------------------------------------------------------------
	DEFINE FONT oFontNum NAME "Arial" SIZE 000,-016 BOLD
	DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-019 BOLD
	DEFINE FONT oFontTit NAME "Arial" SIZE 000,-011 BOLD

	If lAuditoria
		Aviso( "Auditoria", ; //"Auditoria"
			"Esta guia foi gravada e esta sendo analisada pela auditoria.",; //"Esta guia foi gravada e esta sendo analisada pela auditoria."
			{ 'Ok' }, 2 )
		Return
	Endif
	//-------------------------------------------------------------------
	//  ponto de entrada Bops 126389 - Inserção de Msg de Observação
	//-------------------------------------------------------------------
	If ExistBlock("PLS09AF2")
		cMsgObs := ExecBlock("PLS09AF2",.F.,.F.,{cOpeMov,cAnoAut,cMesAut,cNumAut,cCodOpeG,oBrwPro,lAuditoria})
	Endif
	//-------------------------------------------------------------------
	//  Mostra Resumo da Autorizacao...
	//-------------------------------------------------------------------
	DEFINE MSDIALOG oDlg TITLE "Dados da prorrogação de internação" FROM 009,000 TO 024,070 OF GetWndDefault()

	nColAut := PLRETPOS("BQV_IMGSTA",oBrwPro:aHeader)
	aEval(oBrwPro:aCols,{ |aVet|  IF(!aVet[Len(oBrwPro:aHeader)+1],If(AllTrim(aVet[nColAut])=="ENABLE",nItensSIM++,nItensNAO++),nil) })

	cNomUser := TransForm(M->B4Q_USUARI,PesqPict("BE1","BE1_USUARI"))+" - "+M->B4Q_NOMUSR
	cNomRDA  := M->B4Q_NOMSOL
	cSIM     := StrZero(nItensSIM,2)
	cNAO     := StrZero(nItensNAO,2)

	oBot02 := SButton():New(097, 035, 6, {|| Pergunte("PLA090",.F.),lImpGuiDir:=(mv_par01==1),Eval(bImpGuia),If(lImpGuiDir,oDlg:End(),nil) },,.T.)
	oBot02:cToolTip := "Imprimir a prorrogação de internação"

	oBot01 := SButton():New(097, 005, 1, {|| oDlg:End() },,.T.)
	oBot01:cToolTip := "Fechar Tela"

	oBot03 := SButton():New(097, 065, 5, {|| Pergunte("PLA090",.T.),lImpGuiDir:=(mv_par01==1) },,.T.)
	oBot03:cToolTip := "Parametros Impressao"

	@ 007,005 SAY oSay PROMPT 'Prorrogação'+" "+" Número   "  SIZE 220,010 OF oDlg PIXEL FONT oFontNum
	@ 006,095 SAY oSay PROMPT cOpeMov+"."+cAnoAut+"."+cMesAut+"."+cNumAut SIZE 220,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_HRED

	If nItensSIM > 0 .And. ! Empty(B4Q->B4Q_SENHA)
		@ 005,230 SAY oSay PROMPT "Senha"  SIZE 220,010 OF oDlg PIXEL
		@ 014,150 SAY oSay PROMPT "[ " + AllTrim(B4Q->B4Q_SENHA) +" ]" SIZE 220,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_HRED
	Endif

	@ 025,005 SAY oSay PROMPT "Usuario              "  SIZE 220,010 OF oDlg PIXEL
	@ 025,065 MSGET cNomUser                           SIZE 205,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

	@ 043,005 SAY oSay PROMPT "Solicitante"  SIZE 220,010 OF oDlg PIXEL
	@ 043,065 MSGET cNomRDA                           SIZE 205,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

	@ 061,005 SAY oSay PROMPT "Itens Autorizados"  SIZE 220,010 OF oDlg PIXEL
	@ 061,065 MSGET cSIM                               SIZE 004,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

	@ 079,005 SAY oSay PROMPT "Itens NAO Autorizados"  SIZE 220,010 OF oDlg PIXEL
	@ 079,065 MSGET cNAO                               SIZE 004,010 OF oDlg WHEN .F. PIXEL FONT oFontTit COLOR CLR_HBLUE

	If !Empty(cMsgObs)
		@ 079,082 SAY oSay PROMPT SubStr(cMsgObs,1,60) SIZE 220,010 OF oDlg PIXEL COLOR CLR_HRED
	EndIf

	ACTIVATE MSDIALOG oDlg CENTERED on init if(Type('oBot02') == "O",oBot02:SetFocus(),Nil)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS09MPao

@description Monta dados de uma autorizacao (itens)
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLS09MPao(cChave,cTipo,aCabProc,aTrbProc,aDadProc,cAlias)

	LOCAL aAux := {}
	LOCAL lRet := .T.

	BQV->(DbSetOrder(1))
	BQV->(MsSeek(xFilial("BQV")+cChave))
	STORE COLS "BQV" TO aAux FROM aCabProc VETTRAB aTrbProc While xFilial("BQV")+cChave == BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT)

	If Len(aAux) == 0 .and. cAlias == "BQV"
		Help("",1,"PLS090ITEN")
		Return
		lRet := .F.
	Endif

	aDadProc := aClone(aAux)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS09PIm2

@description Chama a rotina de impressão
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLS09PIm2()
	PLS09PIma(.F.,'')
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLS09PIma

@description Rotina de impressão
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLS09PIma(lWeb,cPath)

	LOCAL cMsg 	 := ""
	LOCAL cArqNa := ""

	DEFAULT lWeb := .F.
	DEFAULT cPath:= ''

	If B4Q->B4Q_AUDITO == '1'
		cMsg := 'Guia em auditoria. Impressão não disponível.'
	Endif

	If B4Q->B4Q_CANCEL == '1'
		cMsg := 'Guia cancelada. Impressão não disponível.'
	Endif

	If B4Q->B4Q_STATUS == '0'
		cMsg := 'Guia não autorizada. Impressão não disponível.'
	Endif

	If !Empty(cMsg)
		If !lWeb
			MsgStop(cMsg)
			return {.F.,cMsg,cArqNa}
		Else
			return {.F.,cMsg,cArqNa}
		Endif
	Endif

	PLSR420N(3, "NR")

Return {.T.,cMsg,cArqNa}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA09Pprt

@description Tabelas de terminologias
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLSA09Pprt(lValid)
	LOCAL cRet    := "@#.T."
	LOCAL cTabela := ''
	LOCAL lRet    := .F.
	DEFAULT lValid  := .F.

	If alltrim(Readvar()) $ 'M->B4Q_SEXO/B4Q->B4Q_SEXO'
		cTabela := "43"
	ElseIf alltrim(Readvar()) $ 'M->B4Q_ESTADI/B4Q->B4Q_ESTADI'
		cTabela := "31"
	ElseIf alltrim(Readvar()) $ 'M->B4Q_DIAIMG/B4Q->B4Q_DIAIMG'
		cTabela := "29"
	ElseIf alltrim(Readvar()) $ 'M->B4Q_FINALI/B4Q->B4Q_FINALI'
		cTabela := "33"
	ElseIf alltrim(Readvar()) $ 'M->B4Q_GRAUPA/B4Q->B4Q_GRAUPA'
		cTabela := "35"
	ElseIf alltrim(Readvar()) $ 'M->B4Q_TIPQUI/B4Q->B4Q_TIPQUI'
		cTabela := "58"
	ElseIf alltrim(Readvar()) $ 'M->B4Q_ECOG/B4Q->B4Q_ECOG'
		cTabela := "30"
	ElseIf alltrim(Readvar()) $ 'M->BQV_VIAADM/BQV->BQV_VIAADM'
		cTabela := "62"
	Endif

	If !lValid
		cRet := "@#BTQ_FILIAL == '"+xFilial("BTQ")+"' .AND. "
		cRet += "  BTQ_CODTAB == '"+cTabela+"' .AND. "
		cRet += "  (dtos(BTQ_VIGDE) <= '"+DTOS(dDataBase)+"' .OR. Empty(BTQ_VIGATE) ) .AND. "
		cRet += "  (dtos(BTQ_VIGATE) >= '"+DTOS(dDataBase)+"' .OR. Empty(BTQ_VIGATE)) "
		cRet += " @#"
	Else
		cRet := " SELECT BTQ_CDTERM A FROM "+RetSqlName('BTQ')
		cRet += "  WHERE BTQ_FILIAL = '"+xFilial("BTQ")+"' AND "
		cRet += "  BTQ_CODTAB = '"+cTabela+"' AND "
		cRet += "  BTQ_CDTERM = '"+&(ReadVar())+"' AND "
		cRet += "  (BTQ_VIGDE <= '"+DTOS(dDataBase)+"' OR BTQ_VIGATE = ' ' ) AND "
		cRet += "  (BTQ_VIGATE >= '"+DTOS(dDataBase)+"' OR BTQ_VIGATE = ' ') AND "
		cRet += "  D_E_L_E_T_ = ' ' "
		PlsQuery(cRet,'TrbBTQ')
		If (!BTQ->(Eof()) .and. !Empty(TrbBTQ->A)) .or. Empty(&(ReadVar()))
			lRet := .T.
		Else
			Help("",1,"REGNOIS")
			lRet := .F.
		Endif
		TrbBTQ->(DbCloseArea())
	Endif

return {cRet,lRet}

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSP02CAN

@description Cancelamento da guia
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PLSP02CAN(lAut, aMotCanc)
	LOCAL cMask		:= ""
	LOCAL cFile		:= ""
	LOCAL cLog			:= ""
	LOCAL nI			:= ""
	LOCAL oMemo
	LOCAL oDlgLog
	LOCAL __cFileLog	:= ""
	LOCAL aMsg			:= {}
	LOCAL aRecCan		:= {}
	LOCAL lRet			:= .T.
	LOCAL lApagaGuia    := GetNewPar("MV_PLAUDAN",.F.) // Determina que mesmo se a guia estiver na auditoria EM analise podera ser excluida
	DEFAULT lAut		:= .F.
	DEFAULT aMotCanc := {}

	//Function PLSA09PCAN(lWeb,lAut,aMsg,aRecCan,lCancAudi,lDesabMsg, aMotCanc)

	If !lAut // Quando é chamado através do cancelamento de prorrogação
		aMotCanc := P090MTVCAN()

		if empty(aMotCanc[1]) .and. empty(aMotCanc[2])
			msgInfo("Informe um motivo válido!") //"Informe um motivo válido!"
			Return //Verificar essa validação
		EndIf

		PLSA09PCAN(.F.,nil,nil,nil,lApagaGuia,nil,aMotCanc)
	Else

		While !B4Q->(Eof()) .and. xFilial("B4Q")+BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT) == xFilial("B4Q")+B4Q->B4Q_GUIREF
			PLSA09PCAN(.F.,.T.,aMsg,aRecCan,lApagaGuia,nil,aMotCanc)
			B4Q->(DbSkip())
		EndDo

		If Len(aMsg) > 0
			lRet := .F.
			//Exibe o Log
			cLog := "Detalhes do processamento" + CRLF
			cLog += Replicate("-",25) + CRLF
			cLog += "Esta autorização possui uma ou mais Prorrogações de internação vinculadas, com pendências no setor de auditoria. A guia não poderá ser cancelada." + CRLF
			cLog += "Para dar continuidade, analise as pendências abaixo." + CRLF + CRLF
			cLog += "GUIA / STATUS" + CRLF
			cLog += Replicate("-",25) + CRLF

			For nI := 1 to Len(aMsg)
				cLog += aMsg[1] + CRLF
			Next

			__cFileLog := MemoWrite(Criatrab(,.f.) + ".LOG", cLog)

			DEFINE MSDIALOG oDlgLog TITLE "Cancelamento de Prorrogação de internação" From 3,0 to 340,417 PIXEL

			@ 5,5 GET oMemo  VAR cLog MEMO SIZE 200,145 OF oDlgLog PIXEL
			oMemo:bRClicked := {||AllwaysTrue() }

			DEFINE SBUTTON  FROM 153,175 TYPE 1 ACTION oDlgLog:End() ENABLE OF oDlgLog PIXEL //Apaga
			DEFINE SBUTTON  FROM 153,145 TYPE 13 ACTION (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cLog))) ENABLE OF oDlgLog PIXEL

			ACTIVATE MSDIALOG oDlgLog CENTER

			Return {lRet,.T.}

		Else
			If !MsgYesNo("Confirma o CANCELAMENTO da GUIA?")
				Return {.F.,.T.}
			EndIf

			For nI := 1 to Len(aRecCan)

				If aRecCan[nI][1] == "B4Q"
					B4Q->(DbGoTo(aRecCan[nI][2]))

					B4Q->( RecLock("B4Q", .F.) )
					B4Q->B4Q_STATUS := '3'
					B4Q->B4Q_CANCEL := '1'
					B4Q->( MsUnLock() )

				EndIf

				If aRecCan[nI][1] == "BQV"
					BQV->(DbGoTo(aRecCan[nI][2]))

					BQV->( RecLock("BQV", .F.) )
					BQV->BQV_AUDITO := '0'
					BQV->BQV_STATUS := '0'
					BQV->( MsUnLock() )

				EndIf

				If aRecCan[nI][1] == "B53"
					B53->(DbGoTo(aRecCan[nI][2]))

					B53->(Reclock("B53",.F.))
					B53->B53_STATUS := '6'
					B53->(MsUnlock())

				EndIf

			Next

			Return {lRet,.T.}
		EndIf
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA09PCAN

@description Cancelamento
@author  Karine Riquena Limp
@version P12
@since   27.07.16
@param lWeb, lógico, identifica se a função esta sendo acionada via portal. Caso verdadeiro, o retorno da funcao sempre sera a mensagem a ser exibida no portal do prestador
@param lAut, lógico, identifica se a função esta sendo acionada pelas rotinas de atendimento (SADT/Odonto/Internação). Caso verdadeiro, o sistema localiza todas as prorrogações vinculadas a guia origem e somente cancela a guia caso todos as prorrogações possam ser cancelados.
@param lCancAudi, com o valor true, significa que a guia está sendo cancelada pela auditoria.
@param aMotCanc, motivo TISS do cancelamento
@todo Validar se os procedimentos da guia já foram PAGOS/COBRADOS em alguma guia de SADT/INTERNACAO. Caso SIM, nao deixa cancelar
@return cMsg, Mensagem a ser exibida na tela (somente se chamada via portal)

/*/
//-------------------------------------------------------------------
Function PLSA09PCAN(lWeb,lAut,aMsg,aRecCan,lCancAudi,lDesabMsg, aMotCanc, lRPC, nStatusTiss)
	LOCAL cFaseGuia   := ""
	LOCAL cSeqPF      := ""
	LOCAL cMsg		  := ""
	LOCAL cGuiRef	  := B4Q->B4Q_GUIREF
	LOCAL lCanTis	  := B4Q->( FieldPos("B4Q_CANTIS") ) > 0
	LOCAL lOk		  := .T.
	DEFAULT aMsg	  := {}
	DEFAULT aRecCan	  := {}
	DEFAULT lWeb	  := .F.
	DEFAULT lAut	  := .F.
	DEFAULT lCancAudi := .F.
	DEFAULT lDesabMsg := .F.
	DEFAULT aMotCanc	  := {}
	DEFAULT lRPC		:= .F.
	DEFAULT nStatusTiss	:= 0

	//Guia cancelada
	If B4Q->B4Q_CANCEL == '1'
		lOk := .F.
		cMsg := 'A prorrogação já encontra-se CANCELADA!'

		//Vamos informar que a guia já foi cancelada guando vier de uma requisição da TISS online
		nStatusTiss := 1 //Guia cancelada com sucesso

		If !lWeb .And. !lAut .And. !lRPC
			Aviso( "Cancelar prorrogação", ;
				cMsg,;
				{"Ok"}, 2 )
		ElseIf lWeb
			Return cMsg
		ElseIf lAut
			Return
		EndIf

	EndIf

	If !lCancAudi

		//Existem procedimentos em analise pela auditoria
		B53->(dbSetOrder(1))//B53_FILIAL + B53_NUMGUI + B53_ORIMOV
		If B53->(dbSeek(B4Q->(B4Q_FILIAL+B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT)))

			If B53->B53_SITUAC $ '23'
				lOk := .F.
				cStatus := Iif(B53->B53_SITUAC == '2',"Em Analise","Em Espera")
				cMsg	:= "Não será possivel cancelar a prorrogação informada. Status da Guia:" + cStatus

				If !lWeb .And. !lAut .And. !lRPC
					Alert(cMsg)

				ElseIf lWeb
					Return cMsg

				ElseIf lAut
					aAdd(aMsg,TransForm(B4Q->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT),PesqPict("B4Q","B4Q_NUMLIB"))+ " / " + cStatus + CRLF)
				EndIf
			EndIf
		EndIf
	EndIf

	////Ponto de entrada apos validacao padrao
	If ExistBlock("PL09ACKCAN")
		If !Execblock("PL09ACKCAN",.F.,.F.,{cGuiRef})
			Return
		EndIf
	EndIf

	If lOk

		If !lWeb .And. !lAut .And. !lDesabMsg .And. !lRPC .And. !MsgYesNo("Confirma o CANCELAMENTO da PRORROGAÇÃO?")
			Return
		EndIf

		//Atualiza o cabecalho

		If !lAut
			B4Q->( RecLock("B4Q", .F.) )
			B4Q->B4Q_STATUS := '3' // negado
			B4Q->B4Q_CANCEL := '1' //cancelado

			if len(aMotCanc) > 0
				if !lWeb
					B4Q->B4Q_CANTIS := aMotCanc[1] //Motivo TISS
					B4Q->B4Q_CANEDI := aMotCanc[2] //Texto motivo
				else
					B4Q->B4Q_CANEDI := aMotCanc[1] //Texto motivo
				endif
			endif


			If B4Q->(FieldPos("B4Q_STTISS")) > 0
				B4Q->B4Q_STTISS := '6' //cancelado
			EndIf

			B4Q->( MsUnLock() )

			//Vamos cancelar a Guia na BEA tambem
			BEA->( RecLock("BEA", .F.) )
			BEA->BEA_STATUS := '3' // negado
			BEA->BEA_CANCEL := '1' //cancelado
			BE4->BE4_STTISS := PLSANLSTIG(,,.T. ) //Como está cancelada, no portal deve exibir o status TISS como cancelada 
			BEA->( MsUnLock() )

			//Vamos informar que a guia foi cancelada guando vier de uma requisição da TISS online
			nStatusTiss := 1 //Guia cancelada com sucesso
		Else
			aAdd(aRecCan,{"B4Q",B4Q->(Recno())})
		EndIf

		//Atualiza os itens
		BQV->( DbSetOrder(1) ) //BQV_FILIAL + BQV_CODOPE + BQV_ANOIN + BQV_MESINT + BQV_NUMINT + BQV_SEQUEN
		BQV->( MsSeek( xFilial("BQV")+B4Q->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT) ) )
		While !BQV->(Eof()) .And. B4Q->(B4Q_FILIAL+B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT) == BQV->(BQV_FILIAL+BQV_CODOPE+BQV_ANOINT+BQV_MESINT+BQV_NUMINT)

			If !lAut
				BQV->( RecLock("BQV", .F.) )
				BQV->BQV_AUDITO := '0'
				BQV->BQV_STATUS := '0'
				BQV->( MsUnLock() )
			Else
				aAdd(aRecCan,{"BQV",BQV->(Recno())})
			EndIf

			BQV->( DbSkip() )
		EndDo

		//Atualiza a auditoria
		B53->(dbSetOrder(1))//B53_FILIAL + B53_NUMGUI + B53_ORIMOV
		If B53->(dbSeek(B4Q->(B4Q_FILIAL+B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT)))
			If !lAut
				B53->(Reclock("B53",.F.))
				B53->B53_STATUS := '6' //cancelado
				B53->(MsUnlock())
			Else
				aAdd(aRecCan,{"B53",B53->(Recno())})
			EndIf
		EndIf

		//atualiza diarias guia de internação
		PUPDIAINT(0,.T.)

		//Ponto de entrada apos tratamento padrao
		If ExistBlock("PLS09ACAN")
			ExecBlock("PLS09ACAN",.F.,.F.)
		Endif

		If !lAut
			MsgInfo(STR0073) //"Guia cancelada com sucesso"
		EndIf
	EndIf

//Vamos informar que a guia não foi cancelada guando vier de uma requisição da TISS online
Iif(nStatusTiss != 1, nStatusTiss := 2 , "")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} P09PBlank

@description ACols blank
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function P09PBlank(aCols,aHeader,aVetTrab)

	LOCAL nInd	:= 0

	aadd(aCols,{})
	For nInd :=  1 To Len(aHeader)+1
		If nInd <= Len(aHeader)
			If     aHeader[nInd,8] == "C"
				aadd(aCols[Len(aCols)],Space(aHeader[nInd,4]))
			ElseIf aHeader[nInd,8] == "D"
				aadd(aCols[Len(aCols)],ctod(""))
			ElseIf aHeader[nInd,8] == "N"
				aadd(aCols[Len(aCols)],0)
			Else
				aadd(aCols[Len(aCols)],nInd)
			Endif
		Else
			aadd(aCols[Len(aCols)],.F.)
		Endif
	Next

	For nInd :=  1 To Len(aHeader)+1
		If nInd <= Len(aHeader)
			aCols[Len(aCols),nInd] := CriaVar(aHeader[nInd,2],.T.)
		Else
			aCols[Len(aCols),nInd] := .F.
		Endif
	Next

	aadd(aVetTrab,0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PL09VLAUDP

@description Verifica se a guia esta em análise antes da exclusão
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PL09VLAUDP(cAlias)

	If PLSALIASEX("B53")
		If B53->(FieldPos("B53_NUMERO")) > 0

			DbSelectArea("B53")
			B53->(dbSetOrder(1))

			If B53->(dbSeek(xFilial("B53")+B4Q->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT)))
				If B53->B53_SITUAC == "2"
					Help("",1,"PL800VLD")
					Return .F.
				EndIf
			EndIf
		EndIf
	Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLB4QValid

@description Valida campo idade
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
function PLB4QValid()
return (M->B4Q_IDADE <> 0)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLB4QWhen

@description When do campo IDADE
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
function PLB4QWhen()
return (!empty(M->B4Q_GUIREF) .and. M->B4Q_IDADE == 0)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL9PInfPro

@description define o arquivo de ini
@author  Karine Riquena Limp
@version P12
@since   27.07.16

/*/
//-------------------------------------------------------------------
Function PL9PInfPro()
	Local aArea := GetArea()
	Local lInterProt := .F.

	If Empty(B4Q->B4Q_PROATE)

		If GetNewPar("MV_PLSUNI","1") == "1" .And. B4Q->B4Q_CODEMP == GetNewPar("MV_PLSGEIN","0050")
			lInterProt := .T.
		EndIf

		cNumProto := Space(20)
		P773AutInc("B4Q",@cNumProto,nil,lInterProt,.F.)

		//Conclui um protocolo
		If !Empty(cNumProto) .And. lInterProt
			P773AutCon("B4Q",cNumProto,B4Q->(B4Q_OPEMOV+B4Q_ANOAUT+B4Q_MESAUT+B4Q_NUMAUT))
		EndIf

		If !Empty(cNumProto)
			B4Q->(RecLock("B4Q",.F.))
			B4Q->B4Q_PROATE := cNumProto
			B4Q->(MsUnLock())

			MsgInfo("Protocolo registrado: "+cNumProto)
		EndIf
	Else
		MsgInfo("O protocolo já foi registrado para este atendimento.")
	Endif

	RestArea(aArea)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA09PAUT

@description Validação do procedimento
@author  Karine Riquena Limp
@version P12
@since   01.08.16

/*/
//-------------------------------------------------------------------
Function PLSA09PAUT(cSequen,cCodPad,cCodPro,nQtdPro,cTipo,lChkP,lProtRN395)
	LOCAL lRet       := .F.
	LOCAL nX		 := 1
	LOCAL nOrdBA0    := BA0->(IndexOrd())
	LOCAL nRecBA0    := BA0->(Recno())
	LOCAL nOrdBR8    := BR8->(IndexOrd())
	LOCAL nRecBR8    := BR8->(Recno())
	LOCAL nPosCodPad := 0
	LOCAL nPosCodPro := 0
	LOCAL nPosDesPro := 0
	LOCAL cCodProLin := ""
	LOCAL cCodTab    := ""
	LOCAL cCodExe    := ""
	LOCAL cRegAte    := "1"
	LOCAL cAliasProc := ""
	LOCAL lNegProPac := .F. // SE TROCAR PARA .T. IRIA INIBIR A CRITICA 09L PROCEDIMENTO JA EXISTE NO PACOTE
	LOCAL aCompo	 := {}
	LOCAL aRet		 := {}
	LOCAL aArea	 := GetArea()
	LOCAL lUnimeds   := IF(AllTrim(GetNewPar("MV_PLSUNI","1"))=="1",.T.,.F.)
	LOCAL lProPTUGen := .F.
	LOCAL lLembre    := .F.
	LOCAL cCodSequen :=	 M->BQV_SEQUEN
	LOCAL nL		 := 0
	LOCAL nt		 := 0
	LOCAL lFirst	 :=.T.
	LOCAL aDadUsr     := {}
	LOCAL nLimitePTU  := 0
	LOCAL nPosNRTROL  := 0
	LOCAL nItensPTU   := 0
	LOCAL cCodLoc

	LOCAL aBkBrwCrit	 := {}
	LOCAL lInterProt  := .F.
	LOCAL aRetFun := {}

	DEFAULT lChkP	 := .T.
	DEFAULT lProtRN395:= .F.

	if Vazio(cCodPro)
		lRet := .T.
	else

		If GetNewPar("MV_PLRN395","0") == "0"
			lProtRN395 := .F.
		EndIf

		BE4->(DbSetORder(2))//BE4_FILIAL+BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT
		BE4->(msSeek(xFilial("BE4")+M->B4Q_GUIREF))

		aRetFun := PLSDADRDA(BE4->BE4_OPERDA,;
			BE4->BE4_CODRDA,;
			'1',;
			BE4->BE4_DATPRO,;
			BE4->BE4_CODLOC,;
			BE4->BE4_CODESP,;
			cCodPad,;
			cCodPro,,,,,,.T.) // lProrInt = .T. (Prorrogação de Internação)

		//----------------------------------------------------------------
		//  Verifica se o protocolo foi informado
		//----------------------------------------------------------------
		If lProtRN395 .And. Type("cNumProto") <> "U" .And. Empty(cNumProto)

			aDadUsr := PLSGETUSR()
			If lUnimeds
				If len(aDadUsr) > 0
					If aDadUsr[45] <> PlsIntPad()
						lInterProt := .T.
					EndIf
				else
					MsgStop("Informe o número da Guia Referenciada antes de digitar o procedimento.")
					Return(lRet)
				EndIf
			EndIf

			If lInterProt
				P773AutInc("B4Q",@cNumProto,nil,lInterProt,.F.,nil,nil,nil,aDadUsr[2],.T.)
			Else
				P773AutInc("B4Q",@cNumProto,nil,nil,nil,nil,nil,nil,aDadUsr[2],.T.)
			EndIf

			M->BQV_PROATE := cNumProto

			If Empty(cNumProto) .And. !lInterProt
				lOk := .F.
				Return(.F.)
			Endif

		EndIf

		//----------------------------------------------------------------
		// Tratamento para verificar no Browse se ha o mesmo procedimento
		// para que seja somado o valor para qtde periodicidade.
		//----------------------------------------------------------------
		lProPTUGen := .f.
		If (BQV->(readvar()) $ "M->BQV_CODPRO") .and. Alltrim(M->BQV_CODPRO) $ allTrim(__cCodMedGen+"-"+__cCodMatGen+"-"+__cCodTaxGen+"-"+__cCodOpmGen) //Verifica eventos genericos
			lProPTUGen := .T.
		EndIf

		If ValType(oBrwPro) = "O"

			nPosQtd:= Ascan(oBrwPro:aHeader,{ |x| x[2] == "BQV_QTDPRO"})
			nPosCod:= Ascan(oBrwPro:aHeader,{ |x| x[2] == "BQV_CODPRO"})
			nPosSeq:= Ascan(oBrwPro:aHeader,{ |x| x[2] == "BQV_SEQUEN"})
			nPosDat:= Ascan(oBrwPro:aHeader,{ |x| x[2] == "BQV_DATPRO"})
			nPosHor:= Ascan(oBrwPro:aHeader,{ |x| x[2] == "BQV_HORPRO"})

			If 	nPosQtd > 0 .and. nPosCod > 0 .and. (BQV->(readvar()) $ "M->BQV_CODPRO")

				For nL:=1 to Len(oBrwPro:ACOLS)
					If oBrwPro:ACOLS[nL,nPosCod]=cCodPro  .and. oBrwPro:ACOLS[nL,nPosDat]== dDatabase  .and. substr(oBrwPro:ACOLS[nL,nPosHor],1,3) ==Substr(StrTran(time(),":",""),1,3)
						If (nQtdPro+oBrwPro:ACOLS[nL,nPosQtd]) >1 .and. !lProPTUGen
							Aviso( "Atenção", "Este procedimento já foi adicionado.", { "Ok" }, 2 )
							Return(.F.)
						Endif
					Endif
				Next nL

			Endif

		Endif

		//----------------------------------------------------------------
		//  Se todos obrigatorios foram informados
		//----------------------------------------------------------------
		If ValType(oEncAut) <> 'U'
			If !Obrigatorio(oEncAut:aGets,oEncAut:aTela)
				Return(.F.)
			Endif
		EndIf

		//----------------------------------------------------------------
		//  Nao informado
		//----------------------------------------------------------------
		If Empty(M->B4Q_CODRDA)
			Aviso( "Rede de Atendimento", "Informe a Rede de Atendimento antes de informar o procedimento.", {  "Ok"  }, 2 )
			Return(lRet)
		Endif

		//----------------------------------------------------------------
		//  Nao informado
		//----------------------------------------------------------------
		If Empty(M->B4Q_USUARI)
			Aviso( "Usuario", "Informe o Usuario antes de informar o procedimento.", {  "Ok"  }, 2 )
			Return(lRet)
		Endif

		//----------------------------------------------------------------
		//  Pega a tabela correspondente
		//----------------------------------------------------------------
		If (GetNewPar("MV_PLSDTPG",.F.) .Or. Empty(GetNewPar("MV_PLSTBPD","")))  .And. lChkP

			aRet 	:= PLSCHKPAC("BQV",BE4->BE4_CODRDA,BE4->BE4_DTDIGI)
			cPadPro := aRet[1]
			cCodPad := aRet[2]
			M->BQV_CODPAD := cCodPad
			//----------------------------------------------------------------
			//  PLSRETTAB
			//----------------------------------------------------------------

			cCodLoc := M->(BE4_CODLOC)
			cCodLoc := Iif(cCodLoc == nil,"",M->(BE4_CODLOC+BE4_LOCAL))

			aCodTab := PLSRETTAB(cCodPad,cCodPro,BE4->BE4_DTDIGI,;
				BE4->BE4_OPERDA,BE4->BE4_CODRDA,BE4->BE4_CODESP,BE4->BE4_SUBESP,cCodLoc,;
				BE4->BE4_DTDIGI,,BE4->BE4_OPERDA,,"1","1")

			If aCodTab[1]
				cCodTab := IiF(!Empty(aCodTab[3]),aCodTab[3],cCodTab)
			EndIf

		EndIf

		//----------------------------------------------------------------
		//  PLSCOMEVE
		//----------------------------------------------------------------
		aCompo := PLSCOMEVE(cCodTab,cCodPad,cCodPro,BE4->BE4_OPERDA,M->B4Q_DATPRO,"03")
		If Len(aCompo) == 0

			if !empty(cCodPro)
				MsgInfo(STR0064 + AllTrim(cCodPro) + STR0065 + cCodTab) //"O Procedimento "###" nao possui composicao de pagamento definida na TDE "
			else
				lRet := .T.
			endif

		Else

			// Na guia de prorrogação de internação o executante é a propria Rede de Atendimento.
			// Ela que sera analisada se poderá executar o procedimentos que estão na guia (PLSXAUTP), por isso não enviamos um executante especifico

			cCodExe := ""

			//----------------------------------------------------------------
			//  Se for uma Unimed, verifica se foi lancado um procedimento repetido
			//  diferente de Mat/Med/Taxa generica
			//  Alteracao realizada para atender as regras do Ptu Online
			//----------------------------------------------------------------
			If lUnimeds

				If !Empty(BE4->BE4_NRTROL) .And. !Empty(BE4->BE4_NRAOPE) .And. BE4->BE4_COMUNI == "1"
					nPosCodPro  := Ascan(oBrwPro:aHeader,{ |x| x[2] == "BQV_CODPRO"})
					nPosDesPro	:= Ascan(oBrwPro:aHeader,{ |x| x[2] == "BQV_DESPRO"})

					If BQV->(FieldPos("BQV_NRTROL")) > 0
						nPosNrtrol  := Ascan(oBrwPro:aHeader,{ |x| x[2] == "BQV_NRTROL"})
					EndIf

					cCodProLin	:= Alltrim(oBrwPro:aCols[oBrwPro:OBROWSE:nAt,nPosCodPro])

					If Alltrim(M->BQV_CODPRO) $ allTrim(__cCodMedGen+"-"+__cCodMatGen+"-"+__cCodTaxGen+"-"+__cCodOpmGen) //Verifica eventos genericos
						lProPTUGen := .T.
					EndIf

					//Verifica se o procedimento ja foi adicionado anteriormente no browse.
					If (oBrwPro:linAddLine .Or. cCodProLin <>  Alltrim(M->BQV_CODPRO)) .And. !lProPTUGen

						For nX := 1 to Len(oBrwPro:aCols)
							If Alltrim(oBrwPro:aCols[nX,nPosCodPro]) == Alltrim(M->BQV_CODPRO) .And. nPosNrtrol > 0 .And. Empty(oBrwPro:aCols[nX,nPosNrtrol])
								Aviso( 	"Críticas da Autorização",;
									"Este procedimento já foi adicionado.",;
									{"Ok"}, 2 )//OK

								//Quando o usuario usa a tecla ESC, apos digitar um codigo de procedimento que ja exista a descricao ja esta atualizada, entao preciso retornar a descricao que esta na linha da getDados.
								M->BQV_DESPRO := oBrwPro:aCols[oBrwPro:oBrowse:nAt,nPosDesPro]
								Return(lRet)
							EndIf
						Next nX

					EndIf

					//----------------------------------------------------------------
					//  Verifica se alcancou o limite de itens PTU Online
					//----------------------------------------------------------------
					nPosNRTROL  := Ascan(oBrwPro:aHeader,{ |x| x[2] == "BQV_NRTROL"})
					nPosCodPro  := Ascan(oBrwPro:aHeader,{ |x| x[2] == "BQV_CODPRO"})
					aDadUsr := PLSGETUSR()
					nLimitePTU := GetNewPar("MV_PLLIPTU",50)

					For nX := 1 to Len(oBrwPro:aCols)
						If Empty(oBrwPro:aCols[nX,nPosNRTROL]) .And. !Empty(oBrwPro:aCols[nX][nPosCodPro] )
							nItensPTU ++
						EndIf
					Next nX

					If nItensPTU >= nLimitePTU
						MsgInfo(STR0060+Alltrim(Str(nLimitePTU))+STR0061)//"O limite para solicitações PTU Online é de "###" itens."
						Return(.F.)
					EndIf

				EndIf

			EndIf

			//----------------------------------------------------------------
			//  Valida o pacote x procedimento do pacote
			//----------------------------------------------------------------
			If GetNewPar("MV_PLSDTPG",.F.)
				If !Empty(cCodPad) .And. Empty(cPadPro)
					cPadPro := cCodPad
				EndIf

				lNegProPac := PLSVLDINP("2",cPadPro,oEncAut,oBrwPro,oBrwCri,"BE4","BQV","BQZ")
			EndIf

			//----------------------------------------------------------------
			// Autorizacao da guia
			//----------------------------------------------------------------
			lRet := PLSA090Aut(cSequen,cCodPad,cCodPro,nQtdPro,cTipo,"BQV","B4Q","BQZ",oBrwPro,;
				oBrwCri,cCodExe,.F.,.T.,BE4->BE4_PADINT,BE4->BE4_PADCON,nil,;
				BE4->BE4_GRPINT+BE4->BE4_TIPINT,nil,.T.,aDadB43,aCabB43,aTrbB43,cRegAte,"E",;
				oBrwPro,cAliasProc,.F.,lNegProPac,.T.,,,,{BE4->BE4_DATPRO,Substr(BE4->BE4_HORPRO,1,4)}) // Informa a data e hora de internação, caso o RDA esteja bloqueado, verificar se foi antes da internação

		EndIf

		//----------------------------------------------------------------
		// OK
		//----------------------------------------------------------------
		If lRet

			BR8->( DbSetOrder(1) )
			If BR8->( MsSeek(xFilial("BR8")+cCodPad+cCodPro) )

				//----------------------------------------------------------------
				// Lembretes
				//----------------------------------------------------------------
				If BR8->( FieldPos("BR8_LEMBRE") ) > 0 .and. !Empty(BR8->BR8_LEMBRE)
					If lLembre := PLSLEMBRE(.T.,nil,nil,nil,nil,nil,.T.)
						Aviso("Lembrete", Alltrim(BR8->BR8_LEMBRE), {"Ok"})
					Endif
				Endif

				BR8->( DbGoTo(nRecBR8) )
				BR8->( DbSetOrder(nOrdBR8) )

			EndIf

		EndIf

	endIf

	RestArea( aArea )

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL09PDELPR

@description Validação na exclusão da linha para setar a quantidade autorizada
@author Karine Riquena Limp
@since 02/08/2016
@version P12
/*/
//-------------------------------------------------------------------
function PL09PDELPR()
	Local lDelPro		:= .F.
	Local lRet			:= .T.
	Local cStPro		:= oBrwPro:aCols[oBrwPro:OBROWSE:nAt][oBrwPro:PLRETPOS("BQV_STATUS")]
	Local nQtdPro 	:= oBrwPro:aCols[oBrwPro:OBROWSE:nAt][oBrwPro:PLRETPOS("BQV_QTDPRO")]
	Local nQtdSol 	:= oBrwPro:aCols[oBrwPro:OBROWSE:nAt][oBrwPro:PLRETPOS("BQV_QTDSOL")]
	Local cCodPad		:= oBrwPro:aCols[oBrwPro:OBROWSE:nAt][oBrwPro:PLRETPOS("BQV_CODPAD")]
	Local cCodPro		:= oBrwPro:aCols[oBrwPro:OBROWSE:nAt][oBrwPro:PLRETPOS("BQV_CODPRO")]
	Local aArea		:= getArea()

	BR8->( DbSetOrder(1) )
	If BR8->( MsSeek( xFilial("BR8")+cCodPad+cCodPro ) )

		If BR8->BR8_TPPROC == "4"
			//----------------------------------------------------
			// Verifico se é delete ou undelete da linha
			//----------------------------------------------------
			If !oBrwPro:aCols[oBrwPro:Linha()][Len(oBrwPro:aHeader)+1]
				lDelPro := .T.
			Else
				lDelPro := .F.
			EndIf

			if lDelPro

				M->B4Q_QTDADD -= nQtdSol
				//----------------------------------------------------
				// Verifico se é um procedimento autorizado
				//----------------------------------------------------
				if cStPro == "1"
					M->B4Q_QTDADA -= nQtdPro
				endIf

			else

				M->B4Q_QTDADD += nQtdSol
				//----------------------------------------------------
				// Verifico se é um procedimento autorizado
				//----------------------------------------------------
				if cStPro == "1"
					M->B4Q_QTDADA += nQtdPro
				endIf

			endIf

		Endif

	Endif


	oEncAut:oBox:Refresh()
	oEncAut:Refresh()

	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PUPDIAINT

@description Atualiza quantidade de diarias da internação e também a data de internação
@author Karine Riquena Limp
@since 02/08/2016
@version P12
/*/
//-------------------------------------------------------------------
function PUPDIAINT(nOpc, lCanc)

	Local nQtdGuiPro := 0
	Local lDataAlta := .F.

	Default lCanc := .F.

	BE4->(dbSetOrder(2))
	BAU->(dbSetOrder(1))

	if BE4->(msSeek(xFilial("BE4")+B4Q->B4Q_GUIREF))

		BE4->( RecLock("BE4", .F.) )

		if(!lCanc .and. nOpc == K_Incluir)

			BE4->BE4_DIASPR += B4Q->B4Q_QTDADA
			BE4->BE4_PRORRO := "1"

			//se calcula data da alta automaticamente
			if !empty(BE4->BE4_DTALTA) .and. BAU->(msSeek(xFilial("BAU")+BE4->BE4_CODRDA)) .and. BAU->BAU_GRALAU == "1"
				BE4->BE4_DTALTA := BE4->BE4_DTALTA + B4Q->B4Q_QTDADA
				BE4->BE4_HRALTA := Left(StrTran(Time(),":",""),5)

				lDataAlta := .T.
			endIf

		elseif(nOpc == K_Excluir .or. lCanc)

			//--------------------------------------------------------------
			// Qtde. de prorrogações vinculadas a internação
			//--------------------------------------------------------------
			cSQL := "SELECT COUNT(*) QUANTIDADE FROM " + RetSQLName("B4Q")
			cSQL += " WHERE B4Q_FILIAL = '"+xFilial("B4Q")+"' "
			cSQL += " AND B4Q_GUIREF  = '"+(BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT))+"' "
			cSQL += " AND NOT (B4Q_OPEMOV = '"+B4Q->B4Q_OPEMOV+"' "
			cSQL += " AND B4Q_ANOAUT  = '"+B4Q->B4Q_ANOAUT+"' "
			cSQL += " AND B4Q_MESAUT  = '"+B4Q->B4Q_MESAUT+"' "
			cSQL += " AND B4Q_NUMAUT  = '"+B4Q->B4Q_NUMAUT+"') "
			cSQL += " AND D_E_L_E_T_  = ' ' "
			cSQL := ChangeQuery(cSQL)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSQL),"TRBB4Q",.F.,.T.)

			nQtdGuiPro := TRBB4Q->QUANTIDADE
			TRBB4Q->(dbCloseArea())

			BE4->BE4_DIASPR -= B4Q->B4Q_QTDADA
			BE4->BE4_DIASPR := iif(BE4->BE4_DIASPR > 0, BE4->BE4_DIASPR, 0)
			BE4->BE4_PRORRO := iif(nQtdGuiPro == 0 .and. BE4->BE4_DIASPR == 0, "0", "1")

			//se calcula data da alta automaticamente
			if !empty(BE4->BE4_DTALTA) .and. BAU->(msSeek(xFilial("BAU")+BE4->BE4_CODRDA)) .and. BAU->BAU_GRALAU == "1"
				//se a data da alta na BE4 menos a quantidade de diarias autorizadas na prorrogação for menor que a data atual,
				//significa que ja foram usados alguns dias da prorrogação, entao a data da alta não pode ficar menor que a data atual
				if (BE4->BE4_DTALTA - B4Q->B4Q_QTDADA) < ddatabase
					BE4->BE4_DTALTA := ddataBase
					BE4->BE4_DIASPR := ddataBase - (BE4->BE4_DTALTA - B4Q->B4Q_QTDADA) //QTDE de dias prorrogados utilizados
					BE4->BE4_PRORRO := "1"
				else
					BE4->BE4_DTALTA := BE4->BE4_DTALTA - B4Q->B4Q_QTDADA
				endIf

				BE4->BE4_HRALTA := Left(StrTran(Time(),":",""),5)

				lDataAlta := .T.
			endIf

		endIf

		BE4->( MsUnLock() )

	endIf

	// Integração do Aviso de Internação (API)
	If lDataAlta .And. FindFunction("PLMapIntAviso")
		PLMapIntAviso(BE4->BE4_CODOPE, BE4->BE4_ANOINT, BE4->BE4_MESINT, BE4->BE4_NUMINT)
	EndIf

return


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSB4QDES

@description Função de validação do inicializador padrão do campo B4Q_DESESP
@author Francisco Edcarlo
@since 27/11/2017
@version P12
/*/
//-------------------------------------------------------------------
Function PLSB4QDES()

	Local cRet := ""

	If (TYPE("M->B4Q_CDPFSO") <> "U")
		cRet := IIF( !INCLUI, ALLTRIM(POSICIONE("BQ1",1,XFILIAL("BQ1") + M->(B4Q_CDPFSO + B4Q_ESPSOL),"BQ1_DESCRI")),"")
	EndIf

Return (cRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL09PGRef

@description Função que carrega a visualização da Guia de referência
@author José G. Romano
@since 05/12/2021
@version P12
/*/
//-------------------------------------------------------------------
Function PL09PGRef(cAlias, cNumGuia)

	LOCAL   cTipAnexo := ""

	DEFAULT cNumGuia   := ""
	DEFAULT cAlias 	   := "BEA"

	//remove pontos e hífens
	cNumGuia := Strtran(Strtran(Strtran(cNumGuia, ".", ""), "-", ""), " ", "")
	cAlias := Strtran(cAlias," ", "")
	cAlias := UPPER(cAlias)

	If empty(cNumGuia) .Or. Len(cNumGuia) < 18
		MsgAlert(STR0076, STR0075) // Por favor, selecione uma Guia válida
		Return .F.
	EndIf

	If cAlias == "BEA" //ATENDIMENTO

		BEA->(DbSetOrder(1))

		If BEA->(Dbseek(xFilial("BEA") + cNumGuia))

			Do Case

				Case GetNewPar("MV_PLATIOD","0") == "1" .And. BEA->( FieldPos("BEA_TIPATO") ) > 0 .And. BEA->BEA_TIPO = '4'

					FwMsgRun(, {|| PLS090OMov("BEA",BEA->( Recno() ), 2)},,STR0077)
				Case BEA->BEA_TIPO $ "1,2"

					FwMsgRun(, {|| PLSA090Mov("BEA",BEA->( Recno() ), 2,,, BEA->BEA_ORIGEM)},,STR0077)

				Case BEA->BEA_TIPO == "4"

					FwMsgRun(, {|| PLS090OMov("BEA",BEA->( Recno() ), 2,,, BEA->(BEA_OPEUSR+BEA_CODEMP+BEA_MATRIC+BEA_TIPREG+BEA_DIGITO),BEA->BEA_ORIGEM)},,STR0077)
				Case !(BEA->BEA_TIPO $ "1,2,4")
					MsgStop(STR0078 + xFilial("BEA") + cNumGuia) //"Não foi possível localizar a guia com o número ["

			EndCase
		Else
			MsgStop(STR0078 + xFilial("BEA") + NumGuia) //"Não foi possível localizar a guia com o número ["
		EndIf

		RestArea(BEA->(GetArea()))

	ElseIf cAlias == "BE4" //INTERNAÇÃO

		BE4->(DbSetOrder(2))

		If BE4->( MsSeek(xFilial("BE4") + cNumGuia) )

			FwMsgRun(, {|| PLSA092Mov("BE4", BE4->(Recno()), 2)},,STR0077)
		Else
			MsgStop(STR0078 + xFilial("BE4") + cNumGuia) //"Não foi possível localizar a guia com o número ["
		EndIf

		RestArea(BE4->(GetArea()))

	ElseIf cAlias == "B4A" //ANEXOS CLÍNICOS

		B4A->(DbSetOrder(1))

		If B4A->( MsSeek(xFilial("B4A") + cNumGuia) )

			If B4A->B4A_TIPANE == "2" 	//2=Quimioterapia
				cTipAnexo := "07"

			ElseIf B4A->B4A_TIPANE == "1"//1=Radioterapia
				cTipAnexo := "08"

			Else //3=OPME
				cTipAnexo := "09"
			EndIf

			FwMsgRun(, {|| PLS09AMov("B4A", B4A->(Recno()), 2, .T., cTipAnexo, B4A->B4A_TIPANE)},,STR0077)

		Else
			MsgStop(STR0078 + xFilial("B4A") + cNumGuia) //"Não foi possível localizar a guia com o número ["
		EndIf

		RestArea(B4A->(GetArea()))

	ElseIf cAlias == "B4Q" //PRORROGAÇÃO DE INTERNAÇÃO

		B4Q->(DbSetOrder(1))

		If B4Q->( MsSeek(xFilial("B4Q") + cNumGuia) )

			FwMsgRun(, {|| PLS09PMov("B4Q", B4Q->(Recno()), 2)},,STR0077)
		Else
			MsgStop(STR0078 + xFilial("B4Q") + cNumGuia) //"Não foi possível localizar a guia com o número ["
		EndIf

		RestArea(B4Q->(GetArea()))

	ElseIf cAlias == "B44" //AUTORIZAÇÃO DE REEMBOLSO

		B44->(DbSetOrder(1))

		If B44->( MsSeek(xFilial("B44") + cNumGuia) )

			FwMsgRun(, {|| PL001MOV("B44", B44->(Recno()), 2)},,STR0077)
		Else
			MsgStop(STR0078 + xFilial("B44") + cNumGuia) //"Não foi possível localizar a guia com o número ["
		EndIf

		RestArea(B44->(GetArea()))
	Else

		MsgStop(STR0079)//Não foi possível localizar o Tipo da Guia
	EndIf

Return .T.

