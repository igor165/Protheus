#INCLUDE "PLSA300a.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300HOR ³ Autor ³ Tulio Cesar        ³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna os horarios disponiveis de uma intervalo de/ate   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA300Hr(cHorIni,cHorFin,cInterv,cExcIni,cExcFin,cPltIni,cPltFin)

LOCAL cHora     	:= cHorIni
LOCAL aHorarios 	:= {}
LOCAL nLen        
LOCAL cAux      	:= Subs(cInterv,1,2)
LOCAL cAux1			:= StrTran(cInterv, ":","")
LOCAL lIntervalo    := Iif(!Empty(cExcIni) .and. !Empty(cExcFin), .T., .F.)
PRIVATE lBBD_ATERNA := BBD->(FieldPos("BBD_ATERNA")) > 0

If ! Empty(cAux) .and. cAux1 > '0000'
	While cHora <= cHorFin
		If lIntervalo
			If cHora >= cExcIni .and.  cHora < cExcFin
				cHora := cExcFin
				Loop
			Endif
		Endif
		aadd(aHorarios,cHora)
		cHora := PlsSomaHor(cHora,cInterv)
	Enddo

	If !Empty(cPltIni) .and. !Empty(cPltFin)
		cHora := cPltIni	
		While cHora < cPltFin
			aadd(aHorarios,cHora)
			cHora := PlsSomaHor(cHora,cInterv)
		Enddo
	Endif
		
	nLen := Len(aHorarios)-1
	aSize(aHorarios,nLen)
	
Elseif cAux == '0000'
	aadd(aHorarios,cHorIni)
	aadd(aHorarios,cHorFin)
Else	
	FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', STR0001 , 0, 0, {}) //"Existe horarios de agenda em branco. Verifique (PLSA300HR)"
Endif   

Return(aHorarios)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300PES ³ Autor ³ Tulio Cesar        ³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa uma agenda de um paciente...                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA300PES()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cNomPac    := Space(40)
LOCAL oDlgPesPac
LOCAL oSayPac
LOCAL lConfirm   := .F.
LOCAL aBrowPac   := {}
LOCAL aVetPad    := { {"","","","","","",0,'',0,'','','','',''} }
LOCAL oBrowPac
LOCAL bFecha     := { || nLin := oBrowPac:nAt, lConfirm := .T., oDlgPesPac:End() }
LOCAL bCancel    := { || oDlgPesPac:End() }
LOCAL bRefresh   := { || PLSA300Pq(AllTrim(cNomPac),aBrowPac,aVetPad,oBrowPac),;
						 oSayTxt1:Refresh(), oSayTxt2:Refresh()  }
LOCAL dData      
LOCAL cHorario                     
LOCAL nLin
LOCAL nRegBBD    := 0
LOCAL oSayTxt1
LOCAL oSayTxt2
LOCAL oSayTxt3

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define fontes utilizadas somente nesta funcao...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFont 	 NAME "Arial" SIZE 0,-11 BOLD                               
DEFINE FONT oFontDat NAME "Arial" SIZE 000,-017 
DEFINE FONT oFontRod NAME "Arial" SIZE 000,-014 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPesPac TITLE STR0002 FROM 008.2,000 TO 025,ndColFin OF GetWndDefault() //"Pesquisa de Agenda"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta objeto que recebera o nome a ser pesquisado...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
@ 007,008 SAY oSayPac PROMPT STR0003  SIZE 220,010 OF oDlgPesPac PIXEL COLOR CLR_HBLUE  //"Nome do Paciente       "
@ 006,068 MSGET cNomPac                                 SIZE 140,010 OF oDlgPesPac PIXEL PICTURE "@!" VALID Eval(bRefresh)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Browse...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aBrowPac := aClone(aVetPad)

oBrowPac := TcBrowse():New( 025, 008, 378, 060,,,, oDlgPesPac,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrowPac:AddColumn(TcColumn():New(STR0004,nil,; //"Paciente"
         nil,nil,nil,nil,065,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPac:ACOLUMNS[1]:BDATA     := { || Transform(aBrowPac[oBrowPac:nAt,12], __cPictUsr) }                  
oBrowPac:AddColumn(TcColumn():New(STR0005,nil,; //"Nome"
         nil,nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPac:ACOLUMNS[2]:BDATA     := { || aBrowPac[oBrowPac:nAt,1] }
oBrowPac:AddColumn(TcColumn():New(STR0006,nil,; //"Data"
         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPac:ACOLUMNS[3]:BDATA     := { || aBrowPac[oBrowPac:nAt,2] }
oBrowPac:AddColumn(TcColumn():New(STR0007,nil,; //"Horario"
         nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPac:ACOLUMNS[4]:BDATA     := { || aBrowPac[oBrowPac:nAt,3] }         
oBrowPac:AddColumn(TcColumn():New(STR0008,nil,; //"Medico"
         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPac:ACOLUMNS[5]:BDATA     := { || aBrowPac[oBrowPac:nAt,4] }
oBrowPac:AddColumn(TcColumn():New(STR0009,nil,; //"Especialidade"
         nil,nil,nil,nil,045,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPac:ACOLUMNS[6]:BDATA     := { || aBrowPac[oBrowPac:nAt,5] }
oBrowPac:AddColumn(TcColumn():New(STR0010,nil,; //"Localidade"
         nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPac:ACOLUMNS[7]:BDATA     := { || aBrowPac[oBrowPac:nAt,6] }
oBrowPac:AddColumn(TcColumn():New(STR0011,nil,; //"Usr. Sistema"
         nil,nil,nil,nil,050,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPac:ACOLUMNS[8]:BDATA     := { || aBrowPac[oBrowPac:nAt,13] }

oBrowPac:SetArray(aBrowPac)
oBrowPac:BLDBLCLICK		:= bFecha
oBrowPac:bChange		:= {|| oSayTxt1:Refresh(), oSayTxt2:Refresh(), oSayTxt3:Refresh() }

@ 090, 007 Say oSayTxt1 PROMPT STR0012 					SIZE 060, 010 OF oDlgPesPac PIXEL FONT oFontRod //"Empresa:"
@ 090, 060 Say oSayTxt1 PROMPT aBrowPac[oBrowPac:nAt,10]	SIZE 180, 010 OF oDlgPesPac PIXEL COLOR CLR_HBLUE FONT oFontRod
                              
@ 102, 007 Say oSayTxt2 PROMPT STR0013 					SIZE 060, 010 OF oDlgPesPac PIXEL FONT oFontRod //"Titular:"
@ 102, 060 Say oSayTxt2 PROMPT aBrowPac[oBrowPac:nAt,11]	SIZE 180, 010 OF oDlgPesPac PIXEL COLOR CLR_HBLUE FONT oFontRod

@ 114, 007 Say oSayTxt3 PROMPT STR0014 				SIZE 060, 010 OF oDlgPesPac PIXEL FONT oFontRod //"Solicitante:"
@ 114, 060 Say oSayTxt3 PROMPT aBrowPac[oBrowPac:nAt,14]	SIZE 180, 010 OF oDlgPesPac PIXEL COLOR CLR_HBLUE FONT oFontRod

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define botoes da tela...                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE SBUTTON FROM 110,330 TYPE 1  ACTION Eval(bFecha)  ENABLE OF oDlgPesPac
DEFINE SBUTTON FROM 110,360 TYPE 2  ACTION Eval(bCancel) ENABLE OF oDlgPesPac

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgPesPac
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna a data e o horario...                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lConfirm
   dData    := cTod(Subs(aBrowPac[nLin,2],1,10))
   cHorario := aBrowPac[nLin,3]  
   nRegBBD  := aBrowPac[nLin,7]  
   BBD->( dbGoto( aBrowPac[nLin,7] ) )
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da Funcao...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return({dData,cHorario,lConfirm,nRegBBD})

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300APQ ³ Autor ³ Tulio Cesar        ³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa usuarios...                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA300APq(cNomeUsr,oDlgRes,nTamDlgBrw,aListaUsr,oListaUsr)
LOCAL aPad 		:= { { "","","",0,.T.,"","","" } }
LOCAL lRet 		:= .F.                
                         
If Alltrim(cPartic) = "1"
	Return(.T.)
Endif

If Empty(cNomeUsr)
   Return(.T.)
Else
   lRet := .T.
Endif   

aListaUsr := {}
                                                
BA1->(DbSetOrder(3))
BA1->(MsSeek(xFilial("BA1")+AllTrim(cNomeUsr)))

While  	!BA1->(Eof()) .And. xFilial("BA1")+AllTrim(cNomeUsr) == ;
		 BA1->(BA1_FILIAL+Subs(BA1_NOMUSR,1,Len(AllTrim(cNomeUsr))))

	If ! Empty(BA1->BA1_MOTBLO)
		BA1->(DbSkip())
		Loop
	Endif
	
	BTS->(DbSetOrder(1))
	BTS->(MsSeek(xFilial("BTS")+BA1->BA1_MATVID))

	BT5->(DbSetOrder(1))
	BT5->(MsSeek(xFilial("BT5")+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_CONEMP))	
	
	SA1->(DbSetOrder(1))
	SA1->(MsSeek(xFilial("BA1")+BT5->BT5_CODCLI))	
				
	aadd(aListaUsr,{BA1->BA1_NOMUSR,;
		TransForm(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"@R !.!!!.!!!!.!!!!!!-!!-!"),;
		BA1->BA1_TELEFO,;
		BA1->(Recno()),;
		.T.,;
		BA1->BA1_MATANT, BA1->BA1_MAE, SA1->A1_NOME})
	BA1->(DbSkip())
Enddo

If Len(aListaUsr) == 0
   aListaUsr := aClone(aPad)
Endif   

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSA300TPE ³ Autor ³ Tulio Cesar        ³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Trata periodicidade...                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA300TPe(cMatricUsr,dData,cCodEsp,nDsPer,oEnc, lDireto,lDesmarca)
LOCAL nOrdBBD := BBD->(IndexOrd())
LOCAL nRecBBD := BBD->(Recno())         
LOCAL dAuxDep := dData+nDsPer
LOCAL dAuxAnt := dData-nDsPer
LOCAL nRecBA1 := BA1->( Recno() )
LOCAL lLog01
LOCAL lLog02
LOCAL lRet    := .T.
LOCAL bFecha  := { || BBD->(DbSetOrder(nOrdBBD)), BBD->(DbGoTo(nRecBBD)), lRet }

LOCAL bNomCre := { || BAU->(DbSetOrder(1)), ;
                       BAU->(MsSeek(xFilial("BAU")+BBD->(BBD_CODIGO))),  ;
                       AllTrim(X3COMBO("BAU_LEGEND",BAU->BAU_LEGEND))+". "+AllTrim(BAU->BAU_NOME) }
                       
DEFAULT lDireto := .F.                       
DEFAULT lDesmarca := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a matricula sem os pontinhos...                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMatricUsr := StrTran(cMatricUsr,".","")
cMatricUsr := StrTran(cMatricUsr,"-","")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Nao testa perioticidade para pacientes particulares...                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cMatricUsr == "99999999999999999"
	lRet := .T.
	lRefresh := .T.
	oEnc:Refresh()
	Return(Eval(bFecha))
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Em alguns casos nao sera nescessario esta verificacao...                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                         
If lDireto 
	lRet := .T.
	lRefresh := .T.
	oEnc:Refresh()
	Return(Eval(bFecha))
Endif

//AREA DE TRABALHO PARA ABERTURA DO BROWSER
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Busca no prazo inferior ao definido em parametro...                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BBD->(DbSetOrder(2))
If BBD->(MsSeek(xFilial("BBD")+cMatricUsr+cCodEsp))
   While ! BBD->(Eof()) .And. ;
         BBD->(BBD_FILIAL+BBD_CODPAC+BBD_CODESP) == xFilial("BBD")+cMatricUsr+cCodEsp 
         
         lLog01 := ( dtos(BBD->BBD_DATA) >= dtos(dAuxAnt) )
         lLog02 := ( dtos(BBD->BBD_DATA) <= dtos(dAuxDep) )

         If lLog01 .And. lLog02
            If (Empty(BBD->BBD_NUMATE) .And. Empty(BBD->BBD_CODCAN) ) //dtos(dData) >= dtos(BBD->BBD_DATA) ) .And. 
            	//While .T.
                   nCaso := Aviso(STR0015,STR0016,{"&OK",STR0017,STR0018}) //"Marcacao de Consultas"###"Ja existe uma agenda em aberto para este usuario/prestador/especialidade"###"&Visualizar"###"&Fechar"
                   Do Case
                      Case nCaso == 1
                      		lRet := .T.
                      		Return(Eval(bFecha))
                      Case nCaso == 2
                      		PLSA300VIS(lDesmarca,cMatricUsr,cCodEsp)  
                      		If TYPE("bFiltro") == 'B'
	                      	   Eval(bFiltro)
	                      	EndIf   
	                      	BA1->( DbGoto(nRecBA1) )
                      Case nCaso == 3
                            lRet := .F.
                      		Return(Eval(bFecha))
                   EndCase
             	//Enddo
            Endif
//            ElseIf ( dtos(dData) < dtos(BBD->BBD_DATA) ) .and. (Empty(BBD->BBD_CODCAN))
//                   lRet := MsgYesNo("Ja existe agenda posterior a data que ja esta querendo agendar. Agenda ja marcada "+dtoc(BBD->BBD_DATA)+" horario "+BBD->BBD_HORA+Space(10)+"Deseja continuar ?")
//                   Return(Eval(bFecha))
//            Endif           
       Endif               
	   BBD->(DbSkip())     
   Enddo                    
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(Eval(bFecha))

Function PLSA300VDt(dData)
LOCAL lRet := .F.
LOCAL dOld  

LOCAL lBranco := Empty(dData)
               
// Desabilita variavel que indica que o botao "proxima agenda" foi pressionado.
lByPass := .F.         

If ! lBranco
   lRet := ( dtos(DdATA) >= DtoS( MSDate() ) )
   If lRet 
      lRet := Eval(bFiltro)
      If !lRet
         MsgInfo(STR0019) //"Data sem agenda para a especialidade selecionada."
         lRet := .T.
      Endif
   Else
      MsgInfo(STR0020) //"Data anterior a data base do sistema"
   Endif  
Endif
dOld := dData

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300PUsºAutor  ³Geraldo Felix Juniorº Data ³  06/13/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validacao do campo matricula do paciente da marcacao de    º±±
±±º          ³consultas.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA300PUs(cMatrUsr)
LOCAL   lRet    := .F.               
LOCAL   dData
LOCAL 	_cCodEsp
LOCAL   cNReduz
LOCAL	oPac
LOCAL  lBBD_ATERNA := BBD->(FieldPos("BBD_ATERNA")) > 0
PRIVATE aDadUsr := {}    

If Type("oEnc") == 'O'
	oPac := oEnc
ElseIf Type("oUsr") == 'O'
	oPac := oUsr
Else
	Return (lRet)
Endif

If Type('M->BBO_DATA') == "D"
   dData := M->BBO_DATA
Else 
   dData := dDataBase
Endif   

If Type('M->BBO_CODESP') == "C"
   _cCodEsp := M->BBO_CODESP
Else 
   _cCodEsp := cCodEsp
Endif   

lRet := PLSA090USR(cMatrUsr,dData,Time(),"BBD")
If lRet                                         
   aDadUsr := PLSGETUsr()
   lRet := PLSA300TPe(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),dData,_cCodEsp,GetNewPar("MV_PLDSCAG",30),oPac:oBox,,.T.)//Dias para agendamento de consultas mesma especial.
   
   If lRet
      lRefresh := .T.
      M->BBD_CODPAC := BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
      M->BBD_NOME   := BA1->BA1_NOMUSR
      M->BBD_TELEFO := BA1->BA1_TELEFO
      M->BBD_MATANT := BA1->BA1_MATANT
      If lBBD_ATERNA//BBD->(FieldPos("BBD_ATERNA")) > 0 
         M->BBD_ATERNA := "0"
      EndIf   
   Endif
Endif

cNReduz:= Posicione("BA1",2,xFilial("BA1")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),"BA1_NREDUZ")
If Empty(cNReduz)
   BA3->( DbSetOrder(01) )
   BA3->( MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)) )
   cNReduz := Posicione("BG9",1,xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_TIPOUS),"BG9_NREDUZ")
EndIf
M->BBO_NOME 	:= BA1->BA1_NOMUSR
M->BBO_NOMEMP 	:= cNReduz
M->BBO_CODPAC 	:= BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)
M->BBO_TELEFO 	:= BA1->BA1_TELEFO
M->BBO_MATANT 	:= BA1->BA1_MATANT
If BBO->(FieldPos("BBO_ATERNA")) > 0 
   M->BBO_ATERNA := "0"
EndIf   

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300FesºAutor  ³Microsiga           º Data ³  06/13/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA300Fes(cCodEsp,cCodInt,cCodLoc,dData)
LOCAL lRet
LOCAL cDia := AllTrim(Str(Dow(dData)))                                           

lRet := Eval(bSeekBB7,cCodInt,cCodLoc,cCodEsp,cDia)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300CESºAutor  ³Microsiga           º Data ³  06/13/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA300CES(cCodInt,cCodLoc,dData,cCodEsp)
Local lRet := If(Empty(cCodEsp),.T.,BAQ->(ExistCpo("BAQ",cCodEsp,1)))
LOCAL cDia := AllTrim(Str(Dow(dData)))                                           

If lRet
   lRet := Eval(bSeekBB7,cCodInt,cCodLoc,cCodEsp,cDia)
Endif   

If lRet
   Eval(bFiltro)
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300CLCºAutor  ³Microsiga           º Data ³  06/13/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA300CLC(cCodInt,cCodLoc)
LOCAL lRet := BD1->(ExistCpo("BD1",cCodInt+cCodLoc,1))

If lRet
   Eval(bFiltro)
Endif

Return(lRet)    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300CRAºAutor  ³Microsiga           º Data ³  06/13/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA300CRA(cCodCre)
LOCAL lRet := If(Empty(cCodCre),.T.,BAU->(ExistCpo("BAU",cCodCre,1)))

If lRet
   Eval(bFiltro)
Endif
                
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300OpeºAutor  ³Microsiga           º Data ³  06/13/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA300Ope(cCodOpe)
LOCAL lRet :=IF(Empty(M->BBO_CODINT),.T.,BA0->(ExistCpo("BA0",M->BBO_CODINT,1)))

If lRet
   Eval(bFiltro)
Endif

Return(lRet)  

//CRIACAO DA FUNCAO PARA ABRIR BROWSER DE INFORMACAO SOBRE CONSULTAS MEDICAS
         
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA300VISºAutor  ³FAGUNDES, Jobson G. º Data ³             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ CRIA UMA PESQUISA QUE MOSTRA TODAS AS CONSULTAS DE UM      º±±
±±º          ³ USUARIO.                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function PLSA300VIS(lDesmarca,cMatricUsr,cCodEsp)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cNomPac    
LOCAL oDlgVisPac
LOCAL cSQLV  
LOCAL cNmMed
LOCAL cEspec
LOCAL dDt
LOCAL nLin
LOCAL cLoc
LOCAL oBrowPacV
LOCAL lConfirm   	:= .F.
LOCAL aBrowPacV   	:= {}
LOCAL aVetPadV    	:= { {"","","","","","","","","",""} }
LOCAL bCancelV    	:= { || oDlgVisPac:End() }
LOCAL cNomTit		:= ''
LOCAL cNReduz		:= ''
LOCAL oFont 	 
LOCAL oFontDat 
LOCAL oFontRod 
LOCAL oSayTxt1
LOCAL oSayTxt2
LOCAL oSayTxt3
LOCAL oBtn
LOCAL cNomSol		:= ''
LOCAL nRegBAU := BAU->( Recno() )
LOCAL aRet          
DEFAULT lDesmarca	:= .T.
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define fontes utilizadas somente nesta funcao...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFont 	 NAME "Arial" SIZE 0,-11 BOLD                               
DEFINE FONT oFontDat NAME "Arial" SIZE 000,-017 
DEFINE FONT oFontRod NAME "Arial" SIZE 000,-014 BOLD

DEFINE MSDIALOG oDlgVisPac TITLE STR0002 FROM 008.2,000 TO 027,ndColFin OF GetWndDefault() //"Pesquisa de Agenda"

// Efetua busca...                                                          
cSQLV := " SELECT BBD_FILIAL, BBD_NOME, BBD_HORA, BBD_DATA, BBD_CODIGO, BBD_CODESP, BBD_LOCAL, BBD_CODLOC, R_E_C_N_O_ AS REGBBD ,BBD_CODINT ,BBD_CODPAC ,BBD_CODSOL "
cSQLV += " FROM "+BBD->(RetSQLName("BBD"))
cSQLV += " WHERE BBD_FILIAL	= '"+xFilial("BBD")+"' "
cSQLV += "   AND BBD_CODPAC = '"+cMatricUsr+"' "
cSQLV += "   AND BBD_CODESP = '"+cCodEsp+"' "
cSQLV += "   AND BBD_NUMATE = '"+Space(TamSX3("BBD_NUMATE")[1])+"' "
cSQLV += "   AND BBD_CODCAN = '' "
cSQLV += "   AND D_E_L_E_T_ = ' ' "
cSQLV += " ORDER BY BBD_FILIAL,BBD_NOME,BBD_DATA,BBD_HORA "
PLSQuery(cSQLV,"TrbPesV")

TrbPesV->(DbGoTop())
While ! TrbPesV->(Eof())	
	
	dDt    := TrbPesV->BBD_DATA
	dDt    := dToc(dDt) + " ("+PLSDIASEM(dDt)+")"
	cNmMed := Posicione("BAU",1,xFilial("BAU")+TrbPesV->BBD_CODIGO,"BAU_NOME")
	cEspec := Posicione("BAQ",1,xFilial("BAQ")+TrbPesV->BBD_CODINT+BBD_CODESP,"BAQ_DESCRI")
	cLoc   := Posicione("BD1",1,xFilial("BD1")+TrbPesV->BBD_CODINT+BBD_LOCAL,"BD1_DESLOC")
	cNomTit:= Posicione("BA1",2,xFilial("BA1")+Substr(TrbPesV->BBD_CODPAC,1, 14)+GetNewPar("MV_PLCDTGP","01"),"BA1_NOMUSR")//Codigo do Grau de Parentesco do Titular
	cNReduz:= Posicione("BA1",2,xFilial("BA1")+TrbPesV->BBD_CODPAC,"BA1_NREDUZ")
	If Empty(cNReduz)
	   BA3->( DbSetOrder(01) )
	   	   BA3->( MsSeek(xFilial("BA3")+Left(cMatricUsr,14)) )
	   cNReduz := Posicione("BG9",1,xFilial("BG9")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_TIPOUS),"BG9_NREDUZ")
	EndIf
	cNomSol:= Iif(TrbPesV->BBD_CODSOL == '999999','PACIENTE',TrbPesV->BBD_CODSOL+'-'+;
			  Posicione("BAU",1,xFilial("BAU")+TrbPesV->BBD_CODSOL,"BAU_NOME"))

	TrbPesV->(aadd(aBrowPacV,{BBD_NOME,dDt,BBD_HORA,cNmMed,cEspec,cLoc,cNReduz,cNomTit,BBD_CODPAC,cNomSol,REGBBD}))
	TrbPesV->(DbSkip())
Enddo
      
TrbPesV->(DbCloseArea())
DbSelectArea("BA1")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa resultado da pesquisa...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aBrowPacV) == 0
   aBrowPacV := aClone(aVetPadV)
Endif       

oBrowPacV := TcBrowse():New( 005, 005, 385, 100,,,, oDlgVisPac,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrowPacV:AddColumn(TcColumn():New(STR0004,nil,; //"Paciente"
         nil,nil,nil,nil,065,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPacV:ACOLUMNS[1]:BDATA     := { || Transform(aBrowPacV[oBrowPacV:nAt,9],__cPictUsr) }         
         
oBrowPacV:AddColumn(TcColumn():New(STR0005,nil,; //"Nome"
         nil,nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPacV:ACOLUMNS[2]:BDATA     := { || aBrowPacV[oBrowPacV:nAt,1] }         
oBrowPacV:AddColumn(TcColumn():New(STR0006,nil,; //"Data"
         nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPacV:ACOLUMNS[3]:BDATA     := { || aBrowPacV[oBrowPacV:nAt,2] }
oBrowPacV:AddColumn(TcColumn():New(STR0007,nil,; //"Horario"
         nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPacV:ACOLUMNS[4]:BDATA     := { || aBrowPacV[oBrowPacV:nAt,3] }
oBrowPacV:AddColumn(TcColumn():New(STR0008,nil,; //"Medico"
         nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPacV:ACOLUMNS[5]:BDATA     := { || aBrowPacV[oBrowPacV:nAt,4] }
oBrowPacV:AddColumn(TcColumn():New(STR0009,nil,; //"Especialidade"
         nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPacV:ACOLUMNS[6]:BDATA     := { || aBrowPacV[oBrowPacV:nAt,5] }
oBrowPacV:AddColumn(TcColumn():New(STR0010,nil,; //"Localidade"
         nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))     
         oBrowPacV:ACOLUMNS[7]:BDATA     := { || aBrowPacV[oBrowPacV:nAt,6] }

oBrowPacV:SetArray(aBrowPacV)
oBrowPacV:bChange := {|| oSayTxt1:Refresh(), oSayTxt2:Refresh(), oSayTxt3:Refresh() }
    
@ 108, 005 Say oSayTxt1 PROMPT STR0021 					SIZE 060, 010 OF oDlgVisPac PIXEL FONT oFontRod //"Empresa.:"
@ 108, 060 Say oSayTxt1 PROMPT aBrowPacV[oBrowPacV:nAt,7]	SIZE 180, 010 OF oDlgVisPac PIXEL COLOR CLR_HBLUE FONT oFontRod
                              
@ 120, 005 Say oSayTxt2 PROMPT STR0013 					SIZE 060, 010 OF oDlgVisPac PIXEL FONT oFontRod //"Titular:"
@ 120, 060 Say oSayTxt2 PROMPT aBrowPacV[oBrowPacV:nAt,8]	SIZE 180, 010 OF oDlgVisPac PIXEL COLOR CLR_HBLUE FONT oFontRod

@ 132, 005 Say oSayTxt3 PROMPT STR0014 				SIZE 060, 010 OF oDlgVisPac PIXEL FONT oFontRod //"Solicitante:"
@ 132, 060 Say oSayTxt3 PROMPT aBrowPacV[oBrowPacV:nAt,10]	SIZE 180, 010 OF oDlgVisPac PIXEL COLOR CLR_HBLUE FONT oFontRod

//DEFINE O BOTAO FECHAR
DEFINE SBUTTON FROM 130,363 TYPE 2  ACTION Eval(bCancelV) ENABLE OF oDlgVisPac

//DEFINE O BOTAO DESMARCAR     
If lDesmarca 
   oBtn := SButton():New(130, 333, 3,  {|| aRet := PLS300ADES(oBrowPacV:nAt ,aBrowPacV) ,Iif(aRet[1] ,aBrowPacV := aClone(aRet[2]) ,.T. ) ,oBrowPacV:Refresh() ,oBrowPacV:SetArray(aBrowPacV) ,Iif( Len(aBrowPacV)>0 ,.T. ,oDlgVisPac:End() ) },,.T.)
   oBtn:cToolTip := STR0022 //"Desmarcar"
EndIf	

//Ativa o Dialogo...

ACTIVATE MSDIALOG oDlgVisPac

BAU->( dbGoto(nRegBAU) )

RETURN()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSPESUSER ³ Autor ³ Tulio Cesar        ³ Data ³ 16.01.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa generica de usuarios...                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS300USER(lBloqueia,cCodOpe)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cChave     := Space(100)
LOCAL oDlgPesUsr                         
LOCAL oTipoPes
LOCAL oSayUsr
LOCAL nOpca      := 0
LOCAL aBrowUsr   := {}
LOCAL aVetPad    := { {"ENABLE","","",0,"","","","","","","",""} }
LOCAL oBrowUsr
LOCAL bRefresh   := { || If(!Empty(cChave),PLSAPUSRPq(AllTrim(cChave),Subs(cTipoPes,1,1),lChkChk,aBrowUsr,aVetPad,oBrowUsr,lBloqueia,cCodOpe),.T.), oSayTxt1:Refresh(), If( Empty(aBrowUsr[1,2]) .And. !Empty(cChave),.F.,.T. )  }
LOCAL cValid     := "{|| Eval(bRefresh) }"
LOCAL bOK        := { || IF(!Empty(cChave),(nLin := oBrowUsr:nAt, nOpca := 1,oDlgPesUsr:End()),Help("",1,"PLSMCON")) }
LOCAL bCanc      := { || nOpca := 3,oDlgPesUsr:End() }
LOCAL nReg                                   
LOCAL oGetChave
LOCAL oSayTxt1
//LOCAL aTipoPes   := {"1-Nome do Usuario","2-Matricula","3-Matricula Antiga","4-Matricula Empresa","5-Nome do Pai","6-Nome da Mae"}
LOCAL aTipoPes   := {}
LOCAL nOrdem     := 1
LOCAL cTipoPes   := ""
LOCAL cInterc    := GetNewPar("MV_PLSGEIN","0050")//Codigo da Empresa de Intercambio
LOCAL oChkChk
LOCAL lChkChk    := .F.
LOCAL nLin       := 1
LOCAL aButtons   := {}
LOCAL cSQL

DEFAULT lBloqueia:= .F.
DEFAULT cCodOpe  := PLSINTPAD()

PRIVATE aOpcoes  := {}

DEFINE FONT oFont 	 NAME "Arial" SIZE 0,-11 BOLD                               
DEFINE FONT oFontDat NAME "Arial" SIZE 000,-017 
DEFINE FONT oFontRod NAME "Arial" SIZE 000,-014 BOLD

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define botao para visualizar a familia do usuario posicionado...         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtons, {"BMPGROUP",{|| PLSA300FAM(aBrowUsr[oBrowUsr:nAt,2]) },STR0023,STR0024} ) //"Visualizar Familia - <CTRL + A>"###"Familia"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define botao para visualizar a Vida										 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtons, {"RESPONSA",{|| If(!Empty(aBrowUsr[oBrowUsr:nAt,2]),;
								    ( BA1->( DbSetOrder(2) ),;
								      BA1->( MsSeek( xFilial("BA1")+AllTrim(StrTran(StrTran(aBrowUsr[oBrowUsr:nAt,2],'.',''),'-','')) ) ),;
								      If( BA1->( Found() ),;
								      	  AxVisual("BA1",BA1->(RECNO()),K_Visualizar),;
								      	  MsgAlert(STR0025) ) ),.T. ) },STR0026,STR0027} ) //"Usuario nao encontrado"###"Dados da vida do beneficiario"###"Vida"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define botao para Bloqueio de Usuario									 				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtons, {"BMPDEL",{|| PLS300BLUS(AllTrim(StrTran(StrTran(aBrowUsr[oBrowUsr:nAt,2],'.',''),'-','') ),cInterc,bRefresh) },STR0028,STR0029} ) //"Bloqueia Usuario"###"Bloqueio"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carencia do Usuario																		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Aadd(aButtons, {"RELATORIO",{|| If(!Empty(aBrowUsr[oBrowUsr:nAt,2]),;
									PL300VISCAR("",Nil,Nil,Nil,1,oDlgPesUsr,1,AllTrim(StrTran(StrTran(aBrowUsr[oBrowUsr:nAt,2],'.',''),'-','')) ),.T.) },STR0030,STR0030} ) //"Carencias"###"Carencias"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ajusta matriz																			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aBrowUsr := aClone(aVetPad)

cSQL := "SELECT BX8_OPCAO, BX8_CHAVE FROM "+RetSQLNAME("BX8")
cSQL += " WHERE "
cSQL += "BX8_FILIAL = '"+xFilial("BX8")+"' AND "
cSQL += "BX8_RDMAKE = 'PLSPESUSR' AND "
cSQL += "D_E_L_E_T_ = ' '"
PLSQuery(cSQL,"PLSBX8")

If ! PLSBX8->(Eof())
   While ! PLSBX8->(Eof())
         aadd(aTipoPes,AllTrim(Str(nOrdem,2))+"-"+PLSBX8->BX8_OPCAO)
         aadd(aOpcoes,{AllTrim(PLSBX8->BX8_CHAVE)})
         nOrdem ++
   PLSBX8->(DBSkip())
   Enddo 
Else
   aTipoPes   := {STR0031,STR0032,STR0033,STR0034,STR0035,STR0036,STR0037} //"1-Nome do Usuario"###"2-Matricula"###"3-Matricula Antiga"###"4-Matricula Empresa"###"5-Nome do Pai"###"6-Nome da Mae"###"7-Nome Empresa/Nome Usuario"

   aadd(aOpcoes,{"BA1_NOMUSR"})
   aadd(aOpcoes,{"BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG"})
   aadd(aOpcoes,{"BA1_MATANT"}) 
   aadd(aOpcoes,{"BA1_MATEMP"})
   aadd(aOpcoes,{"BA1_PAI"})
   aadd(aOpcoes,{"BA1_MAE"})
   aadd(aOpcoes,{""})
Endif

PLSBX8->(DbCloseArea())
DbSelectArea("BX8")
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlgPesUsr TITLE STR0038 FROM 008.2,000 TO 030,ndColFin OF GetWndDefault() //"Pesquisa de Beneficiarios"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta objeto que recebera o a chave de pesquisa  ...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oGetChave := TGet():New(050,100,{ | U | IF( PCOUNT() == 0, cChave, cChave := U ) },oDlgPesUsr,210,008 ,"@!S30",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Browse...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowUsr := TcBrowse():New( 070, 008, 378, 075,,,, oDlgPesUsr,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrowUsr:AddColumn(TcColumn():New("",nil,nil,nil,nil,nil,015,.T.,.F.,nil,nil,nil,.T.,nil))
         oBrowUsr:ACOLUMNS[1]:BDATA := { || aBrowUsr[oBrowUsr:nAt,1] }
         
oBrowUsr:AddColumn(TcColumn():New(STR0039,nil,nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil)) //"Matricula"
         oBrowUsr:ACOLUMNS[2]:BDATA := { || aBrowUsr[oBrowUsr:nAt,2] }
         
oBrowUsr:AddColumn(TcColumn():New(STR0040,nil,nil,nil,nil,nil,055,.F.,.F.,nil,nil,nil,.F.,nil)) //"Matricula Antiga"
         oBrowUsr:ACOLUMNS[3]:BDATA := { || aBrowUsr[oBrowUsr:nAt,9] }
         
oBrowUsr:AddColumn(TcColumn():New(STR0005,nil,nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil)) //"Nome"
         oBrowUsr:ACOLUMNS[4]:BDATA := { || aBrowUsr[oBrowUsr:nAt,3] }
         
oBrowUsr:AddColumn(TcColumn():New(STR0041,nil,nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil)) //"Nome Reduzido Empresa"
         oBrowUsr:ACOLUMNS[5]:BDATA := { || aBrowUsr[oBrowUsr:nAt,10] }
         
oBrowUsr:AddColumn(TcColumn():New(STR0042,nil,nil,nil,nil,nil,090,.F.,.F.,nil,nil,nil,.F.,nil)) //"Produto"
         oBrowUsr:ACOLUMNS[6]:BDATA := { || aBrowUsr[oBrowUsr:nAt,11] }
         
oBrowUsr:AddColumn(TcColumn():New(STR0043,nil,nil,nil,nil,nil,030,.F.,.F.,nil,nil,nil,.F.,nil))      //"Data Inclusao"
         oBrowUsr:ACOLUMNS[7]:BDATA := { || aBrowUsr[oBrowUsr:nAt,6] }

@ 050,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 090,010 OF oDlgPesUsr PIXEL COLOR CLR_HBLUE
@ 050,319 CHECKBOX oChkChk   Var lChkChk PROMPT STR0044 PIXEL SIZE 080, 010 OF oDlgPesUsr //"Pesquisar Palavra Chave"
                          
@ 150, 007 Say oSayTxt1 PROMPT STR0013 					SIZE 060, 010 OF oDlgPesUsr PIXEL FONT oFontRod //"Titular:"
@ 120, 060 Say oSayTxt1 PROMPT aBrowUsr[oBrowUsr:nAt,12]	SIZE 180, 010 OF oDlgPesUsr PIXEL COLOR CLR_HBLUE FONT oFontRod

oBrowUsr:SetArray(aBrowUsr)
oBrowUsr:BLDBLCLICK	:= bOK
oBrowUsr:bChange	:= { || oSayTxt1:Refresh() }

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Dialogo...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlgPesUsr ON INIT Eval({ || EnChoiceBar(oDlgPesUsr,bOK,bCanc,.F.,aButtons) })

If nOpca == K_OK
   If !Empty(aBrowUsr[nLin,2])
      BA1->(DbGoTo(aBrowUsr[nLin,8]))
   Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorno da Funcao...                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(nOpca==K_OK)
/*/                                                                                        
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLS300BLUS ³ Autor ³ Tulio Cesar        ³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa a usuarios na base de dados ...                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLS300BLUS(cMatric,cInterc,bRefresh)

LOCAL nRecNo

BA1->( DbSetOrder(2) )
If BA1->( MsSeek( xFilial("BA1")+cMatric ) ) .And. BA1->BA1_CODEMP == AllTrim(cInterc) .And. Empty(BA1->BA1_MOTBLO)
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Recno e Skip															 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nRecNo := BA1->( Recno() ) 
	BA1->( DbSkip() ) 
    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ If																		 ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) <> cMatric 
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Go Top																	³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   BA1->( DbGoTo(nRecNo) )
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Bloqueia a Familia														³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	   PL260BLOCO("BA1",BA1->(Recno()),4)
	Else
	   BA1->( DbGoTo(nRecNo) )
	   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	   //³ Bloqueia a Usuario														³
	   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PL260BLOUS("BA1",BA1->(Recno()),4,nil,nil,nil,nil,.F.)   
	Endif
Else
  	MsgAlert(STR0045) //"Nao e permitido o bloqueio deste usuario"
EndIf	            
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Eval(bRefresh)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina															 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return
/*/                                                                                        
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSAPUSRPq ³ Autor ³ Tulio Cesar        ³ Data ³ 18.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Pesquisa a usuarios na base de dados ...                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PLSAPUSRPq(cChave,cTipoPes,lChkChk,aBrowUsr,aVetPad,oBrowUsr,lBloqueia,cCodOpe)
Local aArea     := GetArea()
LOCAL cSQL      := ""
LOCAL cRetBA1
LOCAL cNomeEmp  := ""
LOCAL cNomeUsr  := ""
LOCAL nFor   
LOCAL lTroca    := .F.
LOCAL cCodPla	:= ''
LOCAL cVerPla	:= ''
LOCAL cDesPla	:= ''
LOCAL cTitular 	:= GetNewPar("MV_PLCDTIT","T")//Codigo indicador do Titular do contrato no modulo Plano de Saude. Exemplo : T
LOCAL cNReduz	:= ''
LOCAL cNomTit	:= ''

If '"' $ cChave .Or. ;
	"'" $ cChave
	Aviso( STR0046, ; //"Caracter Invalido"
	STR0047,; //"Existem caracteres invalidos em sua pesquisa."
	{ "Ok" }, 2 )
	Return(.F.)
Endif
                                                                                 '
cRetBA1 := BA1->(RetSQLName("BA1"))
cRetBA3 := BA3->(RetSQLName("BA3"))
cRetBG9 := BG9->(RetSQLName("BG9"))
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Limpa resultado...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aBrowUsr := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Efetua busca...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT BA1_DATBLO,BA1_NREDUZ,BA1_MATANT,BA1_NOMUSR, BA1_CODINT, BA1_CODEMP, BA1_MATRIC, BA1_TIPREG, BA1_DIGITO, BA1_DATNAS, BA1_PAI, BA1_IMAGE, BA1_TIPUSU, "
cSQL += "BA1_MAE, BA1_DATINC, BA1_BAIRRO, BA1_MOTBLO, BA1_CODPLA, BA1_VERSAO,BA3_CODPLA, BA3_VERSAO,BA3_CODINT,BA3_CODEMP,BA3_TIPOUS, BG9_NREDUZ, BA1.R_E_C_N_O_ BA1REG "
cSQL += " FROM "
cSQL += cRetBA1+" BA1, "
cSQL += cRetBA3+" BA3, "
cSQL += cRetBG9+" BG9 "
cSQL += " WHERE "
cSQL += "BA1_FILIAL = '"+xFilial("BA1")+"' AND "
cSQL += "BA3_FILIAL = '"+xFilial("BA3")+"' AND "
cSQL += "BA3_CODINT = BA1_CODINT AND "
cSQL += "BA3_CODEMP = BA1_CODEMP AND "
cSQL += "BA3.D_E_L_E_T_ = ' 'AND "
cSQL += "BA3_MATRIC = BA1_MATRIC AND "
cSQL += "BG9_FILIAL = '"+xFilial("BG9")+"' AND "
cSQL += "BG9_CODINT = BA3_CODINT AND "
cSQL += "BG9_CODIGO = BA3_CODEMP AND "
cSQL += "BG9_TIPO   = BA3_TIPOUS AND "
cSQL += "BG9.D_E_L_E_T_ = ' 'AND "

If lBloqueia
	cSQL += "BA1_MOTBLO = '' AND "
Endif

If cTipoPes <> "7"
	If lChkChk
		cSQL += aOpcoes[Val(cTipoPes),1]+" LIKE '%"+AllTrim(cChave)+"%' AND "
	Else
		cSQL += aOpcoes[Val(cTipoPes),1]+" LIKE '"+AllTrim(cChave)+"%' AND "
	Endif
	cSQL += "BA1.D_E_L_E_T_ = ' ' "
	cSQL += "ORDER BY BA1_FILIAL,"+aOpcoes[Val(cTipoPes),1]
Else
	If cTipoPes == "7" //Nome Empresa e Nome do Usuario, separado por ; (ponto e virgula)
		For nFor := 1 To Len(AllTrim(cChave))
			If Subs(cChave,nFor,1) == ";"
				lTroca := .T.
				nFor ++
			Endif
			
			If ! lTroca
				cNomeEmp += Subs(cChave,nFor,1)
			Else
				cNomeUsr += Subs(cChave,nFor,1)
			Endif
		Next
	Endif
	
	If lChkChk
		cSQL += "BA1_NREDUZ LIKE '%"+cNomeEmp+"%' AND "
		cSQL += "BA1_NOMUSR LIKE '%"+cNomeUsr+"%' AND "
	Else
		cSQL += "BA1_NREDUZ LIKE '"+cNomeEmp+"%' AND "
		cSQL += "BA1_NOMUSR LIKE '"+cNomeUsr+"%' AND "
	Endif
	cSQL += cRetBA1+".D_E_L_E_T_ = '' "
	cSQL += "ORDER BY BA1_FILIAL,BA1_NREDUZ,BA1_NOMUSR"
Endif
                                       
PLSQuery(cSQL,"TrbPes")

TrbPes->(DbGoTop())
While ! TrbPes->(Eof())
	If !Empty(TrbPes->BA1_CODPLA)
		cCodPla := TrbPes->BA1_CODPLA
		cVerPla := TrbPes->BA1_VERSAO
	Else
		cCodPla := TrbPes->BA3_CODPLA
		cVerPla := TrbPes->BA3_VERSAO
	Endif
	
	cDesPla	:= Posicione("BI3",1,xFilial("BI3")+TrbPes->BA1_CODINT+cCodPla+cVerPla,"BI3_DESCRI")
	
	// Para possicionar o titular.
	If TrbPes->BA1_TIPUSU <> cTitular
		BA1->( dbSetorder(01) )
		If BA1->( MsSeek(xFilial("BA1")+TrbPes->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+cTitular)) )
			cNomTit	:= BA1->BA1_NOMUSR
			cNReduz	:= BA1->BA1_NREDUZ
		Else
			cNomTit	:= 'Não encontrado!'
			cNReduz	:= ''
		Endif
	Else
		cNomTit	:= TrbPes->BA1_NOMUSR
		cNReduz	:= TrbPes->BA1_NREDUZ
	Endif

	If Empty(cNReduz)
		cNReduz := TrbPes->BG9_NREDUZ
	EndIf

	TrbPes->(aadd(aBrowUsr,{Iif(Empty(BA1_DATBLO),"ENABLE", Iif(BA1_DATBLO > Iif(TYPE('M->BBO_DATA')<>'U',M->BBO_DATA,dDataBase),"ENABLE","DISABLE")),;
	BA1_CODINT+"."+BA1_CODEMP+"."+BA1_MATRIC+"-"+BA1_TIPREG+"-"+BA1_DIGITO,;
	BA1_NOMUSR,;
	Calc_Idade(dDataBase,BA1_DATNAS),;
	AllTrim(BA1_PAI)+" - "+AllTrim(BA1_MAE),;
	BA1_DATINC,;
	BA1_BAIRRO,;
	BA1REG,;
	BA1_MATANT,;
	cNReduz,;
	cCodPla+' - '+cDesPla,;
	cNomTit}))
	TrbPes->(DbSkip())
Enddo
      
TrbPes->(DbCloseArea())
RestArea(aArea)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa resultado da pesquisa...                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aBrowUsr) == 0
	aBrowUsr := aClone(aVetPad)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza browse...                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBrowUsr:SetArray(aBrowUsr)
oBrowUsr:Refresh()
oBrowUsr:SetFocus()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLS300ADES ³ Autor ³ Alexander         ³ Data ³ 11.10.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Desmarca agenda											  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLS300ADES(nLin,aMat)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cTitulo := STR0048 //"Agenda Medica - Cancelar Agenda"
LOCAL cCodCan := Space( TamSX3("BTJ_CODIGO")[1] )
LOCAL cDesBlo := Space( TamSX3("BTJ_DESCRI")[1] )
LOCAL nOpca   := 0
LOCAL aDadBHY := {}
LOCAL nTam
LOCAL nBBDRec := BBD->( Recno() )
LOCAL lRet 	  := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se a matriz de visualizacao esta vazia									 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aMat) == 0 
   lRet := .F.
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abre dialog para seleciona opcao desejada...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 008.2,010.3 TO 014,045 OF GetWndDefault()
	
		@ 05,10 Say  STR0049  PIXEL OF oDlg		 //"Codigo"
	    @ 15,10 MsGet cCodCan Picture "99"  SIZE 20,08  PIXEL of oDlg F3 "BY8PLS" HASBUTTON Valid cDesBlo := Posicione("BTJ",1,xFilial("BTJ")+cCodCan,"BTJ_DESCRI")   
		@ 05,35 Say  STR0050  PIXEL OF oDlg		 //"Descricao"
		@ 15,35 MsGet cDesBlo Picture "@!" SIZE 80,08.5  PIXEL of oDlg When .F.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Cria Botao																 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DEFINE SBUTTON FROM 26,40 TYPE 1  ACTION { || nOpca := 1, oDlg:End() } ENABLE OF oDlg
		DEFINE SBUTTON FROM 26,68 TYPE 2  ACTION { || oDlg:End() } ENABLE OF oDlg
		
	ACTIVATE MSDIALOG oDlg CENTERED 

	If nOpca == 1 .And. !Empty(cDesBlo)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicia Transacao														 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Begin Transaction
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona																 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BBD->( DbGoto( aMat[nLin,Len(aMat[nLin])] ) )	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicio do Cancelamento (Desmarcar)										 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aadd(aDadBHY,{"BHY_CODIGO",	BBD->BBD_CODIGO})
			aadd(aDadBHY,{"BHY_CODINT",	BBD->BBD_CODINT})
			aadd(aDadBHY,{"BHY_DATA"  ,	BBD->BBD_DATA})
			aadd(aDadBHY,{"BHY_HORA"  ,	BBD->BBD_HORA})
			aadd(aDadBHY,{"BHY_TIPO"  ,	BBD->BBD_TIPO})
			aadd(aDadBHY,{"BHY_ENCAIX",	BBD->BBD_ENCAIX})
			aadd(aDadBHY,{"BHY_PRTATD",	BBD->BBD_PRTATD})
			aadd(aDadBHY,{"BHY_CODESP",	BBD->BBD_CODESP})
			aadd(aDadBHY,{"BHY_CODLOC",	BBD->BBD_CODLOC})
			aadd(aDadBHY,{"BHY_LOCAL",	BBD->BBD_LOCAL})
			aadd(aDadBHY,{"BHY_SIGLA",	BBD->BBD_SIGLA})
			aadd(aDadBHY,{"BHY_NUMREG",	BBD->BBD_ESTCR})
			aadd(aDadBHY,{"BHY_ESTCR",	BBD->BBD_ESTCR})
			aadd(aDadBHY,{"BHY_CODPRF",	BBD->BBD_CODPRF})
			aadd(aDadBHY,{"BHY_CODPAC",	BBD->BBD_CODPAC})
			aadd(aDadBHY,{"BHY_NOME",	BBD->BBD_NOME})
			aadd(aDadBHY,{"BHY_USUOPE",	BBD->BBD_USUOPE})
			aadd(aDadBHY,{"BHY_CODCAN",	cCodCan})
			aadd(aDadBHY,{"BHY_CODSOL",	BBD->BBD_CODSOL})
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava BHY																 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PLSCanAge(aDadBHY)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Altera BBD																 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			BBD->(RecLock("BBD",.F.))
				BBD->BBD_STATUS	:= '7'
				BBD->BBD_HORCAN := Left(Time(),5)
				BBD->BBD_CODCAN	:= cCodCan
				If BBD->( FieldPos("BBD_DATCAN") ) > 0					
				   BBD->BBD_DATCAN := Date()
				Endif
			BBD->(MsUnLock())    
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Fim da transacao														 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		End Transaction
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Retira o iten cancelado do browse										 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nTam := Len(aMat) 
		aDel(aMat,nLin)   
		aSize(aMat,nTam-1)
				
	Else 
		lRet := .F.
    EndIf
EndIF
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se retirou o iten volta para o registro original						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lRet                                                     
   BBD->( DbGoto( nBBDRec ) )	
EndIf	  
	
Return( {lRet,aMat} )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PL300VLBLQºAutor  ³Geraldo Felix Jr    º Data ³  01/10/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se o horario selecionado foi bloqueado por outra   º±±
±±º          ³estacao.                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL300VLBLQ(cCodInt, cCodRda, cCodEsp, cCodLoc, dData, cHorario)

LOCAL cSql 	:= ''
LOCAL lRet	:= .T.

cHorario := Transform(cHorario, "@R 99:99")

cSQL := "SELECT BBQ_FILIAL FROM "+RetSQLName("BBQ")+" WHERE "
	cSQL += "BBQ_FILIAL = '"+xFilial("BBQ")+"' AND "
	cSQL += "BBQ_CODINT = '"+cCodInt+"' AND "
	cSQL += "BBQ_CODRDA = '"+cCodRda+"' AND "
	cSQL += "BBQ_CODLOC = '"+cCodLoc+"' AND "
	cSQL += "'"+dtos(dData)+"' >= BBQ_DATDE AND '"+dtos(dData)+"' <= BBQ_DATATE AND "
	cSQL += "'"+cHorario+"' >= BBQ_HORDE AND '"+cHorario+"' <= BBQ_HORATE AND "
	cSQL += "D_E_L_E_T_ = ' '"
PLSQuery(cSQL,"TRB1")
	
If !TRB1->( Eof() )                        

	MsgStop(STR0051) //"A agenda deste medico foi bloqueada por outra estacao."
	lRet := .F.
Endif
            
TRB1->( dbCloseArea() )

Return(lRet)