#INCLUDE "PLSA003.ch"
#include "PLSMGER.CH"
#include "PROTHEUS.CH"
#include "DBTREE.CH"
#include "TCBROWSE.CH"
#include "JPEG.CH"
#define __aCdCri177 {"09D",STR0001} //"Cobranca bloqueada devido ao Parcelamento."
#define K_Bloqueio 9
#define K_Desbloq  10
#define K_Parcela  13


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | PLSA003   ³ Autor ³ Daher			    | Data ³ 11.05.2010±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Parcelamento		    									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PLSA003
LOCAL cAlias  := "B0K"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis LOCAL...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro   := STR0002       //"Parcelameto de Guias"
PRIVATE aRotina  := {   			{ STR0003	   		, 'AxPesqui'     	, 0 , K_Pesquisar  },; //"Pes. Lote"
									{ STR0004	   		, 'AxVisual' 		, 0 , K_Visualizar 	},;  //"Vis. Lote"
									{ STR0005  	    	, 'PLSA003INC'		, 0 , K_Incluir    	},; //"Novo Lote"
									{ STR0006  	    	, 'PLSA003EXC'		, 0 , K_Parcela    	},; //"Exlcuir Lote"
									{ STR0007	   		, 'PLSA003VAR' 		, 0 , K_Parcela 	},; //"Deb/Cre. Benef."
									{ STR0008	   		, 'PLSA003VRR' 		, 0 , K_Parcela 	}}  //"Deb/Cre. RDA"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
//³ Validacao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
If !PLSALIASEXI("B0K")
	MsgAlert( "Não é possível utilizar esta rotina! (Execute o compatibilizador da rotina)" )
	Return
EndIf

If Existblock("PLSA003A1")
	aRotina := Execblock("PLSA003A1",.F.,.F.,{aRotina})
Endif

B0K->(DbSetOrder(1))
B0K->(DbGoTop())
B0K->(mBrowse(006,001,022,075,cAlias,,,,,,))

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | PLSA003VIS| Autor ³ Daher			    | Data ³ 11.05.2010±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Parcelamento		    									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PLSA003VIS(cAlias,nReg,nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis da rotina...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cCpoSta   := &(cAlias+"->"+cAlias+"_FASE")
LOCAL cCpoSit   := &(cAlias+"->"+cAlias+"_SITUAC")
LOCAL cTipGui   := &(cAlias+"->"+cAlias+"_TIPGUI")
LOCAL cCodOpe   := &(cAlias+"->"+cAlias+"_CODOPE")
LOCAL nOpca
LOCAL aRetorno
LOCAL nFor
LOCAL aProxAno
LOCAL aCampos   := {}
LOCAL cFunCpo
LOCAL cTipCpo
LOCAL aAlter    := {}
LOCAL nOrdBCL   := BCL->(IndexOrd())
LOCAL nRecBCL   := BCL->(Recno())
Local aArea		:= GetArea()

//__lManunt := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa posicao do layout da guia...                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BCL->BCL_TIPGUI <> cTipGui
   BCL->(DbSetOrder(1))
   BCL->(MsSeek(xFilial("BCL")+cCodOpe+cTipGui))
Endif

cFunCpo   := BCL->BCL_FUNACP
cTipCpo   := BCL->BCL_TIPACP
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa parametrizacao do ajuste no layout da guia...                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cFunCpo)
   Help("",1,"PLSA500ES1")
   Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Determina os campos que serao analisados...                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPar := {cTipGui}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a funcao do layout...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipCpo == "1"
   cMacro   := AllTrim(cFunCpo)
   aCampos := &(cMacro)(aPar,,,)
Else
   aCampos := ExecBlock(cFunCpo,.F.,.F.,aPar)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa o PLSA500MOV passando o parametro de ajuste...                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("BCI")
BCI->(dbSetOrder(3))
BCI->(MsSeek(xFilial("BCI")+cCodOpe+cTipGui)) //BCI_FILIAL, BCI_CODOPE, BCI_TIPGUI, R_E_C_N_O_, D_E_L_E_T_

PLSA500MOV(cAlias,nReg,K_Visualizar,aCampos)

BCL->(DbSetOrder(nOrdBCL))
BCL->(DbGoTo(nRecBCL))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | PLSA003EXC³ Autor ³ Daher			    | Data ³ 11.05.2010±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Parcelamento		    									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PLSA003EXC(cAlias,nReg,nOpc)
LOCAL nOpca 	:= 0
Local I__f      := 0
Local nI        := 0
Local cAliGui   := "BD5"
Local cAliBSQ	:= "BSQ"
Local cAliBGQ   := "BGQ"
Local aGuiaParc := {}
Local aLanBSQ	:= {}
Local aLanBGQ   := {}
Local aArea		:= GetArea()
Local lOk		:= .T.
Local aButtons  := {}
Local aSize 	:= {}
Local aInfo 	:= {}
Local aPosObj 	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busco os lancamentos de debito/credito do prestador					 	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
&(cAliBGQ+"->(DbSetOrder(9))")
If &(cAliBGQ+"->(MsSeek('"+xFilial(cAliBGQ)+"'+'"+B0K->B0K_CODOPE+B0K->B0K_LOTPAR+"'))")
   While ! &(cAliBGQ+"->(Eof())") .and. xFilial(cAliBGQ)+B0K->B0K_CODOPE+B0K->B0K_LOTPAR == &(cAliBGQ+"->"+cAliBGQ+"_FILIAL")+&(cAliBGQ+"->"+cAliBGQ+"_CODOPE")+&(cAliBGQ+"->"+cAliBGQ+"_LOTPAR")
        If !Empty(&(cAliBGQ+"->"+cAliBGQ+"_NUMLOT"))
           lOk	:= .F.
           exit
        Endif
   		&(cAliBGQ+"->(DbSkip())")
   Enddo
Endif

If !lOk
	Aviso( STR0072 , STR0009, {STR0073} )//"Lançamentos"###"Existem lancamentos já faturados de debito/credito para o prestador."###"Ok"
	RestArea(aArea)
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busco os lancamentos de debito/credito do beneficiario					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
&(cAliBSQ+"->(DbSetOrder(10))")
If &(cAliBSQ+"->(MsSeek('"+xFilial(cAliBSQ)+"'+'"+B0K->B0K_CODOPE+B0K->B0K_LOTPAR+"'))")
   While ! &(cAliBSQ+"->(Eof())") .and. xFilial(cAliBSQ)+B0K->B0K_CODOPE+B0K->B0K_LOTPAR == &(cAliBSQ+"->"+cAliBSQ+"_FILIAL")+&(cAliBSQ+"->"+cAliBSQ+"_CODINT")+&(cAliBSQ+"->"+cAliBSQ+"_LOTPAR")
        If !Empty(&(cAliBSQ+"->"+cAliBSQ+"_NUMCOB"))
           lOk	:= .F.
           exit
        Endif
   		&(cAliBSQ+"->(DbSkip())")
   Enddo
Endif

If !lOk
	Aviso( STR0072 , STR0010, {STR0073} )//"Lançamentos"###"Existem lancamentos já faturados de debito/credito para o beneficiario."###"Ok"
	RestArea(aArea)
	Return
Endif

If Existblock("PLSA003A2")
	If Execblock("PLSA003A2",.F.,.F.,{})
		RestArea(aArea)
		Return
	Endif
Endif

aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 1, 1, .T., .T., .F. } )
AAdd( aObjects, { 1, aSize[4] * 0.25, .T., .F., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg TITLE STR0011 FROM aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() //"Exclusao de Lote"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
COPY 'B0K' TO MEMORY

Zero();MsMGet():New('B0K',0,K_Excluir,,,,,aPosObj[1],,,,,,oDlg,,,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:End()},{||oDlg:End()},.F.,aButtons)  })

If nOpca == K_OK

    Begin Transaction

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleto os lancamentos de debito/credito do prestador					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	&(cAliBGQ+"->(DbSetOrder(9))")
	If &(cAliBGQ+"->(MsSeek('"+xFilial(cAliBGQ)+"'+'"+B0K->B0K_CODOPE+B0K->B0K_LOTPAR+"'))")
	   While ! &(cAliBGQ+"->(Eof())") .and. xFilial(cAliBGQ)+B0K->B0K_CODOPE+B0K->B0K_LOTPAR == &(cAliBGQ+"->"+cAliBGQ+"_FILIAL")+&(cAliBGQ+"->"+cAliBGQ+"_CODOPE")+&(cAliBGQ+"->"+cAliBGQ+"_LOTPAR")
	        aadd(aLanBGQ,&(cAliBGQ+"->(Recno())"))
	   		&(cAliBGQ+"->(DbSkip())")
	   Enddo
	Endif

	For nI:=1 to Len(aLanBGQ)
		&(cAliBGQ+"->(DbGoTo("+alltrim(str(aLanBGQ[nI]))+"))")
		&(cAliBGQ+"->(Reclock('"+cAliBGQ+"',.F.))")
		&(cAliBGQ+"->(DbDelete())")
		&(cAliBGQ+"->(MsUnlock())")
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleto os lancamentos de debito/credito do beneficiario					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	&(cAliBSQ+"->(DbSetOrder(10))")
	If &(cAliBSQ+"->(MsSeek('"+xFilial(cAliBSQ)+"'+'"+B0K->B0K_CODOPE+B0K->B0K_LOTPAR+"'))")
	   While ! &(cAliBSQ+"->(Eof())") .and. xFilial(cAliBSQ)+B0K->B0K_CODOPE+B0K->B0K_LOTPAR == &(cAliBSQ+"->"+cAliBSQ+"_FILIAL")+&(cAliBSQ+"->"+cAliBSQ+"_CODINT")+&(cAliBSQ+"->"+cAliBSQ+"_LOTPAR")
	        aadd(aLanBSQ,&(cAliBSQ+"->(Recno())"))
	   		&(cAliBSQ+"->(DbSkip())")
	   Enddo
	Endif

	For nI:=1 to Len(aLanBSQ)
		&(cAliBSQ+"->(DbGoTo("+alltrim(str(aLanBSQ[nI]))+"))")
		&(cAliBSQ+"->(Reclock('"+cAliBSQ+"',.F.))")
		&(cAliBSQ+"->(DbDelete())")
		&(cAliBSQ+"->(MsUnlock())")
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desmarco a guia															 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	&(cAliGui+"->(DbSetOrder(12))")
	If &(cAliGui+"->(MsSeek('"+xFilial(cAliGui)+"'+'"+B0K->B0K_CODOPE+B0K->B0K_LOTPAR+"'))")
	   While ! &(cAliGui+"->(Eof())") .and. xFilial(cAliGui)+B0K->B0K_CODOPE+B0K->B0K_LOTPAR == &(cAliGui+"->"+cAliGui+"_FILIAL")+&(cAliGui+"->"+cAliGui+"_CODOPE")+&(cAliGui+"->"+cAliGui+"_LOTPAR")
	        aadd(aGuiaParc,&(cAliGui+"->(Recno())"))
	   		&(cAliGui+"->(DbSkip())")
	   Enddo
	Endif

	For nI:=1 to Len(aGuiaParc)
		&(cAliGui+"->(DbGoTo("+alltrim(str(aGuiaParc[nI]))+"))")
		&(cAliGui+"->(Reclock('"+cAliGui+"',.F.))")
		&(cAliGui+"->"+cAliGui+"_LOTPAR"):= " "
		&(cAliGui+"->(MsUnlock())")
		BD6->(DbSetOrder(1))
		If BD6->(MsSeek(xFilial("BD6")+&(cAliGui+"->"+cAliGui+"_CODOPE")+&(cAliGui+"->"+cAliGui+"_CODLDP")+&(cAliGui+"->"+cAliGui+"_CODPEG")+&(cAliGui+"->"+cAliGui+"_NUMERO")+&(cAliGui+"->"+cAliGui+"_ORIMOV")))
				While !BD6->(Eof()) .and. xFilial("BD6")+&(cAliGui+"->"+cAliGui+"_CODOPE")+&(cAliGui+"->"+cAliGui+"_CODLDP")+&(cAliGui+"->"+cAliGui+"_CODPEG")+&(cAliGui+"->"+cAliGui+"_NUMERO")+&(cAliGui+"->"+cAliGui+"_ORIMOV") == BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)

					If BD6->BD6_BLOCPA == '1' .and.  BD6->BD6_MOTBPF == __aCdCri177[1]
						BD6->(Reclock("BD6",.F.))
						BD6->BD6_BLOCPA := ''
						BD6->BD6_MOTBPF := ''
						BD6->BD6_DESBPF := ''
						BD6->(MsUnlock())
					Endif
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Marco os BD7 para o prestador como bloqueados						³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				    BD7->( DbSetOrder(1) )
					If BD7->( MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) ) )
						   While !BD7->(Eof()) .And.	BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) =;
														BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

								    BD7->(Reclock("BD7",.f.))
								    	PLBLOPC("BD7", .f., __aCdCri177[1])
									BD7->(MsUnlock())
									
								BD7->( DbSkip() )
							EndDo
				   	EndIf
					BD6->(DbSkip())
				Enddo
		Endif
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ deleto o historico														 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	B0L->(DbSetOrder(2))
	While B0L->(MsSeek(xFilial("B0L")+B0K->(B0K_CODOPE+B0K_LOTPAR)))
		B0L->(Reclock("B0L",.F.))
		B0L->(DbDelete())
		B0L->(MsUnlock())
	Enddo
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ deleto o cabecalho														 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	B0K->(Reclock("B0K",.F.))
	B0K->(DbDelete())
	B0K->(MsUnlock())
	End Transaction

Endif

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | PLSA003   ³ Autor ³ Daher			    | Data ³ 11.05.2010±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Parcelamento		    									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PLSA003INC
LOCAL cAlias  := "BD5"
LOCAL cFiltro := "@"+cAlias+"_FILIAL = '"+xFilial("BD5")+"' "
LOCAL aRetFil := PLSA003FAD()
LOCAL lSeleciona := .f.
LOCAL lFiltroAd2 := !Empty(aRetFil[3])
LOCAL aGuiaParc	 := {}
LOCAL nI		 := 1
Local lParcMedico  := GetNewPar("MV_PLPARCE",'0') == '1'
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis LOCAL...                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro   := STR0012       //"Parcelameto de Guias"
PRIVATE aRotina  := {   			{ STR0013	   		, 'AxPesqui'     , 0 , K_Pesquisar  },; //"Pes. Guia"
									{ STR0014	   		, 'PLSA003VIS' 	, 0 , K_Visualizar 	},; //"Vis.Guia Posi."
									{ STR0015		    , 'PLSA003AAR'	, 0 , K_Alterar    	}}  //"Gerar"
Private	pcArq		:=	''
Private	cMarca		:=	padr(GetMark( .T. ),4)
Private	oMarBrw

If Existblock("PLSA003A3")
	aRotina := Execblock("PLSA003A3",.F.,.F.,{aRotina})
Endif

If aRetFil[1]

	If lFiltroAd2
		cFiltro += AllTrim(aRetFil[3])
	EndIf
	cFiltro += " AND "+cAlias+"_TIPGUI IN "+AllTrim(aRetFil[2])
	cFiltro += " AND "+cAlias+"_SITUAC = '1'"
	cFiltro += " AND "+cAlias+"_FASE  IN ('3','4')"
	cFiltro += " AND "+cAlias+"_VLRTPF > 0 "
	cFiltro += " AND "+cAlias+"_LOTPAR = ' ' "
	cFiltro += " AND "+cAlias+"_NUMFAT = ' ' "
	If lParcMedico
    	cFiltro += " AND "+cAlias+"_NUMLOT = ' ' "
	Endif

	If !Empty(GetNewPar("MV_PATIPPA",""))
		cFiltro += " AND "+cAlias+"_TIPPAC IN ("+GetNewPar("MV_PATIPPA","")+") "
    Endif

	cFiltro += " AND D_E_L_E_T_ = ' ' "

	If Existblock("PLSA003FI")
		cFiltro := Execblock("PLSA003FI",.F.,.F.,{cFiltro,aRetFil,cAlias})
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpo se ja existe alguma marca										³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	&(cAlias+"->(DbSetOrder(11))")
	If &(cAlias+"->(MsSeek('"+xFilial(cAlias)+"'+'"+cMarca+"'))")
	   While ! &(cAlias+"->(Eof())") .and. xFilial(cAlias)+cMarca == &(cAlias+"->"+cAlias+"_FILIAL")+&(cAlias+"->"+cAlias+"_OKMARK")
	        aadd(aGuiaParc,&(cAlias+"->(Recno())"))
	   		&(cAlias+"->(DbSkip())")
	   Enddo
	Endif

	For nI:=1 to Len(aGuiaParc)
		&(cAlias+"->(DbGoTo("+alltrim(str(aGuiaParc[nI]))+"))")
		&(cAlias+"->(Reclock('"+cAlias+"',.F.))")
		&(cAlias+"->"+cAlias+"_OKMARK"):= " "
		&(cAlias+"->(MsUnlock())")
	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Mostro o browse														³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea(cAlias)
	DbSetOrder(1)
	SET FILTER TO &cFiltro
	//DbSelectArea(cAlias)
	//DbSetOrder(1)

	oMarBrw := MarkBrow( cAlias, 'BD5_OKMARK',,, lSeleciona, cMarca, nil,,,, 'Mark_PLSA003()' )

	DbSelectArea(cAlias)
	DbSetOrder(1)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta mbrowse padrao...                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA003PAR ³ Autor ³ Daher			    | Data ³ 11.05.2010±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Parcelamento		    									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function Mark_PLSA003()

DbSelectArea( 'BD5' )

If	IsMark( 'BD5_OKMARK', cMarca )
	BD5->(Reclock("BD5",.F.))
		BD5->BD5_OKMARK :=  Space( 04 )
	BD5->(MsUnlock())
Else
	BD5->(Reclock("BD5",.F.))
		BD5->BD5_OKMARK :=  cMarca
	BD5->(MsUnlock())
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA003PAR ³ Autor ³ Daher			    | Data ³ 11.05.2010±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Parcelamento		    									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/

Function PLSA003PAR(cAlias,nReg,nOpc)

PLSA003ODA(cAlias, nReg, nOpc)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    |PLSA003VRR ³ Autor ³ Daher			    | Data ³ 11.05.2010±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³					    									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PLSA003VRR(cAlias,nReg,nOpc)

Local cFil

PRIVATE aRotina  := {   { STR0016   , 'AxPesqui'   , 0 , K_Pesquisar  },; //"Pesquisar"
						{ STR0017   , 'AxVisual' 	, 0 , K_Visualizar 	},; //"Visualizar"
						{ STR0018   , 'PLSA003Mo1'  , 0 , K_Alterar    	},; //"Mo&dificar"
						{ STR0019   , 'PLSA003Mo1'  , 0 , K_Excluir    	},; //"Excluir"
						{ STR0020   , "PLSODHIS"  	, 0 , K_Incluir    	},; //"Historico"
						{ STR0021   , "PLSA756LEG"	, 0 , K_Incluir     } }  //"Legenda"

PRIVATE aCdCores  	:= { 	{ 'BR_VERDE'    ,'Lancamento Informado' },;
							{ 'BR_VERMELHO' ,'Lancamento Faturado' } }


Private cCadastro 	:= STR0022 //"Debitos/Creditos para Parcelamento"

If Existblock("PLSA003A4")
	aRotina := Execblock("PLSA003A4",.F.,.F.,{aRotina})
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sintaxe do Filtro para tela...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFil := "@BGQ_FILIAL = '"+xFilial("BGQ")+"' AND BGQ_CODOPE = '"+B0K->B0K_CODOPE+"'  AND BGQ_LOTPAR = '"+B0K->B0K_LOTPAR+"' AND D_E_L_E_T_ = ' ' "

DbSelectArea("BGQ")
BGQ->(DbSetOrder(9))//BGQ_FILIAL, BGQ_CODOPE, BGQ_LOTPAR
If BGQ->(MsSeek(xFilial("BGQ")+B0K->B0K_CODOPE+B0K->B0K_LOTPAR))
	SET FILTER TO &cFil
	BGQ->(DbSeek(xFilial("BGQ")))
	BGQ->(mBrowse(06,01,22,75,'BGQ',,"BGQ->BGQ_NUMLOT <> ' '"))
Else
	Aviso( STR0074, STR0023, {STR0073} )//"Registros"###"Nao existem registros relacionados a este lote."###"Ok"
Endif

DbSelectArea("BGQ")
SET FILTER TO

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA003Mov ³ Autor ³ Daher				³ Data ³ 01.09.10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Chama funcao para efetuar alteracao/exclusao de Lancamentos³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA003Mov(cAlias, nReg, nOpc)
LOCAL cChave  := ""
LOCAL aRecnos := {}
LOCAL cAno 	  := ""
LOCAL cMes    := ""
LOCAL nI	  := 1
LOCAL lFlag   := .F.
LOCAL nRecBSQ := 0
LOCAL nOrdBSQ := 0

BGQ->(DbSetOrder(10))

If nOpc = 3

	If BSQ->BSQ_NUMCOB <> ' '
		MsgAlert(STR0024, STR0025)  //"Atencao"###"Lancamento ja faturado. Somente podera ser visualizado !"
		AxVisual(cAlias,nReg,K_Visualizar)
	Elseif BGQ->(MsSeek(xFilial("BGQ")+BSQ->BSQ_CODINT+BSQ->BSQ_CODSEQ)) .and. !Empty(BGQ->BGQ_NUMLOT)
		MsgAlert(STR0024, STR0026)  //"Atencao"###"Lancamento viculado ao prestador ja faturado. Somente podera ser visualizado !"
		AxVisual(cAlias,nReg,K_Visualizar)
	Else
		AxAltera(cAlias,nReg,nOpc,,,,,)
		PLS003Alt()
	Endif

ElseIf nOpc = 4

	cChave := BSQ->BSQ_CODINT+BSQ->BSQ_CODSEQ

	If BSQ->BSQ_NUMCOB <> ' '
		MsgAlert(STR0024, STR0027)  //"Atencao"###"Lancamento ja faturado. Nao podera ser excluido !"
	ElseIf BGQ->(MsSeek(xFilial("BGQ")+BSQ->BSQ_CODINT+BSQ->BSQ_CODSEQ)) .and. !Empty(BGQ->BGQ_NUMLOT)
		MsgAlert(STR0024, STR0028)  //"Atencao"###"Lancamento viculado ao prestador ja faturado. Nao podera ser excluido !"
	Endif

	RegToMemory(cAlias)
	AxDeleta(cAlias,nReg,nOpc)

    If BGQ->(MsSeek(xFilial("BGQ")+cChave)) .and. MsgYesNo(STR0029) //"Deseja excluir o lançamento vinculado ao prestador?"
		RegToMemory("BGQ")
		cCadastro 	:= STR0030 //"Debitos/Creditos vinculados para Prestador"
		AxDeleta("BGQ",BGQ->(Recno()),K_Excluir)
	Endif

ElseIf nOpc = 7

	cChave  := BSQ->BSQ_CODINT+BSQ->BSQ_LOTPAR
	nRecBSQ := BSQ->(Recno())
	nOrdBSQ := BSQ->(IndexOrd())

	If BSQ->BSQ_NUMCOB <> ' '
		MsgAlert(STR0024, STR0031)  //"Atencao"###"Lancamento ja faturado. Nao podera ser prorrogado !"
	Elseif BGQ->(MsSeek(xFilial("BGQ")+BSQ->BSQ_CODINT+BSQ->BSQ_CODSEQ)) .and. !Empty(BGQ->BGQ_NUMLOT)
		MsgAlert(STR0024, STR0032)  //"Atencao"###"Lancamento viculado ao prestador ja faturado. Nao podera ser prorrogado !"
    Else
    	If MsgYesNo(STR0033) //"Deseja prorrogar o lançamento selecionado e os seus subsequentes para a próxima competência?"

    	     BSQ->(DbSetOrder(1))
    	     While !BSQ->(Eof()) .and. cChave == BSQ->BSQ_CODINT+BSQ->BSQ_LOTPAR
    	            aadd(aRecnos,{BSQ->(Recno())})
    	     	BSQ->(DbSkip())
    	     Enddo

    	     For nI:=1 to Len(aRecnos)
    	         BSQ->(DbGoTo(aRecnos[nI][1]))
    	         If BSQ->BSQ_NUMCOB <> ' ' .or. ( !Empty(BSQ->BSQ_CODSEQ) .and. BGQ->(MsSeek(xFilial("BGQ")+BSQ->BSQ_CODINT+BSQ->BSQ_CODSEQ)) .and. !Empty(BGQ->BGQ_NUMLOT))
     				lFlag := .T.
     				exit
 	   	         Endif
    	     Next

    	     If lFlag
    	     	MsgAlert(STR0034, STR0035)  //"Atenção"###"Existem lançamentos subsequentes já faturados. Não será possível a prorrogação."
    	     Else
	    	     For nI:=1 to Len(aRecnos)

	    	         BSQ->(DbGoTo(aRecnos[nI][1]))

	    	         cAno := BSQ->BSQ_ANO
	    	         cMes := BSQ->BSQ_MES

	    	         BSQ->(Reclock("BSQ",.F.))
	    	         	BSQ->BSQ_ANO := substr(PLSDIMAM(cAno,cMes,'1'),1,4)
    	     			BSQ->BSQ_MES := substr(PLSDIMAM(cAno,cMes,'1'),5,2)
	    	         BSQ->(MsUnlock())

	    	         B0L->(RecLock("B0L",.T.))
						B0L->B0L_FILIAL := xFilial("B0L")
						B0L->B0L_CODSEQ := GETSX8NUM("B0L","B0L_CODSEQ");CONFIRMSX8()
						B0L->B0L_ANO    := BSQ->BSQ_ANO
						B0L->B0L_MES    := BSQ->BSQ_MES
						B0L->B0L_VALOR  := BSQ->BSQ_VALOR
						B0L->B0L_DESCRI := STR0036 //"PRORROGACAO DE PARCELA BENEFICIARIO"
						B0L->B0L_USUARI := SUBSTR(cUsuario,7,15)
						B0L->B0L_DATALT	:= dDataBase
					   	B0L->B0L_CODOPE := B0K->B0K_CODOPE
					   	B0L->B0L_OPELOT := B0K->B0K_CODOPE
					   	B0L->B0L_LOTPAR := B0K->B0K_LOTPAR
					   	B0L->B0L_TIPO   := '1'
					B0L->(MsUnlock())

	    	         If BGQ->(MsSeek(xFilial("BGQ")+BSQ->BSQ_CODINT+BSQ->BSQ_CODSEQ))

	    	          		cAno := BGQ->BGQ_ANO
	    	         		cMes := BGQ->BGQ_MES

	    	          		BGQ->(Reclock("BGQ",.F.))
		    	         		BGQ->BGQ_ANO := substr(PLSDIMAM(cAno,cMes,'1'),1,4)
	    	     				BGQ->BGQ_MES := substr(PLSDIMAM(cAno,cMes,'1'),5,2)
		    	         	BGQ->(MsUnlock())

			    	        B0L->(RecLock("B0L",.T.))
								B0L->B0L_FILIAL := xFilial("B0L")
								B0L->B0L_CODSEQ := GETSX8NUM("B0L","B0L_CODSEQ");CONFIRMSX8()
								B0L->B0L_ANO    := BGQ->BGQ_ANO
								B0L->B0L_MES    := BGQ->BGQ_MES
								B0L->B0L_VALOR  := BGQ->BGQ_VALOR
								B0L->B0L_DESCRI := STR0037 //"PRORROGACAO DE PARCELA PRESTADOR"
								B0L->B0L_USUARI := SUBSTR(cUsuario,7,15)
								B0L->B0L_DATALT	:= dDataBase
							   	B0L->B0L_CODOPE := B0K->B0K_CODOPE
							   	B0L->B0L_OPELOT := B0K->B0K_CODOPE
							   	B0L->B0L_LOTPAR := B0K->B0K_LOTPAR
							   	B0L->B0L_TIPO   := '2'
							B0L->(MsUnlock())

	    	         Endif
	    	     Next
	    	     MsgInfo(STR0038) //"Prorrogação concluida com sucesso !!!"
    	     Endif

    	Endif
    	BSQ->(DbGoTo(nRecBSQ))
    	BSQ->(DbSetOrder(nOrdBSQ))
	Endif
Endif

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA003Mo1 ³ Autor ³ Daher				³ Data ³ 01.09.10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Chama funcao para efetuar alteracao/exclusao de Lancamentos³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA003Mo1(cAlias, nReg, nOpc)
LOCAL cChave := ""

BSQ->(DbSetOrder(1))


If nOpc = 3

	If BGQ->BGQ_NUMLOT <> ' '
		MsgAlert(STR0024, STR0025)  //"Atencao"###"Lancamento ja faturado. Somente podera ser visualizado !"
		AxVisual(cAlias,nReg,K_Visualizar)
	Elseif BSQ->(MsSeek(xFilial("BSQ")+BGQ->BGQ_SEBSQP)) .and. !Empty(BGQ->BGQ_NUMLOT)
		MsgAlert(STR0024, STR0026)  //"Atencao"###"Lancamento viculado ao prestador ja faturado. Somente podera ser visualizado !"
		AxVisual(cAlias,nReg,K_Visualizar)
	Else
		AxAltera(cAlias,nReg,nOpc,,,,,)
		PLS003Al1()
	Endif

ElseIf nOpc = 4

	cChave := BGQ->BGQ_SEBSQP

	If BGQ->BGQ_NUMLOT <> ' '
		MsgAlert(STR0024, STR0027)  //"Atencao"###"Lancamento ja faturado. Nao podera ser excluido !"
	Elseif BSQ->(MsSeek(xFilial("BSQ")+BGQ->BGQ_SEBSQP)) .and. !Empty(BGQ->BGQ_NUMLOT)
		MsgAlert(STR0024, STR0028)  //"Atencao"###"Lancamento viculado ao prestador ja faturado. Nao podera ser excluido !"
	Endif

	RegToMemory(cAlias)
	AxDeleta(cAlias,nReg,nOpc)

    If BSQ->(MsSeek(xFilial("BSQ")+cChave)) .and. MsgYesNo(STR0039) //"Deseja excluir o lançamento vinculado ao beneficiario?"
		RegToMemory("BSQ")
		cCadastro 	:= STR0040 //"Debitos/Creditos vinculados para Beneficiario"
		AxDeleta("BSQ",BSQ->(Recno()),K_Excluir)
	Endif
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | PLS003Alt ³ Autor ³ Daher			    | Data ³ 11.05.2010±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³					    									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PLS003Alt()
Local lRet := .T.

B0L->(RecLock("B0L",.T.))
	B0L->B0L_FILIAL := xFilial("B0L")
	B0L->B0L_CODSEQ := GETSX8NUM("B0L","B0L_CODSEQ");CONFIRMSX8()
	B0L->B0L_ANO    := BSQ->BSQ_ANO
	B0L->B0L_MES    := BSQ->BSQ_MES
	B0L->B0L_VALOR  := BSQ->BSQ_VALOR
	B0L->B0L_DESCRI := STR0041 //"ALTERACAO DE DADOS DA PARCELA BENEFICIARIO"
	B0L->B0L_USUARI := SUBSTR(cUsuario,7,15)
	B0L->B0L_DATALT	:= dDataBase
   	B0L->B0L_CODOPE := B0K->B0K_CODOPE
   	B0L->B0L_OPELOT := B0K->B0K_CODOPE
   	B0L->B0L_LOTPAR := B0K->B0K_LOTPAR
   	B0L->B0L_TIPO   := '1'
B0L->(MsUnlock())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procura Lancto de Credito na RDA e se houve Alteracao                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BGQ->(DbSetOrder(10))
If BGQ->(MsSeek(xFilial("BGQ")+BSQ->BSQ_CODINT+BSQ->BSQ_CODSEQ))


		cCadastro 	:= STR0030 //"Debitos/Creditos vinculados para Prestador"
		AxAltera("BGQ",BGQ->(Recno()),K_Alterar,,,,,)

   		B0L->(RecLock("B0L",.T.))
			B0L->B0L_FILIAL := xFilial("B0L")
			B0L->B0L_CODSEQ := GETSX8NUM("B0L","B0L_CODSEQ");CONFIRMSX8()
			B0L->B0L_ANO    := BGQ->BGQ_ANO
			B0L->B0L_MES    := BGQ->BGQ_MES
			B0L->B0L_VALOR  := BGQ->BGQ_VALOR
			B0L->B0L_DESCRI := STR0042 //"ALTERACAO DE DADOS DA PARCELA PRESTADOR"
			B0L->B0L_USUARI := SUBSTR(cUsuario,7,15)
			B0L->B0L_DATALT	:= dDataBase
	       	B0L->B0L_OPELOT := B0K->B0K_CODOPE
	       	B0L->B0L_CODOPE := B0K->B0K_CODOPE
	       	B0L->B0L_LOTPAR := B0K->B0K_LOTPAR
		   	B0L->B0L_TIPO   := '2'
		B0L->(MsUnlock())

EndIf

If Existblock("PLSA003A5")
	Execblock("PLSA003A5",.F.,.F.,{})
Endif

Return lRet
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    | PLS003Alt ³ Autor ³ Daher			    | Data ³ 11.05.2010±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³					    									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PLS003Al1()
Local lRet := .T.

B0L->(RecLock("B0L",.T.))
	B0L->B0L_FILIAL := xFilial("B0L")
	B0L->B0L_CODSEQ := GETSX8NUM("B0L","B0L_CODSEQ");CONFIRMSX8()
	B0L->B0L_ANO    := BGQ->BGQ_ANO
	B0L->B0L_MES    := BGQ->BGQ_MES
	B0L->B0L_VALOR  := BGQ->BGQ_VALOR
	B0L->B0L_DESCRI := STR0042 //"ALTERACAO DE DADOS DA PARCELA PRESTADOR"
	B0L->B0L_USUARI := SUBSTR(cUsuario,7,15)
	B0L->B0L_DATALT	:= dDataBase
   	B0L->B0L_CODOPE := B0K->B0K_CODOPE
   	B0L->B0L_OPELOT := B0K->B0K_CODOPE
   	B0L->B0L_LOTPAR := B0K->B0K_LOTPAR
   	B0L->B0L_TIPO   := '2'
B0L->(MsUnlock())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Procura Lancto de Credito na RDA e se houve Alteracao                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BSQ->(DbSetOrder(1))
If BSQ->(MsSeek(xFilial("BSQ")+BGQ->BGQ_SEBSQP))


		cCadastro 	:= STR0040 //"Debitos/Creditos vinculados para Beneficiario"
		AxAltera("BSQ",BSQ->(Recno()),K_Alterar,,,,,)

   		B0L->(RecLock("B0L",.T.))
			B0L->B0L_FILIAL := xFilial("B0L")
			B0L->B0L_CODSEQ := GETSX8NUM("B0L","B0L_CODSEQ");CONFIRMSX8()
			B0L->B0L_ANO    := BSQ->BSQ_ANO
			B0L->B0L_MES    := BSQ->BSQ_MES
			B0L->B0L_VALOR  := BSQ->BSQ_VALOR
			B0L->B0L_DESCRI := STR0041 //"ALTERACAO DE DADOS DA PARCELA BENEFICIARIO"
			B0L->B0L_USUARI := SUBSTR(cUsuario,7,15)
			B0L->B0L_DATALT	:= dDataBase
	       	B0L->B0L_OPELOT := B0K->B0K_CODOPE
	       	B0L->B0L_CODOPE := B0K->B0K_CODOPE
	       	B0L->B0L_LOTPAR := B0K->B0K_LOTPAR
		   	B0L->B0L_TIPO   := '1'
		B0L->(MsUnlock())

EndIf

If Existblock("PLSA003A6")
	Execblock("PLSA003A6",.F.,.F.,{})
Endif

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA003VAR ³ Autor ³ Daher			    | Data ³ 11.05.2010±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³					    									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/

Function PLSA003VAR(cAlias,nReg,nOpc)

Local cFil

PRIVATE aRotina  := {   { STR0016	   , 'AxPesqui'     , 0 , K_Pesquisar  },; //"Pesquisar"
									{ STR0017	   , 'AxVisual' 	, 0 , K_Visualizar 	},; //"Visualizar"
									{ STR0018	   , 'PLSA003Mov'   , 0 , K_Alterar    	},; //"Mo&dificar"
									{ STR0019 	   , 'PLSA003Mov'   , 0 , K_Excluir    	},; //"Excluir"
									{ STR0020      , "PLSODHIS"  	, 0 , K_Incluir    	},; //"Historico"
									{ STR0021      , "PLSA756LEG"	, 0 , K_Incluir     },; //"Legenda"
									{ STR0043      , "PLSA003Mov"	, 0 , K_Incluir     } }  //"Prorrogar"

PRIVATE aCdCores  	:= { 	{ 'BR_VERDE'    ,'Lancamento Informado' },;
							{ 'BR_VERMELHO' ,'Lancamento Faturado' } }


Private cCadastro 	:= STR0044 //"Debitos/Creditos para Beneficiario"


If Existblock("PLSA003A7")
	aRotina := Execblock("PLSA003A7",.F.,.F.,{aRotina})
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sintaxe do Filtro para tela...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFil := "@BSQ_FILIAL = '"+xFilial("BSQ")+"' AND BSQ_CODINT = '"+B0K->B0K_CODOPE+"'  AND BSQ_LOTPAR = '"+B0K->B0K_LOTPAR+"' AND D_E_L_E_T_ = ' ' "

DbSelectArea("BSQ")
BSQ->(DbSetOrder(10))
If BSQ->(MsSeek(xFilial("BSQ")+B0K->B0K_CODOPE+B0K->B0K_LOTPAR))
	SET FILTER TO &cFil
	BSQ->(DbSeek(xFilial("BSQ")))
	BSQ->(mBrowse(06,01,22,75,'BSQ',,"BSQ->BSQ_NUMCOB <> ' '"))
	DbSelectArea("BSQ")
Else
	Aviso( STR0074, STR0023, {STR0073} )//"Registros"###"Nao existem registros relacionados a este lote."###"Ok"
Endif

SET FILTER TO

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PLSA003AAR ³ Autor ³ Daher			    | Data ³ 11.05.2010±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Ger. Parcelamento	    									  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
/*/
Function PLSA003AAR(cAlias, nReg, nOpc)

Local cCodSeq	   := ""
Local cUsuari	   := ""
Local cAno	   	   := ""
Local cMes	   	   := ""
Local cCodLan	   := ""
Local cCodRDA	   := ""
Local cNomRDA	   := ""
Local cPlGuiP 	   := "" //Variaveis Auxiliares
Local cCodLanBSQ   := GetNewPar("MV_PLYDBUS","001")            //Codigo Lancto de Debito do Usuario
Local cCodLanBGQ   := GetNewPar("MV_PLYCDRD","001")            //Codigo de Lancto para Credito da RDA
Local lParcMedico  := GetNewPar("MV_PLPARCE",'0') == '1'
Local nValorCob	   := 0
Local nValorPag	   := 0
Local aGuiaParc	   := {}
Local aStatus	   := {}
Local aTpPar	   := {}
Local aCodRda	   := {}
Local aMatric	   := {}
Local aMatric2	   := {}
Local aGuiaBloq	   := {}
Local nSel 		   := 0
Local nI		   := 1
Local aArea		   := GetArea()

BSP->(DbSetOrder(1))
If !BSP->(MsSeek(xFilial("BSP")+cCodLanBSQ))
    Aviso( STR0075, STR0045, {STR0073} )//"Tipo de Lançamento"###"Nao foi possivel localizar o tipo de lancamento padrao de debito/credito para o beneficiario"###"Ok"
	RestArea(aArea)
	return
Endif

If lParcMedico
	BBB->(DbSetOrder(1))
	If !BBB->(MsSeek(xFilial("BBB")+cCodLanBGQ))
		Aviso( STR0075, STR0046, {STR0073} )//"Tipo de Lançamento"###"Nao foi possivel localizar o tipo de lancamento padrao de debito/credito para a RDA"###"Ok"
		RestArea(aArea)
		return
	Endif
Endif

&(cAlias+"->(DbSetOrder(11))")
If &(cAlias+"->(MsSeek('"+xFilial(cAlias)+"'+'"+cMarca+"'))")
   While ! &(cAlias+"->(Eof())") .and. xFilial(cAlias)+cMarca == &(cAlias+"->"+cAlias+"_FILIAL")+&(cAlias+"->"+cAlias+"_OKMARK")
        aadd(aGuiaParc,&(cAlias+"->(Recno())"))
   		&(cAlias+"->(DbSkip())")
   Enddo
Else
	Aviso( STR0076, STR0047, {STR0073} )//"Selecão de Guias!"###"Nao existem guias selecionadas."###"Ok"
	RestArea(aArea)
	return
Endif

If MsgYesNo(STR0048) //"Deseja gerar um novo lote para as guias selecionadas?"

		For nI:=1 to Len(aGuiaParc)
			&(cAlias+"->(DbGoTo("+alltrim(str(aGuiaParc[nI]))+"))")

			If aScan(aMatric,{|x| x[1]+x[2]+x[3]+x[4] == &(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODEMP")+&(cAlias+"->"+cAlias+"_MATRIC")+&(cAlias+"->"+cAlias+"_TIPREG")}) == 0
				aadd(aMatric,{&(cAlias+"->"+cAlias+"_CODOPE"),;
								&(cAlias+"->"+cAlias+"_CODEMP"),;
								&(cAlias+"->"+cAlias+"_MATRIC"),;
								&(cAlias+"->"+cAlias+"_TIPREG"),;
								&(cAlias+"->"+cAlias+"_CONEMP"),;
								&(cAlias+"->"+cAlias+"_VERCON"),;
								&(cAlias+"->"+cAlias+"_SUBCON"),;
								&(cAlias+"->"+cAlias+"_VERSUB"),;
								&(cAlias+"->"+cAlias+"_NOMUSR")})
				aadd(aMatric2,{&(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODEMP")+&(cAlias+"->"+cAlias+"_MATRIC")+&(cAlias+"->"+cAlias+"_TIPREG"),;
								&(cAlias+"->"+cAlias+"_NOMUSR")})
			Endif
			nValorCob += &(cAlias+"->"+cAlias+"_VLRTPF")

			If aScan(aCodRda,{|x| x[1] == &(cAlias+"->"+cAlias+"_CODRDA")}) == 0
				aadd(aCodRda,{&(cAlias+"->"+cAlias+"_CODRDA"),&(cAlias+"->"+cAlias+"_NOMRDA")})
			Endif

			BD6->(DbSetOrder(1))
			If BD6->(MsSeek(xFilial("BD6")+&(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODLDP")+&(cAlias+"->"+cAlias+"_CODPEG")+&(cAlias+"->"+cAlias+"_NUMERO")+&(cAlias+"->"+cAlias+"_ORIMOV")))
				While !BD6->(Eof()) .and. xFilial("BD6")+&(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODLDP")+&(cAlias+"->"+cAlias+"_CODPEG")+&(cAlias+"->"+cAlias+"_NUMERO")+&(cAlias+"->"+cAlias+"_ORIMOV") == BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)

					BR8->(DbSetOrder(1))
					BR8->(MsSeek(xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO)))
					If BR8->BR8_ODONTO == '1'
						If aScan(aTpPar,{|x| x[1] == '2'}) == 0
							aadd(aTpPar,{'2','Parcelamento Odontologico'})
						Endif
					Else
						If aScan(aTpPar,{|x| x[1] == '1'}) == 0
				   			aadd(aTpPar,{'1','Parcelamento Medico'})
						Endif
					Endif
					BD6->(DbSkip())
				Enddo
			Endif

		Next


		If Len(aMatric) > 1
			nSel := PLSCRIGEN(aMatric2,{ {STR0049,"@R !!!!.!!!!.!!!!!!-!!",70} , {"Nome","@C",170 }} ,STR0050)[2]	 //"Matricula"###"Selecione o usuário para o qual deve ser realizado o parcelamento e confirme."
		Else
			nSel := 1
		Endif

		cCodInt := aMatric[nSel][1]
		cCodEmp := aMatric[nSel][2]
		cMatric := aMatric[nSel][3]
		cTipReg := aMatric[nSel][4]
		cConEmp := aMatric[nSel][5]
		cVerCon := aMatric[nSel][6]
		cSubCon := aMatric[nSel][7]
		cVerSub := aMatric[nSel][8]

		If Len(aTpPar) > 1
			nSel := PLSCRIGEN(aTpPar,{ {STR0051,"@C",70} , {STR0052,"@C",170 } } ,STR0053)[2]		 //"Codigo"###"Descricao"###"Selecione o tipo de parcelamento a ser realizado."
		Else
			nSel := 1
		Endif
		cTpPar := aTpPar[nSel][1]

		If lParcMedico
			If Len(aCodRda) > 1
				nSel := PLSCRIGEN(aCodRda,{ {STR0051,"@C",70} , {STR0054,"@C",120 } } ,STR0055)[2]	 //"Codigo"###"Nome"###"Selecione a RDA para o qual sera realizado o parcelamento."
				cCodRDA := aCodRda[nSel][1]
				cNomRDA := aCodRda[nSel][2]
			Else
				nSel := 1
				cCodRDA := aCodRda[nSel][1]
				cNomRDA := aCodRda[nSel][2]
			Endif
		Endif

		If lParcMedico
				For nI:=1 to Len(aGuiaParc)
					&(cAlias+"->(DbGoTo("+alltrim(str(aGuiaParc[nI]))+"))")

		            BD6->(DbSetOrder(1))
					If BD6->(MsSeek(xFilial("BD6")+&(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODLDP")+&(cAlias+"->"+cAlias+"_CODPEG")+&(cAlias+"->"+cAlias+"_NUMERO")+&(cAlias+"->"+cAlias+"_ORIMOV")))
						While !BD6->(Eof()) .and. xFilial("BD6")+&(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODLDP")+&(cAlias+"->"+cAlias+"_CODPEG")+&(cAlias+"->"+cAlias+"_NUMERO")+&(cAlias+"->"+cAlias+"_ORIMOV") == BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Marco os BD7 para o prestador como bloqueados						³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						    BD7->( DbSetOrder(1) )
							If BD7->( MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) ) )
								   While !BD7->(Eof()) .And.	BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) =;
																   	BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

										If BD7->BD7_CODRDA == cCodRDA .and.  BD7->BD7_BLOPAG <> '1' .and. BD7->BD7_VLRPAG > 0 .and. Empty(BD7->BD7_NUMLOT)
											nValorPag += BD7->BD7_VLRPAG
										Endif
										BD7->( DbSkip() )
									EndDo
						   	EndIf
							BD6->(DbSkip())
						Enddo
					Endif
				Next
		Endif

	    PLSA003ODA(cAlias,cCodInt,cCodEmp,cMatric,cTipReg,cConEmp,cVerCon,;
	    		   cSubCon,cVerSub,nValorCob,cTpPar,cCodLanBSQ,cCodLanBGQ,;
	    		   aGuiaParc,lParcMedico,cCodRDA,nValorPag,cNomRDA)

Endif

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ P003ProcPar³ Autor ³ Daher			    ³ Data ³ 11.05.10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ 						 									  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function P003ProcPar(lGrava,aCols,aDados,cLotePar,aHeader,lParcMedico,;
					 cCodLanBGQ,nValorPag,cAlias,aGuiaParc,cCodRDA,cNomRDA)
LOCAL aHeadBSQ := {}
LOCAL i		   := 1
LOCAL j		   := 1
LOCAL cChave   := ""
LOCAL cChaMe   := ""
LOCAL nPos 	   := 0
LOCAL nI	   := 1

store header "BSQ" to aHeadBSQ for .t.

Begin Transaction
while i <= len(aCols)
		If lGrava
			BSQ->(Reclock("BSQ",.T.))
				While j <= len(aHeadBSQ)
					If aHeadBSQ[j][10] == 'V'
					     j++
					     loop
					EndIf
					BSQ->BSQ_FILIAL := XFILIAL("BSQ")
					cChave := "BSQ->"+aHeadBSQ[j][2]
				    cChaMe := "M->"+aHeadBSQ[j][2]
				    &cChave:= &cChaMe
					if "BSQ_ANO" $ aHeadBSQ[j][2]
					    nPos := PLRETPOS("B1Q_ANO",aHeader)
						&cChave:= aCols[i][nPos]
					elseif "BSQ_MES" $ aHeadBSQ[j][2]
						nPos := PLRETPOS("B1Q_MES",aHeader)
						&cChave:= aCols[i][nPos]
					elseif "BSQ_LOTPAR" $ aHeadBSQ[j][2]
						&cChave:= cLotePar
					elseif "BSQ_VALOR" $ aHeadBSQ[j][2]
						nPos := PLRETPOS("B1Q_VALOR",aHeader)
						&cChave:= aCols[i][nPos]
				    elseif "BSQ_CODSEQ" $ aHeadBSQ[j][2]
						&cChave:= GetSx8Num('BSQ','BSQ_CODSEQ');confirmsx8()
					elseif "BSQ_ABERTO" $ aHeadBSQ[j][2]
						&cChave:= '1'
					elseif "BSQ_BLOCOB" $ aHeadBSQ[j][2]
						&cChave:= GetNewPar("MV_PABLOCP","0")
					endif
				    j++
				EndDo
			BSQ->(MsUnLock())
		Else
			aadd(aDados,{'001',aCols[i][PLRETPOS("B1Q_VALOR",aHeader)],aCols[i][PLRETPOS("B1Q_ANO",aHeader)],aCols[i][PLRETPOS("B1Q_MES",aHeader)],M->BSQ_USUARI,Posicione("BA1",2,XFILIAL("BA1")+M->BSQ_USUARI,"BA1_NOMUSR")})
		Endif

		If lGrava
			If lParcMedico
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		        //³ Inclui Credito para a RDA(BGQ)                                           ³
		        //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		        BBB->(DbSetOrder(1))
		        If BBB->(MsSeek(xFilial("BBB")+cCodLanBGQ))
			   	    BGQ->(Reclock("BGQ",.T.))
					BGQ->BGQ_FILIAL := xFilial("BGQ")
					BGQ->BGQ_CODSEQ := GETSX8NUM( 'BGQ','BGQ_CODSEQ' );ConfirmSx8()
					BGQ->BGQ_CODIGO := cCodRDA
					BGQ->BGQ_ANO	:= BSQ->BSQ_ANO
					BGQ->BGQ_MES    := BSQ->BSQ_MES
					BGQ->BGQ_CODLAN := cCodLanBGQ
					BGQ->BGQ_VALOR  := round(nValorPag/Val(BSQ->BSQ_NPARCE),2)
					BGQ->BGQ_TIPO   := BBB->BBB_TIPSER
					BGQ->BGQ_TIPOCT := '2'
					BGQ->BGQ_INCIR  := BBB->BBB_INCIR
					BGQ->BGQ_INCINS := BBB->BBB_INCINS
					BGQ->BGQ_INCPIS := BBB->BBB_INCPIS
					BGQ->BGQ_INCCOF := BBB->BBB_INCCOF
					BGQ->BGQ_INCCSL := BBB->BBB_INCCSL
					BGQ->BGQ_VERBA  := BBB->BBB_VERBA
					BGQ->BGQ_CODOPE := PlsIntPad()
					BGQ->BGQ_CONMFT := BBB->BBB_CONMFT
					BGQ->BGQ_NOME   := cNomRDA
					BGQ->BGQ_SEBSQP := BSQ->BSQ_CODSEQ
					BGQ->BGQ_LOTPAR := cLotePar
					BGQ->BGQ_BLOPAG := GetNewPar("MV_PABLOCP","0")

					BGQ->(MsUnLock())
				Endif
			Endif
			PLS756Grv()
		Else
			If lParcMedico
				aadd(aDados,{'002',round(nValorPag/Val(M->BSQ_NPARCE),2),aCols[i][PLRETPOS("B1Q_ANO",aHeader)],aCols[i][PLRETPOS("B1Q_MES",aHeader)],cCodRDA,cNomRDA})
			Endif
		Endif

		i++
	    j:=1
enddo

For nI:=1 to Len(aGuiaParc)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Marco a guia com o lote da parcela									³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		&(cAlias+"->(DbGoTo("+alltrim(str(aGuiaParc[nI]))+"))")
		If lGrava
			&(cAlias+"->(Reclock('"+cAlias+"',.F.))")
			&(cAlias+"->"+cAlias+"_LOTPAR"):= cLotePar
			&(cAlias+"->(MsUnlock())")
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Bloqueio os itens da guia 											³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PLSPOSGLO(PLSINTPAD(),__aCdCri177[1],__aCdCri177[2],'1',"1")
		BD6->(DbSetOrder(1))
		If BD6->(MsSeek(xFilial("BD6")+&(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODLDP")+&(cAlias+"->"+cAlias+"_CODPEG")+&(cAlias+"->"+cAlias+"_NUMERO")+&(cAlias+"->"+cAlias+"_ORIMOV")))
			While !BD6->(Eof()) .and. xFilial("BD6")+&(cAlias+"->"+cAlias+"_CODOPE")+&(cAlias+"->"+cAlias+"_CODLDP")+&(cAlias+"->"+cAlias+"_CODPEG")+&(cAlias+"->"+cAlias+"_NUMERO")+&(cAlias+"->"+cAlias+"_ORIMOV") == BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV)

			    If BD6->BD6_VLRTPF > 0 .and. Empty(BD6->BD6_NUMFAT)
				    If lGrava
						BD6->(Reclock("BD6",.F.))
						BD6->BD6_BLOCPA := '1'
						BD6->BD6_MOTBPF := __aCdCri177[1]
						BD6->BD6_DESBPF := PLSBCTDESC()
						BD6->(MsUnlock())
					Else
						aadd(aDados,{'003',&(cAlias+"->"+cAlias+"_CODOPE"),&(cAlias+"->"+cAlias+"_CODLDP"),&(cAlias+"->"+cAlias+"_CODPEG"),&(cAlias+"->"+cAlias+"_NUMERO"),BD6->BD6_SEQUEN,BD6->BD6_CODPAD,alltrim(BD6->BD6_CODPRO),padr(BD6->BD6_DESPRO,20),BD6->BD6_VLRTPF})
					Endif
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Marco os BD7 para o prestador como bloqueados						³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lParcMedico
			    	BD7->( DbSetOrder(1) )
				    If BD7->( MsSeek(xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) ) )
						   While !BD7->(Eof()) .And.	BD6->(BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN) =;
													   	BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN)

								If BD7->BD7_CODRDA == cCodRDA .and.  BD7->BD7_BLOPAG <> '1' .and. BD7->BD7_VLRPAG > 0 .and. Empty(BD7->BD7_NUMLOT)
									
									If lGrava
										BD7->(Reclock("BD7",.F.))
											PLBLOPC("BD7", .t., __aCdCri177[1], PLSBCTDESC())
										BD7->(MsUnlock())
									Else
										aadd(aDados,{'004',&(cAlias+"->"+cAlias+"_CODOPE"),&(cAlias+"->"+cAlias+"_CODLDP"),&(cAlias+"->"+cAlias+"_CODPEG"),&(cAlias+"->"+cAlias+"_NUMERO"),BD6->BD6_SEQUEN,BD6->BD6_CODPAD,alltrim(BD6->BD6_CODPRO),padr(BD6->BD6_DESPRO,20),BD7->BD7_VLRPAG,BD7->BD7_CODUNM})
									Endif
								Endif
								BD7->( DbSkip() )
						   EndDo
			   	    EndIf
				Endif

				BD6->(DbSkip())
			Enddo
		Endif
Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gravo o cabecalho													³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGrava
	B0K->(Reclock("B0K",.T.))
	B0K->B0K_FILIAL := xFilial("B0K")
	B0K->B0K_CODOPE := PlsIntPad()
	B0K->B0K_USUOPE := cUserName
	B0K->B0K_DATGER := dDataBase
	B0K->B0K_HORGER := alltrim(strtran(SUBSTR(Time(),1,5),':',''))
	B0K->B0K_LOTPAR := cLotePar
	B0K->(MsUnlock())
Endif

End Transaction

If Len(aDados) > 0
	aDados := aClone(ASort(aDados,,, { |x,y| x[1]+x[3]+x[4] < y[1]+y[3]+y[4] }))
Endif

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ P003AliTree³ Autor ³ Daher			    ³ Data ³ 11.05.10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³															  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function P003AliTree(oTree,aDados)
LOCAL nI	 := 1
LOCAL nJ 	 := 1
LOCAL cCargo := ""
LOCAL lFirst := .T.

For nI:= 1 to Len(aDados)
			cCargo := Soma1(cCargo)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monto a arvore dos debitos creditos para os beneficiarios                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nJ 	   := nI
			lFirst := .T.
			While nJ <= Len(aDados) .and. aDados[nJ][1] == '001'
				If lFirst
					oTree:AddTree(' [001] - Geracão de Débito/Crédito para o Beneficiario',.T.,"PCOFXOK",nil,"PCOFXOK",nil,cCargo)
					oTree:AddTree("["+TransForm(aDados[nJ][5],"@R !!!!.!!!!.!!!!!!-!!!")+"] ["+padr(aDados[nJ][6],20)+"] [ANO - "+aDados[nJ][3]+"]"+" [MES - "+aDados[nJ][4]+"]"+" [VALOR - R$ "+Alltrim(Str(round(aDados[nJ][2],2)))+"]",.T.,'',nil,'',nil,cCargo)
		        	oTree:EndTree()
		        	lFirst := .F.
		        Else
		        	oTree:AddTree("["+TransForm(aDados[nJ][5],"@R !!!!.!!!!.!!!!!!-!!!")+"] ["+padr(aDados[nJ][6],20)+"] [ANO - "+aDados[nJ][3]+"]"+" [MES - "+aDados[nJ][4]+"]"+" [VALOR - R$ "+Alltrim(Str(round(aDados[nJ][2],2)))+"]",.T.,'',nil,'',nil,cCargo)
		        	oTree:EndTree()
		        Endif
		        nJ++
			Enddo
			If !lFirst
				nI := nJ-1
				oTree:EndTree()
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monto a arvore dos debitos creditos para os prestadores                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nJ 	   := nI
			lFirst := .T.
			While nJ <= Len(aDados) .and. aDados[nJ][1] == '002'
				If lFirst
					oTree:AddTree(' [002] - Geracão de Débito/Crédito para o Prestador',.T.,"PCOFXOK",nil,"PCOFXOK",nil,cCargo)
		        	oTree:AddTree("["+aDados[nJ][5]+'] ['+ padr(aDados[nJ][6],20)+"] [ANO - "+aDados[nJ][3]+"]"+" [MES - "+aDados[nJ][4]+"]"+" [VALOR - R$ "+Alltrim(Str(round(aDados[nJ][2],2)))+"]",.T.,'',nil,'',nil,cCargo)
		        	oTree:EndTree()
		        	lFirst := .F.
		        Else
		        	oTree:AddTree("["+aDados[nJ][5]+'] ['+ padr(aDados[nJ][6],20)+"] [ANO - "+aDados[nJ][3]+"]"+" [MES - "+aDados[nJ][4]+"]"+" [VALOR - R$ "+Alltrim(Str(round(aDados[nJ][2],2)))+"]",.T.,'',nil,'',nil,cCargo)
		        	oTree:EndTree()
		        Endif
		        nJ++
			Enddo
			If !lFirst
				nI := nJ-1
				oTree:EndTree()
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monto a arvore dos bloqueios de guias				                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nJ 	   := nI
			lFirst := .T.
			While nJ <= Len(aDados) .and. aDados[nJ][1] == '003'
				If lFirst
					oTree:AddTree(' [003] - Itens de Guias Bloqueados para Cobrança',.T.,"PCOFXOK",nil,"PCOFXOK",nil,cCargo)
		        	oTree:AddTree("["+TransForm(aDados[nJ][2]+aDados[nJ][3]+aDados[nJ][4]+aDados[nJ][5]+aDados[nJ][6],"@R !!!!.!!!!.!!!!!!!!.!!!!!!!!-!!!")+'] ['+ aDados[nJ][7]+'.'+alltrim(aDados[nJ][8])+" - "+padr(aDados[nJ][9],20)+"] "+"[VALOR - R$ "+Alltrim(Str(round(aDados[nJ][10],2)))+"]",.T.,'',nil,'',nil,cCargo)
		        	oTree:EndTree()
		        	lFirst := .F.
		        Else
		        	oTree:AddTree("["+TransForm(aDados[nJ][2]+aDados[nJ][3]+aDados[nJ][4]+aDados[nJ][5]+aDados[nJ][6],"@R !!!!.!!!!.!!!!!!!!.!!!!!!!!-!!!")+'] ['+ aDados[nJ][7]+'.'+alltrim(aDados[nJ][8])+" - "+padr(aDados[nJ][9],20)+"] "+"[VALOR - R$ "+Alltrim(Str(round(aDados[nJ][10],2)))+"]",.T.,'',nil,'',nil,cCargo)
		        	oTree:EndTree()
		        Endif
		        nJ++
			Enddo
			If !lFirst
				nI := nJ-1
				oTree:EndTree()
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Monto a arvore dos bloqueios de subitens			                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nJ 	   := nI
			lFirst := .T.
			While nJ <= Len(aDados) .and. aDados[nJ][1] == '004'
				If lFirst
					oTree:AddTree(' [004] - Subitens de Guias Bloqueados para Pagamento',.T.,"PCOFXOK",nil,"PCOFXOK",nil,cCargo)
		        	oTree:AddTree("["+TransForm(aDados[nJ][2]+aDados[nJ][3]+aDados[nJ][4]+aDados[nJ][5]+aDados[nJ][6]+aDados[nJ][11],"@R !!!!.!!!!.!!!!!!!!.!!!!!!!!-!!!.!!!")+'] ['+ aDados[nJ][7]+'.'+alltrim(aDados[nJ][8])+" - "+padr(aDados[nJ][9],20)+"] "+"[VALOR - R$ "+Alltrim(Str(round(aDados[nJ][10],2)))+"]",.T.,'',nil,'',nil,cCargo)
		        	oTree:EndTree()
		        	lFirst := .F.
		        Else
		        	oTree:AddTree("["+TransForm(aDados[nJ][2]+aDados[nJ][3]+aDados[nJ][4]+aDados[nJ][5]+aDados[nJ][6]+aDados[nJ][11],"@R !!!!.!!!!.!!!!!!!!.!!!!!!!!-!!!.!!!")+'] ['+ aDados[nJ][7]+'.'+alltrim(aDados[nJ][8])+" - "+padr(aDados[nJ][9],20)+"] "+"[VALOR - R$ "+Alltrim(Str(round(aDados[nJ][10],2)))+"]",.T.,'',nil,'',nil,cCargo)
		        	oTree:EndTree()
		        Endif
		        nJ++
			Enddo
			If !lFirst
				nI := nJ-1
				oTree:EndTree()
			Endif

Next
oTree:EndUpdate()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA003ODA ³ Autor ³ Daher			    ³ Data ³ 11.05.10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Inclui debito/credito 									  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PLSA003ODA(cAlias,cCodInt,cCodEmp,cMatric,cTipReg,cConEmp,cVerCon,;
	    		    cSubCon,cVerSub,nValorCob,cTpPar,cCodLanBSQ,cCodLanBGQ,;
	    		    aGuiaParc,lParcMedico,cCodRDA,nValorPag,cNomRDA)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL nRecB0K	:= B0K->(Recno())
LOCAL nIndB0K	:= B0K->(IndexOrd())
LOCAL nOpca	    := 0
LOCAL oDlg
LOCAL cCadastro := STR0056  //"Debito/Credito"
LOCAL i 	    := 1
LOCAL j 	    := 1
LOCAL nI	    := 1
LOCAL lFirst	:= .T.
LOCAL nRecno 	:= 0
LOCAL cChave    := ""
LOCAL cChaMe    := ""
LOCAL cLotePar  := ""
LOCAL cCargo	:= "000"
LOCAL aHeadBSQ  := {}
Local I__f      := 0
Local lOdonto   := .F.
Local aButtons  := {}
LOCAL nLenNum 	:= Len(B0K->B0K_LOTPAR)
LOCAL oObjBrw	:= nil
LOCAL nTrb 		:= 115
LOCAL aSize 	:= {}
LOCAL aInfo 	:= {}
LOCAL aPosObj 	:= {}
LOCAL aFiles    := {}
LOCAL oTree 	:= {}
LOCAL aRetTab   := {}
LOCAL aDados	:= {}
LOCAL bOk		:= {|| nOpca := 1,oDlg:End()}
Local aAreaBG9	:= BG9->(GetArea())
PRIVATE aTELA[0][0]
PRIVATE aGETS[0]
PRIVATE aCols
PRIVATE aHeader

aSize := MsAdvSize()
aObjects := {}
AAdd( aObjects, { 1, 1, .T., .T., .F. } )
AAdd( aObjects, { 1, aSize[4] * 0.25, .T., .F., .F. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro FROM  aSize[7],0 To aSize[6],aSize[5] OF GetWndDefault() Pixel
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Enchoice...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
COPY 'BSQ' TO MEMORY BLANK
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega os Campos da Tela de Debito (BSQ) com os Dados da Guia (BD5      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
M->BSQ_CODSEQ := "AUTO"

If ExistBlock("PLSMATANT")
	M->BSQ_MATANT := Execblock("PLSMATANT",.f.,.f.,{cCodInt+cCodEmp+cMatric+cTipReg})
Else
	M->BSQ_MATANT := Posicione("BA1",2,XFILIAL("BA1")+cCodInt+cCodEmp+cMatric+cTipReg,"BA1_MATANT")
Endif

M->BSQ_USUARI := Posicione("BA1",2,XFILIAL("BA1")+cCodInt+cCodEmp+cMatric+cTipReg,"BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO")
M->BSQ_CODINT := cCodInt
M->BSQ_CODEMP := cCodEmp
M->BSQ_CONEMP := cConEmp
M->BSQ_VERCON := cVerCon
M->BSQ_SUBCON := cSubCon
M->BSQ_VERSUB := cVerSub
M->BSQ_MATRIC := cMatric
M->BSQ_TIPO   := Posicione("BSP",1,XFILIAL("BSP")+cCodLanBSQ,"BSP_TIPSER")
M->BSQ_CODLAN := cCodLanBSQ
M->BSQ_VALOR  := nValorCob
M->BSQ_TPPART := cTpPar //TIPO DE PARCELAMENTO 1=Medico;2=Odontologico

DbSelectArea("BG9")
BG9->(dbSetOrder(1))//BG9_FILIAL, BG9_CODINT, BG9_CODIGO, BG9_TIPO
If BG9->(MsSeek(xFilial("BG9")+cCodInt+cCodEmp))
	M->BSQ_TIPEMP := BG9->BG9_TIPO
EndIf
RestArea(aAreaBG9)

nOpc := K_Incluir
Zero();MsMGet():New('BSQ',0,K_Incluir,,,,,aPosObj[1],,,,,,oDlg,,,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta GetDados...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Copy "B1Q" TO Memory Blank
Store Header "B1Q" TO aHeader For .T.
Store COLS Blank "B1Q" TO aCols FROM aHeader
aCols[1][PLRETPOS("B1Q_ANO",aHeader)]    := Str(Year(dDataBase), 4)
aCols[1][PLRETPOS("B1Q_MES",aHeader)] 	  := StrZero(Month(dDataBase), 2)
aCols[1][PLRETPOS("B1Q_VALOR",aHeader)]	  := nValorCob
aCols[1][PLRETPOS("B1Q_CODPAR",aHeader)] := "01"

oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],K_Incluir,"AllwaysTrue","AllwaysTrue",,.T.,,,,,,,,,oDlg)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,{|| nOpca := 1,If(Obrigatorio(aGets,aTela) .and. PLS756TOk(),oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) },{||oDlg:End()},.F.,aButtons)  })

If nOpca == K_OK
	DEFINE MSDIALOG oDlg TITLE STR0057 FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()  //"Ações de parcelamento a serem executadas. Confirma o processamento?"
		oTree := DbTree():New(030,010,180,345,oDlg,nil,nil,.T.,nil)
		oTree:BuildTrb(nTrb,2)
		oTree:BeginUpdate()
		oTree:SetEnable()


		P003ProcPar(.F.,aCols,aDados,cLotePar,aHeader,lParcMedico,;
					 cCodLanBGQ,nValorPag,cAlias,aGuiaParc,cCodRDA,cNomRDA)

		P003AliTree(@oTree,aDados)

	ACTIVATE MSDIALOG oDlg ON INIT Eval( { || EnChoiceBar(oDlg,bOk,{||nOpca := 2,oDlg:End()},.F.,{}) })
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Rotina de gravacao dos dados...                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK

    B0K->(DbSetOrder(1))
    B0K->(MsSeek(xFilial("B0K")+PlsIntPad()+Replicate("Z",nLenNum),.T.))
    B0K->(DbSkip(-1))
    If B0K->(B0K_FILIAL+B0K_CODOPE) <> xFilial("B0K")+PlsIntPad()
    	cLotePar := StrZero(1,nLenNum)
    Else
    	cLotePar := StrZero(Val(B0K->B0K_LOTPAR)+1,nLenNum)
    Endif

	P003ProcPar(.T.,aCols,aDados,cLotePar,aHeader,lParcMedico,;
				 cCodLanBGQ,nValorPag,cAlias,aGuiaParc,cCodRDA,cNomRDA)

    If Existblock("PLSA003A8")
			Execblock("PLSA003A8",.F.,.F.,{cAlias,cCodInt,cCodEmp,cMatric,cTipReg,cConEmp,cVerCon,;
			    		   					cSubCon,cVerSub,nValorCob,cTpPar,cCodLanBSQ,cCodLanBGQ,;
			    		   					aGuiaParc,lParcMedico,cCodRDA,nValorPag,cNomRDA,cLotePar})
	Endif

	MsgInfo(STR0058) //"Ações de parcelamento concluidas com sucesso !!!"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Fecho o mbrowse														     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	B0K->(DbSetOrder(1))
	B0K->(MsSeek(xFilial("B0K")+cLotePar))
	oObjBrw := GetWndDefault()
	oObjBrw:End()
Else
	MsgInfo(STR0059) //"Ações de parcelamento abortadas."
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
B0K->(DbGoTo(nRecB0K))
B0K->(DbSetOrder(nIndB0K))
Return(nOpca)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSYODHIS  ³ Autor ³ Daher			    ³ Data ³ 11.05.10 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Historico de Alt/Exc/Reprocessamento de Parcelas  		  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSODHIS(cAlias, nReg, nOpc)
Local cFil
PRIVATE aRotina  := 	{ { STR0016        , 'AxPesqui'     , 0 , K_Pesquisar  },; //"Pesquisar"
						  { STR0017   , 'AxVisual' 	, 0 , K_Visualizar 	} }  //"Visualizar"

Private cCadastro 	:= STR0060 //"Historico de Manipulacao de Parcelas"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sintaxe do Filtro para tela...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cFil := "@B0L_FILIAL = '"+xFilial("B0L")+"' AND B0L_OPELOT = '"+B0K->B0K_CODOPE+"'  AND B0L_LOTPAR = '"+B0K->B0K_LOTPAR+"' AND B0L_TIPO = '"+If(cAlias=="BGQ",'2','1')+"' AND D_E_L_E_T_ = ' ' "


DbSelectArea("B0L")
B0L->(DbSetOrder(2))
Set Filter to &cFil

B0L->(DbSetOrder(1))
B0L->(DbSeek(xFilial("B0L")))
B0L->(DbGoTop())
B0L->(mBrowse(06,01,22,75,'B0L'))

DbSelectArea("B0L")
Set Filter to

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA003FAD ³ Autor ³ Daher             ³ Data ³ 13.05.2010 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Pede para selecionar um filtro de tipo de guias...         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA003FAD()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL oDlg
LOCAL cFiltro  	:= ""
LOCAL cFiltro2  	:= ""
LOCAL nOpca    	:= 0
LOCAL bOK      	:= { || nOpca := 1, oDlg:End() }
LOCAL bCancel  	:= { || nOpca := 0, oDlg:End() }
LOCAL aCores   	:= {}
LOCAL aCdCores 	:= {}
LOCAL nInd
LOCAL nFor
LOCAL oChkCab
LOCAL lChk01   	:= .F.
LOCAL lChk02   	:= .F.
LOCAL lChk03   	:= .F.
LOCAL lChk04    := .F.
LOCAL nColIni  	:= 020
LOCAL nLinIni  	:= 025
LOCAL cOpcFase		:= ""
LOCAL cGuia			:= "'',"
LOCAL oGrupo
LOCAL oCombFase
LOCAL oSayTipo
LOCAL oSay
PRIVATE cTipoPre	:= Space(50)
PRIVATE cMesDe		:= Space(02)
PRIVATE cMesAt		:= Space(02)
PRIVATE cAnoDe		:= Space(04)
PRIVATE cAnoAt		:= Space(04)
PRIVATE cRDADe		:= Space(06)
PRIVATE cRDAAt		:= Space(06)
PRIVATE cLocalDe	:= Space(04)
PRIVATE clocalAt	:= Space(04)
PRIVATE cFase		:= Space(01)
PRIVATE cCdOpeDe    := Space(04)
PRIVATE cCdOpeAte   := Space(04)
PRIVATE cEmpDe      := Space(04)
PRIVATE cEmpAte     := Space(04)
PRIVATE cMatDe      := Space(06)
PRIVATE cMatAte     := Space(06)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if Val(GetVersao(.F.)) >= 12 //Valida versão 12
	DEFINE MSDIALOG oDlg TITLE STR0061 FROM 8,5 TO 30,70 OF GetWndDefault()  //"Seleção de Guias"
Else
	DEFINE MSDIALOG oDlg TITLE STR0061 FROM 008.2,008.3 TO 28,068 OF GetWndDefault()  //"Seleção de Guias"
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca propriedades de guias x cores...                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PLSMCorCM(aCores,aCdCores,"BCI")
if Val(GetVersao(.F.)) >= 12 //Valida versão 12
	@ 016 + 15, 005  TO 150, 080  PIXEL OF oDlg LABEL 'Tipos de Guia'
	@ 016 + 15, 083  TO 160, 230 + 5 PIXEL OF oDlg LABEL 'Filtros'

	For nFor  := 1 To Len(aCdCores)
		If     nFor == 1
			lChk01 := .T.
			@ nLinIni-1 + 15 ,nColIni-12 CHECKBOX oChkCab VAR lChk01 PROMPT aCdCores[1,2] PIXEL SIZE 60, 09 OF oDlg
		ElseIf nFor == 2
			lChk02 := .T.
			@ nLinIni-1 + 15 ,nColIni-12 CHECKBOX oChkCab VAR lChk02 PROMPT aCdCores[2,2] PIXEL SIZE 60, 09 OF oDlg
		Endif

		nLinIni += 12
	Next

	@ 025 + 15, 116 SAY  STR0062 PIXEL OF oDlg  //"Mes de: "
	@ 025 + 15, 138 MSGET oSay VAR cMesDe SIZE 010,008 PIXEL OF oDlg
	@ 025 + 15, 170 SAY  STR0063 PIXEL  OF oDlg  //"Mes ate: "
	@ 025 + 15, 194 MSGET oSay VAR cMesAt SIZE 010,008 PIXEL OF oDlg

	@ 040 + 15, 115 SAY  STR0064 PIXEL OF oDlg  //"Ano de: "
	@ 040 + 15, 138 MSGET oSay VAR cAnoDe SIZE 010,008 PIXEL OF oDlg
	@ 040 + 15, 169 SAY  STR0065 PIXEL  OF oDlg  //"Ano ate: "
	@ 040 + 15, 194 MSGET oSay VAR cAnoAt SIZE 010,008 PIXEL OF oDlg

	@ 057 + 15, 115 SAY  STR0066 PIXEL OF oDlg  //"RDA de: "
	@ 057 + 15, 138 MSGET cRDADe F3 "BA0PLS" SIZE 010,008 PIXEL OF oDlg //hasbutton-DAHER
	@ 057 + 15, 180 SAY  STR0067 PIXEL  OF oDlg  //"Ate: "
	@ 057 + 15, 194 MSGET cRDAAt F3 "BA0PLS" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER

	@ 074 + 15, 089 SAY  STR0068 PIXEL OF oDlg  //"Local Digitacao de:"
	@ 074 + 15, 138 MSGET cLocalDe F3 "PLSLOC" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER
	@ 074 + 15, 180 SAY  STR0067 PIXEL  OF oDlg  //"Ate: "
	@ 074 + 15, 194 MSGET cLocalAt F3 "PLSLOC" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER

	@ 091 + 15, 100 SAY  STR0069 PIXEL OF oDlg  //"Operadora de:"
	@ 091 + 15, 138 MSGET cCdOpeDe F3 "B89PLS" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER
	@ 091 + 15, 180 SAY  STR0067 PIXEL  OF oDlg  //"Ate: "
	@ 091 + 15, 194 MSGET cCdOpeAte F3 "B89PLS" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER

	@ 108 + 15, 104 SAY  STR0070 PIXEL OF oDlg  //"Empresa de:"
	@ 108 + 15, 138 MSGET cEmpDe F3 "BQ2PLS" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER
	@ 108 + 15, 180 SAY  STR0067 PIXEL  OF oDlg  //"Ate: "
	@ 108 + 15, 194 MSGET cEmpAte F3 "BQ2PLS" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER

	@ 125 + 15, 104 SAY  STR0071 PIXEL OF oDlg  //"Matricula de:"
	@ 125 + 15, 138 MSGET cMatDe F3 "PLSMAT" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER
	@ 125 + 15, 180 SAY  STR0067 PIXEL  OF oDlg  //"Ate: "
	@ 125 + 15, 194 MSGET cMatAte  F3 "PLSMAT" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER
Else
	@ 016, 005  TO 145, 080 PIXEL OF oDlg LABEL 'Tipos de Guia'
	@ 016, 083  TO 145, 230 PIXEL OF oDlg LABEL 'Filtros'

	For nFor  := 1 To Len(aCdCores)
		If     nFor == 1
			lChk01 := .T.
			@ nLinIni-1,nColIni-12 CHECKBOX oChkCab VAR lChk01 PROMPT aCdCores[1,2] PIXEL SIZE 60, 09 OF oDlg
		ElseIf nFor == 2
			lChk02 := .T.
			@ nLinIni-1,nColIni-12 CHECKBOX oChkCab VAR lChk02 PROMPT aCdCores[2,2] PIXEL SIZE 60, 09 OF oDlg
		Endif

		nLinIni += 12
	Next

	@ 025, 116 SAY  STR0062 PIXEL OF oDlg  //"Mes de: "
	@ 025, 138 MSGET oSay VAR cMesDe SIZE 010,008 PIXEL OF oDlg
	@ 025, 170 SAY  STR0063 PIXEL  OF oDlg  //"Mes ate: "
	@ 025, 194 MSGET oSay VAR cMesAt SIZE 010,008 PIXEL OF oDlg

	@ 040, 115 SAY  STR0064 PIXEL OF oDlg  //"Ano de: "
	@ 040, 138 MSGET oSay VAR cAnoDe SIZE 010,008 PIXEL OF oDlg
	@ 040, 169 SAY  STR0065 PIXEL  OF oDlg  //"Ano ate: "
	@ 040, 194 MSGET oSay VAR cAnoAt SIZE 010,008 PIXEL OF oDlg

	@ 057, 115 SAY  STR0066 PIXEL OF oDlg  //"RDA de: "
	@ 057, 138 MSGET cRDADe F3 "BA0PLS" SIZE 010,008 PIXEL OF oDlg //hasbutton-DAHER
	@ 057, 180 SAY  STR0067 PIXEL  OF oDlg  //"Ate: "
	@ 057, 194 MSGET cRDAAt F3 "BA0PLS" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER

	@ 074, 089 SAY  STR0068 PIXEL OF oDlg  //"Local Digitacao de:"
	@ 074, 138 MSGET cLocalDe F3 "PLSLOC" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER
	@ 074, 180 SAY  STR0067 PIXEL  OF oDlg  //"Ate: "
	@ 074, 194 MSGET cLocalAt F3 "PLSLOC" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER

	@ 091, 100 SAY  STR0069 PIXEL OF oDlg  //"Operadora de:"
	@ 091, 138 MSGET cCdOpeDe F3 "B89PLS" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER
	@ 091, 180 SAY  STR0067 PIXEL  OF oDlg  //"Ate: "
	@ 091, 194 MSGET cCdOpeAte F3 "B89PLS" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER

	@ 108, 104 SAY  STR0070 PIXEL OF oDlg  //"Empresa de:"
	@ 108, 138 MSGET cEmpDe F3 "BQ2PLS" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER
	@ 108, 180 SAY  STR0067 PIXEL  OF oDlg  //"Ate: "
	@ 108, 194 MSGET cEmpAte F3 "BQ2PLS" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER

	@ 125, 104 SAY  STR0071 PIXEL OF oDlg  //"Matricula de:"
	@ 125, 138 MSGET cMatDe F3 "PLSMAT" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER
	@ 125, 180 SAY  STR0067 PIXEL  OF oDlg  //"Ate: "
	@ 125, 194 MSGET cMatAte  F3 "PLSMAT" SIZE 010,008 PIXEL OF oDlg//hasbutton-DAHER
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa a dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg,bOK,bCancel,.F.,{}) CENTER
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta filtro dinamico...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpca == K_OK
   For nFor := 1 To Len(aCdCores)
       If     nFor == 1 .And. lChk01
              cFiltro += +"'"+aCdCores[nFor,3]+"',"
              cGuia   += "'"+AllTrim( Str( Val( aCdCores[nFor,3] ) ) )+'='+aCdCores[nFor,2]+"',"
       ElseIf nFor == 2 .And. lChk02
              cFiltro += +"'"+aCdCores[nFor,3]+"',"
              cGuia   += "'"+AllTrim( Str( Val( aCdCores[nFor,3] ) ) )+'='+aCdCores[nFor,2]+"',"
       Endif
   Next
   cFiltro := "("+Subs(cFiltro,1,Len(cFiltro)-1)+")"

	For nFor :=1 To 7
		If nFor == 1
			If !Empty(cMesDe) .or. !Empty(cMesAt)
			    cFiltro2 += " AND BD5_MESPAG >= '" + AllTRIM(cMesDe) + "'
				cFiltro2 += " AND BD5_MESPAG <= '" + AllTRIM(cMesAt) + "'
			Endif
		ElseIf nFor == 2
			If !Empty(cAnoAt)
			    cFiltro2 += " AND BD5_ANOPAG >= '" + AllTRIM(cAnoDe) + "'
				cFiltro2 += " AND BD5_ANOPAG <= '" + AllTRIM(cAnoAt) + "'
		   EndIf
		ElseIf nFor == 3
			If !Empty(cRDAAt)
			    cFiltro2 += " AND BD5_CODRDA >= '" + AllTRIM(cRDADe) + "'
				cFiltro2 += " AND BD5_CODRDA <= '" + AllTRIM(cRDAAt) + "'
			EndIf
		ElseIf nFor == 4
			If !Empty(cLocalAt)
			    cFiltro2 += " AND BD5_CODLDP >= '" + AllTRIM(cLocalDe) + "'
				cFiltro2 += " AND BD5_CODLDP <= '" + AllTRIM(cLocalAt) + "'
			EndIf
		ElseIf nFor == 5
			If !Empty(cCdOpeAte)
			    cFiltro2 += " AND BD5_CODOPE >= '" + AllTRIM(cCdOpeDe) + "'
				cFiltro2 += " AND BD5_CODOPE <= '" + AllTRIM(cCdOpeAte) + "'
			EndIf
		ElseIf nFor == 6
			If !Empty(cEmpAte)
			    cFiltro2 += " AND BD5_CODEMP >= '" + AllTRIM(cEmpDe) + "'
				cFiltro2 += " AND BD5_CODEMP <= '" + AllTRIM(cEmpAte) + "'
			EndIf
		ElseIf nFor == 7
			If !Empty(cMatAte)
			    cFiltro2 += " AND BD5_MATRIC >= '" + AllTRIM(cMatDe) + "'
				cFiltro2 += " AND BD5_MATRIC <= '" + AllTRIM(cMatAte) + "'
			EndIf
		EndIf
	Next

Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna para a matric de pesquisa somente as guias selecionadas no filtro³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aMatGui := {}
cGuia   := SubString( cGuia,1,Len( cGuia )-1 )
aMatGui := &('{'+cGuia+'}')
If Len(aMatGui) == 2
   aMatGui := {aMatGui[2]}
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return({IF(nOpca==K_OK,.T.,.F.),cFiltro,cFiltro2 })