#INCLUDE "PLSA315.ch"
#include "PROTHEUS.CH"       
#include "PLSMGER.CH"
#include "COLORS.CH"
#include "TCBROWSE.CH"
#include "JPEG.CH"
#define K_Agenda 1
#define K_Cancel 3
#define _nBytes 20 

Static oPacientesAux
Static aStatus       := {{"1",STR0155,STR0066,1},; //"esta Agendado"###"Agendado"
					     {"5",STR0156,STR0043,2},; 	//"esta em espera"###"Espera"
					     {"6",STR0157,STR0067,3},; 	//"esta no ConsultСrio"###"ConsultСrio"
					     {"4",STR0158,STR0068,4},; 	//"foi atendido"###"Atendido"
					     {"7",STR0159,STR0160,5},; 	//"foi cancelada"###"Cancelada"
					     {"1",STR0161,STR0022,6},; 	//"e um encaixe"###"Encaixe"
					     {"8",STR0162,STR0163,7}} 	//"dado falta"###"Falta"

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбдддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA315 Ё Autor ЁGeraldo Felix Junior   Ё Data Ё 29.01.02 Ё╠╠
╠╠цддддддддддедддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Tela da Recepcao                                          Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA315               

Local nLin
Local cCodOpe
Local cDesOpe
Local cCodLoc                          
Local cDesLoc
Local cCdAmbu
Local cDsAmbu
Local oDlg
Local oGrupo
Local oMedicos
Local oHorarios
Local oPronto
Local oLisEsp
Local oListaUsr
Local oTimerBrw
Local nBrw		:= 0
Local nTime     := GETMV("MV_PLSTAGE")  
Local nX		:= 0
Local dDtRec    := dDataBase
Local cAno		:= Alltrim( Str( Year( dDtRec ) ) )
Local cDia		:= Alltrim( Str( Dow( dDtRec ) ) )
Local cMes		:= StrZero( Month( dDtRec ),2 )
Local cDiaMes	:= StrZero( Day( dDtRec ),2 )
Local cHoraEnc  := ""
Local cBB7Name  := BB7->(RetSQLName("BB7"))
Local cBB8Name  := BB8->(RetSQLName("BB8"))
Local cBAUName  := BAU->(RetSQLName("BAU"))
Local cBAQName  := BAQ->(RetSQLName("BAQ"))
Local cCodCPA   := GetNewPar("MV_PLSCOPA","0100010014")
Local cCodCon	:= GetMv("MV_PLSCDCO")
Local cDirImg   := GETMV("MV_PLSDIMG")
Local cPrefixo  := "PLSA315"
Local cTime     := AllTrim(GetNewPar("MV_PLSMSAT","0"))                                      
Local cMotBlo   :=  GetNewPar("MV_PLMCBL","001")
Local aRet		:= {}
Local aListaUsr := { {"","","",0,.T.,"","",""} }
Local aMedicos  := {}
Local aSalas 	:= {}                
Local aHorarios := {}
Local aHorMed   := {}
Local aPronto   := {}            
Local aHorPro   := {}
Local aLisEsp   := {}            
Local aHorEsp   := {}
Local aProPad   := { { "","","","",0,"","","","",""} }
Local aPTBot	:= {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.}
Local aButtons  := {}
Local aButtonUsr := {}
Local bFiltra   := { |lDireto| PLSA315Fil(aHorMed,aHorarios,aSalas,oHorarios,oMedicos,oPronto,aPronto,aHorPro,oLisEsp,aLisEsp,aHorEsp,cCodOpe,dDtRec,lDireto) }
Local bAtuDados := { || Eval(bMonVet), Eval(bFiltra) }
Local bMonVet  	:= { || PLSA315Vet(cBB7Name,cBB8Name,cBAUName,cBAQName,aMedicos,aSalas,cDia,cCodLoc,cCodOpe,aHorarios,aHorMed,dDtRec,cCdAmbu,aPronto,aHorPro,cDiaMes,cMes,cAno,aLisEsp,aHorEsp) }
Local bValid   	:= { || oPacientesAux := oHorarios, IIf(Len(aHorMed)>0,PLSA315Vld(oHorarios,aHorMed,oMedicos,aSalas,dDtRec,cCodCon,bAtuDados,cDirImg,bBotao04,cCdAmbu),MsgInfo(STR0001)) } //"Nao existe agenda aberta!"
Local bOK       := { || dbSelectArea("BBD"), oDlg:End() } 
Local bCancel   := { || dbSelectArea("BBD"), oDlg:End() }
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define codeblocks das teclas de atalho...                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Local bBotao03  := bValid
Local bBotao02  := { || aRet := PLSA300Pes(), PLSA315Pes(aRet,aHorarios,oHorarios,aSalas,oMedicos,bFiltra,aHorMed) }
Local bBotao04  := { || IIf(Len(aHorMed) > 0, PLSA315Can(oHorarios,aHorMed,bAtuDados,nBrw,aHorPro,oPronto,oLisEsp,aHorEsp,aSalas[oMedicos:nAt,7]), MsgInfo(STR0001)) } //"Nao existe agenda aberta!"
Local bBotao05  := { || ( PLSA300(IIf(Len(aHorMed) > 0,aHorMed[oHorarios:nAt,3],''),;
						   		  IIf(Len(aHorMed) > 0,aHorMed[oHorarios:nAt,4],''),;
								  ,'',;
								  IIf(Len(aHorMed) > 0,aHorMed[oHorarios:nAt,5],''),; 
								  IIf(Len(aHorMed) > 0,aHorMed[oHorarios:nAt,14],"0") ),;
							      PLSA315ENABLEKEYS(bBotao02, bBotao03, bBotao04, bBotao05, bBotao06, bBotao08,;
							     				   bBotao09, bBotao10, bBotao11, bBotao12, bBotao13,;
							     				   nBrw, aHorMed, oHorarios, aHorPro, oPronto, bBotLes),;
							      Eval(bAtuDados) ) }
Local bBotao06  := { || PLSA315Aut(aSalas,oMedicos,aHorMed,oHorarios,oTimerBRW,bAtuDados,1) }
Local bBotao07  := { || PLSA308() }
Local bBotao08  := { || NaoDisp() }
Local bBotao09  := { || IIf(Len(aHorMed) > 0, PLSA315ATD(cCodLoc,cDesLoc, aHorMed, oHorarios,aSalas[oMedicos:nAt,7]), MsgInfo(STR0001)) } //"Nao existe agenda aberta!"
Local bBotao10  := { || IIf(Len(aHorMed) > 0, (aRet := PLSA315Enc(dDtRec,cCodLoc,cCodOpe,oMedicos,aSalas,aHorMed,cCdAmbu,cCodCon,bAtuDados ),(lRet:=aRet[1],cHoraEnc:=aRet[2]), If( lRet,PLSA315SET(cHoraEnc,aHorMed,oHorarios),nil) ), MsgInfo(STR0001)) } //"Nao existe agenda aberta!"
Local bBotao11  := { || PLSA315Pro(aHorPro,oPronto,dDtRec,cCodLoc,cCodOpe,oMedicos,aSalas,cCodCPA,bAtuDados,aHorMed) }
Local bBotao12  := { || oDlg:Hide(), PLSA176(),oDlg:Show() }
Local bBotao13	:= { || Eval(bAtuDados),PLSA315SMd(oMedicos,aSalas,aMedicos,cCodOpe,cDesOpe,cCodLoc,cDesLoc,cCdAmbu,cDsAmbu,bAtuDados,dDtRec,aHorMed)}
Local bBotao14  := { || IIf(Len(aHorMed)>0, PL300VISCAR(aSalas[oMedicos:nAt,10],dDtRec,aListaUsr,oListaUsr,1,oDlg,1,If( nBrw==1,aHorMed[oHorarios:nAt,3],If( nBrw==2,aHorPro[oPronto:nAt,02], If( nBrw==3,aHorEsp[oLisEsp:nAt,02],"" ) ) ) ),MsgInfo(STR0001) )} //"Nao existe agenda aberta!"
Local bBotLes  	:= { || PLSA315Les(0,dDtRec,cCodLoc,cCodOpe,oMedicos,aSalas,cCdAmbu,cCodCon,aHorEsp,aHorMed,bAtuDados) }
Local bSelMdPr  := { || PLSA315PSM(oMedicos,aSalas,cCodOpe,cDesOpe,cCodLoc,cDesLoc,cCdAmbu,cDsAmbu,bAtuDados,oPronto,aHorPro) }
Local bBotao15  := { || IIf(Len(aHorMed)>0,PL315AGCH( aHorMed[oHorarios:nAt,4], aHorMed[oHorarios:nAt,6], aHorMed[oHorarios:nAt,7], aSalas[oMedicos:nAt,7] , bAtuDados ),.T.) }
Local bPause	:= { || PLS315Pause(oMedicos,aSalas,bAtuDados,,dDtRec,aHorMed)} 
Local bBotaoPE  := { || Execblock("PLS315BT",.F.,.F.,{aHorMed,oHorarios,aHorPro,oPronto,aHorEsp,oLisEsp,aSalas,oMedicos,aListaUsr,oListaUsr,oDlg,nBRW,dDtRec})}

Local cVida	    := ""
Local lBiomet   := SuperGetMv("MV_BIOCONF",,.F.)
Local bBotao16 
Local aDadBt    :={}
Local cPictBt   := ""
Local cDescBt   := ""
Local cTitBt    := ""
Local aSize     := MsAdvSize()
Local nWRes   	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
Local nHRes   	:=	oMainWnd:nClientHeight	// Resolucao horizontal do monitor
Local bBotao17  := { || PLSA315Aut(aSalas,oMedicos,aHorMed,oHorarios,oTimerBRW,bAtuDados,2) }

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Privadas...                                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private cLocal
Private lRefresh 	:= .F.                                
Private Inclui		:= .F.
Private nTamDlgBrw 	:= 518
Private cConSem 	:= "ATEND"
Private cCadastro 	:= STR0002 //"Recepcao"
Private cTmpLim		:= "00:10"
Private cCodEsp     := ""
Private aCriMovi 	:= {STR0003,; //"Agenda medica ja virou uma guia em situacao anterior!"
						STR0004,; //"Procedimento invalido!"
						STR0005,; //"Usuario invalido!"
						STR0006,; //"RDA invalida!"
						STR0007,; //"Calendario de pagamento incompativel!"
						STR0008} //"Problemas na gravacao do movimento!"
Private aRotina     := MenuDef()
Private cCodAmb             

PutHelp("PPL315VLD",{STR0004},{},{},.T.)  
PutHelp("SPL315VLD",{STR0315},{},{},.T.) 


If 	lBiomet
	aPTBot	  := {.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.,.T.}
	bBotao16  := { || IIf(Len(aHorMed)>0 .AND. !EMPTY(aHorMed[oHorarios:nAt,3]),cVida:=Posicione("BA1",2,xFilial("BA1")+aHorMed[oHorarios:nAt,3],"BA1_MATVID"), cVida:= "" ),;
					  IIf(!Empty(cVida),PLSBIOMET("BTS",cVida,.T.,"1"),.T.)}
EndIf 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ponto de entrada para desabilitar BOTOES PARA um grupo de operadores	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("PLSBUTOP")
   aPTBot := ExecBlock("PLSBUTOP",.F.,.F.,{"PLSA315"})   
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Botoes																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If aPTBot[1]
   aadd(aButtons,{"PESQUISA" 	,bBotao02,STR0009,STR0010} ) //"Pesquisar Agenda - <F4>"###"Pesquisa"
EndIf   

If aPTBot[2]
   aadd(aButtons,{"EXCLUIR"		,bBotao04,STR0011,STR0012} ) //"Cancelar Agenda - <F6> "###"Cancela"
EndIf   

If aPTBot[3]
	aadd(aButtons,{"NOTE"     	,bBotao05,STR0013,STR0014} ) //"Marcacao Consulta - <F7>"###"Marcacao"
EndIf

If aPTBot[4]
	aadd(aButtons,{"COLGERA"  	,bBotao06,STR0015,STR0016} ) //"Encaminhamento - <F8>"###"Encaminha"
EndIf

If aPTBot[5]
	aadd(aButtons,{"PEDIDO"   	,bBotao09,STR0017,STR0018} ) //"Atestado MИdico - <F10> "###"Atestado"
EndIf

If aPTBot[6]
	aadd(aButtons,{"RESPONSA" 	,bBotao11,STR0019,STR0020} ) //"Pronto Atendimento - <F11>"###"Pronto At"
EndIf

If aPTBot[7]
	aadd(aButtons,{"BMPPARAM" 	,bBotao10,STR0021,STR0022} ) //"Encaixe - <F12>"###"Encaixe"
EndIf

If aPTBot[8]
	aadd(aButtons,{"DISCAGEM" 	,bBotao12,STR0023,STR0024} ) //"Telefones Uteis - <CTRL + T>"###"Fones"
EndIf

If aPTBot[9]
	aadd(aButtons,{"CLOCK04" 	,bPause  ,STR0025,STR0026} ) //"Ativa/Desativa Pausa - <CTRL + P>"###"Pausa"
EndIf

If aPTBot[10]
	Aadd(aButtons,{"RELATORIO"  ,bBotao14,STR0027,STR0028} ) //"Carencias - <ALT + N>"###"Carencias"
EndIf

If aPTBot[11]
	Aadd(aButtons,{"S4WB014B"   ,bBotao13,STR0029,STR0030} ) //"Abre/Fecha salas - <CTRL + F>"###"Salas"
EndIf

If aPTBot[12]
	Aadd(aButtons,{"BMPGROUP"   ,bBotao15,STR0031,STR0032} ) //"Informar Chamada de paciente"###"Chamadas"
EndIf   

If aPTBot[13]
	aadd(aButtons,{"COLGERA"  	,bBotao17,STR0314,STR0314} ) //"InternaГЦo"
EndIf

If lBiomet .and. aPTBot[16]
	Aadd(aButtons,{"OBJETIVO"       ,bBotao16,STR0304,STR0305} )	
EndIf
If ExistBlock('PLS315BT')
	If ExistBlock('PLS315DAD')
		aDadBt:=Execblock("PLS315DAD",.F.,.F.)	
	    cPictBt:= aDadBt[1]
	    cDescBt:= aDadbt[2]
	    cTitBt := aDadbt[3]
	Else 
		cPictBt:= STR0311
	    cDescBt:= STR0312
	    cTitBt := STR0313
	EndIf 
	aadd(aButtons,{cPictBt, bBotaoPE,cDescBt,cTitBt})

EndIf                      

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seta teclas de atalho...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetKey(2	 	,{|a,b| IIf(nBrw#0, PLSA315VIS(IIf(nBrw==1,( {aHorMed, oHorarios} ),( {aHorPro,oPronto} ) ),nBrw),NIL) }) // Ver horarios...
SetKey(5		,{|a,b| Eval(bBotLes)  })
SetKey(16		,{|a,b| PLS315LOC(aHorPro, oPronto, 3) } )
SetKey(VK_F5 	,{|a,b| Eval(bBotao03) })
SetKey(VK_F9 	,{|a,b| Eval(bBotao08) })


If aPTBot[1]
	SetKey(VK_F4,{|a,b| Eval(bBotao02) })
EndIf	

If aPTBot[2]
	SetKey(VK_F6,{|a,b| Eval(bBotao04) })
EndIf	

If aPTBot[3]
	SetKey(VK_F7,{|a,b| Eval(bBotao05) })
EndIf	

If aPTBot[4]
	SetKey(VK_F8,{|a,b| Eval(bBotao06) })
EndIf	

If aPTBot[5]
	SetKey(VK_F10,{|a,b| Eval(bBotao09) })
EndIf	

If aPTBot[6]
	SetKey(VK_F11,{|a,b| Eval(bBotao11) })
EndIf	

If aPTBot[7]
	SetKey(VK_F12,{|a,b| Eval(bBotao10) })
EndIf

If aPTBot[8]
	SetKey(1,{|a,b| Eval(bBotao12) })
EndIf

If aPTBot[11]
	SetKey(6,{|a,b| Eval(bBotao13) }) // Abre e fecha sala
EndIf

If lBiomet .and. aPTBot[16]
	SetKey(9,{|a,b| Eval(bBotao16) })
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca parametros da rotina...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! Pergunte("PLS315",.T.)
   Return
Else
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Alimenta variavel														Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   cCodOpe := mv_par01
   cCodLoc := mv_par02
   cCdAmbu := mv_par03
   If Empty(cCodOpe) .or. Empty(cCodLoc) .or. Empty(cCdAmbu)
      MsgAlert(STR0033) //"Informe todos os parametros!"
      Return
   EndIf	   
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Set ordem																Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   BSC->( DbSetOrder(1) )  //BSC_FILIAL + BSC_CODINT + BSC_CODLOC + BSC_CDAMBU + STR(BSC_NSALAS)
   If !BSC->( MsSeek(xFilial("BSC")+cCodOpe+cCodLoc+cCdAmbu) )
      MsgAlert(STR0034) //"Nao foi encontrado esta selecao na tabela de Locais Atend. X AmbulatСrios (BSC)!"
      Return
   EndIf
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Alimenta variavel				   										Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   cDesOpe := AllTrim(Posicione("BA0",1,xFilial("BA0")+cCodOpe,"BA0_NOMINT"))
   cDesLoc := AllTrim(Posicione("BD1",1,xFilial("BD1")+cCodOpe+cCodLoc,"BD1_DESLOC"))
   cDsAmbu := AllTrim(BSD->(Posicione("BSD",1,xFilial("BSD")+cCdAmbu,"BSD_DSAMBU")))
   cTmpLim := BD1->BD1_TMPLIM
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Manta Array																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Eval(bMonVet)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Informacoes sobre a resolucao de tela para montar os objetos...     Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aSize := MsAdvSize()
aObjects := {}/*[L][A][][]*/
AAdd( aObjects, { nHRes*0.4, nWRes*0.07, .F., .F.} )//ambulatorio
AAdd( aObjects, { nHRes*0.4, 25       , .F., .F.} )//legenda
AAdd( aObjects, { nHRes*0.4, nWRes*0.07, .F., .F.} )//pronto atendimento
AAdd( aObjects, { nHRes*0.4, nWRes*0.05, .F., .T.} )//lista de espera
aInfo 	 := { aSize[1],aSize[2],aSize[3],aSize[4], 3, 3 }
aPosObj1 := MsObjSize( aInfo, aObjects, .f., .f. ) //ambulatorio

aObjects2 := {}
AAdd( aObjects2, { nHRes*0.5, 240, .T., .F.} ) //box rda
AAdd( aObjects2, { nHRes*0.5, 050, .T., .T.} ) //box data
aInfo  	 := { aPosObj1[1][4],aSize[2],aSize[3],aSize[4], 3, 3 }
aPosObj2 := MsObjSize( aInfo, aObjects2, .f., .f. )

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlg TITLE cCadastro+Space(15)+STR0035+cCodLoc+" - "+cDesLoc+Space(10)+STR0036+cCdAmbu+" - "+cDsAmbu FROM aSize[7],0 To aSize[6],aSize[5] OF oMainWnd PIXEL  //"Local: "###"AmbulatСrio: "
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta medicos disponiveis..                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ aPosObj1[1][1],aPosObj1[1][2] GROUP oGrupo TO aPosObj1[1][3],aPosObj1[1][4] PIXEL OF oDlg LABEL STR0037+cDsAmbu+" ]     -     "+"[ "+dtoc(dDataBase)+" ("+PLSDIASEM(dDataBase)+") ]"  COLOR CLR_HBLUE, CLR_HRED //" AmbulatСrio [ "
oMedicos := TcBrowse():New( aPosObj1[1][1]+8,aPosObj1[1][2]+2 , aPosObj1[1][4]-8,aPosObj1[1][3]-45,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )


//If nHRes > 969	.and. nHRes < 1545// Resolucao 1280x1024


/*
	ADD COLUMN TO oMedicos BITMAP DATA { || LoadBitmap( GetResources(),	If(Empty(aSalas[oMedicos:nAt,3]),"BR_BRANCO",;
																		     IIf(aSalas[oMedicos:nAt,14],"BR_AZUL",;
																				If(!aSalas[oMedicos:nAt,6],;
																					IIf(aSalas[oMedicos:nAt,13]=="S",;
																						IIf(!Empty(aSalas[oMedicos:nAt,08]),"BR_VERDE","BR_AMARELO"),;
																					"BR_CINZA"),;
																				"BR_LARANJA"))) ) } TITLE "" WIDTH 015 NOHILITE
	
*/

oMedicos:AddColumn(TcColumn():New(" ",{ || Iif(Empty(aSalas[oMedicos:nAt,3]),"BR_BRANCO",;
																		     IIf(aSalas[oMedicos:nAt,14],"BR_AZUL",;
																				If(!aSalas[oMedicos:nAt,6],;
																					IIf(aSalas[oMedicos:nAt,13]=="S",;
																						IIf(!Empty(aSalas[oMedicos:nAt,08]),"BR_VERDE","BR_AMARELO"),;
																					"BR_CINZA"),;
																				"BR_LARANJA")))},;
                                                                    nil,nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))

																				
	oMedicos:AddColumn(TcColumn():New(STR0038,			{ || aSalas[oMedicos:nAt,1] },nil,nil,nil,nil,014,.F.,.F.,nil,nil,nil,.F.,nil))      //"Sala"
	oMedicos:AddColumn(TcColumn():New(STR0039,			{ || aSalas[oMedicos:nAt,3] },nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))      //"MИdico"
	oMedicos:AddColumn(TcColumn():New(STR0040,	{ || aSalas[oMedicos:nAt,10] },nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))      //"Especialidade"
	oMedicos:AddColumn(TcColumn():New(STR0041,		{ || IIf(aSalas[oMedicos:nAt,4]==0,"",aSalas[oMedicos:nAt,4]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Agendas"
	oMedicos:AddColumn(TcColumn():New(STR0042,			{ || IIf(aSalas[oMedicos:nAt,5]==0,"",aSalas[oMedicos:nAt,5]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Atend."
	oMedicos:AddColumn(TcColumn():New(STR0043,			{ || IIf(aSalas[oMedicos:nAt,16]==0,"",aSalas[oMedicos:nAt,16]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Espera"
	oMedicos:AddColumn(TcColumn():New(STR0022,		{ || IIf(aSalas[oMedicos:nAt,17]==0,"",aSalas[oMedicos:nAt,17]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Encaixe"
	oMedicos:AddColumn(TcColumn():New(STR0044,		{ || IIf(aSalas[oMedicos:nAt,18]==0,"",aSalas[oMedicos:nAt,18]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Cancelad."
	oMedicos:AddColumn(TcColumn():New(STR0045,	{ || IIf(aSalas[oMedicos:nAt,19]==0,"",aSalas[oMedicos:nAt,19]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Hor. Livres"
	
	oMedicos:SetArray(aSalas)           
	oMedicos:bChange 	:= {|| oHorarios:nAt := 1, Eval(bFiltra, .F.) }
	oMedicos:BLDBLCLICK	:= {|| PLSA315Epr(	oMedicos,aSalas,cCodOpe,cCodLoc,cCdAmbu,dDtRec,aHorMed,aHorPro,oPronto,bAtuDados ) }

	@ aPosObj1[2,1]+05,aPosObj1[2,2]+05/*175,013*/  BITMAP oBmp RESNAME "BR_BRANCO" 	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj1[2,1]+05,aPosObj1[2,2]+15/*175,025*/ Say oSay PROMPT STR0046 					SIZE 070,010 OF oDlg PIXEL //"Desocupada"
	
	@ aPosObj1[2,1]+05,aPosObj1[2,2]+95/*175,123*/ BITMAP oBmp RESNAME "BR_CINZA"	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj1[2,1]+05,aPosObj1[2,2]+105/*175,133*/ Say oSay PROMPT STR0047 					SIZE 100,010 OF oDlg PIXEL //"Aguardando Paciente"
	
	@ aPosObj1[2,1]+05,aPosObj1[2,2]+170/*175,203*/ BITMAP oBmp RESNAME "BR_LARANJA"	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj1[2,1]+05,aPosObj1[2,2]+180/*175,213*/ Say oSay PROMPT STR0048 					SIZE 100,010 OF oDlg PIXEL //"Em Atendimento"

	@ aPosObj1[2,1]+15,aPosObj1[2,2]+05/*190,013*/ BITMAP oBmp RESNAME "BR_VERDE"   	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj1[2,1]+15,aPosObj1[2,2]+15/*190,025*/ Say oSay PROMPT STR0049 					SIZE 100,010 OF oDlg PIXEL //"Aguardando Liberacao de Sala"
	
   	@ aPosObj1[2,1]+15,aPosObj1[2,2]+95/*190,123*/ BITMAP oBmp RESNAME "BR_AMARELO"  OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj1[2,1]+15,aPosObj1[2,2]+105/*190,133*/ Say oSay PROMPT STR0050 					SIZE 100,010 OF oDlg PIXEL //"Sala Virtual"
	
	@ aPosObj1[2,1]+15,aPosObj1[2,2]+170/*190,203*/ BITMAP oBmp RESNAME "BR_AZUL"   	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj1[2,1]+15,aPosObj1[2,2]+180/*190,213*/ Say oSay PROMPT STR0051 					SIZE 100,010 OF oDlg PIXEL //"Pause"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Trecho removido pois o sistema atualiza a tela dinamicamente agora       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
/*ElseIf nHRes >= 1545	

	@ 015, 005 GROUP oGrupo TO 140, 300 PIXEL OF oDlg LABEL STR0037+cDsAmbu+" ]     -     "+"[ "+dtoc(dDataBase)+" ("+PLSDIASEM(dDataBase)+") ]"  COLOR CLR_HBLUE, CLR_HRED        //" AmbulatСrio [ "
	
	oMedicos := TcBrowse():New( 026, 011, 285, 110,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

	ADD COLUMN TO oMedicos BITMAP DATA { || LoadBitmap( GetResources(),	If(Empty(aSalas[oMedicos:nAt,3]),"BR_BRANCO",;
																		     IIf(aSalas[oMedicos:nAt,14],"BR_AZUL",;
																				If(!aSalas[oMedicos:nAt,6],;
																					IIf(aSalas[oMedicos:nAt,13]=="S",;
																						IIf(!Empty(aSalas[oMedicos:nAt,08]),"BR_VERDE","BR_AMARELO"),;
																					"BR_CINZA"),;
																				"BR_LARANJA"))) ) } TITLE "" WIDTH 015 NOHILITE
	
	oMedicos:AddColumn(TcColumn():New(STR0038,			{ || aSalas[oMedicos:nAt,1] },nil,nil,nil,nil,014,.F.,.F.,nil,nil,nil,.F.,nil))      //"Sala"
	oMedicos:AddColumn(TcColumn():New(STR0039,			{ || aSalas[oMedicos:nAt,3] },nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))      //"MИdico"
	oMedicos:AddColumn(TcColumn():New(STR0040,	{ || aSalas[oMedicos:nAt,10] },nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))      //"Especialidade"
	oMedicos:AddColumn(TcColumn():New(STR0041,		{ || IIf(aSalas[oMedicos:nAt,4]==0,"",aSalas[oMedicos:nAt,4]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Agendas"
	oMedicos:AddColumn(TcColumn():New(STR0042,			{ || IIf(aSalas[oMedicos:nAt,5]==0,"",aSalas[oMedicos:nAt,5]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Atend."
	oMedicos:AddColumn(TcColumn():New(STR0043,			{ || IIf(aSalas[oMedicos:nAt,16]==0,"",aSalas[oMedicos:nAt,16]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Espera"
	oMedicos:AddColumn(TcColumn():New(STR0022,		{ || IIf(aSalas[oMedicos:nAt,17]==0,"",aSalas[oMedicos:nAt,17]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Encaixe"
	oMedicos:AddColumn(TcColumn():New(STR0044,		{ || IIf(aSalas[oMedicos:nAt,18]==0,"",aSalas[oMedicos:nAt,18]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Cancelad."
	oMedicos:AddColumn(TcColumn():New(STR0045,	{ || IIf(aSalas[oMedicos:nAt,19]==0,"",aSalas[oMedicos:nAt,19]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Hor. Livres"
	
	oMedicos:SetArray(aSalas)           
	oMedicos:bChange 	:= {|| oHorarios:nAt := 1, Eval(bFiltra, .F.) }
	oMedicos:BLDBLCLICK	:= {|| PLSA315Epr(	oMedicos,aSalas,cCodOpe,cCodLoc,cCdAmbu,dDtRec,aHorMed,aHorPro,oPronto,bAtuDados ) }

	@ 145,013 BITMAP oBmp RESNAME "BR_BRANCO" 	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 145,025 Say oSay PROMPT STR0046 					SIZE 070,010 OF oDlg PIXEL //"Desocupada"
	
	@ 145,123 BITMAP oBmp RESNAME "BR_CINZA"	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 145,133 Say oSay PROMPT STR0047 					SIZE 100,010 OF oDlg PIXEL //"Aguardando Paciente"
	
	@ 145,203 BITMAP oBmp RESNAME "BR_LARANJA"	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 145,213 Say oSay PROMPT STR0048 					SIZE 100,010 OF oDlg PIXEL //"Em Atendimento"
	
	@ 155,013 BITMAP oBmp RESNAME "BR_VERDE"   	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 155,025 Say oSay PROMPT STR0049 					SIZE 100,010 OF oDlg PIXEL //"Aguardando Liberacao de Sala"
	
	@ 155,123 BITMAP oBmp RESNAME "BR_AMARELO"  OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 155,133 Say oSay PROMPT STR0050 					SIZE 100,010 OF oDlg PIXEL //"Sala Virtual"
	
	@ 155,203 BITMAP oBmp RESNAME "BR_AZUL"   	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 155,213 Say oSay PROMPT STR0051 					SIZE 100,010 OF oDlg PIXEL //"Pause"

	
Else
	@ 015, 005 GROUP oGrupo TO 142, 230 PIXEL OF oDlg LABEL STR0037+cDsAmbu+" ]     -     "+"[ "+dtoc(dDataBase)+" ("+PLSDIASEM(dDataBase)+") ]"  COLOR CLR_HBLUE, CLR_HRED        //" AmbulatСrio [ "
		
		oMedicos := TcBrowse():New( 026, 011, 217, 098,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
		
	ADD COLUMN TO oMedicos BITMAP DATA { || LoadBitmap( GetResources(),	If(Empty(aSalas[oMedicos:nAt,3]),"BR_BRANCO",;
																		     IIf(aSalas[oMedicos:nAt,14],"BR_AZUL",;
																				If(!aSalas[oMedicos:nAt,6],;
																					IIf(aSalas[oMedicos:nAt,13]=="S",;
																						IIf(!Empty(aSalas[oMedicos:nAt,08]),"BR_VERDE","BR_AMARELO"),;
																					"BR_CINZA"),;
																				"BR_LARANJA"))) ) } TITLE "" WIDTH 015 NOHILITE
	
	oMedicos:AddColumn(TcColumn():New(STR0038,			{ || aSalas[oMedicos:nAt,1] },nil,nil,nil,nil,014,.F.,.F.,nil,nil,nil,.F.,nil))      //"Sala"
	oMedicos:AddColumn(TcColumn():New(STR0039,			{ || aSalas[oMedicos:nAt,3] },nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))      //"MИdico"
	oMedicos:AddColumn(TcColumn():New(STR0040,	{ || aSalas[oMedicos:nAt,10] },nil,nil,nil,nil,060,.F.,.F.,nil,nil,nil,.F.,nil))      //"Especialidade"
	oMedicos:AddColumn(TcColumn():New(STR0041,		{ || IIf(aSalas[oMedicos:nAt,4]==0,"",aSalas[oMedicos:nAt,4]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Agendas"
	oMedicos:AddColumn(TcColumn():New(STR0042,			{ || IIf(aSalas[oMedicos:nAt,5]==0,"",aSalas[oMedicos:nAt,5]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Atend."
	oMedicos:AddColumn(TcColumn():New(STR0043,			{ || IIf(aSalas[oMedicos:nAt,16]==0,"",aSalas[oMedicos:nAt,16]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Espera"
	oMedicos:AddColumn(TcColumn():New(STR0022,		{ || IIf(aSalas[oMedicos:nAt,17]==0,"",aSalas[oMedicos:nAt,17]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Encaixe"
	oMedicos:AddColumn(TcColumn():New(STR0044,		{ || IIf(aSalas[oMedicos:nAt,18]==0,"",aSalas[oMedicos:nAt,18]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Cancelad."
	oMedicos:AddColumn(TcColumn():New(STR0045,	{ || IIf(aSalas[oMedicos:nAt,19]==0,"",aSalas[oMedicos:nAt,19]) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Hor. Livres"
	
	oMedicos:SetArray(aSalas)           
	oMedicos:bChange 	:= {|| oHorarios:nAt := 1, Eval(bFiltra, .F.) }
	oMedicos:BLDBLCLICK	:= {|| PLSA315Epr(	oMedicos,aSalas,cCodOpe,cCodLoc,cCdAmbu,dDtRec,aHorMed,aHorPro,oPronto,bAtuDados ) }

	@ 125,013 BITMAP oBmp RESNAME "BR_BRANCO" 						OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 125,025 Say oSay PROMPT STR0046 					SIZE 070,010 OF oDlg PIXEL //"Desocupada"
	
	@ 125,108 BITMAP oBmp RESNAME "BR_CINZA"   					OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 125,118 Say oSay PROMPT STR0047 					SIZE 100,010 OF oDlg PIXEL //"Aguardando Paciente"
	
	@ 125,173 BITMAP oBmp RESNAME "BR_LARANJA"   				OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 125,183 Say oSay PROMPT STR0048 					SIZE 100,010 OF oDlg PIXEL //"Em Atendimento"
	
	@ 133,013 BITMAP oBmp RESNAME "BR_VERDE"   					OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 133,025 Say oSay PROMPT STR0049 					SIZE 100,010 OF oDlg PIXEL //"Aguardando Liberacao de Sala"
	
	@ 133,108 BITMAP oBmp RESNAME "BR_AMARELO"   				OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 133,118 Say oSay PROMPT STR0050 					SIZE 100,010 OF oDlg PIXEL //"Sala Virtual"
		
	@ 133,173 BITMAP oBmp RESNAME "BR_AZUL"   	OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 133,183 Say oSay PROMPT STR0051 					SIZE 100,010 OF oDlg PIXEL //"Pause"
	
EndIf */     
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta horarios...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ aPosObj2[1,1],aPosObj2[1,2] GROUP oGrupo TO aPosObj2[1,3],aPosObj2[1,4] PIXEL OF oDlg LABEL STR0052  COLOR CLR_HBLUE, CLR_HRED//" Pacientes "
@ aPosObj2[2,1],aPosObj2[2,2] GROUP oGrupo TO aPosObj2[2,3],aPosObj2[2,4] PIXEL OF oDlg LABEL ""  COLOR CLR_HBLUE, CLR_HRED//LEGENDA

/*
If nHRes > 969	.and.   nHRes < 1545	// Resolucao 1280x1024
	@ 15, 309 GROUP oGrupo TO 260, 604 PIXEL OF oDlg LABEL STR0052  COLOR CLR_HBLUE, CLR_HRED        //" Pacientes "
ElseIf nHRes >= 1545		
	@ 15, 309 GROUP oGrupo TO 300, 604 PIXEL OF oDlg LABEL STR0052  COLOR CLR_HBLUE, CLR_HRED        //" Pacientes "
Else
	@ 015, 235 GROUP oGrupo TO 220, 480 PIXEL OF oDlg LABEL STR0052  COLOR CLR_HBLUE, CLR_HRED        //" Pacientes "
EndIf
*/

nAlt := aPosObj1[1,4] + 10
oHorarios := TcBrowse():New( aPosObj2[1,1]+8,aPosObj2[1,2]+2, aPosObj2[1,4]-nAlt,aPosObj2[1,3]-45,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

/*
If nHRes > 969	.and.   nHRes < 1545 // Resolucao 1280x1024
	oHorarios := TcBrowse():New( 27, 315,280, 225,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
ElseIf nHRes >= 1545		
	oHorarios := TcBrowse():New( 27, 315,280, 270,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
Else
	oHorarios := TcBrowse():New( 026, 242, 230, 190,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
EndIf
*/
                               
/*                               
ADD COLUMN TO oHorarios BITMAP DATA { || IIf(Len(aHorMed)>0,IIf(!Empty(aHorMed[oHorarios:nAt,10]) .And. (aHorMed[oHorarios:nAt,10] # cMotBlo),"NOCHECKED",;
											  IIf( (aHorMed[oHorarios:nAt,7] == '5' .Or. aHorMed[oHorarios:nAt,9] == '1') .And. !aHorMed[oHorarios:nAt,7] $ '8,7,6,2,3,4',;
											  		IIf(PLSA315ATRZ(aHorMed,oHorarios,2),"BR_VERMELHO",PLSA315Cor(aHorMed,oHorarios) ),;
											  PLSA315Cor(aHorMed,oHorarios) ) ),) } TITLE "" WIDTH 015 NOHILITE
*/


oHorarios:AddColumn(TcColumn():New(" ",{ || IIf(Len(aHorMed)>0,IIf(!Empty(aHorMed[oHorarios:nAt,10]) .And. (aHorMed[oHorarios:nAt,10] # cMotBlo),"NOCHECKED",;
									                     IIf( (aHorMed[oHorarios:nAt,7] == '5' .Or. aHorMed[oHorarios:nAt,9] == '1') .And. !aHorMed[oHorarios:nAt,7] $ '8,7,6,2,3,4',;
											  		              IIf(PLSA315ATRZ(aHorMed,oHorarios,2),"BR_VERMELHO",PLSA315Cor(aHorMed,oHorarios) ),;
											                         PLSA315Cor(aHorMed,oHorarios) ) ),) },;
                                                                               nil,nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
											  
											  
											  

oHorarios:AddColumn(TcColumn():New(STR0053,nil,nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))      //"Hora"
oHorarios:ACOLUMNS[2]:BDATA := { || IIf(Len(aHorMed)>0,aHorMed[oHorarios:nAt,2],) }

oHorarios:AddColumn(TcColumn():New(STR0054,nil,nil,nil,nil,nil,100,.F.,.F.,nil,nil,nil,.F.,nil))      //"Paciente"
oHorarios:ACOLUMNS[3]:BDATA := { || IIf(Len(aHorMed)>0,aHorMed[oHorarios:nAt,4],) }

oHorarios:AddColumn(TcColumn():New(STR0055,nil,nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))      //"Telefone"
oHorarios:ACOLUMNS[4]:BDATA := { || IIf(Len(aHorMed)>0,aHorMed[oHorarios:nAt,5],) }

oHorarios:AddColumn(TcColumn():New(STR0056,nil,nil,nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil))      //"Ult. Chamados"
oHorarios:ACOLUMNS[5]:BDATA := { || IIf(Len(aHorMed)>0,aHorMed[oHorarios:nAt,16],) }

oHorarios:AddColumn(TcColumn():New(STR0057,nil,nil,nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil))      //"Operador"
oHorarios:ACOLUMNS[6]:BDATA := { || IIf(Len(aHorMed)>0,aHorMed[oHorarios:nAt,18],) }

oHorarios:AddColumn(TcColumn():New(STR0058,nil,nil,nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil))      //"Matricula Nova"
oHorarios:ACOLUMNS[7]:BDATA := { || IIf(Len(aHorMed)>0,TransForm(aHorMed[oHorarios:nAt,3],"@R !!!!.!!!!.!!!!!!.!!-!"),) }

oHorarios:AddColumn(TcColumn():New(STR0059,nil,nil,nil,nil,nil,080,.F.,.F.,nil,nil,nil,.F.,nil))      //"Matricula Ant."
oHorarios:ACOLUMNS[8]:BDATA := { || IIf(Len(aHorMed)>0,TransForm(aHorMed[oHorarios:nAt,17],"@R !!!!.!!!!.!!!!!!.!!-!"),) }

If ExistBlock("PLS315HOR")   

	aNewColum := ExecBlock("PLS315HOR",.F.,.F.)

	For nX := 1 to Len(aNewColum)
		oHorarios:AddColumn(TcColumn():New(aNewColum[nX][1],;
											aNewColum[nX][2],;
											aNewColum[nX][3],;
											aNewColum[nX][4],;
											aNewColum[nX][5],;
											aNewColum[nX][6],;
											aNewColum[nX][7],;
											aNewColum[nX][8],;
											aNewColum[nX][9],;
											aNewColum[nX][10],;
											aNewColum[nX][11],;
											aNewColum[nX][12],;
											aNewColum[nX][13],;
											aNewColum[nX][14]))     
		oHorarios:ACOLUMNS[len(	oHorarios:ACOLUMNS)]:BDATA := &(aNewColum[nX][15])
	Next

EndIf	

oHorarios:SetArray(aHorMed)         
oHorarios:BLDBLCLICK 	:= bValid
oHorarios:BGOTFOCUS		:= {|| nBrw := 1 }
oHorarios:BLOSTFOCUS	:= {|| nBrw := 0 }
oHorarios:bChange := { || oPacientesAux := oHorarios }
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta pronto atendimento...                                              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aAlt := {nWRes*0.07,25,nWRes*0.07,nWRes*0.07}
nAlt := aAlt[1] + aAlt[2] + 50

@ aPosObj1[2,1],aPosObj1[2,2] GROUP oGrupo TO aPosObj1[2,3],aPosObj1[2,4] PIXEL OF oDlg LABEL ""  COLOR CLR_HBLUE, CLR_HRED //LEGENDA
@ aPosObj1[3,1],aPosObj1[3,2] GROUP oGrupo TO aPosObj1[3,3],aPosObj1[3,4] PIXEL OF oDlg LABEL STR0060  COLOR CLR_HBLUE, CLR_HRED //" Pronto Atendimento - ( Pesquisar - <CTRL + P> ) "

oPronto := TcBrowse():New( aPosObj1[3,1]+8,aPosObj1[3,2]+2, aPosObj1[3,4]-8,aPosObj1[3,3]-nAlt,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
/*
If nHRes > 969	.and. nHRes < 1545 // Resolucao 1280x1024
	
	oPronto := TcBrowse():New( 210, 011, 285, 055,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
ElseIf nHRes >= 1545	
	@ 170, 005 GROUP oGrupo TO 265, 300 PIXEL OF oDlg LABEL STR0060  COLOR CLR_HBLUE, CLR_HRED //" Pronto Atendimento - ( Pesquisar - <CTRL + P> ) "
	
Else
	@ 143, 005 GROUP oGrupo TO 210, 230 PIXEL OF oDlg LABEL STR0060  COLOR CLR_HBLUE, CLR_HRED //" Pronto Atendimento - ( Pesquisar - <CTRL + P> ) "
	oPronto := TcBrowse():New( 150, 011, 217, 058,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
EndIf
*/ 


/*
ADD COLUMN TO oPronto BITMAP DATA { || IIf(Len(aHorPro) == 0, "BR_VERDE", IIf(PLSA315ATRZ(aHorPro,oPronto, 13),IIf(aHorPro[oPronto:nAt,12]=="0","BR_VERMELHO","BR_PRETO"),IIf(aHorPro[oPronto:nAt,12]=="0","BR_VERDE","BR_PRETO")))} TITLE "" WIDTH 015 NOHILITE
*/

oPronto:AddColumn(TcColumn():New(" ",{ || IIf(Len(aHorPro) == 0, "BR_VERDE", IIf(PLSA315ATRZ(aHorPro,oPronto, 13),IIf(aHorPro[oPronto:nAt,12]=="0","BR_VERMELHO","BR_PRETO"),IIf(aHorPro[oPronto:nAt,12]=="0","BR_VERDE","BR_PRETO"))) },;
                                                                     nil,nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))	



oPronto:AddColumn(TcColumn():New(STR0061,			{ || IIf(Len(aHorPro)>0,aHorPro[oPronto:nAt,13],nil) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Chegada"
oPronto:AddColumn(TcColumn():New(STR0054,		{ || IIf(Len(aHorPro)>0,aHorPro[oPronto:nAt,3],nil) },nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))      //"Paciente"
oPronto:AddColumn(TcColumn():New(STR0040,	{ || IIf(Len(aHorPro)>0,aHorPro[oPronto:nAt,10],nil) },nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))               //"Especialidade"
oPronto:AddColumn(TcColumn():New(STR0039,			{ || IIf(Len(aHorPro)>0,aHorPro[oPronto:nAt,8],nil) },nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))        //"MИdico"
oPronto:AddColumn(TcColumn():New(STR0062,			{ || IIf(Len(aHorPro)>0,StrZero(aHorPro[oPronto:nAt,11],3),nil) },nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))      //"Seq."
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Soma a quantidade de vezes que o usuario foi chamado pela recepcao.      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды         
oPronto:AddColumn(TcColumn():New(STR0032,{ || IIf(Len(aHorPro)>0, StrZero(aHorPro[oPronto:nAt,14],2), nil) },nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))               //"Chamadas"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Set array no obj														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды         
oPronto:SetArray(aHorPro)         
oPronto:BGOTFOCUS	:= {|| IIf(Len(aHorPro) > 0,nBrw := 2,nBrw := 0) }
oPronto:BLOSTFOCUS	:= {|| nBrw := 0 }
oPronto:BLDBLCLICK 	:= {|| PLSA315APr(oPronto,aHorPro,dDtRec,oMedicos:nAt,aSalas,bAtuDados) }
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Lista de Espera															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//nAlt := aObjects[1,2] + aObjects[3,2] + 05

aAlt := {nWRes*0.05,nWRes*0.07,nWRes*0.05,nWRes*0.05}
nAlt := aAlt[1] + aAlt[2] + 43



@ aPosObj1[4,1],aPosObj1[4,2] GROUP oGrupo TO aPosObj1[4,3],aPosObj1[4,4] PIXEL OF oDlg LABEL STR0063  COLOR CLR_HBLUE, CLR_HRED //" Lista de Espera - ( <CTRL + E> ) "
oLisEsp := TcBrowse():New( aPosObj1[4,1]+8,aPosObj1[4,2]+2, aPosObj1[4,4]-8,aPosObj1[4,4]-nAlt,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
/*voltar
If nHRes > 969 .and. nHRes < 1545 	// Resolucao 1280x1024
	@ 300, 005 GROUP oGrupo TO 372, 300 PIXEL OF oDlg LABEL STR0063  COLOR CLR_HBLUE, CLR_HRED //" Lista de Espera - ( <CTRL + E> ) "
	oLisEsp := TcBrowse():New( 310, 011, 285, 055,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
ElseIf nHRes >= 1545	
	@ 270, 005 GROUP oGrupo TO 345, 300 PIXEL OF oDlg LABEL STR0063  COLOR CLR_HBLUE, CLR_HRED //" Lista de Espera - ( <CTRL + E> ) "
	oLisEsp := TcBrowse():New( 280, 011, 285, 065,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
Else 
	@ 212, 005 GROUP oGrupo TO 258, 230 PIXEL OF oDlg LABEL STR0063  COLOR CLR_HBLUE, CLR_HRED //" Lista de Espera - ( <CTRL + E> ) "
	oLisEsp := TcBrowse():New( 218, 011, 217, 038,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
EndIf   */

/*
ADD COLUMN TO oLisEsp BITMAP DATA { || "BR_VERDE" } TITLE "" WIDTH 015 NOHILITE
*/

oLisEsp:AddColumn(TcColumn():New(" ",{ || "BR_VERDE" },;
         nil,nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))

oLisEsp:AddColumn(TcColumn():New(STR0061,			{ || IIf(Len(aHorEsp)>0,aHorEsp[oLisEsp:nAt,12],) },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil))      //"Chegada"
oLisEsp:AddColumn(TcColumn():New(STR0054,		{ || IIf(Len(aHorEsp)>0,aHorEsp[oLisEsp:nAt,3],) },nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))      //"Paciente"
oLisEsp:AddColumn(TcColumn():New(STR0040,	{ || IIf(Len(aHorEsp)>0,aHorEsp[oLisEsp:nAt,9],) },nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))               //"Especialidade"
oLisEsp:AddColumn(TcColumn():New(STR0039,			{ || IIf(Len(aHorEsp)>0,aHorEsp[oLisEsp:nAt,7],) },nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil))        //"MИdico"
oLisEsp:AddColumn(TcColumn():New(STR0062,			{ || IIf(Len(aHorEsp)>0,StrZero(aHorEsp[oLisEsp:nAt,10],3),) },nil,nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))      //"Seq."

oLisEsp:SetArray(aHorEsp)         
oLisEsp:BGOTFOCUS	:= {|| IIf(Len(aHorEsp) > 0,nBrw := 3,nBrw := 0) }
oLisEsp:BLOSTFOCUS	:= {|| nBrw := 0 }
oLisEsp:BLDBLCLICK 	:= {|| IIf(Len(aHorEsp) > 0,PLSA315Les(aHorEsp[oLisEsp:nAt,1],dDtRec,cCodLoc,cCodOpe,oMedicos,aSalas,cCdAmbu,cCodCon,aHorEsp,aHorMed,bAtuDados),Nil) }

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grupo de legenda														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
/*voltar
If nHRes > 969	.and.  nHRes < 1545		// Resolucao 1280x1024
	
	@ 335, 309 GROUP oGrupo TO 372, 604 PIXEL OF oDlg LABEL STR0064  COLOR CLR_HBLUE, CLR_HRED        //" Legenda "
*/	
	@ aPosObj2[2,1]+05,aPosObj2[2,2]+05 BITMAP oBmp RESNAME "BR_BRANCO" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj2[2,1]+05,aPosObj2[2,2]+15 Say oSay PROMPT STR0065 SIZE 040,010 OF oDlg PIXEL //"HorАrio Livre"
	
	@ aPosObj2[2,1]+05,aPosObj2[2,2]+60 BITMAP oBmp RESNAME "BR_CINZA"   OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj2[2,1]+05,aPosObj2[2,2]+70 Say oSay PROMPT STR0066 SIZE 040,010 OF oDlg PIXEL //"Agendado"
	
	@ aPosObj2[2,1]+05,aPosObj2[2,2]+100 BITMAP oBmp RESNAME "BR_VERDE" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj2[2,1]+05,aPosObj2[2,2]+110 Say oSay PROMPT STR0043 SIZE 040,010 OF oDlg PIXEL //"Espera"
	
	@ aPosObj2[2,1]+05,aPosObj2[2,2]+155 BITMAP oBmp RESNAME "BR_LARANJA" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj2[2,1]+05,aPosObj2[2,2]+165 Say oSay PROMPT STR0067 SIZE 040,010 OF oDlg PIXEL //"ConsultСrio"
	
	@ aPosObj2[2,1]+15,aPosObj2[2,2]+05 BITMAP oBmp RESNAME "BR_AZUL" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj2[2,1]+15,aPosObj2[2,2]+15 Say oSay PROMPT STR0068 SIZE 040,010 OF oDlg PIXEL //"Atendido"
	
	@ aPosObj2[2,1]+15,aPosObj2[2,2]+60 BITMAP oBmp RESNAME "BR_AMARELO" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj2[2,1]+15,aPosObj2[2,2]+70 Say oSay PROMPT STR0022 SIZE 040,010 OF oDlg PIXEL //"Encaixe"
	
	@ aPosObj2[2,1]+15,aPosObj2[2,2]+100 BITMAP oBmp RESNAME "BR_VERMELHO" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj2[2,1]+15,aPosObj2[2,2]+110 Say oSay PROMPT STR0069 SIZE 045,010 OF oDlg PIXEL //"Espera Excedida"
	
	@ aPosObj2[2,1]+15,aPosObj2[2,2]+155 BITMAP oBmp RESNAME "NOCHECKED" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ aPosObj2[2,1]+15,aPosObj2[2,2]+165 Say oSay PROMPT STR0070 SIZE 040,010 OF oDlg PIXEL //"Cancelado"
/*ElseIf nHRes >= 1545			

	@ 300, 309 GROUP oGrupo TO 345, 604 PIXEL OF oDlg LABEL STR0064  COLOR CLR_HBLUE, CLR_HRED        //" Legenda "
	
	@ 315,320 BITMAP oBmp RESNAME "BR_BRANCO" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 315,330 Say oSay PROMPT STR0065 SIZE 040,010 OF oDlg PIXEL //"HorАrio Livre"
	
	@ 315,397 BITMAP oBmp RESNAME "BR_CINZA"   OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 315,407 Say oSay PROMPT STR0066 SIZE 040,010 OF oDlg PIXEL //"Agendado"
	
	@ 315,447 BITMAP oBmp RESNAME "BR_VERDE" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 315,457 Say oSay PROMPT STR0043 SIZE 040,010 OF oDlg PIXEL //"Espera"
	
	@ 315,504 BITMAP oBmp RESNAME "BR_LARANJA" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 315,514 Say oSay PROMPT STR0067 SIZE 040,010 OF oDlg PIXEL //"ConsultСrio"
	
	@ 325,320 BITMAP oBmp RESNAME "BR_AZUL" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 324,330 Say oSay PROMPT STR0068 SIZE 040,010 OF oDlg PIXEL //"Atendido"
	
	@ 325,397 BITMAP oBmp RESNAME "BR_AMARELO" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 325,407 Say oSay PROMPT STR0022 SIZE 040,010 OF oDlg PIXEL //"Encaixe"
	
	@ 325,447 BITMAP oBmp RESNAME "BR_VERMELHO" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 325,457 Say oSay PROMPT STR0069 SIZE 045,010 OF oDlg PIXEL //"Espera Excedida"
	
	@ 325,504 BITMAP oBmp RESNAME "NOCHECKED" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 325,515 Say oSay PROMPT STR0070 SIZE 040,010 OF oDlg PIXEL //"Cancelado"


	
Else // Resolucao 1024x768
	@ 223, 235 GROUP oGrupo TO 258, 480 PIXEL OF oDlg LABEL STR0064  COLOR CLR_HBLUE, CLR_HRED        //" Legenda "
	
	@ 232,240 BITMAP oBmp RESNAME "BR_BRANCO" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 232,250 Say oSay PROMPT STR0065 SIZE 040,010 OF oDlg PIXEL //"HorАrio Livre"
	
	@ 232,287 BITMAP oBmp RESNAME "BR_CINZA"   OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 232,297 Say oSay PROMPT STR0066 SIZE 040,010 OF oDlg PIXEL //"Agendado"
	
	@ 232,334 BITMAP oBmp RESNAME "BR_VERDE" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 232,344 Say oSay PROMPT STR0043 SIZE 040,010 OF oDlg PIXEL //"Espera"
	
	@ 232,391 BITMAP oBmp RESNAME "BR_LARANJA" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 232,403 Say oSay PROMPT STR0067 SIZE 040,010 OF oDlg PIXEL //"ConsultСrio"
	
	@ 247,240 BITMAP oBmp RESNAME "BR_AZUL" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 247,250 Say oSay PROMPT STR0068 SIZE 040,010 OF oDlg PIXEL //"Atendido"
	
	@ 247,287 BITMAP oBmp RESNAME "BR_AMARELO" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 247,297 Say oSay PROMPT STR0022 SIZE 040,010 OF oDlg PIXEL //"Encaixe"
	
	@ 247,334 BITMAP oBmp RESNAME "BR_VERMELHO" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 247,344 Say oSay PROMPT STR0069 SIZE 045,010 OF oDlg PIXEL //"Espera Excedida"
	
	@ 244,391 BITMAP oBmp RESNAME "NOCHECKED" OF oDlg SIZE 20,20 NOBORDER WHEN .F. PIXEL
	@ 247,403 Say oSay PROMPT STR0070 SIZE 040,010 OF oDlg PIXEL //"Cancelado"
	
EndIf  */
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define timer para dar refresh no browse da agenda...                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oTimerBrw 	:= TTimer():New( nTime*900 ,bAtuDados,oDlg)	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa dialogo...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlg CENTER ON INIT Eval({ || oPacientesAux := oHorarios, dbSelectArea("BBD"), EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons), oTimerBrw:Activate(),Eval(bFiltra), If(cTime=="1",nil,nil),nil }) 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cancela definicao de teclas de atalho...                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SET KEY VK_F4   TO
SET KEY VK_F5   TO
SET KEY VK_F6   TO
SET KEY VK_F7   TO
SET KEY VK_F8   TO
SET KEY VK_F9   TO
SET KEY VK_F10  TO
SET KEY VK_F11  TO
SET KEY VK_F12  TO
SET KEY 1 	    TO
SET KEY 2 	    TO
SET KEY 6 	    TO
SET KEY 13 	    TO                      
SET KEY 20 	    TO           
SET KEY 16 		TO
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA315VET Ё Autor ЁGeraldo Felix JuniorЁ Data Ё 29.01.02 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Funcao de apoio para criar as matrizes aSalas   e aHorarioЁ╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function PLSA315Vet(cBB7Name,cBB8Name,cBAUName,cBAQName,aMedicos,aSalas,cDia,cCodLoc,cCodOpe,aHorarios,;
						   aHorMed,dDtRec,cCdAmbu,aPronto,aHorPro,cDiaMes,cMes,cAno,aLisEsp,aHorEsp)

Local nI
Local nSeq
Local nAux
Local cSQL
Local aAux
Local lAux 		:= .F.
Local nRecBBD	:= 0
Local nSala 	:= 1
Local cMotBlo 	:= GetNewPar("MV_PLMCBL","001")
Local aMatEst   := {0,0,0,0,0,0,0}
Local aBloq		:= {}
Local nPosBlq	:= 0
Local lPLS315AHR := ExistBlock("PLS315AHR")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Montar variaveis para utilizacao nas querys...                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT "
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Dados da agenda...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL += "BB7_CODIGO, BB7_DIA, BB7_CODESP, BB7_CODINT, BB7_HORENT,BB7_HORSAI, BB7_EXCINI, BB7_EXCFIN, BB7_CODLOC, "
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Dados do Local de atendimento...                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL += "BB8_CODIGO, BB8_CODLOC, BB8_LOCAL, BB8_CODINT, BB8_TMPCON, BB7_PLTINI, BB7_PLTFIN, BB7_INTERV,"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Dados do medico...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL += "BAU_CODIGO, BAU_NOME, BAU_LEGEND, "+cBAUName+".R_E_C_N_O_ REGBAU, "
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Dados da especialidade...                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL += "BAQ_CODESP, BAQ_DESCRI "
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta From...                                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL += "FROM "+cBB7Name+", "+cBAUName+", "+cBB8Name+", "+cBAQName+" "
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Where																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL += "WHERE "
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Filtra por filial e deletados...                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL += "BB7_FILIAL = '"+xFilial("BB7")+"' AND "
cSQL += "BAU_FILIAL = '"+xFilial("BAU")+"' AND "
cSQL += "BB8_FILIAL = '"+xFilial("BB8")+"' AND "
cSQL += "BAQ_FILIAL = '"+xFilial("BAQ")+"' AND "
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё delete																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL += cBB7Name+".D_E_L_E_T_ = '' AND "
cSQL += cBAUName+".D_E_L_E_T_ = '' AND "
cSQL += cBB8Name+".D_E_L_E_T_ = '' AND "
cSQL += cBAQName+".D_E_L_E_T_ = '' AND "
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta relacionamento entre tabelas envolvidas...                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL += "BB7_CODIGO = BAU_CODIGO AND "
cSQL += "BB7_CODINT = BB8_CODINT AND "
cSQL += "BB7_CODIGO = BB8_CODIGO AND "
cSQL += "BB7_CODLOC = BB8_CODLOC AND "
cSQL += "BB7_CODESP = BAQ_CODESP AND "
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Filtro para ignorar agendas em branco na base...                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSql += " (BB7_HORENT <> '  :  ' AND BB7_HORENT <> ' ' AND BB7_HORSAI <> '  :  ' AND BB7_HORSAI <> ' ' OR "
cSql += "  BB7_PLTINI <> '  :  ' AND BB7_PLTINI <> ' ' AND BB7_PLTFIN <> '  :  ' AND BB7_PLTFIN <> ' ') AND "
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta filtro baseados nos parametros da rotina...                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL += "BB7_DIA    = '"+cDia+"' 	AND "
cSQL += "BB7_DIAMES = '"+cDiaMes+"'	AND "
cSQL += "BB7_MES    = '"+cMes+"'	AND "
cSQL += "BB7_ANO	= '"+cAno+"'	AND "
cSQL += "BB7_CODINT = '"+cCodOpe+"'	AND "
cSQL += "BB8_LOCAL  = '"+cCodLoc+"' "
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ordena o resultado da consulta...                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL += "ORDER BY BAU_FILIAL,BAU_NOME"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Area																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Select("Trba315") <> 0
	Trba315->(DbCloseArea())
	DbSelectArea("BDH")
EndIf
PLSQuery(@cSQL,"Trba315")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Primeiro															     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Trba315->( DbGoTop() )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Zera matriz																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aHorarios := {}
aHorMed   := {}
aMedicos  := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seta ordem																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->( DbSetorder(01) )
While ! Trba315->(Eof())
	aadd(aMedicos,{Trba315->(BB7_CODIGO),;
					AllTrim(Trba315->BAU_NOME),;	
					Trba315->REGBAU,;
					Trba315->BB7_CODESP,;
					Trba315->BAQ_DESCRI,;
					AllTrim(X3COMBO("BAU_LEGEND",Trba315->BAU_LEGEND))+". ",;
					Trba315->BB7_CODLOC} )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Matriz auxiliar															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aAux := Trba315->(PLSA300HR(BB7_HORENT,BB7_HORSAI,IIf(!Empty(BB7_INTERV),BB7_INTERV,BB8_TMPCON),BB7_EXCINI,BB7_EXCFIN,BB7_PLTINI,BB7_PLTFIN)) 
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё For na aux																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	For nAux := 1 To Len(aAux)   
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё VerIfica se o horario esta ocupado, caso esteja preenche com os dados do paciente... Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		lAux := .F.
		If ( Ascan(aHorarios,{|a| a[1]+a[2] = Trba315->(BB7_CODIGO)+aAux[nAux] }) == 0 )
			If BBD->(MsSeek(xFilial("BBD")+Trba315->BB7_CODIGO+cCodOpe+Trba315->BB8_CODLOC+dtos(dDtRec)+aAux[nAux])) .And.;
			   BBD->BBD_PRTATD <> '1'
			   	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   	//Ё Continua verIficao...													Ё
    		   	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				While !BBD->( Eof() ) .And.;
					Trba315->BB7_CODIGO+cCodOpe+Trba315->BB8_CODLOC+dtos(dDtRec)+aAux[nAux] ==;
					BBD->(BBD_CODIGO+BBD_CODINT+BBD_CODLOC+DTOS(BBD_DATA)+BBD_HORA)
				    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				    //Ё Se estiver cancelada, passa agenda...  						     		 Ё
	    		    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If !Empty(BBD->BBD_CODCAN) 
						BBD->( dbSkip() )
						Loop

					EndIf
					
					lAux := .T.
					aadd(aHorarios,{Trba315->(BB7_CODIGO),;
									aAux[nAux],;
									BBD->BBD_CODPAC,;
									BBD->BBD_NOME,;
									BBD->BBD_TELEFO,;
									BBD->(Recno()),;
									BBD->BBD_STATUS,;
									IIf(!Empty(AllTrim(Trba315->BAU_NOME)),AllTrim(X3COMBO("BAU_LEGEND",Trba315->BAU_LEGEND))+"."+Space(5)+AllTrim(Trba315->BAU_NOME),""),;
									BBD->BBD_ENCAIX,;
									BBD->BBD_CODCAN,;
									BBD->BBD_CODESP,;
									'',;
									.T.,;
									IIf(BBD->(FieldPos("BBD_ATERNA"))>0,BBD->BBD_CHAMAD, "0"),;
									Trba315->(BB7_CODLOC),;
									Right(AllTrim(BBD->BBD_HORCMD),18),;
									BBD->BBD_MATANT,;
									BBD->BBD_USUOPE })
				    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				    //Ё Skip																	 Ё
	    		    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					BBD->( DbSkip() )
				Enddo
			Else
				lAux := .F.
			EndIf

	  	    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		    //Ё Verdadeiro																 Ё
		    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If !lAux     
				aadd(aHorarios,{Trba315->(BB7_CODIGO),;
								aAux[nAux],;
								"",;
								"",;
								"",;
								0,;
								"",;
								"",;
								"",;
								"",;
								Trba315->BB7_CODESP,;
								"",;
								.T.,;
								"0",;
								Trba315->(BB7_CODLOC),;
								"",;
								"",;
								""})                      
								
			EndIf
			If lPLS315AHR
				aHorarios[Len(aHorarios)] := ExecBlock("PLS315AHR",.F.,.F., {aHorarios[Len(aHorarios)]})
			EndIf	
		EndIf
	Next
	Trba315->(DbSkip())
Enddo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Trba315->(DbCloseArea())
DbSelectArea("BBD")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta os horarios de encaixe... alimentando matriz de horarios           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := " SELECT * FROM "+BBD->(RetSQLName("BBD"))
cSQL += " WHERE BBD_FILIAL = '"+xFilial("BBD")+"' "
cSQL += "   AND BBD_LOCAL  = '"+cCodLoc+"' "
cSQL += "   AND BBD_DATA   = '"+dtos(dDtRec)+"' "
cSQL += "   AND BBD_CODINT = '"+cCodOpe+"' AND "
cSQL += " ( (BBD_ENCAIX = '1') OR (BBD_PRTATD = '1' AND BBD_NUMATE <> '"+Space(Len(BBD->BBD_NUMATE))+"') ) "
cSQL += "   AND D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY BBD_FILIAL "
PLSQuery(cSQL,"Trb315")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Primeiro																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Trb315->( DbGoTop() )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё While																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While ! Trb315->(Eof())
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no credenciado...                                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BAU->(DbSetOrder(1))
	BAU->(MsSeek(xFilial("BAU")+Trb315->(BBD_CODIGO)))
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Para cada encaixe adiciona no vetor...                                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nPos := Ascan(aHorarios, {|x| x[2] ==Trb315->BBD_HORA .And. x[1] == Trb315->BBD_CODIGO .And.;
	(x[3] == Trb315->BBD_CODPAC .And. Trb315->BBD_CODPAC # '99999999999999990')})
	If nPos == 0
		aadd(aHorarios,{Trb315->BBD_CODIGO,;
		Trb315->BBD_HORA,;
		Trb315->BBD_CODPAC,;
		Trb315->BBD_NOME,;
		Trb315->BBD_TELEFO,;
		Trb315->R_E_C_N_O_,;
		Trb315->BBD_STATUS,;
		AllTrim(X3COMBO("BAU_LEGEND",BAU->BAU_LEGEND))+". "+Space(5)+AllTrim(BAU->BAU_NOME),;
		Trb315->BBD_ENCAIX,;
		Trb315->BBD_CODCAN,;
		Trb315->BBD_CODESP,;
		"",;
		.T.,;
		Trb315->BBD_CHAMAD,;
		Trb315->BBD_CODLOC,;
		Right(AllTrim(Trb315->BBD_HORCMD),18),;
		Trb315->BBD_MATANT,;
		Trb315->BBD_USUOPE })
	Else
		aHorarios[nPos][1] := Trb315->BBD_CODIGO
		aHorarios[nPos][2] := Trb315->BBD_HORA
		aHorarios[nPos][3] := Trb315->BBD_CODPAC
		aHorarios[nPos][4] := Trb315->BBD_NOME
		aHorarios[nPos][5] := Trb315->BBD_TELEFO
		aHorarios[nPos][6] := Trb315->R_E_C_N_O_
		aHorarios[nPos][7] := Trb315->BBD_STATUS
		aHorarios[nPos][8] := AllTrim(X3COMBO("BAU_LEGEND",BAU->BAU_LEGEND))+". "+Space(5)+AllTrim(BAU->BAU_NOME)
		aHorarios[nPos][9] := Trb315->BBD_ENCAIX
		aHorarios[nPos][10]:= Trb315->BBD_CODCAN
		aHorarios[nPos][11]:= Trb315->BBD_CODESP
		aHorarios[nPos][12]:= ''
		aHorarios[nPos][13]:= .T.
		aHorarios[nPos][14]:= Trb315->BBD_CHAMAD
		aHorarios[nPos][15]:= Trb315->(BBD_CODLOC)
		aHorarios[nPos][16]:= Right(AllTrim(Trb315->BBD_HORCMD),18)
		aHorarios[nPos][17]:= Trb315->BBD_MATANT
		aHorarios[nPos][18]:= Trb315->BBD_USUOPE
	EndIf
	
	If lPLS315AHR
		aHorarios[Len(aHorarios)] := ExecBlock("PLS315AHR",.F.,.F., {aHorarios[Len(aHorarios)]})
	EndIf
	
	Trb315->( DbSkip() )
Enddo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ordena matriz medico e horarios											 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aSort(aMedicos,,,  { |x, y| x[1] < y[1] })
aSort(aHorarios,,, { |x, y| x[2] < y[2] })

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta matriz horxmedicos												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aHorMed := aClone(aHorarios)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha Area de Trabalho...                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Trb315->(DbCloseArea())
DbSelectArea("BBD")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta os horarios de encaixe...                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aPronto := {}
aHorPro := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta os horarios pronto atendimento...                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cTipoPa := "1"
nSeq	:= 1
For nI := 1 To 2
	cSQL := " SELECT * FROM "+BBD->(RetSQLName("BBD"))
	cSQL += " WHERE BBD_FILIAL = '"+xFilial("BBD")+"' "
	cSQL += "   AND BBD_LOCAL  = '"+cCodLoc+"' "
	cSQL += "   AND BBD_DATA   = '"+dtos(dDtRec)+"' "
	cSQL += "   AND BBD_CODINT = '"+cCodOpe+"' "
	cSQL += "   AND BBD_PRTATD = '1' "
	cSQL += "   AND BBD_TIPOPA = '"+cTipoPa+"' "
	cSql += "   AND BBD_CDAMBU = '"+mv_par03+"' "
	cSql += "   AND BBD_CODCAN = ''  "
	cSQL += "   AND BBD_STATUS <> '2' "
	cSQL += "   AND BBD_NUMATE = '"+Space(Len(BBD->BBD_NUMATE))+"' "
	cSQL += "   AND D_E_L_E_T_ = ' ' "
	cSQL += " ORDER BY BBD_FILIAL,R_E_C_N_O_ "
	PLSQuery(cSQL,"Trb315")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Primeiro																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Trb315->( DbGoTop() )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё While																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	While ! Trb315->( Eof() )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona no credenciado...                                              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BAU->(DbSetOrder(1))
		BAU->(MsSeek(xFilial("BAU")+Trb315->(BBD_CODIGO)))
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Para cada Pronto Atendimento adiciona no vetor...                        Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aadd(aPronto,{	Trb315->R_E_C_N_O_,;
		Trb315->BBD_CODPAC,;
		Trb315->BBD_NOME,;
		Trb315->BBD_TELEFO,;
		Trb315->R_E_C_N_O_,;
		Trb315->BBD_STATUS,;
		Trb315->BBD_CODIGO,;
		IIf(!Empty(AllTrim(BAU->BAU_NOME)),AllTrim(X3COMBO("BAU_LEGEND",BAU->BAU_LEGEND))+". "+Space(5)+AllTrim(BAU->BAU_NOME),""),;
		Trb315->BBD_CODESP,;
		BAQ->(Posicione("BAQ",1,xFilial("BAQ")+Trb315->(BBD_CODINT+BBD_CODESP),"BAQ_DESCRI")),;
		nSeq,;
		Trb315->BBD_TIPOPA,;
		Trb315->BBD_HORCHE,;
		Trb315->BBD_CHAMAD,;
		''})
		Trb315->( DbSkip() )
		nSeq++
	Enddo
	cTipoPa := "0"
	Trb315->( DbCloseArea() )
	DbSelectArea("BDH")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta matriz de lista de espera											 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aHorPro := aClone(aPronto)
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Lista de Espera															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aLisEsp := {}
aHorEsp := {}
nSeq	:= 1
cSQL := " SELECT * FROM "+BBD->(RetSQLName("BBD"))
cSQL += " WHERE BBD_FILIAL = '"+xFilial("BBD")+"' "
cSQL += "   AND BBD_LOCAL  = '"+cCodLoc+"' "
cSQL += "   AND BBD_DATA   = '"+dtos(dDtRec)+"' "
cSQL += "   AND BBD_CODINT = '"+cCodOpe+"' "
cSQL += "   AND BBD_PRTATD = '1' "
cSql += "   AND BBD_CDAMBU = '"+mv_par03+"' "
cSql += "   AND BBD_CODCAN = ''  "
cSQL += "   AND BBD_NUMATE = '"+Space(Len(BBD->BBD_NUMATE))+"' "
cSQL += "   AND BBD_STATUS  = '2' "
cSQL += "   AND D_E_L_E_T_ = ' ' "
cSQL += " ORDER BY BBD_FILIAL,R_E_C_N_O_ "
PLSQuery(cSQL,"TrbBBD")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Primeiro																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
TrbBBD->( DbGoTop() )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё While																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While ! TrbBBD->( Eof() )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no credenciado...                                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BAU->(DbSetOrder(1))
	BAU->( MsSeek( xFilial("BAU")+TrbBBD->BBD_CODIGO ) )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Para cada Pronto Atendimento adiciona no vetor...                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aadd(aLisEsp,{	TrbBBD->R_E_C_N_O_,;
	TrbBBD->BBD_CODPAC,;
	TrbBBD->BBD_NOME,;
	TrbBBD->BBD_TELEFO,;
	TrbBBD->BBD_STATUS,;
	TrbBBD->BBD_CODIGO,;
	IIf(!Empty(AllTrim(BAU->BAU_NOME)),AllTrim(X3COMBO("BAU_LEGEND",BAU->BAU_LEGEND))+". "+Space(5)+AllTrim(BAU->BAU_NOME),""),;
	TrbBBD->BBD_CODESP,;
	BAQ->(Posicione("BAQ",1,xFilial("BAQ")+TrbBBD->(BBD_CODINT+BBD_CODESP),"BAQ_DESCRI")),;
	nSeq,;
	TrbBBD->BBD_TIPOPA,;
	TrbBBD->BBD_HORCHE,;
	TrbBBD->BBD_CHAMAD,;
	'',;
	TrbBBD->BBD_MATANT,;
	TrbBBD->BBD_DATA,;
	TrbBBD->BBD_ATERNA})
	TrbBBD->( DbSkip() )
	nSeq++
EndDo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha area																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
TrbBBD->( DbCloseArea() )
DbSelectArea("BDH")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta matriz de lista de espera											 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aHorEsp := aClone(aLisEsp)
DbSelectArea("BBD")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta as salas...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aSalas := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta as salas...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BSC->(DbSetOrder(1))
If BSC->(MsSeek(xFilial("BSC")+cCodOpe+cCodLoc+cCdAmbu))
	While ! BSC->(Eof()) .And. BSC->(BSC_FILIAL+BSC_CODINT+BSC_CODLOC+BSC_CDAMBU) == xFilial("BSC")+cCodOpe+cCodLoc+cCdAmbu
		For nAux := 1 To BSC->BSC_NSALAS
			aadd(aSalas,{	StrZero(nSala,2),;
			"",;
			"",;
			0,;
			0,;
			.F.,;
			0,;
			"",;
			"",;
			"",;
			"",;
			"",;
			"",;
			.F.,;
			"",;
			0,;
			0,;
			0,;
			0})
			nSala ++
		Next
		BSC->( DbSkip() )
	Enddo
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Procura por salas abertas...                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := " SELECT * FROM "+RetSQLName("BGF")
cSQL += "  WHERE BGF_FILIAL  = '"+xFilial("BGF")+"' "
cSQL += "    AND BGF_CODLOC  = '"+cCodLoc+"' "
cSQL += "    AND BGF_CDAMBU  = '"+cCdAmbu+"' "
cSQL += "    AND BGF_DATA    = '"+DtoS(dDtRec)+"' "
cSQL += "    AND BGF_CODINT  = '"+cCodOpe+"' "
cSQL += "    AND (BGF_STATUS = '1' or BGF_STATUS = '9') "
cSQL += "    AND D_E_L_E_T_  = ' ' "
cSQL += " ORDER BY BGF_FILIAL,BGF_NSALA "
PLSQuery(cSQL,"TrbBGF")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Primeiro																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
TrbBGF->( DbGoTop() )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё While																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While ! TrbBGF->( Eof() )
	If TrbBGF->BGF_STATUS = '9' .and. TrbBGF->BGF_VIRTUA == "S"
		aadd(aSalas,{	TrbBGF->BGF_NSALA,;
		"",;
		"",;
		0,;
		0,;
		.F.,;
		0,;
		"",;
		"",;
		"",;
		"",;
		"",;
		"",;
		.F.,;
		"",;
		0,;
		0,;
		0,;
		0})
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁaScan																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nAux := Ascan(aSalas,{|x| x[1] == TrbBGF->BGF_NSALA})
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//ЁnAux																		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nAux > 0
		BAU->( DbSetOrder(1) )
		BAU->( MsSeek(xFilial("BAU")+TrbBGF->BGF_CODLOJ) )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Calcula quantos horarios a serem atendidos existem no aHorarios...       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aEval(aHorarios,{|x| If(	x[1] 	== BAU->BAU_CODIGO .And.;
		x[11] 	== TrbBGF->BGF_CODESP,;
		aMatEst	:= PLSESTAGEN(x[7],x[10],x[9],x[4],aMatEst),;
		nil ) } )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Calcula quantos horarios a serem atendidos existem no aPronto...         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aEval(aPronto,{|x| If(	x[7]    == BAU->BAU_CODIGO 		.And.;
		x[9]    == TrbBGF->BGF_CODESP,;
		aMatEst := PLSESTAGEN(x[6],"99","99","ZZ",aMatEst),;
		nil ) } )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona na sala														 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BGF->( DbGoTo( TrbBGF->R_E_C_N_O_ ) )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza pacientes atendidos na sala									 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !BGF->( Eof() )
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Inicia a Transacao													     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Begin Transaction
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Altera																	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BGF->(RecLock("BGF", .F.))
			BGF->BGF_NATEND := aMatEst[2]
			BGF->(MsUnlock())
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Fim da Transacao													     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			End Transaction
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza browse de salas												 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aSalas[nAux,2]  := TrbBGF->BGF_CODLOJ
		aSalas[nAux,3]  := AllTrim(X3COMBO("BAU_LEGEND",BAU->BAU_LEGEND))+". "+Space(5)+AllTrim(BAU->BAU_NOME)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Quantidades																 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aSalas[nAux,4]  := aMatEst[1] //Agendado
		aSalas[nAux,5]  := aMatEst[2] //Atendido
		aSalas[nAux,16] := aMatEst[3] //Espera
		aSalas[nAux,17] := aMatEst[4] //Encaixe
		aSalas[nAux,18] := aMatEst[5] //Cancelados
		aSalas[nAux,19] := aMatEst[6] //Horarios Livres
		
		aSalas[nAux,6]  := IIf(aMatEst[7]==0,.F.,.T.)
		aSalas[nAux,7]  := TrbBGF->R_E_C_N_O_
		aSalas[nAux,8]  := TrbBGF->BGF_HORINI
		aSalas[nAux,9]  := TrbBGF->BGF_CODESP
		aSalas[nAux,10]	:= BAQ->(Posicione("BAQ",1,xFilial("BAQ")+TrbBGF->(BGF_CODINT+BGF_CODESP),"BAQ_DESCRI"))
		aSalas[nAux,11]	:= TrbBGF->BGF_CODIGO
		aSalas[nAux,12]	:= TrbBGF->BGF_STATUS
		aSalas[nAux,13]	:= TrbBGF->BGF_VIRTUA
		aSalas[nAux,14]	:= TrbBGF->( (!Empty(BGF_PSAIN1) .AND. Empty(BGF_PSAFN1)) .Or.;
		(!Empty(BGF_PSAIN2) .AND. Empty(BGF_PSAFN2)) .Or.;
		(!Empty(BGF_PSAIN3) .AND. Empty(BGF_PSAFN3)) )
		aSalas[nAux,15] := TrbBGF->BGF_CODLCL
		
		aMatEst := {0,0,0,0,0,0,0}
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Proximo																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	TrbBGF->( DbSkip() )
Enddo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha area																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
TrbBGF->( DbCloseArea() )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seleciona area															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea("BBD")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA315TPe Ё Autor ЁGeraldo Felix JuniorЁ Data Ё 18.12.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Trata periodicidade...                                    Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function XXPLSA315TPe(cMatricUsr,dData,nDsPer)

Local lRet    := .T.
Local nOrdBBD := BBD->( IndexOrd() )
Local nRecBBD := BBD->( Recno() )         
Local dAux    := dData-nDsPer
Local bFecha  := { || BBD->( DbSetOrder(nOrdBBD) ), BBD->( DbGoTo(nRecBBD) ), lRet }
Local bNomCre := { || BAU->( DbSetOrder(1) ),;
                       BAU->( MsSeek( xFilial("BAU")+BBD->(BBD_CODIGO) ) ),;
                       AllTrim( X3COMBO( "BAU_LEGEND",BAU->BAU_LEGEND ) )+". "+Space(5)+AllTrim(BAU->BAU_NOME) }
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a matricula sem os pontinhos...                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cMatricUsr := StrTran(cMatricUsr,".","")
cMatricUsr := StrTran(cMatricUsr,"-","")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return( Eval(bFecha) )
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS315LISU╨       ЁGeraldo Felix Junior╨ Data Ё  29/04/03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Novo conceito na listagem de pacientes.                    ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS315LISU(cCodEsp,dData,aListaUsr,oListaUsr,nOpcao,oEnc,nDsPer,cNome)

Local bOk              
Local oDlgUsu
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verfica																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cNome)
   Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seta Key																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetKey(VK_LBUTTON,{||PLSA315FAM(aListaUsr[oListaUsr:nAt,2],aListaUsr[oListaUsr:nAt,1],aListaUsr[oListaUsr:nAt,8],cCodEsp,dData,aListaUsr,oListaUsr,oEnc,nDsPer)})
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define tela																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlgUsu TITLE STR0071 FROM 018,005 TO 28, 100 OF GetWndDefault() //"Usuarios"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta obj																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oListaUsr := TcBrowse():New( If(nOpcao==K_Cancel,180,013), 002, 372, 062,,,, oDlgUsu,,,,,,,,,,,, .F.,, .T.,, .F., )
oListaUsr:SetArray(aListaUsr)

/*
ADD COLUMN TO oListaUsr BITMAP DATA If(!Empty(aListaUsr[olistaUsr:nAt,5]),LoadBitmap( GetResources(), "ENABLE" ),LoadBitmap( GetResources(), "DISABLE" )) TITLE "" WIDTH 015 NOHILITE
*/

oListaUsr:AddColumn(TcColumn():New(" ",{ || Iif(!Empty(aListaUsr[olistaUsr:nAt,5]),LoadBitmap( GetResources(), "ENABLE" ),LoadBitmap( GetResources(), "DISABLE" )) },;
         nil,nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))

oListaUsr:AddColumn(TcColumn():New(STR0072,nil,nil,nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil)) //"Nome"
oListaUsr:ACOLUMNS[2]:BDATA     := { || aListaUsr[oListaUsr:nAt,1] }

oListaUsr:AddColumn(TcColumn():New(STR0073,nil,nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil)) //"Matricula"
oListaUsr:ACOLUMNS[3]:BDATA     := { || aListaUsr[oListaUsr:nAt,2] }

oListaUsr:AddColumn(TcColumn():New(STR0074,nil,nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil)) //"Matricula Antiga"
oListaUsr:ACOLUMNS[4]:BDATA     := { || aListaUsr[oListaUsr:nAt,6] }

oListaUsr:AddColumn(TcColumn():New(STR0075,nil,nil,nil,nil,nil,140,.F.,.F.,nil,nil,nil,.F.,nil)) //"Empresa"
oListaUsr:ACOLUMNS[5]:BDATA     := { || aListaUsr[oListaUsr:nAt,8] }

oListaUsr:AddColumn(TcColumn():New(STR0076,nil,nil,nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil)) //"Nome da Mae"
oListaUsr:ACOLUMNS[6]:BDATA     := { || aListaUsr[oListaUsr:nAt,7] }

oListaUsr:AddColumn(TcColumn():New(STR0055,nil,nil,nil,nil,nil,070,.F.,.F.,nil,nil,nil,.F.,nil)) //"Telefone"
oListaUsr:ACOLUMNS[7]:BDATA     := { || aListaUsr[oListaUsr:nAt,3] }

oListaUsr:BLDBLCLICK := bOk := { || If(PLSA300TPe( aListaUsr[oListaUsr:nAt,2],dData,cCodEsp,nDsPer,oEnc:oBox),;
												  ( cChave 		:= aListaUsr[oListaUsr:nAt,2],;
												  	cChave 		:= StrTran(cChave,".",""),;
												    cChave 		:= StrTran(cChave,"-",""),;
												    M->BBD_NOME := If(Empty(aListaUsr[oListaUsr:nAt,1]),;
													M->BBD_NOME,aListaUsr[oListaUsr:nAt,1]),;
													M->BBD_CODPAC := If( Empty(cChave), M->BBD_CODPAC, cChave),;
													M->BBD_TELEFO := aListaUsr[oListaUsr:nAt,3],;
													M->BBD_MATANT := If( Empty(aListaUsr[oListaUsr:nAt,6]), M->BBD_MATANT, aListaUsr[oListaUsr:nAt,6]),;
	   											    lRefresh := .T.,;
													oDlgRes:Refresh(),;
													oEnc:oBox:SetFocus(),;
													oDlgUsu:End() ),;
										oDlgUsu:End() ) }
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dialogo															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlgUsu ON INIT Eval({||EnChoiceBar(oDlgUsu,bOk,{||oDlgUsu:End()},.F.)} )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Redefine o CTRL+A...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SET KEY 1 TO
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁRunReport ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  28/05/03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁImprime o atestado medico... deve ser ajustado para cada    ╨╠╠
╠╠╨          Ёcliente.                                                    ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Recepcao medica...                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin,cString,cCodLoc,cDesLoc,aHorMed,oHorarios)

Local cTxt
Local cHoraIni 
Local cHoraFin
Local xLin 		:= 01
Local xCol 		:= 01
Local cMatric   := BBD->BBD_CODPAC          
Local cCodMed	:= BBD->BBD_CODIGO
Local cTipo 	:= aRet[1]
Local cHoIn 	:= Transform(aRet[2],"@R 99:99")
Local cHoFi 	:= Transform(aRet[3],"@R 99:99")
Local cQtdD 	:= Alltrim(Str(aRet[4]))
Local cAcom		:= If( Len(aRet) > 4, Alltrim(aRet[5]), '' ) // Nome do acompanhante!
Local cEmpA		:= If( Len(aRet) > 4, Alltrim(aRet[6]), '' ) // Empresa do acompanhante!     

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona grupo empresa...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды              
BG9->( DbSetorder(01) )
BG9->( MsSeek(xFilial("BG9")+Substr(cMatric, 1,8)) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona o prestador...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды              
BAU->( DbSetorder(01) )
BAU->( MsSeek(xFilial("BAU")+cCodMed) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Zera posicionamento da impressora...                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды              
SetPrc(0,0)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Validacao																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды              
If Alltrim(Upper(cTipo)) == STR0077 //"DAS HORAS"
	cTxt := STR0077 //"DAS HORAS"
Else        
	If cQtdD == "0"
		cTxt := STR0078 //"DO DIA"
	Else
		cTxt := "( "+cQtdD+" ) "+Extenso(Val(cQtdD), .T.)+STR0079 //" DIAS "
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Validacao																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды              
If !Empty(cHoIn)
	cHoraIni := cHoIn
	If Empty(cHoFi)
		cHoraFin := Left(Time(),5)
	Else
		cHoraFin := cHoFi
	EndIf
Else
	cHoraIni := BBD->BBD_HORENT
	cHoraFin := BBD->BBD_HORSAI
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicializa a impressao...                                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                     
BA0->( dbSetorder(01) )
BA0->( MsSeek(xFilial("BA0")+PlsIntPad()) )
@ xLin, xCol 		Psay Padc(BA0->BA0_NOMINT,40)	;xLin++
@ xLin, xCol   		Psay Padc(cDesLoc,40)			;xLin++

@ xLin, xCol		Psay Padc('   ---------------------   ',40)	;xLin++

If Alltrim(Upper(cTipo)) == STR0077 //"DAS HORAS"
	@ xLin, xCol	Psay Padc(STR0080,40)	;xLin++ //'        NOTIfICACAO        '
Else                                          
	If Len(aRet) > 6 .and. aRet[7] <> STR0081  //"Atendimento"
		@ xLin, xCol	Psay Padc(STR0082,40)	;xLin++ //'ATESTADO DE COMPARECIMENTO '
	Else
		@ xLin, xCol	Psay Padc(STR0083,40)	;xLin++	 //'      ATESTADO MEDICO      '
	EndIf
EndIf
@ xLin, xCol		Psay Padc('   ---------------------   ',40)	;xLin+=2
@ xLin, xCol		Psay STR0084 + IIf(!Empty(cAcom),cAcom, BBD->BBD_NOME) 	;xLin++ //"Nome      : "
@ xLin, xCol		Psay STR0085 + IIf(!Empty(cAcom),STR0086,Transform(BBD->BBD_CODPAC, "@R !.!!!.!!!!.!!!!!!-!!-!"))	;xLin++ //"Codigo    : "###'ACOMPANHANTE'
@ xLin, xCol		Psay STR0087 + IIf(!Empty(cAcom),cEmpA, BG9->BG9_DESCRI)	;xLin++ //"Empresa   : "
@ xLin, xCol       	Psay '------------------------------------------'	;xLin+=2

@ xLin, xCol		Psay STR0088 + dToc(BBD->BBD_DATA)  ;xLin+=2 //"Data      : "
@ xLin, xCol		Psay STR0089 + cHoraIni    +Space(05)+STR0090+IIf(!Empty(cHoraFin),cHoraFin,Left(Time(),5)) ;xLin+=2 //"Entrada   : "###" Saida :"
@ xLin, xCol		Psay STR0091 + cTxt ;xLin+=2 //"Atestado  : "

@ xLin, xCol		Psay '------------------------------------------'	;xLin+=2

xLin := 26 
@ xLin, xCol		Psay STR0092;xLin++ //"Medico Solicitante : "
@ xLin, xCol	 	Psay STR0093+BAU->BAU_NOME ;xLin++ //"Dr(a).  : "
@ xLin, xCol+10 	Psay Alltrim(BAU->BAU_SIGLCR)  +" : "+Space(5)+AllTrim(BAU->BAU_CONREG);xLin+=4
@ xLin, xCol		Psay STR0094  //"CARIMBO DA RECEPCAO OBRIGATORIO"
@ xLin, xCol		Psay ""
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Finaliza a execucao do relatorio...                                 Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SET DEVICE TO SCREEN
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se impressao em disco, chama o gerenciador de impressao...          Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If aReturn[5]==1
   DbCommitAll()
   SET PRINTER TO
   OurSpool(wnrel)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Flush																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды              
MS_FLUSH()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava o nome e a empresa do acompanhante...                         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(cAcom)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicia a Transacao													     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Begin Transaction
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Alterar																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BBD->( RecLock("BBD",.F.) )
		BBD->BBD_ACOMPA := cAcom
		BBD->BBD_EMPACP := cEmpA
	BBD->( MsUnlock() )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fim da Transacao													     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	End Transaction
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA315FIL Ё Autor ЁGeraldo Felix JuniorЁ Data Ё 29.01.02 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Funcao de apoio para executar filtro no ahorarios...      Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function PLSA315Fil(aHorMed,aHorarios,aSalas,oHorarios,oMedicos,oPronto,aPronto,aHorPro,oLisEsp,aLisEsp,aHorEsp,cCodOpe,dDtRec,lDireto)

Local nInd
Local cMedico
Local cEspeci
Local lFirst	:= .T.
Local lBlqMed 	:= .F.
Local aAux 		:= {}
Local aBloq		:= {}
Local nPosBlq	:= 0

Default lDireto := .T.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Horarios dos medicos...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aSalas) == 0
	Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alimenta variavel medico												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cMedico := aSalas[oMedicos:nAt,2]
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Limpa matriz															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aHorMed := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё For no horario															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Bloqueio de agendas...													 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cSQL := "SELECT * FROM "+RetSQLName("BBQ")+" WHERE "
cSQL += "BBQ_FILIAL = '"+xFilial("BBQ")+"' AND "
cSQL += "BBQ_CODINT = '"+cCodOpe+"' AND "
cSQL += "BBQ_CODLOC = '"+aSalas[oMedicos:nAt,15]+"' AND "
cSQL += "'"+dtos(dDtRec)+"' >= BBQ_DATDE AND '"+dtos(dDtRec)+"' <= BBQ_DATATE AND "
cSQL += "D_E_L_E_T_ = ''"
PLSQuery(cSQL,"TRBBBQ")
TRBBBQ->(DBEval( { | | aadd(aBloq, {BBQ_CODRDA,BBQ_CODLOC,BBQ_CODESP,BBQ_DATDE,BBQ_DATATE,BBQ_HORDE,BBQ_HORATE}) }))

TRBBBQ->( dbCloseArea() )
DbSelectArea("BDH")

For nInd := 1 To Len(aHorarios)
	If aHorarios[nInd,1] == cMedico .And.;
		( aHorarios[nInd,11] == aSalas[oMedicos:nAt,9] .Or. Empty(aHorarios[nInd,11]) )
		
		nPosBlq := Ascan(aBloq, {|x|	x[1] == cMedico .and.;
		x[2] == aSalas[oMedicos:nAt,15] .and.;
		x[3] == aSalas[oMedicos:nAt,09] .and.;
		aHorarios[nInd,02] >= x[6] .and. aHorarios[nInd,02] <= x[7]})
		
		If nPosBlq == 0
			aadd(aAux,aHorarios[nInd])
			
			If aHorarios[nInd,7] == '5' .And. lFirst // Pega o primeiro em espera
				nFirstWait := Len(aAux)
				lFirst := .F.
			EndIf
			
		ElseIf nPosBlq > 0
			lBlqMed := .T.
			
		EndIf
	EndIf
Next

If Len(aAux) == 0 .and. lBlqMed .and. !lDireto
	MsgAlert(STR0095+; //"A agenda desde mИdico foi bloqueada nesta data pela rotina de Bloqueio de agendas. Acesse a rotina de Agenda medica para "
	STR0096) //"providenciar a remarcaГЦo dos pacientes agendados."
	
	oHorarios:SetArray(aHorMed)
	If !lFirst
		oHorarios:nAt := nFirstWait
	EndIf
	oHorarios:Refresh()
	
	oMedicos:SetArray(aSalas)
	oMedicos:Refresh()
	
	oLisEsp:SetArray(aHorEsp)
	oLisEsp:Refresh()
	
	oPronto:SetArray(aHorPro)
	oPronto:Refresh()
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Matriz horario x medicos											     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aHorMed := aClone(aAux)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Lista de Espera															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aLisEsp) > 0
	cMedico := aSalas[oMedicos:nAt,2]
	aHorEsp := {}
	aAux    := {}
	For nInd := 1 To Len(aLisEsp)
		If aLisEsp[nInd,6] == cMedico
			aadd(aAux,aLisEsp[nInd])
		EndIf
	Next
	aHorEsp := aClone(aAux)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pronto																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aPronto) > 0
	cMedico := aSalas[oMedicos:nAt,2]
	cEspeci := aSalas[oMedicos:nAt,9]
	aHorPro := {}
	aAux    := {}
	For nInd := 1 To Len(aPronto)
		If aPronto[nInd,7] == cMedico
			aadd(aAux,aPronto[nInd])
		ElseIf aPronto[nInd,9] == cEspeci .And. Empty(aPronto[nInd,7])
			aadd(aAux,aPronto[nInd])
		EndIf
	Next
	aHorPro := aClone(aAux)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Codigo sequencial do Local de atendimento (BB8_CODLOC)					 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aSalas) > 0
	cLocal := aSalas[oMedicos:nAt,15]
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualizacoes...                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oHorarios:SetArray(aHorMed)
If !lFirst
	oHorarios:nAt := nFirstWait
EndIf
oHorarios:Refresh()

oMedicos:SetArray(aSalas)
oMedicos:Refresh()

oLisEsp:SetArray(aHorEsp)
oLisEsp:Refresh()

oPronto:SetArray(aHorPro)
oPronto:Refresh()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA300FAM╨Autor  ЁGeraldo Felix Junior╨ Data Ё  09/04/03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Mostrar a familia do usuario posicionado.                  ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Marcacao de consultas.                                     ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLSA315FAM(cFamilia,xcNome,cNomeEmp,cCodEsp,dData,aListaUsr,oListaUsr,oEnc,nDsPer)

Local oSyFam
Local oGrpFam
Local oSyEmp
Local oGrpEmp                            
Local oDlgFam
Local nLen 		:= BA1->(Len(BA1_CODINT)+Len(BA1_CODEMP)+Len(BA1_MATRIC))
Local cChave    := Left(StrTran(cFamilia,".",""), nLen)
Local bMatric	:= {||BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO)}
Local bDblClick := { || (BA1->( DbGoto( aTrbUsr[oBrwUsr:Linha()] ) ),;
					      If( PLSA300TPe( Eval(bMatric),dData,cCodEsp,nDsPer,oEnc:oBox),;
								( cChave 		:= Eval(bMatric),;
								  cChave 		:= StrTran(cChave,".",""),;
							 	  cChave 		:= StrTran(cChave,"-",""),;
							 	  M->BBD_NOME 	:= If( Empty(oBrwUsr:aCols[oBrwUsr:Linha(),1]),M->BBD_NOME,oBrwUsr:aCols[oBrwUsr:Linha(),1] ),;
					 			  M->BBD_CODPAC := If( Empty(cChave), M->BBD_CODPAC, cChave ),;
						 		  M->BBD_TELEFO := If( Empty(aListaUsr[oListaUsr:nAt,3]), M->BBD_TELEFO, aListaUsr[oListaUsr:nAt,3] ),;
						 		  M->BBD_MATANT := If( Empty(BA1->BA1_MATANT), M->BBD_MATANT, BA1->BA1_MATANT),;
						 		  lRefresh := .T.,;
							 	  oDlgRes:Refresh(),;
							 	  oEnc:oBox:SetFocus(),;
							 	  oDlgFam:End(),;
							 	  oDlgUsu:End() ),;
						  oDlgUsu:End() ) ) } 
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Usuarios...                                                         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Private oBrwUsr
Private aCabUsr := {}
Private aDadUsr := {}
Private aTrbUsr := {}
Private aCols	:= {}
Private aHeader	:= {}      

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta a GetDados com a familia                                      Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Store Header "BA1" TO aCabUsr FOR SX3->(X3_CAMPO $ "BA1_MATUSU" .or.;
										 X3_CAMPO $ "BA1_NOMUSR"  .or.;
										 X3_CAMPO $ "BA1_DESUSU" .or.;
										 X3_CAMPO $ "BA1_TELEFO" .or.;
										 X3_CAMPO $ "BA1_DESGRA" )
BA1->(DbSetOrder(2))
If !BA1->(MsSeek(xFilial("BA1")+cChave))
	MsgAlert(STR0097+cChave) //"Usuario nao encontrado BA1:"
	Return
Else
	Store COLS "BA1" TO aDadUsr FROM aCabUsr VETTRAB aTrbUsr While xFilial("BA1")+cChave == BA1->(BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC)
EndIf

DEFINE MSDIALOG oDlgFam TITLE Alltrim(xcNome) FROM 019.5,001 TO 33, 100 OF GetWndDefault()
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta o Browse dos Usuarios                                         Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 014,003 GROUP oGrpFam TO 30, 170 PIXEL OF oDlgFam LABEL STR0098 COLOR CLR_HBLUE, CLR_HRED //" Usuario "
@ 021,007 Say oSyFam Prompt Alltrim(xcNome) Size 150,008 PIXEL OF oDlgFam COLOR CLR_HBLUE

@ 014,175 GROUP oGrpEmp TO 30, 390 PIXEL OF oDlgFam LABEL STR0099 COLOR CLR_HBLUE, CLR_HRED //" Empresa "
@ 021,180 Say oSyEmp Prompt Alltrim(cNomeEmp) Size 150,008 PIXEL OF oDlgFam COLOR CLR_HBLUE

oBrwUsr := TPLSBrw():New(033,001,390,106,nil,oDlgFam,nil,bDblClick,nil,nil,nil,.T.,nil,.T.,nil,aCabUsr,aDadUsr,.T.,"BA1",K_Visualizar,STR0071,{{"BA1_MOTBLO","<>","''"}},nil,nil,aTrbuSR) //"Usuarios"

ACTIVATE MSDIALOG oDlgFam ON INIT Eval({||EnChoiceBar(oDlgFam,{||oDlgFam:End()},{||oDlgFam:End()},.F.)} )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁA315EsMe  ╨Autor  ЁAlexander			 ╨ Data Ё  18-02-06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function A315EsMe(aSalas,cComboEsp,oComboMed)

Local nI
Local nPosMed
Local aComboMed := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inclui um item em branco no combobox de especialidade e medicos          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Aadd( aComboMed, "")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta combomed conforme especialidade									 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nI := 1 To Len(aSalas)
	If !Empty(aSalas[nI][2]) 
		nPosMed	:= Ascan(aComboMed, aSalas[nI][2]+" - "+aSalas[nI][03])        
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Medico																	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nPosMed == 0 .And. aSalas[nI][13] # "S" .And. ( aSalas[nI][9] == Left( cComboEsp, Len(BBD->BBD_CODESP) ) )
			Aadd(aComboMed, aSalas[nI][2]+" - "+aSalas[nI][03])
		EndIf
	EndIf
Next                                      
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oComboMed:aItems := aComboMed
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o codigo da especialidade...                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCodEsp := AllTrim( Left( cComboEsp, Len(BBD->BBD_CODESP) ) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Funcao															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA315   ╨Autor  ЁMicrosiga           ╨ Data Ё  10-27-03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function A315CBOX(aSalas,cComboEsp,cComboMed)

Local nPos
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Valida																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(cComboEsp) .And. !Empty(cComboMed)
	If (nPos :=  Ascan(aSalas, {|x| x[2] == Left(cComboMed,Len(BBD->BBD_CODIGO)) .and. x[9] == Left(cComboEsp,Len(BBD->BBD_CODESP)) })) == 0
		Aviso(STR0100,STR0101,{STR0102}) //"Invalido!"###"MИdico nao antende esta especialidade nesta agenda!"###"&Voltar"
		cComboMed := ''
		Return(.F.)
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(.T.)
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁA315IEVLD ╨Autor  ЁMicrosiga           ╨ Data Ё  09/14/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function A315IEVLD()

If Empty(M->BA1_CODPLA)
	MsgAlert(STR0103) //"Codigo do Plano e obrigatorio!"
	Return(.F.)
EndIf

If Empty(M->BA1_MATANT) 
	MsgAlert(STR0104) //"A Matricula Antiga e obrigatorio!"
	Return(.F.)
EndIf

If Empty(M->BA1_NOMTIT)
	MsgAlert(STR0105) //"O Nome do Titular e obrigatorio!"
	Return(.F.)
EndIf

BI3->( DbSetOrder(1) ) //BI3_FILIAL + BI3_CODINT + BI3_CODIGO + BI3_VERSAO
If !BI3->( MsSeek( xFilial("BI3")+PlsIntPad()+M->BA1_CODPLA+M->BA1_VERSAO ) )
	MsgAlert(STR0106) //"Produto nao encontrado!"
	Return(.F.)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(.T.)
/*
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA315ATRZ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  22/05/03   ╨╠╠
╠╠лммммммммммьмммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё VerIfica o atrazo no pronto atendimento.                    ╨╠╠
╠╠╨          Ё                                                             ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                         ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PLSA315ATRZ(aHorPro,oPronto,nPos)

Local nEstouro 	:= 0
Local lEstouro	:= .T.

If Len(aHorPro) > 0
	nEstouro := PlsSomaHor(aHorPro[oPronto:nAt,nPos],cTmpLim)
Else
	Return(lEstouro)
EndIf

If nEstouro > Left(Time(),5)
	lEstouro := .F.
Else
	lEstouro := .T.
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lEstouro)
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁA315MOSTRA╨Autor  ЁGeraldo Felix Junior╨ Data Ё  05/23/03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function A315MOSTRA( cNomeCre, cSala, aHorPro, aSalas, oMedicos, cCodOpe, cCodLoc )

Local oDlg
Local oSay1
Local oSay2
Local oSay3
Local oFont1
Local oFontNum
Local oBtnBaca
Local oGrupo
Local nOpca    := 2
Local cNomInt  := Posicione("BA0",1,xFilial("BA0")+PlsIntPad(),"BA0_NOMINT")
Local cChkCon  := GetNewPar("MV_PLSCHKC","0000")     

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tela 																					  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlg TITLE STR0107 FROM 005,005 TO 025, 070 OF GetWndDefault() //"Dados da Agenda"

        
DEFINE FONT oFontNum 	NAME "Arial" SIZE 000,-015 
DEFINE FONT oFont1 		NAME "Arial" SIZE 000,-013 BOLD

@ 0, 0 BITMAP oBmp RESNAME "LOGIN" oF oDlg SIZE 200,305 NOBORDER WHEN .F. PIXEL

@ 005, 050 Say oSay Prompt STR0108+cSala Size 150,300 PIXEL OF oDlg COLOR CLR_HBLUE FONT oFont1         //"Sala "

@ 020, 050 GROUP oGrupo TO 050, 255 PIXEL OF oDlg LABEL STR0109  COLOR CLR_HBLUE, CLR_HRED                                       //" Paciente "
@ 032, 055 Say oSay1 Prompt BBD->BBD_NOME Size 150,015 PIXEL OF oDlg COLOR CLR_HRED FONT oFontNum        

@ 060, 050 GROUP oGrupo TO 090, 255 PIXEL OF oDlg LABEL STR0110  COLOR CLR_HBLUE, CLR_HRED                                       //" MИdico "
@ 072, 055 Say oSay2 Prompt cNomeCre Size 150,015 PIXEL OF oDlg COLOR CLR_HRED FONT oFontNum        

@ 100, 050 GROUP oGrupo TO 130, 255 PIXEL OF oDlg LABEL STR0111  COLOR CLR_HBLUE, CLR_HRED                                       //" Operadora "
@ 112, 055 Say oSay3 Prompt cNomInt Size 150,015 PIXEL OF oDlg COLOR CLR_HRED FONT oFontNum        

DEFINE SBUTTON oBtnBaca FROM 135,165 TYPE 01 ACTION (nOpca := 1,oDlg:End()) OF oDlg ENABLE PIXEL
DEFINE SBUTTON oBtnBaca FROM 135,195 TYPE 02 ACTION (nOpca := 2,oDlg:End()) OF oDlg ENABLE PIXEL
DEFINE SBUTTON oBtnBaca FROM 135,225 TYPE 21 ACTION Eval({||A315SelPac(aHorPro, aSalas, oMedicos, .T., oSay1, oSay2, oSay3 )}) OF oDlg ENABLE PIXEL

ACTIVATE MSDIALOG oDlg CENTER
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se for ok																				  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == 1 
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё VerIfica se o usuario esta cadastrado no contrato/subcontrato especIfico para agendamento Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If cChkCon <> '0000' 
	   If AllTrim(BBD->(BBD_CODEMP+BBD_CONEMP+BBD_VERCON+BBD_SUBCON+BBD_VERSUB)) == AllTrim(cChkCon)
	      MsgAlert(STR0112) //'Este usuario esta em um Contrato/Sub-Contrado invalido, favor verIficar!'
	      Return .F.
	   EndIf
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return( IIf( nOpca==1,.T.,.F. ) )
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA315SET    ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  09-14-03   ╨╠╠
╠╠лммммммммммьммммммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Acerta a posicao do browse logo apos marcar um encaixe.        ╨╠╠
╠╠╨          Ё                                                                ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                             ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PLSA315SET(cHora, aHorMed, oHorarios)

Local nPos := AScan(aHorMed, {|x| x[2] == cHora})

If nPos <> 0
	oHorarios:nAt := nPos
	oHorarios:Refresh()
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(NIL)
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁValEnc    ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  05/22/03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Verfica se foi informado horario                           ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function ValEnc(aHorMed)

Local nPos 
Local lRet := .T.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega posicao														   	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nPos := Ascan(aHormed, {|x| x[2] == M->BBD_HORA})
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nPos # 0 
	MsgAlert(STR0113) //"Para incluir um encaixe e necessario informar um horАrio que nao conste na agenda."
	lRet := .F.
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lRet
	If M->BBD_HORA >= "23:59"
		MsgAlert(STR0114) //"HorАrio invalido!"
		lRet := .F.		
	EndIf
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA315   ╨Autor  ЁMicrosiga           ╨ Data Ё  05/17/03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLSA315PUs(cMatrUsr)

Local lRet 	  := .F.
Local cOpePad := PLSINTPAD()

If Subs(cMatrUsr,1,ntCodOpe) <> cOpePad .And. ! Empty(cMatrUsr)
   lRet 	:= .T.
   lRefresh := .T.
Else
   lRet := ExistCpo("BA1",cMatrUsr,2)
EndIf         
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Focus																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lRet
   oEnc:AENTRYCTRLS[1]:SetFocus()
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁA315SmdVal╨Autor  ЁGeraldo Felix Junior╨ Data Ё  10/12/03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Valida o motivo de bloqueio para fechamento da sala com    ╨╠╠
╠╠╨          Ёagendas em aberto.                                          ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё A315SmdVal()                                               ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function A315SmdVal(cMotBlo)

Local lRet := .F.

If Empty(cMotBlo)
	lRet := .T.
ElseIf BTJ->(ExistCpo("BTJ",cMotBlo,1)) 
	cDesBlo := Posicione("BTJ",1,xFilial("BTJ")+cMotBlo,"BTJ_DESCRI")
	oGet2:Refresh()
	lRet := .T.
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA315VUS Ё Autor ЁGeraldo Felix JuniorЁ Data Ё 18.12.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Valida chegada do usuario para atendimento...             Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function PLSA315VUs(oDlgRes,oCritica,aCritica)

Local lRet := .T.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se houver critica exibe...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aCritica) > 0
   oDlgRes:nRight := 763
   oCritica:SetArray(aCritica)
   oCritica:Refresh()
EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSVIRVAL ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  11-13-03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Valida a abertura da sala para um novo medico virtual      ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PlsVirVal(aSalas)                      

Local nCnt
Local lRet := .T.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Validacao																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nCnt := 1 To Len(aSalas)
	If Empty(aSalas[nCnt, 2])
		Aviso(STR0115,STR0116+; //"Salas Disponiveis!"###"Exite pelo menos uma sala vazia para alocar o MИdico, nao ha necessidade de se abrir uma sala "
									STR0117,{STR0102}) //"virtual!"###"&Voltar"
		lRet := .F.
		Exit		
	EndIf
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina Principal...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁValidStatu╨Autor  ЁGeraldo Felix Junior╨ Data Ё  26/04/03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё  Valida a mudanca de status na recpcao                     ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё SIGAPLS Marcacao de consultas.                             ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function ValidStatu(aStatus,aHorMed,nPos,nAt,nTipo,cSala,cSalaVirtual,oMedicos,aSalas,bAtuDados,dDtRec,cCid)

Local Ih
Local nRecBBD	:= aHorMed[nAt,6]
Local lRetorno  := .T. 
Local lAnalize	:= .F.                                 
Local cLimite   := ''
Local cToleran  := Getmv("MV_TOLERAN",.F.,"15")
Local aArea		:= GetArea("BBD")
Local aRet		:= {}
Local lRet		:= .T.
Local cDesPro	:= ''
Local nOpcao	:= 0
Local lBiomet	:= SuperGetMv("MV_BIOCONF",,.F.)
Local cChaveFam := AllTrim(StrTran(aHorMed[nAt,3],".",""))   

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica se o indice esta criado										 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SIX->( DbSetOrder(01) )
If !SIX->( MsSeek("BBD8") )
   MsgAlert(STR0118) //'Favor criar o indice BBD_FILIAL + BBD_NUMATE!'
   Return(.F.)
EndIf	      
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no Horario													 |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->( DbGoTo( nRecBBD ) )
//Ё Usuario em Esprera                                                      |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nTipo == 2 .and. lBiomet .and. aStatus[nPos,4] < aStatus[nTipo,4] 

	BA1->(DbSetOrder(2))
	If BA1->(MsSeek(xFilial("BA1")+cChaveFam))
        lRetorno := PLSBIOMET("BTS",BA1->BA1_MATVID,.T.,"2")
 	Else
 		Aviso( "Digitais", "UsuАrio "+aHorMed[nAt,7]+" nЦo encontrado para realizar validaГЦo BiomИtrica" , {"Ok"} )
	EndIf
	
EndIf

If ExistBlock("PLS315VS")
	lRetorno := ExecBlock("PLS315VS",.F.,.F., { bbd->( RecNo() ), aStatus, nTipo, nPos })
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Mandou apenas imprimir a guia...                                         |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lRetorno
	If nTipo == 5
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Verficia se o usuario esta em consultorio ou atendido					 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !(aHorMed[nAt,7] $ '4,6')
			Aviso(STR0119,STR0120,{"Ok"}) //"Impressao de guia"###"A guia so podera ser impressa para pacientes atendidos ou em ConsultСrio!"
			Return(.F.)
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Seleciona Area															 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		DbSelectArea("BEA")
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posicona no atendimento para impressao da guia							 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BEA->( DbSetorder(13) )
		If BEA->( MsSeek(xFilial("BEA")+BBD->BBD_NUMATE) )
			PLSA090Ima()
		Else
			If BBD->BBD_TIPO $ '1,4'
				MsgAlert(STR0121+BBD->BBD_NUMATE) //'VerIficar o numero do atendimento no BEA: '
			Else
				MsgAlert(STR0122) //'Este atendimento nao e uma consulta ou encaixe!'
			EndIf
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Retorna																	 |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		Return(.F.)
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Efetua o estorno do movimento... existe uma excessao, uma falha logina na sequencia do status que deve ser tratada.|
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If aStatus[nTipo,4] < aStatus[nPos,4] //Estorno..
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё VerIfica posicao														 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If (nDIferenca := (aStatus[nPos,4] - aStatus[nTipo,4]) > 1 )//O estorno deve ser passo a passo..
			Aviso(STR0123,; //"Estorno!"
			STR0124+Upper(aStatus[nPos,3])+STR0125+; //"O estorno deve ser feito passo a passo, nao posso ir de "###" direto para "
			Upper(aStatus[nTipo,3])+STR0126+Upper(aStatus[(nPos-1),3])+"!",{STR0102}) //". Primeiro deve-se ir para "###"&Voltar"
			lAnalize := .F.
			Return(.F.)
		Else
			lAnalize := .T.
		EndIf
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Analize verdadeira														 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lAnalize
		If Aviso(STR0123,STR0127+Lower(aStatus[nPos,2])+STR0128+; //"Estorno!"###"O paciente ja "###", deseja efetuar o estorno voltando para "
			Lower(aStatus[nTipo,3])+"!",{STR0129,STR0102}) == 1 //"&Estornar"###"&Voltar"
			lRetorno := .T.
			lEstorno := .T.
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Reposiciono so para garantir											 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BBD->( DbGoTo( nRecBBD ) )
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Estorna de "espera" para "Agendado"...                                   Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If aStatus[nPos,1] == "5" .And. aStatus[nTipo,1] == "1"
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Inicia a Transacao													     Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Begin Transaction
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Alteracao																 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BBD->( Reclock("BBD",.F.) )
				BBD->BBD_HORCHE	:= ''
				BBD->BBD_STATUS	:= '1'
				BBD->BBD_CODCAN	:= ''
				BBD->BBD_HORCAN	:= ''
				BBD->BBD_DATCAN := Ctod('')
				BBD->BBD_USUOPE	:= PLRETOPE()
				BBD->( MsUnlock() )
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Fim da Transacao													     Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				End Transaction
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Estorna de "Em consultorio" para "Em espera"...                          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			ElseIf aStatus[nPos,1] == "6" .and. aStatus[nTipo,1] == "5"
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Abre o semaforo...                                                               |
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nHGrv := PLSAbreSem("SEMNUMATE.SMF")
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Alteracao																 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Begin Transaction
				BBD->(Reclock("BBD",.F.))
				BBD->BBD_HORENT := ''
				BBD->BBD_STATUS	:= '5'
				BBD->BBD_NUMMOV := ''
				BBD->BBD_CODCAN	:= ''
				BBD->BBD_HORCAN	:= ''
				BBD->BBD_DATCAN := Ctod('')
				BBD->BBD_USUOPE	:= PLRETOPE()
				BBD->BBD_USUCAN	:= ""
				BBD->(MsUnlock())
				End Transaction
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Posiciona o BEA													     Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BEA->( DbSetorder(13) )
				If !Empty(BBD->BBD_NUMATE) .And. BEA->( MsSeek(xFilial("BEA")+BBD->BBD_NUMATE) ) .And. GetNewPar("MV_PLSMCGG","1") == "1"
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Estorna movimentacao...                                              Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			
					aMovim := 	PLSMOVMC( BBD->( Recno() )	,"0"	, BBD->BBD_CODPAD,BBD->BBD_CODPRO )
				EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Limpa o numero do atendimento										 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Begin Transaction
				BBD->(Reclock("BBD",.F.))
				BBD->BBD_NUMATE := Space( Len(BBD->BBD_NUMATE) )
				BBD->BBD_USUOPE	:= PLRETOPE()
				BBD->(MsUnlock())
				End Transaction
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Fecha o semaforo...                                                              |
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				PLSFechaSem(nHGrv,"SEMNUMATE.SMF")
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Estorna de "Atendido" para "Em Consultorio"                              Ё
				//Ё Antes de estornar de "atendido" para "em consultorio", verIfica se ja    Ё
				//Ё existe paciente em consultorio.                                          Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			ElseIf aStatus[nPos,1] == "4" .and. aStatus[nTipo,1] == "6"
				For Ih := 1 to Len(aHorMed)
					If  aHorMed[Ih][7] == '6'
						Aviso(STR0130,STR0131,{"Ok"}) //"Opcao Invalida"###"Ja existe um paciente em ConsultСrio! Finalize o atendimento em aberto e repita a operacao!"
						Return(.F.)
					EndIf
				Next
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Inicia a Transacao													     Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Begin Transaction
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Altera																 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BBD->(Reclock("BBD",.F.))
				BBD->BBD_HORSAI := ''
				BBD->BBD_STATUS	:= '6'
				BBD->BBD_CODCAN	:= ''
				BBD->BBD_HORCAN	:= ''
				BBD->BBD_DATCAN := Ctod('')
				BBD->BBD_USUCAN	:= ""
				BBD->BBD_USUOPE	:= PLRETOPE()
				BBD->(MsUnlock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Fim da Transacao													 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				End Transaction
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Estorna de "Cancelado" para "Atendido" verIfica se pode ocorrer        	 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			ElseIf aStatus[nPos,1] == "7" .and. aStatus[nTipo,1] == "4"
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Inicia a Transacao													     Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Begin Transaction
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Altera																 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BBD->(Reclock("BBD",.F.))
				BBD->BBD_HORSAI := Left(Time(),5)
				BBD->BBD_STATUS	:= '4'
				BBD->BBD_CODCAN	:= ''
				BBD->BBD_HORCAN	:= ''
				BBD->BBD_DATCAN := Ctod('')
				BBD->BBD_USUCAN	:= ""
				BBD->BBD_USUOPE	:= PLRETOPE()
				BBD->(MsUnlock())
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Fim da Transacao													 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				End Transaction
			EndIf
		Else
			Return(.F.)
		EndIf
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Caso nao seja estorno...                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !lEstorno
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Em sala virtual so sera possivel por o usuario em espera...              Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If !aStatus[nTipo,1] $ "5,7" .and. cSalaVirtual == "S"
			Aviso(STR0050,STR0132,{STR0102}) //"Sala Virtual"###"Nao e possivel executar esta operacao em uma sala virtual. Nesta so e permitido por o usuario em ESPERA!"###"&Voltar"
			lRetorno := .F.
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Usuario tentou selecionar a opcao atual do usuario...                    Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf aStatus[nTipo,1] == aHorMed[nAt,7]
			Aviso(STR0130,STR0133+Lower(aStatus[nPos,2])+STR0134,{STR0102}) //"Opcao invalida"###"O usuario ja "###"! Selecione uma opcao valida."###"&Voltar"
			lRetorno := .F.
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Operador colocou o paciente em espera...                                 |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf aStatus[nTipo,1] == "5" .and. nPos < 2
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Reposiciona o usuario caso nao esteja posicionado...                     |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BA1->( DbSetorder(02) )
			If !BA1->( MsSeek(xFilial("BA1")+aHorMed[nAt, 3]) )
				MsgAlert( STR0135+aHorMed[nAt, 3] ) //'Usuario nao encontrado BA1:'
				Return(.F.)
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Trata usuarios bloqueados no momento de transferir para EM ESPERA...     |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If !Empty(BA1->BA1_DATBLO) .and. BA1->BA1_DATBLO <= dDataBase
				If Aviso(STR0136,STR0137+dToc(BA1->BA1_DATBLO)+". "+; //"Usuario Bloqueado!"###"Este usuario foi bloqueado para atendimento no dia "
					STR0138,{STR0139,STR0140}) == 1 //"Deseja efetuar o atendimento assim mesmo ?"###"Nao"###"Sim"
					lRetorno := .F.
				EndIf
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Retorno .T.																 |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If lRetorno
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Obtem tempo de atrazo do paciente...                                     |
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cLimite := ( Val( StrTran( Left( Time(),5 ),":",'' ) ) - Val( StrTran( aHorMed[nAt,2],":",'' ) ) )
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Testa o estorou da tolerancia... caso sim, pergunta se aceita o paciente.|
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If cLimite > Val(cToleran)
					If Aviso( STR0141,STR0142+cToleran+; //"Tolerancia esgotada!"###"O tempo de tolerancia que e de "
						STR0143,{STR0144,STR0102}) = 1 //" minutos ja se esgotou!"###"&Aceitar"###"&Voltar"
						lRetorno := .T.
					Else
						lRetorno := .F.
					EndIf
				Else
					lRetorno := .T.
				EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Motivo da verIficacao de periodicidade neste ponto:          		         Ё
				//|  A rotina de periodicidade da marcacao soh concidera agendas ja 			 |
				//|  confirmadas pela recepcao e que ja geraram guias ativas. Caso o atendente	 |
				//|  Marque duas agendas, uma apos a outra, a rotina nao ira coompreender a 	 |
				//|  periodicidade. Entao ao efetuar o atendimento medico, o sistema efetuara	 |
				//|  novamente esta verIficacao e caso seja constatada, o segundo atendimento 	 |
				//|  sera caracterizado automaticamente como REVISAO/RETORNO.					 |
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If BBD->BBD_TIPO <> '2'
					aRet := PLSA300CAR(BBD->BBD_CODPAC,IIf(BBD->( FieldPos("BBD_ATERNA") )>0,BBD->BBD_ATERNA,"0"),BBD->BBD_CODIGO,BBD->BBD_LOCAL,BBD->BBD_CODESP,aStatus[nTipo,1] == "5")
					lRet := IIf( ValType(aRet[1]) == 'L', aRet[1], .F.)

					lRetorno := lRet
					
					// So trata se for critica de periodicidade...
					If !lRet .and. Len(aRet[2]) > 0 .and. aRet[2][1][1] == '018' .and. Empty(BBD->BBD_USRFRC) // Desconsiderar se foi forcado.
						BR8->( dbSetorder(01) )
						If BR8->( MsSeek(xFilial("BR8")+BBD->BBD_CODPAD+BBD->BBD_CODPRO) )
							cDesPro := Alltrim(BR8->BR8_DESCRI)
						EndIf
						
						While .T.
							nOpcao := Aviso(STR0145, STR0146,; //"Periodicidade"###"A periodicidade permitida foi excedida. Este atendimento serА caracterizada como REVISцO!"
							{STR0147, STR0148, STR0149}) //"&Detalhes"###"Continuar"###"Retornar"
							
							If nOpcao == 1
								// Visualiza critica com todos os detalhes padroes...
								PLSMOVCRI("1",{BBD->BBD_CODPAD,BBD->BBD_CODPRO,cDesPro,"001"},aRet[2],.F.)
								
							ElseIf nOpcao == 2
								// Altera o tipo da consulta para seja caracterizada como REVISAO/RETORNO
								BBD->( RecLock("BBD", .F.) )
								BBD->BBD_TIPO := '2'
								BBD->( MsUnlock() )
								Exit
								
							Else
								lRetorno := .F.
								Exit
								
							EndIf
						Enddo
					ElseIf !lRet .and. Len(aRet[2]) > 0 .and. aRet[2][1][1] == '018' .and. !Empty(BBD->BBD_USRFRC)
						Aviso(STR0145, STR0150,; //"Periodicidade"###"Este atendimento foi forГado pelo atendimento!"
						{STR0148}) //"Continuar"
						
					EndIf
				EndIf
				
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Operador colocou o paciente no consultorio...                            |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf aStatus[nTipo,1] == "6"
			If nPos <> 2
				Aviso(STR0151,STR0152,{STR0102}) //"Opcao Invalida!"###"O paciente nao esta em espera, nao sera possivel envia-lo ao ConsultСrio!"###"&Voltar"
				lRetorno := .F.
			Else
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Valida se a sala esta em PAUSA...                                        Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If aSalas[oMedicos:nAt,14]
					If MsgYesNo(STR0153) //"Esta sala esta em PAUSA! Deseja finalizar a PAUSA?"
						PLS315Pause(oMedicos,aSalas,bAtuDados,.T.,dDtRec,aHorMed)
						lRetorno := .T.
					Else
						lRetorno := .F.
					EndIf
				Else
					lRetorno := .T.
				EndIf
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Usuario apontou termino do atendimento...                                |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf aStatus[nTipo,1] == "4"
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Caso usuario nao esteja em conultorio nao sera possivel dizer que foi atendido |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If aHorMed[nAt,7] # '6'
				Aviso(STR0130,STR0154,{STR0102}) //"Opcao invalida"###"So sera possivel informar que o paciente foi atendido se o mesmo estiver em ConsultСrio."###"&Voltar"
				lRetorno := .F.
			Else
				lRetorno := .T.
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Apontado falta para o usuario...                                         |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		ElseIf aStatus[nTipo,1] == "8" .and. aHorMed[nAt,7] == '1'
			lRetorno := .T.
		EndIf
	EndIf
EndIf

If ExistBlock("PLS315ST")
	lRetorno := ExecBlock("PLS315ST",.F.,.F., { nTipo, cCID })
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Restaura area do BBD...                                                  |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RestArea(aArea)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	   
Return(lRetorno)
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA315   ╨Autor  ЁMicrosiga           ╨ Data Ё  10-27-03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё                                                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PLSA315ENABLEKEYS(bBotao02, bBotao03, bBotao04, bBotao05, bBotao06, bBotao08, bBotao09,;
                                  bBotao10, bBotao11, bBotao12, bBotao13, nBrw, aHorMed, oHorarios,;
                                  aHorPro , oPronto , bBotLes)
                                  
SetKey(2	 ,{|a,b| IIf(nBrw#0, PLSA315VIS(IIf(nBrw==1,({aHorMed, oHorarios}),({aHorPro,oPronto}) ),nBrw),NIL) }) 
SetKey(5	 ,{|a,b| Eval(bBotLes)  })
SetKey(6	 ,{|a,b| Eval(bBotao13) })
SetKey(1	 ,{|a,b| Eval(bBotao12) })

SetKey(VK_F4 ,{|a,b| Eval(bBotao02) })
SetKey(VK_F5 ,{|a,b| Eval(bBotao03) })
SetKey(VK_F6 ,{|a,b| Eval(bBotao04) })
SetKey(VK_F7 ,{|a,b| Eval(bBotao05) })
SetKey(VK_F8 ,{|a,b| Eval(bBotao06) })
SetKey(VK_F9 ,{|a,b| Eval(bBotao08) })
SetKey(VK_F10,{|a,b| Eval(bBotao09) })
SetKey(VK_F12,{|a,b| Eval(bBotao10) })
SetKey(VK_F11,{|a,b| Eval(bBotao11) })
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	   
Return()
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA315COR Ё Autor ЁGeraldo Felix JuniorЁ Data Ё 29.01.02 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Retorna a cor para a coluna status do objeto horarios     Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA315Cor(aHorMed,oHorarios)

Local cCor
Local nLin := oHorarios:nAt
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nLin > Len(aHormed)
   nLin := 1
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Horario sem agenda...                                                    Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(aHorMed[nLin,4]) 
	If Len(aHorMed[nLin]) > 12
		If aHorMed[nLin, 13]
		   cCor := "BR_BRANCO"
		Else
		  cCor := "BR_VERMELHO"
		EndIf
	Else	
		cCor := "BR_BRANCO"
	EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Horario com agenda marcada...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Else
	If (aHorMed[nLin,7] == "1" .or. aHorMed[nLin,7] == "8") .and. aHorMed[nLin,9] == "0" //Agendado normal\
		cCor := "BR_CINZA"
	ElseIf aHorMed[nLin,7] == "4" //Atendido
		cCor := "BR_AZUL"
	ElseIf aHorMed[nLin,7] == "5" //Espera
		cCor := "BR_VERDE"
	ElseIf aHorMed[nLin,7] == "6" //Em atendimento
		cCor := "BR_LARANJA"
	ElseIf aHorMed[nLin,7] == "7" //Cancelado
		cCor := "NOCHECKED" 		//"BR_PRETO"
	ElseIf ( aHorMed[nLin,7] == "1" .or. aHorMed[nLin,7] == "8") .and. aHorMed[nLin,9] == "1" //Agendado encaixe //Encaixe
		cCor := "BR_AMARELO"
	EndIf 
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Quando vem da agenda medica	...                                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Len(aHorMed[nLin]) >= 10   
		If !Empty(aHorMed[nLin,10])
			cCor := "NOCHECKED"
		ElseIf Len(aHorMed[nLin]) > 12 
			If !aHorMed[nLin][13]
				cCor := "BR_VERMELHO"
			EndIf
		EndIf
	EndIf	
	
	If ExistBlock("PLS315COR")
	   cCor := ExecBlock("PLS315COR",.F.,.F.,{cCor,aHorMed,nLin})
	EndIf   
EndIf           
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return( LoadBitmap( GetResources(),cCor ) )
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PlsEstAgen Ё Autor ЁAlexander		   Ё Data Ё 01.02.06 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Totais do Medico Agendamento,Atendimento,Espera...		 Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSESTAGEN(cTipo,cTip2,cTip3,cNome,aMatEst)

	Do Case
	    Case cTipo == "1"  .And. cTip3 <> "1"  //Agendados                  
		 	aMatEst[1]++
		Case cTipo == "4" 						//Atendido                                
			aMatEst[2]++ 	
		Case cTipo == "5" 						//Espera
			aMatEst[3]++ 	
		Case cTipo == "1" .And. cTip3 == "1"	//Encaixe
			aMatEst[4]++ 	
		Case !Empty(cTip2)						//Cancelados
			aMatEst[5]++ 	
		Case cTipo == "6"						//Consultorio
			aMatEst[7]++ 	
	EndCase            
	If Empty(cNome)
	   aMatEst[6]++ 	
	EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return( aMatEst )
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSPOPUP  ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  26/04/03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Menu Pop-Up para mudanca de faze do paciente na recepcao.  ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё Rotina de Recepcao da Marcacao de consultas.               ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PLSPOPUP(oHorarios,aHorMed,oMedicos,aSalas,dDtRec,bBotao04,bAtuDados)

Local oDlgRpc 
Local oTipo          
Local oGet1
Local lOk 	     := .F.
Local lRet 	     := .T.
Local nPos 	     := 0                                                           
Local nTipo      := 1
Local nRecOut    := 0
Local cCab 	     := ""     
Local cCID	     := Space(Len(BEA->BEA_CID))
Local bBlockAt   :=  { || oGet1:Enable(), oGet1:Refresh() }
Local bBlockNAt  :=  { || oGet1:Disable(), cCID := Space(Len(BEA->BEA_CID)), oGet1:Refresh() }
Local aButtons   := {}

Private lEstorno := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Agenda vazia, nao faz nada...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty( aHorMed[oHorarios:nAt,3] )
   Return( {"",.F.,0,.F.} )
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Usuario foi cancelando... nao faz nada...                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
If !Empty( aHorMed[oHorarios:nAt,10] )
	If Aviso(STR0160,STR0164,{STR0102}) == 1 //"CANCELADA"###"Esta agenda foi cancelada!"###"&Voltar"
	   Return( {"",.F.,0,.F.} )
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Busca no aStatus o status atual do usuario no browse...                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nPos := Ascan( aStatus, {|x| x[1] == aHorMed[oHorarios:nAt,7] } )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta o inicio da mensagem padrao usada na validacao quando esta for .F. Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                                      
If nPos # 0 
	cCab := STR0165+aStatus[IIf((nPos == 1 .and. aHorMed[oHorarios:nAt,9] == "1"),6,nPos),2] //"O usuario "
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo com as opcoes...                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                         

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inclusao de botoes de apoio...                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("PL315RCBOT")
   aButtons := ExecBlock("PL315RCBOT",.F.,.F.,{aStatus,oHorarios,oHorarios:nAt,aSalas,oMedicos,aSalas[oMedicos:nAt],oHorarios:AARRAY[oHorarios:nAt]})
EndIf



DEFINE MSDIALOG oDlgRpc FROM 0,0 TO 210,400 TITLE STR0002 Of oMainWnd PIXEL //"Recepcao"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define fontes...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD

@ 36 ,05  TO 37 ,200 LABEL '' OF oDlgRpc PIXEL

@ 28 ,10  SAY cCab Of oDlgRpc PIXEL SIZE 130 ,9 FONT oBold 
@ 42 ,30  SAY STR0166 Of oDlgRpc PIXEL SIZE 060,140 //"Mudar para - "

@ 42, 75 RADIO oTipo VAR nTipo 3D SIZE 50,10 PROMPT	STR0167,; //"&1-Agendado"
													STR0168,; //"&2-Espera"
													STR0169,; //"&3-ConsultСrio"
													STR0170,; //"&4-Atendido"
													STR0171 OF oDlgRpc ON CHANGE (If( nTipo <> 4, Eval(bBlockNAt), Eval(bBlockAt) ) ) PIXEL  //"&5-Imprimir guia"


@ 070, 125 Say oSay PROMPT STR0172 SIZE 070,010 OF oDlgRpc PIXEL //"CID: "
@ 068, 138 MSGet oGet1 VAR cCID F3 IIf(PlsGetVersao() >= 8,"BA9PLS","BA9") Valid BA9->(ExistCpo("BA9",cCID,1)) SIZE 040,010 PIXEL OF oDlgRpc
oGet1:Disable()


ACTIVATE MSDIALOG oDlgRpc ON INIT EnchoiceBar(oDlgRpc,{|| IIf(ValidStatu(aStatus,aHorMed, nPos, oHorarios:nAt, nTipo, aSalas[oMedicos:nAt,1], aSalas[oMedicos:nAt,13],oMedicos,aSalas,bAtuDados,dDtRec,cCid),(lOk:=.T.,oDlgRpc:End()), .F.)},{||lOk := .F.,oDlgRpc:End()}, , aButtons) CENTERED


If nTipo == 3
	nPos := Ascan(aHorMed, {|x| x[7] == "6"})
	If nPos # 0
	   nRecOut := aHorMed[nPos,6]
	EndIf
EndIf           

If nTipo == 4 .And. lOk == .T.
	PLSABTHGrv(3)
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return( If( lOk, {aStatus[nTipo,1], lRet, nRecOut, lEstorno, nTipo, cCID }, {"",.F.,0,.F.,0,""} ) )

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбдддддддддддддддддддддбддддддбдддддддддд©╠╠╠
╠╠ЁFuncao    Ё PLSABTHGrv Ё Autor Ё Andreia J C da SilvaЁ Data Ё 17.03.10 Ё╠╠╠
╠╠цддддддддддеддддддддддддадддддддадддддддддддддддддддддаддддддадддддддддд╢╠╠╠
╠╠ЁDescricao Ё Grava os dados na tabela BTH apos  marcar o paciente       Ё╠╠╠
╠╠Ё			 Ё como atendido, na rotina de recepcao.					  Ё╠╠╠
╠╠юддддддддддадддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды╠╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/

Static Function PLSABTHGrv(nOpc)

Local nH 
Local aArea := GetArea()          


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Abre semaforo															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nH := PLSAbreSem("SEMNUMATE.SMF")            

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inicio da transacao...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Begin Transaction

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Grava a movimentacao em primeiro lugar, caso haja criticas, retorna sem fazer nada...|
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpc == 3 
   	BTH->(RecLock("BTH",.T.))

	BTH->BTH_DATA   := dDataBase
	BTH->BTH_HORINI := Time()
	BTH->BTH_CODPAC := BBD->BBD_CODPAC
	BTH->BTH_NOMPAC := BBD->BBD_NOME
	BTH->BTH_CODATE := BBD->BBD_NUMATE
	BTH->BTH_IDADE  := If(!Empty(BA1->BA1_DATNAS),Calc_Idade(dDataBase,BA1->BA1_DATNAS),0)  
	BTH->BTH_MATVID := BA1->BA1_MATVID
	
	BTH->(MsUnLock())
EndIf	
End Transaction

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha o semaforo unIficado da geracao de guias...                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
PLSFechaSem(nH,"SEMNUMATE.SMF")

RestArea(aArea)

Return

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS315LOC ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  09/23/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁFuncao para pesquisar medicos na abertura da sala, na       ╨╠╠
╠╠╨          Ёrecepcao!                                                   ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLS315LOC(aMatriz, oObj, nPos)

Local oGetChave
Local oDlgPes
Local oTipoPes
Local cTipoPes   := ""
Local cChave     := Space(100)
Local cValid     := "{|| Eval(bRefresh) }"
Local bRefresh   := { || IIf(!Empty(cChave), lPesq := PLS315PSQ(cChave, oGetChave, aMatriz, oObj, nPos), oGetChave:SetFocus() ) }
Local bOK        := { || dbSelectArea("BBD"), oDlgPes:End() }
Local bCanc      := { || dbSelectArea("BBD"), oDlgPes:End() }
Local aTipoPes   := {STR0173} //"1-Nome do Paciente"
Local lPesq		 := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlgPes TITLE STR0010 FROM 005,005 TO 025,080 OF GetWndDefault() //"Pesquisa"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta objeto que recebera o a chave de pesquisa  ...                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oGetChave := TGet():New(040,103,{ | U | If( PCOUNT() == 0, cChave, cChave := U ) },oDlgPes,180,008 ,"@!S30",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Combo BOX com os tipo de pesquisa...                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 040,008 COMBOBOX oTipoPes  Var cTipoPes ITEMS aTipoPes SIZE 090,010 OF oDlgPes PIXEL COLOR CLR_HBLUE
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o Dialogo...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlgPes ON INIT Eval({ || EnChoiceBar(oDlgPes,bOK,bCanc,.F.) }) 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no objeto...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oObj:SetFocus()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLS315PSQ ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  09/23/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁAuxiliar na pesquisa de medicos na abertura de salas!       ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PLS315PSQ(cChave, oGetChave, aMatriz, oObj, nPosChave)	  

Local nPos := 0
                          
cChave := Alltrim(cChave) 

If (nPos := Ascan( aMatriz, {|x| Left(x[nPosChave], Len(cChave)) == cChave } )) > 0 
	oObj:nAt := nPos	
	oObj:Refresh()
Else    
	MsgInfo(STR0174)	 //"Expressao nao encontrada!"
	lRet := .F.
EndIf

oGetChave:SetFocus() 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPL315PSMED╨Autor  ЁMicrosiga           ╨ Data Ё  01/15/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁPesquisa Medico	                                          ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PL315PSMED(aMedAux,oBrwMed)

Local oGetChave
Local oDlg
Local cChave    := Space(100)               
Local cValid    := "{|| Eval(bRefresh) }"
Local bRefresh  := { || IIf(!Empty(cChave), PLS315PSQ(cChave, oGetChave, aMedAux, oBrwMed, 2), oBrwMed:SetFocus()) }

DEFINE MSDIALOG oDlg TITLE STR0175 FROM 010,015 TO 016,080 //"Pesquisa MИdica."
	                                                                                                   
oGetChave := TGet():New(020,005,{ | U | If( PCount() == 0, cChave, cChave := U ) },oDlg,220,008 ,"@!S30",&cValid,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cChave)
	                                                                         	
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()},.F.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA315PES Ё Autor ЁGeraldo Felix JuniorЁ Data Ё 29.01.02 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Pesquisar agenda marcada...                               Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function PLSA315Pes(aRet,aHorarios,oHorarios,aSalas,oMedicos,bFiltra,aHorMed)

Local nPosHor
Local nPosResH
Local cMedico
Local cHora  
Local lRet     := aRet[3]
Local nReg     := aRet[4]     

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Retorna																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ! lRet
   Return
EndIf                 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega posicao														     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nPosHor := Ascan(aHorarios,{|a| a[6] == nReg})
If nPosHor > 0
   cMedico := aHorarios[nPosHor,1]
   cHora   := aHorarios[nPosHor,2]
   nPosMed := AsCan(aSalas,{|a| a[2] == cMedico})
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Posicao																	Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If nPosMed > 0
	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  //Ё Atualiza medico														   Ё
	  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      oMedicos:nAt := nPosMed
      oMedicos:Refresh()
	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  //Ё Filtra																   Ё
	  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      Eval(bFiltra)
	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  //Ё Atualiza Horario														   Ё
	  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      nPosResH 		:= Ascan(aHorMed,{|a| a[2] == cHora})
      oHorarios:nAt := nPosResH
      oHorarios:Refresh()
   Else
      Help("",1,"PLSA315PES")
   EndIf   
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё ValOKEnc   Ё Autor ЁAlexander		   Ё Data Ё 15.02.06 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Valida ok do Encaixe...                                   Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/                                     
Static Function ValOKEnc(aMat,cCod,cLocal,cCodEsp)

Local lRet := .F.
Local aRet := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica no horarios													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aMat) > 0
   If VerIfBrw(aMat,3,7,M->BBD_CODPAC,STR0176) //"Paciente agendado"
      lRet := .T.
   EndIf
Else 
   lRet := .T.  
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Validacao																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lRet 
   aRet := PLSA300CAR(M->BBD_CODPAC,M->BBD_ATERNA,cCod,cLocal,cCodEsp,.F.)
   lRet := IIf( ValType(aRet[1]) == 'L', aRet[1], .F.)
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//|Se criticar por periodicidade, o encaixe pode ser marcado como revisao... |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lRet .and. (Len(aRet[2]) > 0 .and. aRet[2][1][1] == '018')
	If Aviso(STR0177,STR0178, {STR0140,STR0179}) == 1 //"RevisЦo"###"Deseja marcar o encaixe como REVISцO?"###"Sim"###"NЦo"
		M->BBD_TIPO := '2'
		lRet := .T.
	EndIf
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)   
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA315PRO Ё Autor ЁGeraldo Felix JuniorЁ Data Ё 18.12.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Pronto atendimento... Inclusao                            Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function PLSA315Pro(aHorPro,oPronto,dData,cCodLoc,cCodOpe,oMedicos,aSalas,cCodCPA,bAtuDados,aHorMed)

Local nInd               
Local nCnt
Local nTamDlgPad
Local cCodigo
Local cSigla
Local cConReg
Local cEstCr
Local oSay
Local oDlgRes
Local oComboEsp
Local oComboMed
Local lRet      := .F.
Local nOpca     := 0      
Local nDsPer    := GETMV("MV_PLDSCAG")
Local cTitulo 	:= STR0180  //"Pronto Atendimento - Dados do Paciente"
Local cComboMed	:= ""
Local cComboEsp	:= ""
Local aDadBBD   := {}
Local aButtons  := {}
Local aCampos   := {}   
Local aComboMed	:= {}
Local aComboEsp	:= {}
Local bEspMed	:= { || A315EsMe(aSalas,cComboEsp,oComboMed) , A315CBOX(aSalas,cComboEsp,cComboMed) }
Local bOK       := { || nOpca := 1,If( ( Obrigatorio(aGets,aTela) ),;
											( Eval(bAtuDados) , If( ValOKPron( aHorPro,aSalas,aHorMed,aSalas[oMedicos:nAt,2],cCodLoc,aSalas[oMedicos:nAt,9] ) , oDlgRes:End() , (nOpca:=3,.F.) ) ),;
							    	     (nOpca:=3,.F.) ) }
Local bCanc     := { || nOpca := 3,oDlgRes:End() }

Private oEnc
Private aTela   := {}
Private aGets   := {}   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa a sala															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aSalas) == 0
	Return(lRet)
EndIf                     
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё lRefresh																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lRefresh := .F.          
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o codigo da especialidade...                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCodEsp := aSalas[oMedicos:nAt,9]
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Rede de atendimento														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BAU->(DbSetOrder(1))
BAU->(MsSeek(xFilial("BAU")+aSalas[oMedicos:nAt,2]))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta titulo do dialogo de acordo com a opcao...                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(aSalas[oMedicos:nAt,2])
	cCodigo 	:= BAU->BAU_CODIGO
	cSigla  	:= BAU->BAU_SIGLCR
	cConReg 	:= BAU->BAU_CONREG
	cEstCr  	:= BAU->BAU_ESTCR
	cComboMed	:= ""
	cComboEsp	:= ""
	For nCnt := 1 To Len(aSalas)
		If !Empty(aSalas[nCnt][2]) 
			nPosMed	:= Ascan(aComboMed, aSalas[nCnt][2]+" - "+aSalas[nCnt][03])
			nPosEsp	:= Ascan(aComboEsp, aSalas[nCnt][9]+" - "+aSalas[nCnt][10])
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Medico																	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nPosMed == 0 .And. aSalas[nCnt][13] # "S" .And. ( aSalas[nCnt][9] == Left( cCodEsp, Len(BBD->BBD_CODESP) ) )
				Aadd(aComboMed, aSalas[nCnt][2]+" - "+aSalas[nCnt][03])
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Especialidade															 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If nPosEsp == 0
				Aadd(aComboEsp, aSalas[nCnt][9]+" - "+aSalas[nCnt][10])
			EndIf
		EndIf
	Next
Else
	cCodigo := ""
	cSigla  := ""
	cConReg := ""
	cEstCr  := ""
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica sala aberta													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aComboMed) = 0
	MsgStop(STR0181) //"Nenhuma sala aberta. Primeiro abra uma sala!"
	Return(lRet)
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inclui um items em branco no combobox de especialidade e medicos         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Aadd( aComboMed, "")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Mostra a especialidade do medico posicionado							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cComboEsp := aSalas[oMedicos:nAt][9]+" - "+aSalas[oMedicos:nAt][10]
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define botoes...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                           
aadd(aButtons,{"POSCLI",{ || A300INTGER(.T.) },STR0182,STR0183}) //"Usuarios de Outros Intercambios"###"Interc"

@ 001,001 BUTTON STR0184 SIZE 000,00 ACTION Eval({||A300INTGER(.T.)}) PIXEL  //"&Intercambio"

DEFINE MSDIALOG oDlgRes TITLE cTitulo FROM 005,005 TO 030, 055 OF GetWndDefault()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta informacoes do horario/medico selecionado...                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 020,005 Say oSay Prompt STR0185 Size 150,008 PIXEL OF oDlgRes COLOR CLR_HBLUE          //"DATA"
@ 020,030 Say oSay Prompt dtoc(dData) Size 150,008 PIXEL OF oDlgRes     

@ 035,005 Say oSay Prompt STR0186 Size 100,008 PIXEL OF oDlgRes COLOR CLR_HBLUE     //"ESPEC."
@ 035,030 COMBOBOX oComboEsp  Var cComboEsp ITEMS aComboEsp ON CHANGE Eval(bEspMed) SIZE 155,010 OF oDlgRes PIXEL COLOR CLR_HBLUE

@ 050,005 Say oSay Prompt STR0039 Size 100,008 PIXEL OF oDlgRes COLOR CLR_HBLUE     //"MиDICO"
@ 050,030 COMBOBOX oComboMed  Var cComboMed ITEMS aComboMed ON CHANGE A315CBOX(aSalas,cComboEsp,cComboMed) SIZE 155,010 OF oDlgRes PIXEL 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados da enchoice...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aadd(aCampos,"BBD_TIPOPA")
aadd(aCampos,"BBD_CODPAC")
aadd(aCampos,"BBD_NOME")
aadd(aCampos,"BBD_TELEFO")
aadd(aCampos,"BBD_TIPO")      
aadd(aCampos,"BBD_HORA")
aadd(aCampos,"BBD_MATANT")
aadd(aCampos,"BBD_CDAMBU")
aadd(aCampos,"BBD_OBSERV")
aadd(aCampos,"BBD_ATERNA")
If BBD->( FieldPos("BBD_TIPPAC") ) > 0
	aadd(aCampos,"BBD_TIPPAC")     
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alimenta campos															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

RegtoMemory("BBD",.F.,.T.,.F.)

M->BBD_TIPOPA := CriaVar("BBD_TIPOPA")
M->BBD_CODPAC := Space(Len(BBD->BBD_CODPAC))
M->BBD_NOME   := Space(Len(BBD->BBD_NOME))
M->BBD_TELEFO := Space(Len(BBD->BBD_TELEFO))
M->BBD_TIPO   := "1"
M->BBD_HORA   := Left(Time(),5)
M->BBD_MATANT := Space(Len(BBD->BBD_MATANT))
M->BBD_CDAMBU := mv_par03
M->BBD_ATERNA := "0"
M->BBD_OBSERV := Space(Len(BBD->BBD_OBSERV))   
If BBD->( FieldPos("BBD_TIPPAC") ) > 0
	M->BBD_TIPPAC := CriaVar("BBD_TIPPAC")
Endif 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta enchoice...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oEnc := BBD->(MSMGet():New("BBD",0,K_Incluir,,,,aCampos,{065,005,182,182},aCampos,,,,,oDlgRes,,,.T.))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё No caso da agenda vou alterar o valid do campo BBD_NOME...               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nInd := 1 To Len(oEnc:AENTRYCTRLS)
	If oEnc:AENTRYCTRLS[nInd]:cReadVar $ "M->BBD_HORA,M->BBD_CDAMBU,M->BBD_NOME"
		oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
	EndIf
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o dialogo...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlgRes ON INIT Eval( { || nTamDlgPad := oDlgRes:nBottom, EnChoiceBar(oDlgRes,bOK,bCanc,.F.,aButtons) } ) Center
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё inicia transacao na base se confirmado operacao..                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no usuario 													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BA1->(DbSetOrder(2))
	If !BA1->(MsSeek(xFilial("BA1")+M->BBD_CODPAC))
	   MsgAlert('Usuario nao encontrado BA1:'+M->BBD_CODPAC)
	   Return(.F.)
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona na Familia													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BA3->(DbSetOrder(1))
	If !BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
	   MsgAlert('Familia nao encontrada BA3:'+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) )
	   Return(.F.)
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicia a transacao														 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Begin Transaction
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Monta campos e seus conteudos...                                         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If M->BBD_TIPOPA == '0'
			aadd(aDadBBD,{"BBD_CODIGO" ,Left(cComboMed,Len(BAU->BAU_CODIGO))})
		EndIf
		aadd(aDadBBD,{"BBD_CODINT"		,cCodOpe})
		aadd(aDadBBD,{"BBD_DATA"  		,dData})
		aadd(aDadBBD,{"BBD_HORCHE"  	,M->BBD_HORA})
		aadd(aDadBBD,{"BBD_HORA"  		,M->BBD_HORA})
		aadd(aDadBBD,{"BBD_STATUS"		,"5"})
		aadd(aDadBBD,{"BBD_TIPO"  		,M->BBD_TIPO})
		aadd(aDadBBD,{"BBD_ENCAIX"		,"0"})
		aadd(aDadBBD,{"BBD_PRTATD"		,"1"})
		aadd(aDadBBD,{"BBD_CODCAN"		,""})
		aadd(aDadBBD,{"BBD_HORCAN"		,""})
		aadd(aDadBBD,{"BBD_DATCAN"	,Ctod('')})
		aadd(aDadBBD,{"BBD_CODESP"		,Left(cComboEsp,Len(BBD->BBD_CODESP))})
		aadd(aDadBBD,{"BBD_LOCAL",cCodLoc}) //BB8_LOCAL  variavel cCodLoc vem do BD1_CODLOC que e = a BB8_LOCAL
		aadd(aDadBBD,{"BBD_CODLOC",cLocal}) //BB8_CODLOC
		
		aadd(aDadBBD,{"BBD_SIGLA"		,cSigla})
		aadd(aDadBBD,{"BBD_NUMREG"		,cConReg})
		aadd(aDadBBD,{"BBD_ESTCR"		,cEstCr})
		aadd(aDadBBD,{"BBD_CODPRF"		,cCodigo})
		aadd(aDadBBD,{"BBD_CODPAC"		,M->BBD_CODPAC})
		aadd(aDadBBD,{"BBD_NOME"		,M->BBD_NOME})
		aadd(aDadBBD,{"BBD_TELEFO"		,M->BBD_TELEFO})
		aadd(aDadBBD,{"BBD_USUOPE"		,PLRETOPE()})
		aadd(aDadBBD,{"BBD_MATANT"		,M->BBD_MATANT})
		aadd(aDadBBD,{"BBD_TIPOPA"		,M->BBD_TIPOPA})
		aadd(aDadBBD,{"BBD_CDAMBU"		,M->BBD_CDAMBU})
	    aadd(aDadBBD,{"BBD_ATERNA"	,M->BBD_ATERNA})  
	    If BBD->( FieldPos("BBD_TIPPAC") ) > 0
			 aadd(aDadBBD,{"BBD_TIPPAC",M->BBD_TIPPAC})
	   	Endif
	    aadd(aDadBBD,{"BBD_OBSERV"	    ,M->BBD_OBSERV})
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava o codigo do procedimento...                                        Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
		aadd(aDadBBD,{"BBD_CODPAD",Left(cCodCPA,2)})		
		aadd(aDadBBD,{"BBD_CODPRO",Substr(cCodCPA,3,16)})
		aadd(aDadBBD,{"BBD_CODEMP",BA3->BA3_CODEMP})
		aadd(aDadBBD,{"BBD_CONEMP",BA3->BA3_CONEMP})
		aadd(aDadBBD,{"BBD_VERCON",BA3->BA3_VERCON})
		aadd(aDadBBD,{"BBD_SUBCON",BA3->BA3_SUBCON})
		aadd(aDadBBD,{"BBD_VERSUB",BA3->BA3_VERSUB})
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gravacao																 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
		PLSAtuAge(aDadBBD)
		lRet := .T.
	End Transaction             
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды			

	If ExistBlock("PL315GPA")
		ExecBlock("PL315GPA", .F., .F., {})
	EndIf

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
	Eval(bAtuDados)
EndIf          
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё ValOKPron  Ё Autor ЁAlexander		   Ё Data Ё 15.02.06 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Valida ok do Pronto										 Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/                                 
Static Function ValOKPron(aMat,aMatSal,aMatHor,cComMed,cLocal,cCodEsp)

Local lRet := .F.   
Local aRet := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica no horarios													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aMatHor) > 0
   lRet := VerIfBrw(aMatHor,3,7,M->BBD_CODPAC,STR0187) //"Paciente ja agendado"
Else
   lRet := .T.
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica no Pronto														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lRet
	If Len(aMat) > 0
		lRet := VerIfBrw(aMat,2,6,M->BBD_CODPAC,STR0188) //"Ja existe este paciente no pronto atendimento"
	Else
	    lRet := .T.
	EndIf	
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Varidacao																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lRet 
   If A315CBOX( aMatSal,cCodEsp,cComMed )
   	  aRet := PLSA300CAR( M->BBD_CODPAC , M->BBD_ATERNA,cComMed,cLocal,cCodEsp,.F. )
   	  lRet := IIf( ValType(aRet[1]) == 'L', aRet[1], .F.)
   Else
     lRet := .F.	  
   EndIf
EndIf                   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)   
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁVerIfBrw  ╨Autor  ЁAlexander			 ╨ Data Ё  15/02/06   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё VerIfica duplicidade em um brw							  ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function VerIfBrw(aMat,nPos,nPos1,cCont,cMsg)

Local nPosEn := Ascan(aMat, {|x| x[nPos] == cCont .And. !x[nPos1] $ '7,8'})
Local lRet := .T.
If nPosEn # 0   
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё VerIfica se esta cancelado												 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    If !aMat[nPosEn,nPos1] $ '7,8'
       If !MsgYesNo(cMsg+STR0189) //". Deseja continuar ?"
	       lRet := .F.
	   EndIf
    EndIf	   
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)                                                          
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA315VIS╨Autor  ЁGeraldo Felix Junior╨ Data Ё  22/05/03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Visualiza os dados da agenda....                           ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PLSA315VIS(aParam, nBrw)

Local nInd
Local nRecBBD          
Local oDlgVis
Local oChamadas
Local nStart	 := 0
Local cHora 	 := ''
Local aCampos 	 := {}
Local aChamadas	 := {}
Local aVetor 	 := aParam[1]
Local oObject 	 := aParam[2]
Local bOK        := { || oDlgVis:End() }
Local bCanc      := { || oDlgVis:End() }

Private oEnc
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o Recno															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nRecBBD := aVetor[oObject:nAt,IIf(nBrw==1,6,1)]
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no Horario													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->( DbGoTo( nRecBBD ) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Nao encontrado sai														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If BBD->( Eof() )
	Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё lRefresh																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lRefresh := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Campos da enchoice														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aadd(aCampos,"BBD_HORCHE")
aadd(aCampos,"BBD_HORENT")
aadd(aCampos,"BBD_HORSAI")
aadd(aCampos,"BBD_HORCAN")
aadd(aCampos,"BBD_TIPO")                               
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta campos de memoria													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
M->BBD_HORCHE 	:= BBD->BBD_HORCHE
M->BBD_HORENT 	:= BBD->BBD_HORENT
M->BBD_HORSAI  	:= BBD->BBD_HORSAI
M->BBD_HORCAN 	:= BBD->BBD_HORCAN
M->BBD_TIPO   	:= BBD->BBD_TIPO
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define tela																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlgVis TITLE IIf(nBrw==1,STR0107,STR0190) FROM 005,005 TO 029, 055 //"Dados da Agenda"###"Dados do PA"
	                                                                          
@ 020,005 Say oSay Prompt STR0054 Size 150,008 PIXEL OF oDlgVis COLOR CLR_HBLUE          //"Paciente"
@ 020,030 Say oSay Prompt  aVetor[oObject:nAt, IIf(nBrw==1,4,3)] Size 150,008 PIXEL OF oDlgVis     

@ 030,005 Say oSay Prompt STR0053 Size 150,008 PIXEL OF oDlgVis COLOR CLR_HBLUE          //"Hora"
@ 030,030 Say oSay Prompt aVetor[oObject:nAt, IIf(nBrw==1,2,13)] Size 150,008 PIXEL OF oDlgVis
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Get																		 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oEnc := BBD->(MSMGet():New("BBD",0,K_Visualizar,,,,aCampos,{045,002,110,180},aCampos,,,,,oDlgVis,,,.T.) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё For																	     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nInd := 1 To Len(oEnc:AENTRYCTRLS)
	If oEnc:AENTRYCTRLS[nInd]:cReadVar $ "M->BBD_HORCHE,M->BBD_HORENT,M->BBD_HORSAI,M->BBD_HORCAN,M->BBD_TIPO"
		oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
	EndIf
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verfica																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nStart := 1   
nCount := 1
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё While																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While .t.
	cHora	:= Substr(BBD->BBD_HORCMD, nStart, 5)
	If Empty(cHora)
	   Exit
	Else
	   Aadd(aChamadas, {StrZero(nCount, 2),cHora})
	EndIf
	nStart += 6
	nCount ++
Enddo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё If hora chegada															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !Empty(BBD->BBD_HORCMD)
	oChamadas := TcBrowse():New( 115, 002, 180, 065,,,,oDlgVis,,,,,,,,,,,, .F.,, .T.,, .F., )

	oChamadas:AddColumn(TcColumn():New(STR0191,{ || aChamadas[oChamadas:nAt,1] },nil,nil,nil,nil,027,.F.,.F.,nil,nil,nil,.F.,nil)) //"Chamada"
	oChamadas:AddColumn(TcColumn():New(STR0053	 ,{ || aChamadas[oChamadas:nAt,2] },nil,nil,nil,nil,025,.F.,.F.,nil,nil,nil,.F.,nil)) //"Hora"

	oChamadas:SetArray(aChamadas)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Activate																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlgVis Center ON INIT Eval( { || EnChoiceBar(oDlgVis,bOK,bCanc) } )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╩╠╠
╠╠╨	Inicio do bloco de funcoes que fazem criacao de arquivo de semaforo	  ╨╠╠
╠╠хммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA315ENC Ё Autor ЁGeraldo Felix JuniorЁ Data Ё 18.12.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Encaixe...                                                Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function PLSA315Enc(dData,cCodLoc,cCodOpe,oMedicos,aSalas,aHorMed,cCdAmbu,cCodCon,bAtuDados)

Local nInd               
Local nTamDlgPad
Local nH
Local cFile
Local oDlgRes
Local oSay
Local oListaUsr
Local lRet       := .F.
Local nOpca      := 0
Local nDsPer     := GETMV("MV_PLDSCAG")
Local cHorHe	 := Left(Time(),5)
Local cTitulo 	 := STR0192  //"Encaixe - Dados do Paciente"
Local aDadBBD    := {}
Local aButtons   := {}//{ {"RELATORIO"   ,{|| PLSXCADUNC() },"Cadastrar Usuario Admissional/Contrato Nao Cadastrado"} }
Local aCampos    := {}   
Local nNewCampos := 0
Local aNewCampos := {} 
Local aListaUsr  := { {"","","",0,.T.,""} }
Local bNomCre    := { || aSalas[oMedicos:nAt,3] }
Local bOK        := { || nOpca := 1, If( ( Obrigatorio(aGets,aTela) ),;
											( aMat := CriaSemEnc(cCodLoc,cCdAmbu,dData,M->BBD_HORA),;
											If( aMat[1] ,;
											  ( If( ValOKEnc( aHorMed,aSalas[oMedicos:nAt,2],cLocal,cCodEsp ) , oDlgRes:End() , (nOpca:=3,.F.) ) , nH:=aMat[2] , cFile:=aMat[3] ),;
											  (nOpca:=3,.F.) ) ),;
									    (nOpca:=3,.F.) ) }
Local bCanc      := { || nOpca := 3,oDlgRes:End() }

Private oEnc
Private aTela    := {}
Private aGets    := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Testa se existe salas...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aSalas) == 0
	Return( {.F.,""} )
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё lRefresh																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lRefresh := .F.          
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o codigo da especialidade da sala...                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCodEsp := aSalas[oMedicos:nAt,9]
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Teste de sala aberta...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(aSalas[oMedicos:nAt,2])
   Aviso(STR0193,STR0194,{STR0102}) //"Sem MИdico"###"Selecione um mИdico para agendar um horАrio de encaixe"###"&Voltar"
   Return({.F.,""})
EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta titulo do dialogo de acordo com a opcao...                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BAU->( DbSetOrder(1) )
BAU->( MsSeek(xFilial("BAU")+aSalas[oMedicos:nAt,2]) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dialogo...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aadd(aButtons,{"POSCLI",{ || A300INTGER(.T.) },STR0182,STR0183}) //"Usuarios de Outros Intercambios"###"Interc"

@ 001,001 BUTTON STR0184 SIZE 000,00 ACTION Eval({||A300INTGER(.T.)}) PIXEL  //"&Intercambio"

DEFINE MSDIALOG oDlgRes TITLE cTitulo FROM 005,005 TO 025, 055 OF GetWndDefault()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta informacoes do horario/medico selecionado...                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 020,005 Say oSay Prompt STR0185 Size 150,008 PIXEL OF oDlgRes COLOR CLR_HBLUE          //"DATA"
@ 020,040 Say oSay Prompt dtoc(dData) Size 150,008 PIXEL OF oDlgRes     
   
@ 035,005 Say oSay Prompt STR0195 Size 100,008 PIXEL OF oDlgRes COLOR CLR_HBLUE     //"MEDICO"
@ 035,040 Say oSay Prompt Eval(bNomCre) Size 100,008 PIXEL OF oDlgRes     
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados da enchoice...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aadd(aCampos,"BBD_CODPAC")
aadd(aCampos,"BBD_NOME")
aadd(aCampos,"BBD_TELEFO")
aadd(aCampos,"BBD_TIPO")                               
aadd(aCampos,"BBD_HORA")
aadd(aCampos,"BBD_MATANT")
aadd(aCampos,"BBD_OBSERV")
aadd(aCampos,"BBD_ATERNA")   
If BBD->( FieldPos("BBD_TIPPAC") ) > 0
	aadd(aCampos,"BBD_TIPPAC")     
EndIf	

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inclui novos campos na enchoice atraves do ponto de entrada PLCAMMAR     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды    
If ExistBlock("PLCAMMARC")
   aNewCampos := ExecBlock("PLCAMMARC",.F.,.F.)     
   If ValType(aNewCampos) == 'A'
      For nNewCampos :=1 To Len(aNewCampos)    
         aadd(aCampos,aNewCampos[nNewCampos]) 
         M->&(aNewCampos[nNewCampos]) := Criavar(aNewCampos[nNewCampos])
      Next
   EndIf   
EndIf	

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alimenta campos															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
M->BBD_CODPAC := Space(Len(BBD->BBD_CODPAC))
M->BBD_NOME   := Space(Len(BBD->BBD_NOME))
M->BBD_TELEFO := Space(Len(BBD->BBD_TELEFO))
M->BBD_TIPO   := "4"
M->BBD_HORA   := CriaVar("BBD_HORA")
M->BBD_MATANT := Space(Len(BBD->BBD_MATANT))     
M->BBD_DATA	  := dDatabase
M->BBD_OBSERV := Space(Len(BBD->BBD_OBSERV))     
M->BBD_CID := CriaVar("BBD_CID")
M->BBD_ATERNA := "0"
M->BBD_USUCAN := CriaVar("BBD_USUCAN")
If BBD->( FieldPos("BBD_TIPPAC") ) > 0
	M->BBD_TIPPAC := CriaVar("BBD_TIPPAC")
Endif 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta enchoice...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oEnc := BBD->(MSMGet():New("BBD",0,K_Incluir,,,,aCampos,{050,005,145,185},aCampos,,,,,oDlgRes,,,.T.))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё No caso da agenda vou alterar o valid do campo BBD_NOME...               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nInd := 1 To Len(oEnc:AENTRYCTRLS)
    If oEnc:AENTRYCTRLS[nInd]:cReadVar $ "M->BBD_TIPO,M->BBD_NOME"
    	oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
    EndIf
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o dialogo...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                                     
ACTIVATE MSDIALOG oDlgRes Center ON INIT Eval( { || nTamDlgPad := oDlgRes:nBottom, EnChoiceBar(oDlgRes,{|| IIf(!Empty(M->BBD_HORA), ( Eval(bAtuDados) , IIf( ValEnc(aHorMed),Eval(bOK),.F. ) ) , (MsgAlert(STR0196),.F.))},bCanc,.F.,aButtons) } )  //"informe a hora do encaixe!"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё inicia transacao na base se confirmado operacao..                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё VerIfica o usurario														 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BA1->(DbSetOrder(2))
	If !BA1->(MsSeek(xFilial("BA1")+M->BBD_CODPAC))
        MsgAlert('Usuario nao encontrado BA1:'+M->BBD_CODPAC)
		Return( {.F.,""} )
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё VerIfica a Familia														 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BA3->(DbSetOrder(1))
	If !BA3->( MsSeek( xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) ) )
        MsgAlert( 'Familia nao encontrada BA3:'+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) )
		Return( {.F.,""} )
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicia transacao														 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Begin Transaction
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Monta campos e seus conteudos...                                         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aadd(aDadBBD,{"BBD_CODIGO"	,BAU->BAU_CODIGO})
		aadd(aDadBBD,{"BBD_CODINT"	,cCodOpe})
		aadd(aDadBBD,{"BBD_DATA"  	,dData})
		aadd(aDadBBD,{"BBD_HORA"  	,M->BBD_HORA})
		aadd(aDadBBD,{"BBD_HORCHE"	,cHorHe})
		aadd(aDadBBD,{"BBD_STATUS"	,"1"})
		aadd(aDadBBD,{"BBD_TIPO"  	,M->BBD_TIPO})
		aadd(aDadBBD,{"BBD_ENCAIX"	,"1"})
		aadd(aDadBBD,{"BBD_PRTATD"	,"0"})
		aadd(aDadBBD,{"BBD_CODCAN"	,""})
		aadd(aDadBBD,{"BBD_HORCAN"	,""})
		aadd(aDadBBD,{"BBD_DATCAN",Ctod('')})
		aadd(aDadBBD,{"BBD_CODESP"	,cCodEsp})
		aadd(aDadBBD,{"BBD_LOCAL"	,cCodLoc}) //BB8_LOCAL  variavel cCodLoc vem do BD1_CODLOC que e = a BB8_LOCAL
		aadd(aDadBBD,{"BBD_CODLOC"	,cLocal})  //BB8_CODLOC
		
		aadd(aDadBBD,{"BBD_SIGLA" 	,BAU->BAU_SIGLCR})
		aadd(aDadBBD,{"BBD_NUMREG"	,BAU->BAU_CONREG})
		aadd(aDadBBD,{"BBD_ESTCR" 	,BAU->BAU_ESTCR})
		aadd(aDadBBD,{"BBD_CODPRF"	,BAU->(BAU_CODIGO)})
		aadd(aDadBBD,{"BBD_CODPAC"	,M->BBD_CODPAC})
		aadd(aDadBBD,{"BBD_NOME"  	,M->BBD_NOME})
		aadd(aDadBBD,{"BBD_TELEFO"	,M->BBD_TELEFO})
	    aadd(aDadBBD,{"BBD_ATERNA",M->BBD_ATERNA})
	   If BBD->( FieldPos("BBD_TIPPAC") ) > 0
			 aadd(aDadBBD,{"BBD_TIPPAC",M->BBD_TIPPAC})
	   Endif
	    aadd(aDadBBD,{"BBD_OBSERV",M->BBD_OBSERV})
		aadd(aDadBBD,{"BBD_USUOPE"	,PLRETOPE()})
		aadd(aDadBBD,{"BBD_NSALA" 	,aSalas[oMedicos:nAt][1]})
		aadd(aDadBBD,{"BBD_CODSAL"	,aSalas[oMedicos:nAt][11]})
		aadd(aDadBBD,{"BBD_CDAMBU"	,cCdAmbu})        
		
		aadd(aDadBBD,{"BBD_MATANT"	,BA1->BA1_MATANT})
		aadd(aDadBBD,{"BBD_MATVID"	,BA1->BA1_MATVID})
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava procedimento utilizado...                                          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
		aadd(aDadBBD,{"BBD_CODPAD",Left(cCodCon,2)})		
		aadd(aDadBBD,{"BBD_CODPRO",Substr(cCodCon,3,16)})
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Posiciona no contrato...                                                 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aadd(aDadBBD,{"BBD_CODEMP",BA3->BA3_CODEMP})
		aadd(aDadBBD,{"BBD_CONEMP",BA3->BA3_CONEMP})
		aadd(aDadBBD,{"BBD_VERCON",BA3->BA3_VERCON})
		aadd(aDadBBD,{"BBD_SUBCON",BA3->BA3_SUBCON})
		aadd(aDadBBD,{"BBD_VERSUB",BA3->BA3_VERSUB})
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava campos retornados pelo Ponto de Entrada PLCAMMARC                  Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды              
		If ExistBlock("PLCAMMARC",.F.,.F.)
           If ValType(aNewCampos) == 'A'
               For nNewCampos :=1 To Len(aNewCampos)    
                  aadd(aDadBBD,{aNewCampos[nNewCampos],M->&(aNewCampos[nNewCampos])})
               Next
           EndIf   
        EndIf	
		
		PLSAtuAge(aDadBBD)
		lRet := .T.
	End Transaction
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Eval(bAtuDados)  
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Controle de transacao...                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	FClose(nH)
	FErase(cFile)
EndIf          
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return({lRet,BBD->BBD_HORA})
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё CriaSemEnc Ё Autor ЁAlexander		   Ё Data Ё 15.02.06 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Cria Semaforo de Horario do Encaixe						 Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/                                     
Static Function CriaSemEnc(cCodLoc,cCdAmbu,dData,cHora)

Local nH
Local cFile 
Local lRet  := .T.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFile :="F"+cConSem+cCodLoc+cCdAmbu+DtoS(dData)+StrTran(cHora,":",'')+".SMF"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tenta criar o arquivo													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nH := FCreate(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nH == -1
   Aviso(STR0197,STR0198,{STR0102}) //"Ocupado"###"horАrio sendo utilizado por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
   lRet := .F.
EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return( {lRet,nH,cFile} )
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA315aut╨Autor  ЁGeraldo Felix Junior╨ Data Ё  12/08/03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁChama a rotina de autorizacao...                            ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLSA315Aut(aSalas, oMedicos, aHorMed, oHorarios,oTimerBRW,bAtuDados,nServ)

Local nH	
Local bSavKey01  := SetKey(02, Nil)
Local bSavKey02  := SetKey(05, Nil)
Local bSavKey03  := SetKey(16, Nil)
Local bSavKey04  := SetKey(VK_F5, Nil)
Local bSavKey05  := SetKey(VK_F9, Nil)
Local bSavKey06  := SetKey(VK_F4, Nil)
Local bSavKey07  := SetKey(VK_F6,Nil)
Local bSavKey08  := SetKey(VK_F7,Nil)
Local bSavKey09  := SetKey(VK_F8,Nil)
Local bSavKey10  := SetKey(VK_F10,Nil)
Local bSavKey11  := SetKey(VK_F11,Nil)
Local bSavKey12  := SetKey(VK_F12,Nil)
Local bSavKey13  := SetKey(1,Nil)
Local bSavKey14  := SetKey(6,Nil)
Local lAut		 := .T.
Local cFile     
Local nRecBGF    := aSalas[oMedicos:nAt,7]
Local nRecBAU    := BAU->( Recno() )
Local nRecBBD    := If( Len( aHorMed )>0 .And. Len(aHorMed[oHorarios:nAt])>0, aHorMed[oHorarios:nAt,6] , 0 )
Local cChkSem    := "F"+cConSem+AllTrim( Str(nRecBGF) )+".SMF"
Local cTipoEsp   := GetNewPar("MV_PLSTPEN","2")
Local cStatusEnc := GetNewPar("MV_PLSECST","6,4") 
Local aDados     := {}
Local cBenef
Local cRda
Local cLoc
Local cEsp  
Local aDadBt     := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica horario paciente												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
If nRecBBD == 0   
	MsgStop(STR0199) //"Nao existe paciente neste horАrio."
	lAut := .F.
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica horario paciente												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
If lAut .And. nRecBGF == 0 
	MsgStop(STR0200) //"A sala nao esta aberta."
	lAut := .F.
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se esta em alteracao 												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lAut .And. !PLSCHKSEM(cChkSem,STR0201) //"Sala sendo atualizada por outra estacao. Tente dentro de alguns segundos"
	lAut := .F.
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no Horario													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
BBD->( DbGoto(nRecBBD) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se existe																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
If lAut .And. BBD->( Eof() )
	MsgAlert( STR0202+aHorMed[oHorarios:nAt,6] ) //'Paciente nao encontrado BBD:'
	lAut := .F.
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Numero de Controle														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
If lAut .And. !BBD->BBD_STATUS $ cStatusEnc
	If cStatusEnc $ "6,4" // Se for conteudo padrao, apresenta mensagem padrao.
		MsgAlert(STR0203) //'O paciente nao esta em ConsultСrio ou atendido!'
	Else
		// Se nao, apresenta mensagem personalizada.
		nPos := Ascan(aStatus, {|x| x[1] == Alltrim(cStatusEnc)})
		cTexto := "O status atual da agenda nЦo permite realizar o encaminhamento."
		
		If nPos > 0
			cTexto := cTexto += ' Apenas o status "'+ aStatus[nPos][3] + '" permite realizar o encaminhamento.'
		EndIf
		
		MsgAlert(cTexto) 
	EndIf
	lAut := .F.
EndIf

If lAut

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Controle de transacao...                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cFile :="F"+cConSem+AllTrim( Str(nRecBBD) )+".SMF"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tenta criar o arquivo													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nH := FCreate(cFile)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nH == -1
	   Aviso(STR0197,STR0204,{STR0102}) //"Ocupado"###"HorАrio sendo atualizado por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
	   Return
	EndIf   
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no Prestador												     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
	BAU->( DbSetorder(01) )
	BAU->( MsSeek(xFilial("BAU")+aSalas[oMedicos:nAt,2]) )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Matriz aDados															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
    If ExistBlock("PL315Aut")
		ExecBlock("PL315Aut", .F., .F., {BBD->(Recno())})
	EndIf

	aadd(adados, {"SIGLA",BAU->BAU_SIGLCR}  )  
	aadd(adados, {"ESTSOL",BAU->BAU_ESTCR}  )  
	aadd(adados, {"OPESOL",BBD->BBD_CODINT}  )  
	aadd(adados, {"REGSOL",BAU->BAU_CONREG}  )  
    aadd(adados, {"NUMATE",BBD->BBD_NUMATE} )
    aadd(adados, {"TIPPAC",BBD->BBD_TIPPAC} )
    cBenef := BBD->BBD_CODPAC
    
    If GetNewPar("MV_PLSSADP","0") == "1" 
	   cRda    := BAU->BAU_CODIGO
	   cLoc    := BBD->(BBD_CODLOC+BBD_LOCAL)
	   cEsp    := BBD->BBD_CODESP
    EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё lRefresh																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
	lRefresh := .T.
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Set para Inclusao														 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
	Inclui := .T.
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Movimentacao (Sadt)														 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
	If ValType(oTimerBRW) == "O" 
	   oTimerBrw:DeActivate()
	EndIf   
	
	If nServ == 1
		PLSA090MOV("BEA",0,K_Incluir,nil,IIf(Len(aDados)>0,aDados,nil),cTipoEsp,.F.,cBenef,cRda,cLoc,cEsp,nil,nil,nil,nil,nil)
	Else
		PLSA092MOV("BE4",0,K_Incluir,cBenef)
	EndIf
		
	lRefresh := .T.
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Controle de transacao...                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	FClose(nH)
	FErase(cFile)
	If ValType(bAtuDados) == "B"
	   Pergunte("PLS315",.F.)
	   Eval(bAtuDados)
	EndIf   
	If ValType(oTimerBRW) == "O" 
	   oTimerBrw:Activate()
	EndIf   
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Restaura os setkeys 													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
SetKey(2,bSavKey01)
SetKey(5,bSavKey02)
SetKey(16,bSavKey03)
SetKey(VK_F5,bSavKey04)
SetKey(VK_F9,bSavKey05)
SetKey(VK_F4,bSavKey06)
SetKey(VK_F6,bSavKey07)
SetKey(VK_F7,bSavKey08)
SetKey(VK_F8,bSavKey09)
SetKey(VK_F10,bSavKey10)
SetKey(VK_F11,bSavKey11)
SetKey(VK_F12,bSavKey12)
SetKey(1,bSavKey13)
SetKey(6,bSavKey14)

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Limpa Filtro															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
BEA->( DbClearFilter() )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Reposiciona prestador e horario										     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды     
BAU->( DbGoto(nRecBAU) )
BBD->( DbGoto(nRecBBD) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return()
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммямммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA315ATD ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  05/15/03   ╨╠╠
╠╠лммммммммммьмммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Impressao da guia de autorizacao.                           ╨╠╠
╠╠╨          Ё                                                             ╨╠╠
╠╠лммммммммммьммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                         ╨╠╠
╠╠хммммммммммоммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PLSA315ATD(cCodLoc, cDesLoc, aHorMed, oHorarios, nRecBGF)

Local nH
Local cFile

Local nRecBBD		 := 0
Local nLin           := 80
Local titulo         := STR0205 //"Atestado Medico"
Local cChkSem  		 := ""
Local cDesc1         := STR0206 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0207 //"de acordo com os parametros informados pelo usuario."
Local cDesc3         := ""
Local Cabec1       	 := ""
Local Cabec2       	 := ""
Local aArea			 := BBD->( GetArea() )

Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 80
Private tamanho      := "P"
Private nomeprog     := STR0018 // Coloque aqui o nome do programa para impressao no cabecalho //"ATESTADO"
Private nTipo        := 18
Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey     := 0
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := STR0018 // Coloque aqui o nome do arquivo usado para impressao em disco //"ATESTADO"
Private aRet		 :={}

Default cCodLoc  	 := ''
Default cDesLoc		 := ''
Default aHorMed		 := {}
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se nao foi informado a Matriz										Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Valtype(aHorMed) == 'A' .and. Len(aHorMed) > 0
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se nao Tiver nome retorna											Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Empty(aHorMed[oHorarios:nAt,4])
		Return()
	EndIf                 
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta nome															Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cChkSem	 := "F"+cConSem+AllTrim( Str(nRecBGF) )+".SMF"
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Pega recno															Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nRecBBD := aHorMed[oHorarios:nAt,6]
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no horario												Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BBD->( DbGoto(nRecBBD) )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё VerIfica parametros													Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !ParamBox({	{2,STR0208,STR0077,{STR0077,STR0209},50,  ,.T.},;															// Tipo //"Tipo "###"Das Horas"###"Das Horas"###"Do(s) Dia(s)"
					{1,STR0210,StrTran(BBD->BBD_HORCHE,":",""),'@R 99:99','','','Alltrim(Upper(MV_PAR01)) == "DAS HORAS"',30,.T.},; 	// Hora inicial //"Hora Inicial"###"DAS HORAS"
					{1,STR0211,StrTran(BBD->BBD_HORSAI,":",""),'@R 99:99','','','Alltrim(Upper(MV_PAR01)) == "DAS HORAS"',30,.T.},; 	// Hora Final //"Hora Final  "###"DAS HORAS"
		 			{1,STR0212,1              ,'999','','','Alltrim(Upper(MV_PAR01)) <> "DAS HORAS"',25,.T.},; //"Quantidade  "###"DAS HORAS"
		 			{1,STR0213,Space(50)      ,'@!' ,'','',,60,.F.},; //"Acompanhante"
		 			{1,STR0214,Space(50)      ,'@!' ,'','',,60,.F.},; //"Empr. Acomp."
		 			{2,STR0208,STR0081,{STR0081,STR0215},50,  ,.T.}}, STR0205,@aRet,; //"Tipo "###"Atendimento"###"Atendimento"###"Comparecimento"###"Atestado Medico"
		 			NIL,NIL,NIL,NIL,NIL,NIL,NIL,.F.,.F. )
		Return
	EndIf                                 
Else     
	BGF->( DbSetOrder(4) ) //BGF_FILIAL + BGF_CODINT + BGF_CODLOJ + BGF_CODESP + BGF_DATA + BGF_STATUS
    If !BGF->( MsSeek(xFilial("BGF")+BBD->(BBD_CODINT+BBD_CODIGO+BBD_CODESP+DtoS(BBD_DATA) )+"1") ) .Or.;
       !BGF->( MsSeek(xFilial("BGF")+BBD->(BBD_CODINT+BBD_CODIGO+BBD_CODESP+DtoS(BBD_DATA) )+"9") )
	   nRecBGF := BGF->( Recno() )
	Else 
  	   MsgAlert(STR0216) //"Sala nao encontrada!"
	   Return()
	EndIf           
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё De Semaforo															Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cConSem := 'ATEND'
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta nome															Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cChkSem	 := "F"+cConSem+AllTrim( Str(nRecBGF) )+".SMF"
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Pega recno															Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nRecBBD := BBD->( Recno() )
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se foi atendido														Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If Empty(BBD->BBD_NUMATE)	
		MsgAlert(STR0217) //"Esta rotina so imprimira atestados de atendimentos encerrados!"
		Return()
	EndIf
	//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё VerIfica parametros													Ё
	//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !ParamBox({	{2,STR0208,STR0077,{STR0077,STR0209},50,  ,.T.},;				// Tipo //"Tipo "###"Das Horas"###"Das Horas"###"Do(s) Dia(s)"
			{1,STR0210,StrTran(BBD->BBD_HORCHE,":",""),'@R 99:99','','', 'Alltrim(Upper(MV_PAR01)) == "'+STR0077+'"',30,.T.},; 			// Hora inicial //"Hora Inicial"###"DAS HORAS"
 			{1,STR0211,StrTran(BBD->BBD_HORSAI,":",""),'@R 99:99','','', 'Alltrim(Upper(MV_PAR01)) == "'+STR0077+'"',30,.T.},; 	// Hora Final //"Hora Final  "###"DAS HORAS"
 			{1,STR0212,1              ,'999'  ,'','','Alltrim(Upper(MV_PAR01)) <> "'+STR0077+'"',60,.F.} }	, STR0218,@aRet ) //"Quantidade  "###"DAS HORAS"###"Atesdados Medico"

		Return()
	EndIf	
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se esta em alteracao 												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !PLSCHKSEM(cChkSem,STR0201) //"Sala sendo atualizada por outra estacao. Tente dentro de alguns segundos"
   Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFile :="F"+cConSem+AllTrim( Str(nRecBBD) )+".SMF"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tenta criar o arquivo													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nH := FCreate(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nH == -1
   Aviso(STR0197,STR0204,{STR0102}) //"Ocupado"###"HorАrio sendo atualizado por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
   Return
EndIf   
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Seta																Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
wnRel := SetPrint("BBD","PLSA315ATD","PLSATD",@titulo,cDesc1,cDesc2,cDesc3,.T.,,.T.,Tamanho,,.T.)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica esc														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nLastKey == 27
   FClose(nH)
   FErase(cFile)
   Return
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Set Default															Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SetDefault(aReturn,"BBD")
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica esc														Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nLastKey == 27
   FClose(nH)
   FErase(cFile)
   Return
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tipo													   			Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nTipo := If( aReturn[4]==1 ,15,18 )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Processamento. RPTSTATUS monta janela com a regua de processamento. Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ExistBlock("PL315IMP")
	ExecBlock("PL315IMP",.F.,.F.,{Cabec1,Cabec2,Titulo,nLin,"BBD",cCodLoc,cDesLoc,aHorMed,oHorarios})
Else
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin,"BBD",cCodLoc,cDesLoc,aHorMed,oHorarios) },Titulo)
EndIf
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Restaura Area...                                                    Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RestArea(aArea)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FClose(nH)
FErase(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA315ALT Ё Autor ЁGeraldo Felix JuniorЁ Data Ё 18.12.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Pronto atendimento... Alteracao                           Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function PLSA315APr(oPronto,aHorPro,dData,nLinMed,aSalas,bAtuDados)

Local nH
Local nCnt
Local nInd               
Local nTamDlgPad
Local cFile
Local cCodigo
Local cSigla
Local cConReg
Local cEstCr
Local oDlgRes
Local oSay
Local oComboMed
Local oComboEsp
Local lRet       := .F.
Local nOpca      := 0
Local nRecBBD 	 := 0 
Local nRecBGF    := 0
Local cTitulo 	 := STR0219  //"Pronto Atendimento - Alteracao"
Local cComboMed	 := ""
Local cComboEsp	 := ""
Local cChkSem  	 := "F"+cConSem+AllTrim( Str(nRecBGF) )+".SMF"
Local aButtons   := {}
Local aCampos    := {}   
Local aComboMed	 := {}
Local aComboEsp	 := {}
Local bEspMed 	 := { || A315EsMe(aSalas,cComboEsp,oComboMed) , A315CBOX(aSalas,cComboEsp,cComboMed) }
Local bOK        := { || nOpca := 1,If( (Obrigatorio(aGets,aTela) ),oDlgRes:End(),(nOpca:=3,.F.) ) }
Local bCanc      := { || nOpca := 3,oDlgRes:End() }
                          
Private oEnc
Private aTela      := {}
Private aGets      := {}   
                  
If Len(aHorPro) > 0
	nRecBBD := aHorPro[oPronto:nAt,5]
Else
	Return(lRet)
EndIf

If Len(aSalas) > 0
	nRecBGF := aSalas[nLinMed,7]                          
Else
	Return(lRet)
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se esta em alteracao 												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !PLSCHKSEM(cChkSem,STR0201) //"Sala sendo atualizada por outra estacao. Tente dentro de alguns segundos"
   Return(lRet)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё lRefresh																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lRefresh := .F.                     
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Codigo da Especialidade													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCodEsp := aSalas[nLinMed,9]
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Obtem os medicos e especialidades disponiveis...                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды            
If !Empty(aSalas[nLinMed,2])
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no Prestador													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды            
	BAU->(DbSetOrder(1))
	BAU->(MsSeek(xFilial("BAU")+aSalas[nLinMed,2]))
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Alimenta campos															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды            
	cCodigo 	:= BAU->BAU_CODIGO
	cSigla  	:= BAU->BAU_SIGLCR
	cConReg 	:= BAU->BAU_CONREG
	cEstCr  	:= BAU->BAU_ESTCR
	cComboMed	:= ""
	cComboEsp	:= ""
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Checagem																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды            
	For nCnt := 1 To Len(aSalas)
		If !Empty(aSalas[nCnt][2])
			nPosMed	:= Ascan(aComboMed, aSalas[nCnt][2]+" - "+aSalas[nCnt][03])
			nPosEsp	:= Ascan(aComboEsp, aSalas[nCnt][9]+" - "+aSalas[nCnt][10])
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Medico																	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды            
			If nPosMed == 0 .and. aSalas[nCnt][13] # "S" .And. ( aSalas[nCnt][9] == Left( cCodEsp, Len(BBD->BBD_CODESP) ) )
				Aadd(aComboMed, aSalas[nCnt][2]+" - "+aSalas[nCnt][03])
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Especialidade															 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды            
			If nPosEsp == 0
				Aadd(aComboEsp, aSalas[nCnt][9]+" - "+aSalas[nCnt][10])
			EndIf
		EndIf
	Next
Else
	cCodigo := ""
	cSigla  := ""
	cConReg := ""
	cEstCr  := ""
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Inclui um items em branco no combobox de especialidade e medicos         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Aadd( aComboMed, "")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona na agenda...                                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->( DbGoTo(nRecBBD) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFile :="F"+cConSem+AllTrim( Str(nRecBBD) )+".SMF"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tenta criar o arquivo													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nH := FCreate(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nH == -1
   Aviso(STR0197,STR0220,{STR0102}) //"Ocupado"###"Pronto Atendimento sendo atualizado por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
   Return(lRet)
EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o nome do medico e da especialidade                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cComboMed := aHorPro[oPronto:nAt,07]+" - "+aHorPro[oPronto:nAt,08]
cComboEsp := aHorPro[oPronto:nAt,09]+" - "+aHorPro[oPronto:nAt,10]
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialog...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlgRes TITLE cTitulo From 005,005 TO 031, 055 OF GetWndDefault()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta informacoes do horario/medico selecionado...                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 020,005 Say oSay Prompt STR0185 		Size 150,008 PIXEL OF oDlgRes COLOR CLR_HBLUE          //"DATA"
@ 020,030 Say oSay Prompt dtoc(dData) 	Size 150,008 PIXEL OF oDlgRes COLOR CLR_HRED    

@ 035,005 Say oSay Prompt STR0186 Size 100,008 PIXEL OF oDlgRes COLOR CLR_HBLUE     //"ESPEC."
@ 035,030 COMBOBOX oComboEsp  Var cComboEsp ITEMS aComboEsp ON CHANGE Eval(bEspMed) SIZE 157,010 OF oDlgRes PIXEL COLOR CLR_HBLUE

@ 050,005 Say oSay Prompt STR0039 Size 100,008 PIXEL OF oDlgRes COLOR CLR_HBLUE     //"MиDICO"
@ 050,030 COMBOBOX oComboMed  Var cComboMed ITEMS aComboMed ON CHANGE A315CBOX(aSalas,cComboEsp,cComboMed) SIZE 157,010 OF oDlgRes PIXEL 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados da enchoice...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aadd(aCampos,"BBD_TIPOPA")
aadd(aCampos,"BBD_CODPAC")
aadd(aCampos,"BBD_NOME")
aadd(aCampos,"BBD_TELEFO")
aadd(aCampos,"BBD_TIPO")                               
aadd(aCampos,"BBD_HORA")
aadd(aCampos,"BBD_MATANT")
aadd(aCampos,"BBD_CDAMBU")
aadd(aCampos,"BBD_OBSERV")
aadd(aCampos,"BBD_ATERNA")

M->BBD_ATERNA := BBD->BBD_ATERNA
M->BBD_OBSERV := BBD->BBD_OBSERV
M->BBD_PARTIC := BBD->BBD_PARTIC
M->BBD_TIPOPA := BBD->BBD_TIPOPA
M->BBD_CODPAC := BBD->BBD_CODPAC
M->BBD_NOME   := BBD->BBD_NOME
M->BBD_TELEFO := BBD->BBD_TELEFO
M->BBD_TIPO   := BBD->BBD_TIPO
M->BBD_HORA   := BBD->BBD_HORA
M->BBD_MATANT := BBD->BBD_MATANT
M->BBD_CDAMBU := BBD->BBD_CDAMBU
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta enchoice...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
RegtoMemory("BBD",.F.,.T.,.F.)
oEnc := BBD->(MSMGet():New("BBD",0,K_Alterar,,,,aCampos,{065,005,190,190},aCampos,,,,,oDlgRes,,,.T.))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Desabilito os campos que nao podem ser alterados...                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nInd := 1 To Len(oEnc:AENTRYCTRLS)
	If oEnc:AENTRYCTRLS[nInd]:cReadVar $ "M->BBD_NOME,M->BBD_CODPAC,M->BBD_TELEFO,M->BBD_TIPO,M->BBD_HORA,M->BBD_MATANT,M->BBD_CDAMBU,M->BBD_ATERNA"
	   oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
	EndIf
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa DLG																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlgRes ON INIT Eval( { || nTamDlgPad := oDlgRes:nBottom, EnChoiceBar(oDlgRes,bOK,bCanc,.F.,aButtons)}) Center
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё inicia transacao na base se confirmado operacao..                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Reosiciona			                                                     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BBD->( DbGoTo(nRecBBD) )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicia a Transacao													     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
        Begin Transaction
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Alteracao																 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BBD->( RecLock("BBD",.F.) )
			If M->BBD_TIPOPA == '0'
			   BBD->BBD_CODIGO := Left(cComboMed,Len(BAU->BAU_CODIGO))
			Else
			   BBD->BBD_CODIGO := ""
			EndIf
			BBD->BBD_CODESP := Left(cComboEsp,Len(BBD->BBD_CODESP))
			BBD->BBD_TIPOPA := M->BBD_TIPOPA
			BBD->BBD_USUOPE	:= PLRETOPE() 
		BBD->( MsUnlock() ) 
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Fim da Transacao													     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		End Transaction
		lRet := .T.
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza																 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		Eval(bAtuDados)
EndIf       
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FClose(nH)
FErase(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPLSA315Epr╨Autor  ЁGeraldo Felix Junior╨ Data Ё  19/05/03   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Encaminha o pronto atendimento para a sala selecionada.    ╨╠╠
╠╠╨          ЁLeva o primeiro da fila...                                  ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP6                                                        ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/   
Function PLSA315Epr(oMedicos,aSalas,cCodOpe,cCodLoc,cCdAmbu,dDtRec,aHorMed,aHorPro,oPronto,bAtuDados)

Local nH
Local nHC
Local nHGrv
Local nRecBBD
Local cFile
Local cFileC
Local aRet
Local nRecBGF   := aSalas[oMedicos:nAt,7]
Local aMovim	:= {.T.,Space( Len(BBD->BBD_NUMMOV) )}
Local cChkSem   := "F"+cConSem+AllTrim( Str(nRecBGF) )+".SMF"
Local cInterc   := GetNewPar("MV_PLSGEIN","0050")
Local cTime	    := ""
Local cTimeOld  := ""                     
Local cPLSMCGG  := GetNewPar("MV_PLSMCGG","1")
Local cStatusPA := GetNewPar("MV_PLSSAPA","6")
Private cMedico := ''
Private cEspeci	:= ''
Private nAt		:= 0
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Valida sala virtual e a existencia de pacientes na sila do PA...         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды               
If Len(aHorPro) == 0 .Or. aSalas[oMedicos:nAt,13] == 'S'
   Return(.F.)
EndIf	        
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Valida se a sala esta em pause...                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If aSalas[oMedicos:nAt,14]
   MsgInfo(STR0221) //"Nao e possivel encaminhar pacientes a esta sala porque ela esta em PAUSA!"
   Return(.F.)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o primeiro paciente da fila de acordo com a prioridade...           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !A315SelPac(aHorPro, aSalas, oMedicos )
   Return(.F.)
EndIf        
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se esta em alteracao 												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !PLSCHKSEM(cChkSem,STR0201) //"Sala sendo atualizada por outra estacao. Tente dentro de alguns segundos"
   Return(.F.)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Apresenta janela com o paciente que sera encaminhado para a sala...      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !A315MOSTRA( BAU->BAU_NOME, aSalas[oMedicos:nAt][1]+" - "+aSalas[oMedicos:nAt][10],aHorPro, aSalas, oMedicos, cCodOpe, cCodLoc )
	Return(.F.)
EndIf 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o registro															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nRecBBD := BBD->( Recno() )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFile :="F"+cConSem+AllTrim( Str(nRecBBD) )+".SMF"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tenta criar o arquivo													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nH := FCreate(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nH == -1
   Aviso(STR0197,STR0222,{STR0102}) //"Ocupado"###"Pronto Atendimento sendo usado por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
   Return(.F.)
EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Quando for usuario de intercambio eventual, pede para alterar dados cadastrais...|
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If BBD->BBD_CODEMP == cInterc
	BA1->( DbSetorder(02) )
	If !BA1->( MsSeek(xFilial("BA1")+BBD->BBD_CODPAC) )
	   MsgAlert(STR0135+BBD->BBD_CODPAC) //'Usuario nao encontrado BA1:'
	   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё Controle de transacao...                                                 Ё
	   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   FClose(nH)
	   FErase(cFile)
	   Return(.F.)
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё alterar dados cadastrais...														 |
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !PL315ALTIE(.F.,BBD->BBD_CODPAC)
	   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё Controle de transacao...                                                 Ё
	   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   FClose(nH)
	   FErase(cFile)
	   Return(.F.)
	EndIf
EndIf                   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Cria o Semaforo															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aRet := PLSACSATE(aHorMed)
If aRet[1]
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Arquivo Semaforo															Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   nHC    := aRet[2]
   cFileC := aRet[3]
Else
	FClose(nH)
	FErase(cFile)
    Return(.F.)   
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Reposiciona																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->( DbGoto(nRecBBD) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Para checar os Horarios que estao no brw								 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cTime := Left(Time(),5)                 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё WHILE																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While .T.
  If cTime >= "23:59"
 	 MsgAlert(STR0114) //"HorАrio invalido!"
     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
     //Ё Controle de transacao...                                                 Ё
     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
     FClose(nH)
     FErase(cFile)
	 Return(.F.)		
  EndIf
  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  //Ё Se nao existir o horario												   Ё
  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
  nPos := Ascan(aHorMed, {|x| AllTrim(x[2]) == AllTrim(cTime)} )	
  If nPos == 0
  	 Exit
  EndIf
  cTime := PlsSomaHor(cTime,"00:01") 
EndDo 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Abre o semaforo...                                                               |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды			
nHGrv := PLSAbreSem("SEMNUMATE.SMF")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza a consulta com dados referente ao atendimento...                        |
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Begin Transaction
	BBD->( RecLock("BBD", .F.) )
		BBD->BBD_CODIGO		:= aSalas[oMedicos:nAt][02]
		BBD->BBD_CODESP		:= aSalas[oMedicos:nAt][09]
		If Empty(BBD->BBD_NUMATE)
			BBD->BBD_NUMATE 	:= GetSx8Num("BBD","BBD_NUMATE")
		EndIf
		BBD->BBD_NUMMOV     := Space( Len(BBD->BBD_NUMMOV) )
		BBD->BBD_NSALA  	:= aSalas[oMedicos:nAt][01]
		BBD->BBD_CODSAL 	:= aSalas[oMedicos:nAt][11]
		BBD->BBD_CDAMBU 	:= cCdAmbu	
		BBD->BBD_SIGLA  	:= BAU->BAU_SIGLCR
		BBD->BBD_ESTCR  	:= BAU->BAU_ESTCR
		BBD->BBD_NUMREG 	:= BAU->BAU_CONREG
		BBD->BBD_CODPRF		:= BAU->BAU_CODBB0
	  	BBD->BBD_HORA		:= cTime
		BBD->BBD_HORENT		:= cTime
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Para garantir a integridade do Local de atendimento...                           |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If BBD->BBD_CODLOC <> cLocal
			BB8->( DbSetorder(03) )
			If BB8->( MsSeek(xFilial("BB8")+BBD->BBD_CODIGO+BBD->BBD_CODINT+BBD->BBD_LOCAL) )
				BBD->BBD_CODLOC := BB8->BB8_CODLOC
			EndIf
		EndIf	
		BBD->BBD_USUOPE	:= PLRETOPE() 
	BBD->( MsUnlock() )                 
	End Transaction
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Quando encaminha o paciente para o consultorio, grava a movimentacao...  Ё
	//Ё Quando for um PA para execucao de Procedimentos ou de Revisao, o sistema |
	//Ё nao podera gerar guia de consulta. Consultas ou encaixes...              |
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If BBD->BBD_TIPO $ '1,4'
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Gera Guia																 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If cPLSMCGG == "1" 
		   aMovim := 	PLSMOVMC( BBD->( Recno() )	,"1"	,BBD->BBD_CODPAD,BBD->BBD_CODPRO,nil,BBD->BBD_CODLOC,BBD->BBD_CODESP )
		Else
		   aMovim := {}
		EndIf   

		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava os dados referente a guia gerada no contas medicas...              |
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If cPLSMCGG <> "1" .Or. (Len(aMovim)>=1 .And. aMovim[1])
			Begin Transaction
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Muda o paciente que estiver em consultorio para atendido				 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If ( ! ExistBlock("PLS315EA") ) .Or. (ExecBlock("PLS315EA",.F.,.F.,{"PA"}))
			   PLSACOLATE(aHorMed)
			EndIf   
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Reposiciona																 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BBD->( DbGoto(nRecBBD) )
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Atualiza a consulta com os dados da guia...                                      |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BBD->( RecLock("BBD", .F.) )
				BBD->BBD_STATUS	:= cStatusPA
				If cPLSMCGG == "1" .And. Len(aMovim) >= 2
				   BBD->BBD_NUMMOV	:= aMovim[2]
				EndIf   
		   		BBD->BBD_HORENT := Left(Time(),5)
				BBD->BBD_CODCAN	:= ''
				BBD->BBD_HORCAN	:= ''
				   BBD->BBD_DATCAN := Ctod('')
	
				BBD->BBD_USUOPE	:= PLRETOPE() 
			BBD->( MsUnlock() )	
			End Transaction
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Confirma o semaforo do SX8()										     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды       
			BBD->( ConfirmSx8() )                                              
		Else
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Alteracao																 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Begin Transaction
			BBD->(RecLock("BBD", .F.))
				BBD->BBD_NUMATE := Space( Len(BBD->BBD_NUMATE) )
				BBD->BBD_USUOPE	:= PLRETOPE() 
			BBD->(MsUnlock())
			End Transaction
		EndIf           
    EndIf
                    
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha o semaforo...                                                              |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды						
PLSFechaSem(nHGrv,"SEMNUMATE.SMF")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se houver criticas na geracao da guia, mostra elas para o operador...    |
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aMovim) > 0 .And. Len(aMovim[2]) == 1 
	MsgAlert(aCriMovi[Val(aMovim[2])])
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se gerou movimento														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If (cPLSMCGG == "1" .And. !aMovim[1])
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Controle de transacao...                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	FClose(nH)
	FErase(cFile)
	If !Empty(cFileC)
		FClose(nHC)
		FErase(cFileC)
	EndIf	
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fim da Rotina...                                                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Return(.F.)               
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa possivel horario duplicado										 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cTimeOld := cTime
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё WHILE																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While .T.
  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
  //Ё Se nao existir o horario												   Ё
  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
  nPos := Ascan(aHorMed, {|x| AllTrim(x[2]) == AllTrim(cTime) .And. x[6] <> nRecBBD  } )	
  If nPos == 0
  	 Exit
  EndIf
  cTime := PlsSomaHor(cTime,"00:01") 
EndDo 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё se for dIferente acerta a base											 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cTime <> cTimeOld
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Reposiciona																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BBD->( DbGoto(nRecBBD) )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Altera																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BBD->( RecLock("BBD", .F.) )
		BBD->BBD_HORA := cTime			
	BBD->( MsUnlock() )
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё ATUALIZA																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Eval(bAtuDados)
	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FClose(nH)
FErase(cFile)
If !Empty(cFileC)
	FClose(nHC)
	FErase(cFileC)
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Imprissao de guias somente para consultas ou encaixes...                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->( DbGoto(nRecBBD) )
If BBD->BBD_TIPO $ '1,4'
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Imprime a guia do atendimento...                                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If BBD->BBD_CODEMP == cInterc
		If Aviso(STR0223,STR0224,{STR0140,STR0139}) == 1 //"Impressao"###"Imprimir a guia agora ?"###"Sim"###"Nao"
		   PLSA090Ima()
		EndIf
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(.T.)               
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSACSATE  Ё Autor ЁAlexander		   Ё Data Ё 18.12.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Cria semaforo											 Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSACSATE(aHorMed)

Local nH
Local nPos
Local nRecBBD

Local lRet  := .T.
Local cFile := ""
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o horario em consultorio e coloca como atendido					 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nPos := Ascan( aHorMed, {|x| x[7] == "6"} )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se achou																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nPos > 0
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё recno																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nRecBBD := aHorMed[nPos,6]
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no horario que estava em consultorio							 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BBD->( DbGoto(nRecBBD) )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inconsistencia															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If BBD->( Eof() )
	   Return(lRet,nH,cFile)
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Controle de transacao...                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cFile :="F"+cConSem+AllTrim( Str(nRecBBD) )+".SMF"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tenta criar o arquivo													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nH := FCreate(cFile)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nH == -1
	   Aviso(STR0197,STR0204,{STR0102}) //"Ocupado"###"HorАrio sendo atualizado por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
	   lRet := .F.
	EndIf   
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return( {lRet,nH,cFile} )
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSACOLATE Ё Autor ЁAlexander		   Ё Data Ё 18.12.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Coloca como atendido										 Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSACOLATE(aHorMed)

Local nPos
Local nRecBBD
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o horario em consultorio e coloca como atendido					 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nPos := Ascan( aHorMed, {|x| x[7] == "6"} )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica se achou														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nPos > 0
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё recno																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nRecBBD := aHorMed[nPos,6]
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no horario que estava em consultorio							 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BBD->( DbGoto(nRecBBD) )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inconsistencia															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If BBD->( Eof() )
		Return
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicia a Transacao													     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//	Begin Transaction
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Alteracao																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BBD->( RecLock("BBD", .F.) )
	BBD->BBD_STATUS := '4'
	BBD->BBD_CODCAN	:= ''
	BBD->BBD_HORCAN	:= ''
	BBD->BBD_DATCAN := Ctod('') 
	BBD->BBD_USUCAN	:= ""
	BBD->BBD_HORSAI := Left(Time(),5)
	BBD->( MsUnlock() )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Fim da Transacao													     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(.T.)
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA315PSM Ё Autor ЁGeraldo Felix JuniorЁ Data Ё 18.12.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Selecao de medico Pronto Atendimento                      Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA315PSM(oMedicos,aSalas,cCodOpe,cDesOpe,cCodLoc,cDesLoc,cCdAmbu,cDsAmbu,bAtuDados,oPronto,aHorPro)

Local nH
Local nLinBrw      
Local cFile
Local oDlg
Local oBrwMed     
Local nInd    := 0
Local nOpca   := 0             
Local nRecBBD := aHorPro[oPronto:nAt,1]
Local nRecBGF := aSalas[oMedicos:nAt,7]
Local cChkSem := "F"+cConSem+AllTrim( Str(nRecBGF) )+".SMF"
Local cTitulo := STR0225 //"Selecao de MИdico - Pronto Atendimento"
Local aMedAux := {}
Local bOK     := {|| nLinBrw := oBrwMed:nAt, nOpca := 1,oDlg:End() }
Local bCancel := {|| nOpca := 0,oDlg:End() }
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se esta em alteracao 												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !PLSCHKSEM(cChkSem,STR0201) //"Sala sendo atualizada por outra estacao. Tente dentro de alguns segundos"
   Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta vetor que ira ser vinculado ao browse de selecao...                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nInd := 1 To Len(aSalas)
    If !Empty(aSalas[nInd,2])
       aadd(aMedAux,aSalas[nInd])
    EndIf   
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza dados...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->( DbGoTo(nRecBBD) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFile :="F"+cConSem+AllTrim( Str(nRecBBD) )+".SMF"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tenta criar o arquivo													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nH := FCreate(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nH == -1
   Aviso(STR0197,STR0226,{STR0102}) //"Ocupado"###"HorАrio sendo usado por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
   Return
EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlg TITLE cTitulo FROM 010,010 TO 030,060 Pixel 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta says informativos...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 020,005 Say oSay Prompt STR0227 Size 150,008 PIXEL OF oDlg COLOR CLR_HBLUE          //"OPERADORA"
@ 020,047 Say oSay Prompt cCodOpe+" - "+cDesOpe Size 150,008 PIXEL OF oDlg
   
@ 035,005 Say oSay Prompt STR0228 Size 150,008 PIXEL OF oDlg COLOR CLR_HBLUE     //"LocalIDADE"
@ 035,047 Say oSay Prompt cCodLoc+" - "+cDesLoc Size 150,008 PIXEL OF oDlg        
   
@ 050,005 Say oSay Prompt STR0229 Size 100,008 PIXEL OF oDlg COLOR CLR_HBLUE     //"AMBULATсRIO"
@ 050,047 Say oSay Prompt cCdAmbu+" - "+cDsAmbu+STR0230+aSalas[oMedicos:nAt,1] Size 100,008 PIXEL OF oDlg      //" - SALA "
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta browse...                                                          Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 065,005 Say oSay Prompt STR0231 Size 100,008 PIXEL OF oDlg //"Selecione um dos mИdicos abaixo..."
oBrwMed := TcBrowse():New( 072, 005, 184	, 070,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )

oBrwMed:AddColumn(TcColumn():New(STR0039,{ || aMedAux[oBrwMed:nAt,3]},nil,nil,nil,nil,015,.F.,.F.,nil,nil,nil,.F.,nil))      //"MИdico"
oBrwMed:BLDBLCLICK := bOK
oBrwMed:SetArray(aMedAux)         
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o dialogo...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlg ON INIT Eval({|| EnchoiceBar(oDlg,bOK,bCancel,.F.,{}) }) CENTER
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Confirmacao da operacao...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK
	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  //Ё Reosiciona			                                                     Ё
	  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	  BBD->( DbGoTo(nRecBBD) )
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Posiciona no Prestado...                                                 Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      BAU->(DbSetOrder(1))
      BAU->(MsSeek(xFilial("BAU")+aMedAux[nLinBrw,2]) )
	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  //Ё Inicia a Transacao													     Ё
	  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	  Begin Transaction
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Altera...                                                 			   Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      BBD->( RecLock("BBD",.F.) )
	      BBD->BBD_CODIGO := aMedAux[nLinBrw,2]
	      BBD->BBD_CODESP := aMedAux[nLinBrw,9]
	      BBD->BBD_LOCAL  := cCodLoc
	      BBD->BBD_SIGLA  := BAU->BAU_SIGLCR
	      BBD->BBD_ESTCR  := BAU->BAU_ESTCR
	      BBD->BBD_NUMREG := BAU->BAU_CONREG
	      BBD->BBD_CODPRF := BAU->BAU_CODBB0
 		  BBD->BBD_USUOPE := PLRETOPE() 
      BBD->(MsUnLock())
	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
 	  //Ё Fim da Transacao													     Ё
	  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
  	  End Transaction
      //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
      //Ё Atualiza tela															   Ё
      //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      Eval(bAtuDados)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FClose(nH)
FErase(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA315LES Ё Autor ЁAlexander		   Ё Data Ё 01.02.06 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Lista de Espera Inclui Altera							 Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function PLSA315LES(nRecBBD,dData,cCodLoc,cCodOpe,oMedicos,aSalas,cCdAmbu,cCodCon,aHorEsp,aHorMed,bAtuDados)

Local nH
Local nInd               
Local nTamDlgPad
Local nOpcEnc
Local cFile
Local oSay
Local oDlgRes
Local oListaUsr
Local cHorSem	 := Left(Time(),5)
Local lRet       := .F.
Local nOpca      := 0                
Local nRecBGF	 := aSalas[oMedicos:nAt,7]
Local nDsPer     := GETMV("MV_PLDSCAG")
Local cChkSem    := "F"+cConSem+AllTrim( Str(nRecBGF) )+".SMF"
Local cTitulo	 := STR0232  //"Lista de Espera - Dados do Paciente"
Local cHorHe	 := Left(Time(),5)
Local cCodMed    := aSalas[oMedicos:nAt,2] 
Local aDadBBD    := {}        
Local aButtons   := {} 
Local aCampos    := {}   
Local aListaUsr  := { {"","","",0,.T.,""} }
Local bNomCre    := { || aSalas[oMedicos:nAt,3] }
Local bOK        := { || nOpca := 1,;
							If( ( Obrigatorio(aGets,aTela) ),;
							    If( nRecBBD==0,;
						    		( Eval(bAtuDados) , If( ValOKLis(aHorEsp,aSalas,aHorMed,aSalas[oMedicos:nAt,2],cLocal,aSalas[oMedicos:nAt,9]) , oDlgRes:End() , ( nOpca:=3 , .F. ) ) ),;
						        oDlgRes:End() ),;
							( nOpca:=3 , .F. ) ) }
Local bCanc      := { || nOpca := 3 , oDlgRes:End() }

Private oEnc
Private aTela    := {}
Private aGets    := {}   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no registro caso seja alteracao								 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nRecBBD > 0
   BBD->( DbGoTo(nRecBBD) )
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Testa se existe salas...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aSalas) == 0
	Return(lRet)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё lRefresh															     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
lRefresh := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o codigo da especialidade da sala...                                Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cCodEsp := aSalas[oMedicos:nAt,9]
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Teste de sala aberta...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cCodMed)
   Aviso(STR0193,STR0194,{STR0102}) //"Sem MИdico"###"Selecione um mИdico para agendar um horАrio de encaixe"###"&Voltar"
   Return(lRet)
EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se esta em alteracao 												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !PLSCHKSEM(cChkSem,STR0201) //"Sala sendo atualizada por outra estacao. Tente dentro de alguns segundos"
   Return(lRet)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona na Prestador												     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BAU->( DbSetOrder(1) )
BAU->( MsSeek( xFilial("BAU")+cCodMed ) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nRecBBD > 0
	cFile :="F"+cConSem+AllTrim( Str(nRecBBD) )+".SMF"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tenta criar o arquivo													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nH := FCreate(cFile)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nH == -1
	   Aviso(STR0197,STR0233,{STR0102}) //"Ocupado"###"Lista de Espera sendo atualizada por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
	   Return(lRet)
	EndIf   
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dialogo...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aadd(aButtons,{"POSCLI",{ || A300INTGER(.T.) },STR0182, STR0183}) //"Usuarios de Outros Intercambios"###"Interc"
@ 001,001 BUTTON STR0184 SIZE 000,00 ACTION Eval({||A300INTGER(.T.)}) PIXEL  //"&Intercambio"

DEFINE MSDIALOG oDlgRes TITLE cTitulo FROM 005,005 TO 023,055 OF GetWndDefault()
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta informacoes do horario/medico selecionado...                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 020,005 Say oSay Prompt STR0185 Size 150,008 PIXEL OF oDlgRes COLOR CLR_HBLUE          //"DATA"
@ 020,040 Say oSay Prompt dtoc(dData) Size 150,008 PIXEL OF oDlgRes     
   
@ 035,005 Say oSay Prompt STR0039 Size 100,008 PIXEL OF oDlgRes COLOR CLR_HBLUE     //"MиDICO"
@ 035,040 Say oSay Prompt Eval(bNomCre) Size 100,008 PIXEL OF oDlgRes     
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados da enchoice...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aadd(aCampos,"BBD_CODPAC")
aadd(aCampos,"BBD_NOME")
aadd(aCampos,"BBD_TELEFO")
aadd(aCampos,"BBD_TIPO")                               
aadd(aCampos,"BBD_MATANT")
aadd(aCampos,"BBD_OBSERV")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Coloca na lista de espera												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nRecBBD > 0
   aadd(aCampos,"BBD_HORA")
EndIf                

aadd(aCampos,"BBD_ATERNA")

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta tela																 | 
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

RegtoMemory("BBD",.F.,.T.,.F.)

If nRecBBD == 0		//Inclusao
   M->BBD_CODPAC	:= Space(Len(BBD->BBD_CODPAC))
   M->BBD_NOME		:= Space(Len(BBD->BBD_NOME))
   M->BBD_TELEFO	:= Space(Len(BBD->BBD_TELEFO))
   M->BBD_MATANT	:= Space(Len(BBD->BBD_MATANT))     
   M->BBD_OBSERV 	:= Space(Len(BBD->BBD_OBSERV))
   M->BBD_DATA		:= dDatabase
   M->BBD_TIPO 		:= "4"
   M->BBD_ATERNA := "0"
Else 				//Alteracao
   M->BBD_CODPAC	:= BBD->BBD_CODPAC
   M->BBD_NOME		:= BBD->BBD_NOME
   M->BBD_TELEFO	:= BBD->BBD_TELEFO
   M->BBD_HORA   	:= CriaVar("BBD_HORA")
   M->BBD_MATANT	:= BBD->BBD_MATANT
   M->BBD_DATA		:= BBD->BBD_DATA
   M->BBD_OBSERV 	:= BBD->BBD_OBSERV
   M->BBD_ATERNA := BBD->BBD_ATERNA
		M->BBD_CID := BBD->BBD_CID
   M->BBD_TIPO 		:= BBD->BBD_TIPO
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta enchoice...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oEnc := BBD->( MSMGet():New("BBD",0,K_Incluir,,,,aCampos,{050,005,132,155},aCampos,,,,,oDlgRes,,,.T.) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё No caso da agenda vou alterar o valid do campo BBD_NOME...               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nInd := 1 To Len(oEnc:AENTRYCTRLS)
	If nRecBBD > 0
	    If oEnc:AENTRYCTRLS[nInd]:cReadVar $ "M->BBD_CODPAC,M->BBD_TELEFO,M->BBD_MATANT,M->BBD_NOME"
	    	oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
	    EndIf
	   If oEnc:AENTRYCTRLS[nInd]:cReadVar == "M->BBD_ATERNA"
	   	  oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
	   EndIf
	Else
	    If oEnc:AENTRYCTRLS[nInd]:cReadVar $ "M->BBD_MATANT,M->BBD_NOME"
	    	oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
	    EndIf
    EndIf
Next
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o dialogo...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                                     
ACTIVATE MSDIALOG oDlgRes Center ON INIT Eval( { || nTamDlgPad := oDlgRes:nBottom, EnChoiceBar(oDlgRes,{|| IIf( nRecBBD > 0 , IIf( !Empty(M->BBD_HORA) , ( Eval(bAtuDados) , IIf(ValEnc(aHorMed),Eval(bOK),.F.) ) , ( MsgAlert(STR0234) , .F. ) ),Eval(bOK) ) },bCanc,.F.,aButtons) } )  //"Informe um horАrio!"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё inicia transacao na base se confirmado operacao..                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё RepoVerIfica o usurario														 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nRecBBD > 0
	   BBD->( DbGoTo(nRecBBD) )
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё VerIfica o usurario														 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BA1->(DbSetOrder(2))
	If !BA1->(MsSeek(xFilial("BA1")+M->BBD_CODPAC))
        MsgAlert('Usuario nao encontrado BA1:'+M->BBD_CODPAC)
        If nRecBBD > 0
		   FClose(nH)
		   FErase(cFile)
		EndIf	
		Return(lRet)
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё VerIfica a Familia														 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BA3->(DbSetOrder(1))
	If !BA3->( MsSeek( xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) ) )
        MsgAlert( 'Familia nao encontrada BA3:'+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) )
        If nRecBBD > 0
		   FClose(nH)
		   FErase(cFile)
		EndIf	
		Return(lRet)
	EndIf 
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Inicia a Transacao																 |
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды			
	Begin Transaction
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Monta campos e seus conteudos...                                         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nRecBBD == 0
			aadd(aDadBBD,{"BBD_CODIGO"	,BAU->BAU_CODIGO})
			aadd(aDadBBD,{"BBD_CODINT"	,cCodOpe})
			aadd(aDadBBD,{"BBD_DATA"  	,dData})
			aadd(aDadBBD,{"BBD_HORA"  	,CriaVar("BBD_HORA")})
			aadd(aDadBBD,{"BBD_HORCHE"	,cHorHe})
			aadd(aDadBBD,{"BBD_STATUS"	,"2"}) //Lista de Espera
			aadd(aDadBBD,{"BBD_TIPO"  	,M->BBD_TIPO})
			aadd(aDadBBD,{"BBD_ENCAIX"	,"0"})
			aadd(aDadBBD,{"BBD_PRTATD"	,"1"})
			aadd(aDadBBD,{"BBD_CODCAN"	,""})
			aadd(aDadBBD,{"BBD_HORCAN"	,""})
			aadd(aDadBBD,{"BBD_DATCAN",Ctod('')})
			aadd(aDadBBD,{"BBD_CODESP"	,cCodEsp})
			aadd(aDadBBD,{"BBD_LOCAL"	,cCodLoc}) //BB8_LOCAL  variavel cCodLoc vem do BD1_CODLOC que e = a BB8_LOCAL
			aadd(aDadBBD,{"BBD_CODLOC"	,cLocal}) //BB8_CODLOC
			aadd(aDadBBD,{"BBD_SIGLA" 	,BAU->BAU_SIGLCR})
			aadd(aDadBBD,{"BBD_NUMREG"	,BAU->BAU_CONREG})
			aadd(aDadBBD,{"BBD_ESTCR" 	,BAU->BAU_ESTCR})
			aadd(aDadBBD,{"BBD_CODPRF"	,BAU->(BAU_CODIGO)})
			aadd(aDadBBD,{"BBD_CODPAC"	,M->BBD_CODPAC})
			aadd(aDadBBD,{"BBD_NOME"  	,M->BBD_NOME})
			aadd(aDadBBD,{"BBD_TELEFO"	,M->BBD_TELEFO})
		    aadd(aDadBBD,{"BBD_ATERNA",M->BBD_ATERNA})
		    aadd(aDadBBD,{"BBD_OBSERV"  ,M->BBD_OBSERV})
			aadd(aDadBBD,{"BBD_USUOPE"	,PLRETOPE()})
			aadd(aDadBBD,{"BBD_NSALA" 	,aSalas[oMedicos:nAt][1]})
			aadd(aDadBBD,{"BBD_CODSAL"	,aSalas[oMedicos:nAt][11]})
			aadd(aDadBBD,{"BBD_CDAMBU"	,cCdAmbu})        
			aadd(aDadBBD,{"BBD_MATANT"	,BA1->BA1_MATANT})
			aadd(aDadBBD,{"BBD_MATVID"	,BA1->BA1_MATVID})
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Grava procedimento utilizado...                                          Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды		
			aadd(aDadBBD,{"BBD_CODPAD",Left(cCodCon,2)})		
			aadd(aDadBBD,{"BBD_CODPRO",Substr(cCodCon,3,16)})

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Posiciona no contrato...                                                 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aadd(aDadBBD,{"BBD_CODEMP",BA3->BA3_CODEMP})
			aadd(aDadBBD,{"BBD_CONEMP",BA3->BA3_CONEMP})
			aadd(aDadBBD,{"BBD_VERCON",BA3->BA3_VERCON})
			aadd(aDadBBD,{"BBD_SUBCON",BA3->BA3_SUBCON})
			aadd(aDadBBD,{"BBD_VERSUB",BA3->BA3_VERSUB})
			PLSAtuAge(aDadBBD)
		Else 
			BBD->( RecLock("BBD",.F.) )
				BBD->BBD_HORA    := M->BBD_HORA
				BBD->BBD_STATUS  := "1"
				BBD->BBD_ENCAIX  := "1"
				BBD->BBD_PRTATD  := "0"  
				BBD->BBD_CODCAN	:= ""
				BBD->BBD_HORCAN	:= ""
			    BBD->BBD_DATCAN := Ctod('')
				BBD->BBD_USUCAN	:= ""
				BBD->BBD_USUOPE	 := PLRETOPE() 
		        BBD->BBD_OBSERV  := M->BBD_OBSERV
			BBD->( MsUnlock() ) 
		EndIf	
		lRet := .T.
	End Transaction
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Eval(bAtuDados)
EndIf          
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nRecBBD > 0
   FClose(nH)
   FErase(cFile)
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё ValOKLis   Ё Autor ЁAlexander		   Ё Data Ё 15.02.06 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Valida ok do Lista de espera                              Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/                    
Static Function ValOKLis(aMat,aMatSal,aMatHor,cComMed,cLocal,cCodEsp)

Local lRet := .F.
Local aRet := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica no horarios													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aMatHor) > 0
   lRet := VerIfBrw(aMatHor,3,7,M->BBD_CODPAC,STR0187) //"Paciente ja agendado"
Else
   lRet := .T.
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica no lista espera												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lRet
	If Len(aMat) > 0
	   lRet := VerIfBrw(aMat,2,5,M->BBD_CODPAC,STR0235) //"Ja existe este paciente na lista de espera"
	Else 
	   lRet := .T.
	EndIf	            
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Validacao																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lRet
    If A315CBOX( aMatSal,cCodEsp,cComMed )
 	   aRet := PLSA300CAR( M->BBD_CODPAC , M->BBD_ATERNA,cComMed,cLocal,cCodEsp )
 	   lRet := IIf( ValType(aRet[1]) == 'L', aRet[1], .F.)
	Else
       lRet := .F.
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA315SMD Ё Autor ЁGeraldo Felix JuniorЁ Data Ё 18.12.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Abertura e fechamento de salas...                         Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PLSA315SMd(oMedicos,aSalas,aMedicos,cCodOpe,cDesOpe,cCodLoc,cDesLoc,cCdAmbu,cDsAmbu,bAtuDados,dDtRec,aHorMed)

Local nH
Local nHME
Local nCnt
Local nLin
Local nRecBGF
Local nRecBBD       
Local cFile                
Local cFileME
Local cChkSem
Local cNumSal
Local cMedico
Local cEspeci
Local cTitulo 		
Local cSQL
Local oDlg
Local oBrwMed         
Local oFont
Local oGet1
Local oSay
Local oGrupo
Local lSalaVirtual 	:= .F.
Local lMediVirtual	:= .F.
Local lVirtualFlag	:= .F.              
Local lRet			:= .T.
Local lCancela		:= .F.
Local lCons 		:= .F.
Local nOpca   		:= 0             
Local nInd    		:= 0
Local nAux    		:= 0           
Local nLinSel       := 0                 
Local nIncre		:= 0
Local nLi			:= 0	
Local nEsp			:= 0
Local nAge			:= 0
Local nLinBrw 		:= oMedicos:nAt
Local nLiberaMed 	:= 0
Local cSala			:= ''
Local cStatus 		:= ''
Local cMotBlo		:= ''
Local aMedAux 		:= {}
Local aButtons 		:= {}	
Local aMat			:= {}
Local bOK     		:= { || If( Empty( aSalas[nLinBrw,2] ), nLinSel:=oBrwMed:nAt , Nil ) , nOpca:=1 , oDlg:End()  }
Local bCancel 		:= { || nOpca:=0 , oDlg:End() }
	   
Private cDesBlo		:= Space(len(BTJ->BTJ_DESCRI))
Private oGet2

DEFINE FONT oFont NAME STR0236 SIZE 0, -13 BOLD //"Arial"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Verfica sala															 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	                         
If Len(aSalas) == 0
   MsgStop(STR0237) //"Nao existe sala disponivel neste Local de atendimento. VerIfique o cadastro de Local de atendimento"
   Return
EndIf        
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza as variaveis...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	                         
cStatus := If( Empty(aSalas[nLinBrw,2]),"0","1" )
cTitulo := If( Empty(aSalas[nLinBrw,2]),STR0238,STR0239 ) //"Abertura de Sala"###"Fechamento de Sala"
cMotBlo	:= Space( Len(BTJ->BTJ_CODIGO) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pega o numero da sala,medico e especialidade						     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cNumSal := aSalas[nLinBrw,1]
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se esta aberta e vai fechar												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	                         
If cStatus == "1" 
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Pego o registro															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	                         
	nRecBGF := aSalas[nLinBrw,7]                  
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciono na sala														 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	                         
	BGF->( DbGoTo(nRecBGF) )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Controle de transacao...                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cFile := "F"+cConSem+AllTrim( Str(nRecBGF) )+".SMF" 
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tenta criar o arquivo													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nH := FCreate(cFile)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nH == -1      
	   Aviso(STR0197,STR0201,{STR0102}) //"Ocupado"###"Sala sendo atualizada por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
	   Return
	EndIf   
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se e sala virtual														 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If aSalas[nLinBrw,13] == "S"
		Aviso(STR0240, STR0241+; //"Sala Virtual!"###"Para efetivar a abertura de uma sala virtual, pressione < CTRL + F > sobre uma sala "
								STR0242,{STR0102}) //"vazia e selecione o mИdico desejado!"###"&Voltar"
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Controle de transacao...                                                 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		FClose(nH)
		FErase(cFile)
		Return
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё VerIfica a existencia de agendas abertas...                              Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	For nLin := 1 To Len(aHorMed)
		If !Empty(aHorMed[nLin,4])
			If aHorMed[nLin,7] == "1" //Agendado
				lRet     := .F.
				nAge	 ++
			ElseIf aHorMed[nLin,7] == "5" //Espera
				lRet     := .F.
				nEsp	 ++
			ElseIf aHorMed[nLin,7] == "6" //Consultorio, nao deixa fechar!
				lCons := .T.
				Exit
			EndIf
		EndIf
	Next

	If ExistBlock("PLS315SL")
	   aRetPto := ExecBlock("PLS315SL",.F.,.F.,{lCons,aHorMed,lRet})
	   lCons   := aRetPto[1]                                       
	   lRet    := aRetPto[2]
	EndIf   
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Nao permite fechar a sala com antendimento em aberto...                  Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lCons
		MsgInfo(STR0243) //"Existe um paciente em ConsultСrio! Finalize o atendimento para depois fechar a sala!"
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Controle de transacao...                                                 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		FClose(nH)
		FErase(cFile)
		Return
	EndIf				
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Msg																		 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !lRet                    
		cTxt := STR0244 //"Existe(m) "
		If nAge > 0
			cTxt += Alltrim(Str(nAge))+STR0245 //" agenda(s) em aberto "
		EndIf
		If nEsp > 0
			If nAge > 0
				cTxt += STR0246 //" e "
			EndIf
			cTxt += Alltrim(Str(nEsp))+STR0247 //" paciente(s) ja em espera "
		EndIf
		cTxt += STR0248 //"! Deseja cancelar estes registros "
		lCancela := MsgYesNo(cTxt)
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define dialogo...                                                        Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 010,010 TO 030,70 
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tamanho da tela															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nLi 	:= 35
	nIncre 	:= 15
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta says informativos...                                               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !lRet .and. lCancela
       @ 017, 003 GROUP oGrupo TO 060, 236 PIXEL OF oDlg COLOR CLR_HRED       
		@ nLi, 030 Say oSay Prompt STR0249 Size 200,008 PIXEL OF oDlg COLOR CLR_HRED FONT oFont //"EXISTE PELO MENOS UMA AGENDA EM ABERTO!!"
		
		nLi += 10
		@ nLi+3,005 Say oSay Prompt STR0250 Size 200,008  PIXEL OF oDlg COLOR CLR_HBLUE //"Motivo :"
		@ nLi  ,030 MSGet oGet1 VAR cMotBlo F3 "BY8PLS"	Valid A315SmdVal(cMotBlo)  	SIZE 040,010 PIXEL OF oDlg
		@ nLi  ,075 MSGet oGet2 VAR cDesBlo 			SIZE 160,010 PIXEL OF oDlg		
		
	    nLi += 20
	EndIf
	
	@ nLi, 003 GROUP oGrupo TO (nLi+75), 236 PIXEL OF oDlg COLOR CLR_HRED       		     
	nLi += 05
	
	@ nLi,005 Say oSay Prompt STR0227 Size 150,008 PIXEL OF oDlg COLOR CLR_HBLUE //"OPERADORA"
	@ nLi,061 Say oSay Prompt cCodOpe+" - "+cDesOpe Size 150,008 PIXEL OF oDlg
	     
	nLi += nIncre
	@ nLi,005 Say oSay Prompt STR0228 Size 150,008 PIXEL OF oDlg COLOR CLR_HBLUE //"LocalIDADE"
	@ nLi,061 Say oSay Prompt cCodLoc+" - "+cDesLoc Size 150,008 PIXEL OF oDlg
	     
	nLi += nIncre
	@ nLi,005 Say oSay Prompt STR0229 Size 100,008 PIXEL OF oDlg COLOR CLR_HBLUE //"AMBULATсRIO"
	@ nLi,061 Say oSay Prompt cCdAmbu+" - "+cDsAmbu+STR0230+aSalas[oMedicos:nAt,1] Size 100,008 PIXEL OF oDlg //" - SALA "
	     
	nLi += nIncre
	@ nLi,005 Say oSay Prompt STR0251 Size 100,008 PIXEL OF oDlg COLOR CLR_HBLUE //"MиDICO     "
	@ nLi,061 Say oSay Prompt  aSalas[nLinBrw,3] Size 100,008 PIXEL OF oDlg
	     
	nLi += nIncre
	@ nLi,005 Say oSay Prompt STR0252 Size 100,008 PIXEL OF oDlg COLOR CLR_HBLUE //"HORаRIO ABERTURA"
	@ nLi,061 Say oSay Prompt  aSalas[nLinBrw,8] Size 100,008 PIXEL OF oDlg
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Ativa o dialogo...                                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	ACTIVATE MSDIALOG oDlg ON INIT Eval({|| EnchoiceBar(oDlg,{||IIf(!lRet .AND. lCancela,IIf(Empty(cMotBlo),;
														 MsgStop(STR0253),Eval(bOK)),Eval(bOk))},bCancel,.F.,{}) }) CENTER   //"Informe o codigo do bloqueio"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se esta Fechada e vai Abrir												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	                         
ElseIf cStatus == "0"
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Controle de transacao...                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	cFile := "F"+cConSem+cCodLoc+cCdAmbu+AllTrim( cNumSal )+".SMF" 
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Tenta criar o arquivo													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	nH := FCreate(cFile)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If nH == -1      
	   Aviso(STR0197,STR0254,{STR0102}) //"Ocupado"###"Sala sendo aberta por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
	   Return
	EndIf   
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Selecion area															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
    DbSelectArea("BBD")
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Botao para abertura de sala virtual.                                     Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aadd(aButtons,{"PESQUISA"	,{|| PL315PSMED(aMedAux, oBrwMed) },STR0255, STR0256} ) //"Localizar MИdico - <CTLR + L>"###"Localizar"
	SetKey(12,{|a,b| PL315PSMED(aMedAux, oBrwMed) }) // Localiza medico
	
	aadd(aButtons,{"BMPINCLUIR"	,{||(Eval(bOk),lSalaVirtual:=.T.)} ,STR0257,STR0258} ) //"Nova Sala Virtual - <CTRL + N>"###"Sala Virt"
	aadd(aButtons,{"BMPGROUP"	,{||(IIf(PlsVirVal(aSalas),(Eval(bOk),lMediVirtual:=.T.),NIL))},STR0259,STR0260} ) //"Novo mИdico Virtual - <CTRL + M>"###"Med. Virt"
    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta vetor que ira ser vinculado ao browse de selecao...                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	For nInd := 1 To Len(aMedicos)
       lFlag        := .T.
	   lVirtualFlag := .F.
	   lMediVirtual := .F.
	   For nAux := 1 To Len(aSalas)
	       If aMedicos[nInd,1] == aSalas[nAux,2] .and. aSalas[nAux,13] # 'S'
		   	  lFlag := .F.
			  Exit
		   ElseIf aMedicos[nInd,1] == aSalas[nAux,2] .and. aSalas[nAux,13] == 'S'
				lMediVirtual := IIf(Empty(aSalas[nAux,8]),.T.,.F.)
				lVirtualFlag := .T.
				nRecVirtual	 := aSalas[nAux,7]
				Exit
		   EndIf
	   Next
	   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё SIX																	    Ё
 	   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   SIX->( DbSetOrder(01) )
	   If SIX->( MsSeek("BGF4") )
	        BGF->( DbSetOrder(4) ) //BGF_FILIAL + BGF_CODINT + BGF_CODLOJ + BGF_CODESP + BGF_DATA + BGF_STATUS
	        If !BGF->( MsSeek(xFilial("BGF")+cCodOpe+aMedicos[nInd,1]+aMedicos[nInd,4]+dtos(dDtRec)+"1") ) .Or.;
		       !BGF->( MsSeek(xFilial("BGF")+cCodOpe+aMedicos[nInd,1]+aMedicos[nInd,4]+dtos(dDtRec)+"9") )
				If lFlag
					aadd(aMedAux,aMedicos[nInd])
					aadd(aMedAux[Len(aMedAux)],IIf(lVirtualFlag .or. lMediVirtual, "S", ""))
					aadd(aMedAux[Len(aMedAux)],IIf(lVirtualFlag .or. lmediVirtual, nRecVirtual, 0))
					aadd(aMedAux[Len(aMedAux)],lmediVirtual)
				EndIf
			EndIf	
	   Else
			If lFlag
				aadd(aMedAux,aMedicos[nInd])
				aadd(aMedAux[Len(aMedAux)],IIf(lVirtualFlag .or. lMediVirtual, "S", ""))
				aadd(aMedAux[Len(aMedAux)],IIf(lVirtualFlag .or. lmediVirtual, nRecVirtual, 0))
				aadd(aMedAux[Len(aMedAux)],lmediVirtual)
			EndIf
	   EndIf
	Next
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Redefine variaveis... daqui pra frente so poderao ser atualizadas pelo botao da  |
	//Ё enchoicebar caso seja precionado algum botao para sala ou medico virtual...      |	
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   	lVirtualFlag := .F.
   	lMediVirtual := .F.

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Define dialogo...            										     |
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 005,005 TO 025,083 
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta says informativos...                                               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	@ 015,005 Say oSay Prompt STR0227 Size 150,008 PIXEL OF oDlg COLOR CLR_HBLUE //"OPERADORA"
	@ 015,047 Say oSay Prompt cCodOpe+" - "+cDesOpe Size 150,008 PIXEL OF oDlg
	
	@ 030,005 Say oSay Prompt STR0261 Size 150,008 PIXEL OF oDlg COLOR CLR_HBLUE //"Local    "
	@ 030,047 Say oSay Prompt cCodLoc+" - "+cDesLoc Size 150,008 PIXEL OF oDlg
	
	@ 040,005 Say oSay Prompt STR0229 Size 100,008 PIXEL OF oDlg COLOR CLR_HBLUE //"AMBULATсRIO"
	@ 040,047 Say oSay Prompt cCdAmbu+" - "+cDsAmbu+STR0230+aSalas[oMedicos:nAt,1] Size 100,008 PIXEL OF oDlg //" - SALA "
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta browse...                                                          Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	@ 065,005 Say oSay Prompt STR0231 Size 100,008 PIXEL OF oDlg //"Selecione um dos mИdicos abaixo..."
	oBrwMed := TcBrowse():New( 072, 005, 300, 070,,,, oDlg,,,,,,,,,,,, .F.,, .T.,, .F., )
	
/*	
	ADD COLUMN TO oBrwMed BITMAP DATA { || IIf(aMedAux[oBrwMed:nAt,8]=='S',IIf(aMedAux[oBrwMed:nAt,10],"BR_AMARELO","BR_VERDE"),"BR_CINZA") } TITLE "" WIDTH 015 NOHILITE
*/

oBrwMed:AddColumn(TcColumn():New(" ",{ || IIf(aMedAux[oBrwMed:nAt,8]=='S',IIf(aMedAux[oBrwMed:nAt,10],"BR_AMARELO","BR_VERDE"),"BR_CINZA") },;
         nil,nil,nil,nil,015,.T.,.T.,nil,nil,nil,.T.,nil))
	
	oBrwMed:AddColumn(TcColumn():New(STR0039			,{ || aMedAux[oBrwMed:nAt,2]},nil,nil,nil,nil,105,.F.,.F.,nil,nil,nil,.F.,nil)) //"MИdico"
	oBrwMed:AddColumn(TcColumn():New(STR0040	,{ || aMedAux[oBrwMed:nAt,4]},nil,nil,nil,nil,035,.F.,.F.,nil,nil,nil,.F.,nil)) //"Especialidade"
	oBrwMed:AddColumn(TcColumn():New(STR0262		,{ || aMedAux[oBrwMed:nAt,5]},nil,nil,nil,nil,075,.F.,.F.,nil,nil,nil,.F.,nil)) //"Descricao"
	oBrwMed:BLDBLCLICK := bOK
	oBrwMed:SetArray(aMedAux)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Ativa o dialogo...                                                       Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	ACTIVATE MSDIALOG oDlg ON INIT (Eval({|| EnchoiceBar(oDlg,bOK,bCancel,.F.,aButtons)}), oBrwMed:SetFocus()) Center
EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Confirmacao da operacao...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Vai ser fechada															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If cStatus == "1"
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Reposiciono o registro													 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BGF->( DbGoTo(nRecBGF) )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Se for cancelamento deve checar se tem algum usuario usando a agenda     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		For nCnt := 1 To Len(aHorMed)
			If (aHorMed[nCnt,7] == "1" .Or. aHorMed[nCnt,7] == "5" .Or. aHorMed[nCnt,7] == "6" )
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Pega o registro															 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nRecBBD := aHorMed[nCnt,6]
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Checa Semaforo															 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cChkSem := "F"+cConSem+AllTrim( Str(nRecBBD) )+".SMF"
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Checa se esta em alteracao 												 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If !PLSCHKSEM(cChkSem,STR0226) //"HorАrio sendo usado por outra estacao. Tente dentro de alguns segundos"
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Controle de transacao... 												Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					FClose(nH)
					FErase(cFile)
					Return
				EndIf
			EndIf
		Next

	    If ExistBlock("PLS315ES")
	       aRetPto := ExecBlock("PLS315ES",.F.,.F.,{aHorMed,lCancela})
	       aHorMed := aRetPto[1]
	    EndIf   
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Inicia transacao														 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		Begin Transaction
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Poe falta agendas abertas no fechamento da sala.                         Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lCancela
			For nCnt := 1 To Len(aHorMed)
				If (aHorMed[nCnt,7] == "1" .Or. aHorMed[nCnt,7] == "5" .Or. aHorMed[nCnt,7] == "6" )
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Pega o registro															 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					nRecBBD := aHorMed[nCnt,6]
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Posiciona Horario														 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					BBD->( DbGoto(nRecBBD) )
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Alteracao																 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					BBD->( RecLock("BBD",.F.) )
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Trata o fechamento das salas...                                          Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If aHorMed[nCnt,7] <> "6"
						BBD->BBD_STATUS	:= '8'
						BBD->BBD_CODCAN	:= cMotBlo
						BBD->BBD_HORCAN	:= Left(Time(),5)
						BBD->BBD_DATCAN := Date()
						BBD->BBD_USUCAN	:= PlRetOpe()
						BBD->BBD_CDAMBU	:= cCdAmbu
						BBD->BBD_NSALA 	:= aSalas[oMedicos:nAt,1]
						BBD->BBD_CODSAL	:= aSalas[oMedicos:nAt,11]
					Else
						BBD->BBD_HORSAI	:= Time()
						BBD->BBD_STATUS	:= '4'
						BBD->BBD_CODCAN	:= ''
						BBD->BBD_HORCAN	:= ''
						BBD->BBD_DATCAN := Ctod('') 
						BBD->BBD_USUCAN	:= ""
						nLiberaMed  	:= nCnt
					EndIf
					BBD->BBD_USUOPE	:= PLRETOPE()
					BBD->( MsUnlock() )
				EndIf
			Next
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Grava no arquivo de HISTORICO DE SALAS ABERTAS/FECHADAS...               Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		BGF->(RecLock("BGF",.F.))
		BGF->BGF_FILIAL := xFilial("BGF")
		BGF->BGF_HORFIN := Time()
		BGF->BGF_STATUS := "0" //Fechada
		BGF->(MsUnLock())
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza dados nas matrizes padroes...                                   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aSalas[oMedicos:nAt,2] := ""
		aSalas[oMedicos:nAt,3] := ""
		aSalas[oMedicos:nAt,7] := 0
		aSalas[oMedicos:nAt,8] := ""
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Fim da Transacao														 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		End Transaction
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualizacao para o caso de ABERTURA DE SALAS...                          Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	ElseIf cStatus == "0"
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Pega o numero da sala,medico e especialidade						     Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Len(aMedAux) > 0
			cMedico := aMedAux[nLinSel,1]
			cEspeci := aMedAux[nLinSel,4]
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Controle de transacao...                                                 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			cFileME := "F"+cConSem+cCodLoc+cCdAmbu+cMedico+cEspeci+".SMF"
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Tenta criar o arquivo													 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nHME := FCreate(cFileME)
		EndIf
		
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If nHME == -1
			Aviso(STR0197,STR0263,{STR0102}) //"Ocupado"###"Local,AmbulatСrio e mИdico sendo utilizado na abertura de sala por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Controle de transacao... para Local+ambulatorio+numerodasala			 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			FClose(nH)
			FErase(cFile)
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Controle de transacao... para Local+ambulatorio+medico+especialidade	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			FClose(nHME)
			FErase(cFileME)
			Return
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё VerIfica																 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If Empty(aSalas[nLinBrw,2])
			
			If Len(aMedAux) == 0
				MsgInfo(STR0264) //"Nao ha mИdicos na lista. A janela sera fechada!"
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Controle de transacao... para Local+ambulatorio+numerodasala			 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				FClose(nH)
				FErase(cFile)
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Controle de transacao... para Local+ambulatorio+medico+especialidade	 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If Type("nHME") # "U"
					FClose(nHME)                              
				EndIf
				If Type("cFileME") # "U"
					FErase(cFileME)
				EndIf
				Return
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Checa se ja existe  medico em alguma sala							 	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If SIX->( MsSeek("BGF4") )
				BGF->( DbSetOrder(4) ) //BGF_FILIAL + BGF_CODINT + BGF_CODLOJ + BGF_CODESP + BGF_DATA + BGF_STATUS
				If lSalaVirtual .or. lMediVirtual
					If BGF->( MsSeek(xFilial("BGF")+cCodOpe+cMedico+cEspeci+DtoS(dDtRec)+"9") )
						If cCodLoc == BGF->BGF_CODLOC
							Aviso(STR0002,STR0265,{STR0102}) //"Recepcao"###"MИdico e especialidade ja esta em uma sala virtual"###"&Voltar"
							lRet := .F.
						EndIf
					EndIf
				Else
					If BGF->( MsSeek(xFilial("BGF")+cCodOpe+cMedico+cEspeci+DtoS(dDtRec)+"1") )
						If cCodLoc == BGF->BGF_CODLOC
							Aviso(STR0002,STR0266,{STR0102}) //"Recepcao"###"MИdico e especialidade ja esta em uma sala"###"&Voltar"
							lRet := .F.
						EndIf
					EndIf
				EndIf
				If !lRet		
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Atualiza																 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					Eval(bAtuDados)
	
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Controle de transacao... para Local+ambulatorio+numerodasala			 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					FClose(nH)
					FErase(cFile)
	
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Controle de transacao... para Local+ambulatorio+medico+especialidade	 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					FClose(nHME)
					FErase(cFileME)
					Return
				EndIf
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Inicia transacao														 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Begin Transaction
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё VerIfica se e sala virtual												 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If aMedAux[nLinSel,8] # "S"
				If lSalaVirtual .or. lMediVirtual
					cSala := StrZero((Len(aSalas)+1),2)
					If lMediVirtual
						cHoraVitual := Time()
					EndIf
				Else
					cSala := aSalas[oMedicos:nAt,1]
				EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Grava no arquivo de HISTORICO DE SALAS ABERTAS/FECHADAS...               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BGF->(RecLock("BGF",.T.))
				BGF->BGF_CODIGO := BGF->(GetSx8Num("BGF","BGF_CODIGO"))
				BGF->BGF_FILIAL := xFilial("BGF")
				BGF->BGF_CODINT := cCodOpe
				BGF->BGF_CODLOC := cCodLoc
				BGF->BGF_CODLCL := aMedAux[nLinSel,7]
				BGF->BGF_CDAMBU := cCdAmbu
				BGF->BGF_NSALA  := cSala
				BGF->BGF_DATA   := dDtRec
				BGF->BGF_HORINI := IIf(lSalaVirtual .and. !lMediVirtual,"", Time())
				BGF->BGF_HORFIN := "24:00"
				BGF->BGF_CODLOJ := aMedAux[nLinSel,1]
				BGF->BGF_CODESP := aMedAux[nLinSel,4]
				BGF->BGF_STATUS := IIf(lSalaVirtual .or. lMediVirtual,"9", "1") //  Virtual ou Aberta
				BGF->BGF_VIRTUA := IIf(lSalaVirtual .or. lMediVirtual,"S", "N")
				BGF->(MsUnLock())
				BGF->(ConfirmSX8())
			Else
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza o RECNO														 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				nRecBGF := aMedAux[nLinSel,9]
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Reposiciona																 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BGF->( DbGoto(nRecBGF) )
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Altera																	 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BGF->( RecLock("BGF", .F.) )
				BGF->BGF_NSALA		:= aSalas[oMedicos:nAt,1]
				BGF->BGF_HORINI  	:= Time()
				BGF->BGF_STATUS		:= '1'
				BGF->BGF_VIRTUA		:= 'N'
				BGF->( MsUnlock() )
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Fim da Transacao														 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			End Transaction
		EndIf
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Atualiza dados nas matrizes padroes...                                   Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		aSalas[oMedicos:nAt,2] := aMedAux[nLinSel,1]
		aSalas[oMedicos:nAt,3] := aMedAux[nLinSel,2]
		aSalas[oMedicos:nAt,7] := BGF->( Recno() )
		aSalas[oMedicos:nAt,8] := BGF->BGF_HORINI
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Pega o codigo da especialidade da sala...                                Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		cCodEsp := aMedAux[nLinSel,4]
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Controle de transacao... para Local+ambulatorio+medico+especialidade 	 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		FClose(nHME)
		FErase(cFileME)
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Eval(bAtuDados)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao... 												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FClose(nH)
FErase(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Set KEY																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
SET KEY 12 TO
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return                  
             
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  PLS315Pause╨Autor  ЁGeraldo Felix Junior╨ Data Ё  10/06/04   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁBotoes com a finalidade de dar um pausa no atendimento de   ╨╠╠
╠╠╨          Ёuma sala.                                                   ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function PLS315Pause(oMedicos,aSalas,bAtuDados,lDireto,dDtRec,aHorMed)

Local nH
Local nRecBBD	
Local cFile		    
Local oDlg

Local nRecBGF	:= aSalas[oMedicos:nAt,7] //Recno da Sala

Local cChkSem 	:= "F"+cConSem+AllTrim( Str(nRecBGF) )+".SMF" 
Local cObs 		:= ''
Local lEncerra 	:= .F.

Default lDireto := .F.
Default aHorMed := {}
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Testa se ha medico na sala ou se eh uma sala virtual...                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды    
If (aSalas[oMedicos:nAt,13] == 'S' .or. Empty(aSalas[oMedicos:nAt,2]))
	Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona o BGF...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                            
BGF->( DbGoto(nRecBGF) )                   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se esta em alteracao 												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !PLSCHKSEM(cChkSem,STR0267) //"Sala sendo atualizado por outra estacao. Tente dentro de alguns segundos"
   Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao sala...                                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFile := "F"+cConSem+AllTrim( Str(nRecBGF) )+".SMF"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tenta criar o arquivo													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nH := FCreate(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nH == -1
   Aviso(STR0197,STR0268,{STR0102}) //"Ocupado"###"(Pausa) Sala sendo atualizada por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
   Return
EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se vai colocar a sala em pausa											 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !aSalas[oMedicos:nAt,14] // Por a sala em pausa
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё So sera permitido 3 pausas...                                            Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If !Empty(BGF->BGF_PSAIN1) .and. !Empty(BGF->BGF_PSAIN2) .and. !Empty(BGF->BGF_PSAIN3)
		MsgAlert(STR0269) //"Exedido limite de PAUSAS por dia para este mИdico!"
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Controle de transacao...                                                 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		FClose(nH)
		FErase(cFile)
		Return
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё O Medico esta atentendo...                                               Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If aSalas[oMedicos:nAt,6]
		If !MsgYesNo(STR0270)			 //"O mИdico esta em atendimento! Confirma a PAUSA e o encerramento do atendimento?"
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Controle de transacao...                                                 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			FClose(nH)
			FErase(cFile)
			Return
		EndIf
		lEncerra := .T.
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Pergunta padrao...                                                       Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	ElseIf !MsgYesNo(STR0271) //"Confirme a PAUSA no atendimento da sala!"
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Controle de transacao...                                                 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		FClose(nH)
		FErase(cFile)
		Return
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Pede texto explicativo...                                                Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды	
	DEFINE MSDIALOG oDlg TITLE STR0272 FROM 005,005 TO 19, 055 //"Observacoes"
    
	@ 016,003 GROUP oGrupo TO 104, 180 PIXEL OF oDlg LABEL STR0273  COLOR CLR_HBLUE, CLR_HRED        //" Observacoes da Pausa "
	@ 024,006 GET oObs  VAR cObs MEMO SIZE 170,075 OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg Center ON INIT Eval({||EnChoiceBar(oDlg,{||oDlg:End()},{||oDlg:End()}, .F.)} )

	Begin Transaction
		BGS->( RecLock("BGF",.F.) )
			If Empty(BGF->BGF_PSAIN1)			
				BGF->BGF_PSAIN1 := Left(Time(),5)
				BGF->BGF_OBS1	:= Padr( cObs, TamSX3("BGF_OBS1")[1] ) //primeira observacao
			ElseIf Empty(BGF->BGF_PSAIN2)
				BGF->BGF_PSAIN2 := Left(Time(),5)
				BGF->BGF_OBS2	:= Padr( cObs, TamSX3("BGF_OBS2")[1] ) //segunda observacao
			Else
				BGF->BGF_PSAIN3 := Left(Time(),5)
				BGF->BGF_OBS3	:= Padr( cObs, TamSX3("BGF_OBS3")[1] ) //terceira observacao
			EndIf
		BGS->( MsUnlock() )
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Caso tenha que encerrar o atendimento atual...                           Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		If lEncerra
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Localiza o paciente na agenda...                                         Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nPos 	:= Ascan(aHorMed, {|x| x[7] == "6"})
			nRecBBD := aHorMed[nPos,6]
			If nPos # 0
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Posiciona no Horario													 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				BBD->( DbGoto(nRecBBD) )
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Atualiza o registro com status de atentimento concluido...               Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If !BBD->(Eof())
					BBD->( RecLock("BBD", .F.) )
						BBD->BBD_STATUS := '4'
						BBD->BBD_HORSAI := Left(Time(),5)
						BBD->BBD_CODCAN	:= ''
						BBD->BBD_HORCAN	:= ''
					    BBD->BBD_DATCAN := Ctod('')
						BBD->BBD_USUCAN	:= ""
						BBD->BBD_USUOPE	:= PLRETOPE() 
					BBD->( MsUnlock() )
				EndIf
			EndIf
		EndIf
	End Transaction
Else
	If lDireto .Or. MsgYesNo(STR0274) //"Finalizar a PAUSA ?"
		Begin Transaction
			BGS->( RecLock("BGF",.F.) )
				If Empty(BGF->BGF_PSAFN1)			
					BGF->BGF_PSAFN1 := Left(Time(),5)
				ElseIf Empty(BGF->BGF_PSAFN2)
					BGF->BGF_PSAFN2 := Left(Time(),5)
				Else
					BGF->BGF_PSAFN3 := Left(Time(),5)
				EndIf          				
			BGS->( MsUnlock() )
		End Transaction
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza os dados da janela...                                           Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Eval(bAtuDados)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Libera transacao...                                                      Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FClose(nH)
FErase(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁA315SelPac  ╨Autor  ЁGeraldo Felix Junior╨ Data Ё  10/12/03   ╨╠╠
╠╠лммммммммммьммммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁEncontra o primeiro paciente da fila para ser encaminha ao    ╨╠╠
╠╠╨          Ёpronto atendiemento.                                          ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                           ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/  
Function A315SelPac(aHorPro, aSalas, oMedicos, lAtualiza, oSay1, oSay2, oSay3 )

Local nCnt
Local nH
Local cFile
Local nRecBBD	  := 0
Local nRecBGF	  := aSalas[oMedicos:nAt,7]
Local cChkSem  	  := "F"+cConSem+AllTrim( Str(nRecBGF) )+".SMF"
Local lControl    := .F.
Default lAtualiza := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se esta em alteracao 												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !PLSCHKSEM(cChkSem,STR0267) //"Sala sendo atualizado por outra estacao. Tente dentro de alguns segundos"
   Return(.F.)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё While																	 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
While .T.
	For nCnt := 1 To Len(aHorPro)
		If 	aHorPro[nCnt][9] == aSalas[oMedicos:nAt,9] .and. nCnt > nAt
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Alimenta variavel														 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			nRecBBD	 := aHorPro[nCnt][1]
			cCodEsp	 := aHorPro[nCnt][9]
			nAt		 := nCnt    
			lControl := .T.
		    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		    //Ё Posiciona no Horario													 Ё
		    //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	        BBD->( DbGoto(nRecBBD) )    
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Checagem																 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If !Empty(aHorPro[nCnt][7])
				If aHorPro[nCnt][7] == aSalas[oMedicos:nAt][2]				
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Alimenta Medico															 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					cMedico  := aHorPro[nCnt][7]
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Checa agenda															 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If Len(aHorPro[nCnt]) >= 14
					   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					   //Ё Alteracao																Ё
					   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					   If lAtualiza	
						  If !BBD->( Eof() )
						     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						     //Ё Controle de transacao...                                                 Ё
						     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						     cFile := "F"+cConSem+AllTrim( Str(nRecBBD) )+".SMF"
					         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						     //Ё Tenta criar o arquivo													 Ё
						     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						     nH := FCreate(cFile)
						     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						     //Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
						     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						     If nH == -1
						        Aviso(STR0197,STR0222,{STR0102}) //"Ocupado"###"Pronto Atendimento sendo usado por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
						        Return(.F.)
						     EndIf   
							 //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							 //Ё Inicia a Transacao													     Ё
							 //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							 Begin Transaction
						     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						     //Ё Alteracao																  Ё
						     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							 BBD->( RecLock("BBD", .F.) ) 
								aHorPro[nCnt, 14]	++
								BBD->BBD_CHAMAD 	++
								BBD->BBD_HORCMD 	+= Left(Time(),5)+','
							 BBD->( MsUnlock() )	
							 //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
							 //Ё Fim da Transacao													     Ё
							 //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
							 End Transaction
					         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						     //Ё Controle de transacao...                                                 Ё
						     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						     FClose(nH)
						     FErase(cFile)							 
						  EndIf
					   EndIf
					EndIf
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Sai do while															 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					Exit
				EndIf
			Else
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Alimenta Medico															 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				cMedico  := aSalas[oMedicos:nAt][2]
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Checa agenda															 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If Len(aHorPro[nCnt]) >= 14
				   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				   //Ё Alteracao																Ё
				   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				   If lAtualiza	
					  If !BBD->( Eof() )
					     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					     //Ё Controle de transacao...                                                 Ё
					     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					     cFile :="F"+cConSem+AllTrim( Str(nRecBBD) )+".SMF"
				         //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					     //Ё Tenta criar o arquivo													 Ё
					     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					     nH := FCreate(cFile)
					     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					     //Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
					     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					     If nH == -1
					        Aviso(STR0197,STR0222,{STR0102}) //"Ocupado"###"Pronto Atendimento sendo usado por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
					        Return(.F.)
					     EndIf   
						 //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						 //Ё Inicia a Transacao													     Ё
						 //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						 Begin Transaction
					     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					     //Ё Alteracao																  Ё
					     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					  	 BBD->( RecLock("BBD", .F.) ) 
							aHorPro[nCnt, 14]	++
							BBD->BBD_CHAMAD 	++
							BBD->BBD_HORCMD 	:= Alltrim(BBD->BBD_HORCMD)+Left(Time(),5)+','
						 BBD->( MsUnlock() )                                                  
					     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
						 //Ё Fim da Transacao													     Ё
						 //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
						 End Transaction
					     //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					     //Ё Controle de transacao...                                                 Ё
					     //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					     FClose(nH)
					     FErase(cFile)
					  EndIf
				   EndIf
				EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Sai do while															 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				Exit
			EndIf
		EndIf
	Next
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Controle																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lControl
		Exit
	ElseIf lAtualiza
		nAt := 0
	Else
		Exit
	EndIf
Enddo
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona Agenda														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nRecBBD > 0
   BBD->( DbGoto(nRecBBD) )
EndIf	
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checagem																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !lControl .Or. BBD->( Eof() ) 
	MsgInfo(STR0275) //"Nao foi encontrado nenhum paciente que possa ser encaminhado a esse mИdico ou a essa especialidade."
	Return(.F.)	
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona Prestador														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BAU->(DbSetOrder(1))
BAU->(MsSeek(xFilial("BAU")+aSalas[oMedicos:nAt,2]))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lAtualiza .And. Type("oSay1") == "O" .And. Type("oSay2") == "O" .And. Type("oSay3") == "O"
	oSay1:Refresh()
	oSay2:Refresh()
	oSay3:Refresh()
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(.T.)
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PL315ALTIE Ё Autor ЁGeraldo Felix JuniorЁ Data Ё 18.12.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Altera dados cadastrais		                             Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function PL315ALTIE(lPergunta, cMatric)

Local nH
Local nInd
Local cFile
Local cCodEmp
Local oDlgRes
Local oEnc
Local lRet       := .F.
Local nOpca      := 0
Local cConSem    := "ATEND"
Local cInterc  	 := GetNewPar("MV_PLSGEIN","0050")
Local cTitulo    := STR0276 //"Manutencao de intercambio eventual"
Local aCampos    := {}   
Local bOK        := { || nOpca := 1,If( ( Obrigatorio(aGets,aTela) .And. A315IEVLD() ),(oDlgRes:End(),lRet:=.T.),(nOpca:=3,lRet:=.F.))}
Local bCanc      := { || nOpca := 3,(oDlgRes:End(), lRet:=.F.) }

Private aGets    := {}
Private aTela    := {}

Default lPergunta := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё lRefresh																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                        
lRefresh := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                        
If lPergunta
	cCodEmp := Substr(cMatric,4,4)
	If cCodEmp == cInterc
		If !MsgYesNo(STR0277) //"Deseja alterar dados do usuario de intercambio ?"
			Return(.T.)
		EndIf
	Else
		Return(.T.)
	EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFile := "F"+cConSem+AllTrim( cMatric )+".SMF"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tenta criar o arquivo													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nH := FCreate(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nH == -1
   Aviso(STR0197,STR0278,{STR0102}) //"Ocupado"###"Usuario sendo atualizado por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
   Return(lRet)
EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlgRes TITLE cTitulo FROM 005,005 TO 025, 055
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados da enchoice...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aadd(aCampos,"BA1_MATANT")
aadd(aCampos,"BA1_NOMUSR")
aadd(aCampos,"BA1_DATNAS")
aadd(aCampos,"BA1_TIPUSU")
aadd(aCampos,"BA1_GRAUPA")
aadd(aCampos,"BA1_DRGUSR")
aadd(aCampos,"BA1_CPFUSR")      
aadd(aCampos,"BA1_CODPLA")
aadd(aCampos,"BA1_DESPLA")
aadd(aCampos,"BA1_VERSAO")
aadd(aCampos,"BA1_NOMTIT")

RegtoMemory("BA1",.F.,.T.,.F.)

M->BA1_MATANT := BA1->BA1_MATANT
M->BA1_NOMUSR := BA1->BA1_NOMUSR
M->BA1_DATNAS := BA1->BA1_DATNAS
M->BA1_TIPUSU := BA1->BA1_TIPUSU
M->BA1_GRAUPA := BA1->BA1_GRAUPA
M->BA1_DRGUSR := BA1->BA1_DRGUSR
M->BA1_CPFUSR := BA1->BA1_CPFUSR
M->BA1_CODPLA := BA1->BA1_CODPLA
M->BA1_VERSAO := BA1->BA1_VERSAO
M->BA1_NOMTIT := BA1->BA1_NOMTIT
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta enchoice...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

oEnc := BA1->(MSMGet():New("BA1",0,K_Alterar,,,,aCampos,{020,005,140,182},aCampos,,,,,oDlgRes,,,.T.))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё No caso da agenda vou alterar o valid do campo BBD_NOME...               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DbSelectArea("BA1")

For nInd := 1 To Len(oEnc:AENTRYCTRLS)
    oEnc:AENTRYCTRLS[nInd]:BWHEN  := { || .T. }
    oEnc:AENTRYCTRLS[nInd]:BVALID := { || .T. }
    If oEnc:AENTRYCTRLS[nInd]:cReadVar == "M->BA1_VERSAO"
    	oEnc:AENTRYCTRLS[nInd]:BWHEN  := { || .F. }
    EndIf
Next    

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o dialogo...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlgRes ON INIT EnChoiceBar(oDlgRes,bOK,bCanc,.F.) Center
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё inicia transacao na base se confirmado operacao..                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta campos e seus conteudos...                                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Begin Transaction
		BA1->( RecLock("BA1", .F.) )	
			BA1->BA1_MATANT := M->BA1_MATANT
			BA1->BA1_NOMUSR := M->BA1_NOMUSR
			BA1->BA1_DATNAS := M->BA1_DATNAS
			BA1->BA1_TIPUSU := M->BA1_TIPUSU
			BA1->BA1_GRAUPA := M->BA1_GRAUPA
			BA1->BA1_DRGUSR := M->BA1_DRGUSR
			BA1->BA1_CPFUSR := M->BA1_CPFUSR
			BA1->BA1_CODPLA := M->BA1_CODPLA
			BA1->BA1_VERSAO := M->BA1_VERSAO
		    BA1->BA1_NOMTIT := M->BA1_NOMTIT
		BA1->( MsUnlock() )
	End Transaction
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se for chamado do valid, sempre retornara .T.                            Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If lPergunta
	lRet := lPergunta
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha do Semaforo														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FClose(nH)
FErase(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(lRet)
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё p315vld    Ё Autor ЁDaher			   Ё Data Ё 20.04.10 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Validacao										         Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Function pl315vld(cCodPad,cCodProc,cHorario,cMatrUsr,dDtRec,cCodRDA,cCodSol,cCodLoc,cAteRNA,cCodEsp)

Local lRet 	     := .T.      
Local aRetFun    := {} 
Local aDadRDA    := PLSDADRDA(Plsintpad(),cCodRDA,'1',dDtRec,cCodLoc)
Local aDadUsr    := PLSDADUSR(cMatrUsr,'1',.T.,dDtRec)
Local dDatPro    := dDtRec
Local cHorPro    := cHorario
Local aRet	     := {}
Local aHisCri    := {}
Local cSequen    := "001"
Local aAutFor    := {}
Local lCodGloAud := .F.
Local nFor 		 := 1
Local lPerFor    := .T.
Local lForcou	 := .F.
Local cOpeSol    := PlsIntPad()  
Local lFlag		 := .F.     
Local lforCri	 := .F. 
Default cAteRNA  := "0" //Nao e atendimento recen nascido 
Default cCodEsp  := ""

If Empty(cCodProc)
	cCodProc := substr(GetNewPar("MV_PLSCOPA","0100010014"),3,8)
	cCodPad := substr(GetNewPar("MV_PLSCOPA","0100010014"),1,2)
EndIf

If !Empty(cCodProc) .and. ! BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodProc))
	Help("",1,"PL315VLD")
	lRet := .F.      
EndIf

If lRet .and. aDadUsr[1] .and. aDadRDA[1]
                                                                                                 
	aRetFun := PLSAUTP( dDatPro,;
		                cHorPro,;
		                cCodPad,;
		                cCodProc,;
		                1,;
		                aDadUsr,;
		                0,;
		                aDadRDA,;
		                "1",;
		                .T.,;
		                nil,;
		                .T.,;
		                "1",;
		                .T.,;
		                cOpeSol,;
		                cCodSol,;
		                nil,;
		                nil,;
		                nil,;
		                nil,;
		                nil,;
		                .T.,;
		                nil,;
		                nil,;
		                nil,;
		                nil,;
		                nil,;
		                cAteRNA,;
		                nil,;
		                nil,;
		                nil,;
		                nil,;
		                nil,;
		                "1",;
		                nil,;
		                NIL,;
		                NIL,;
		                nil,;
		                nil,;
		                nil,;
		                nil,;
		                nil,;
		                nil,;
		                nil,;
		                nil,;
		                nil,;
		                nil,;
		                .T.,;  
		                nil,;
		                nil,;
		                nil,;
		                cCodEsp) 
		                
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё aret																	 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	aRet := aClone(aRetFun)
	lRet := aRet[1]         
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Caso nao seja autorizada analiso o campo que trata se e permitido forcar Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If lPerFor .And. ! lRet    
		aHisCri 		:= aClone( aRet[2] )
	   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё 1o Regra. somente se todos as criticas podem forcar e que entra na regra de forcar Ё
	   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   If BR8->BR8_PERFOR <> "1"
	      BCT->(DbSetOrder(1))
	      For nFor := 1 To Len(aRet[2])
	      	lforCri := BCT->BCT_PERFOR == '1'
	      
	          If lforCri <> lCodGloAud
	             If ! Empty(aRet[2][nFor][1]) 
	                If BCT->(MsSeek(xFilial("BCT")+PlsIntPad()+aRet[2][nFor][1])) .And. BCT->BCT_PERFOR == "1" 
	                   lFlag := .T.    
	                Else
	                  lFlag := .F.
	                  Exit
	                EndIf     
	             EndIf
	          EndIf   
	      Next
	   Else
	      lFlag := .T.
	   EndIf   
	   //зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё Se existe pelo menos uma critica que pode forcar entra nessa regra de forcarЁ
	   //юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   If lFlag
	
	      lForcou := PLSMOVCRI("1",{cCodPad,cCodProc,BR8->BR8_DESCRI,cSequen},aHisCri,.T.)
	          
	      If lForcou
	         aRet[1] 	:= .T.
	         lAuditoria := .F.
	         nPos    	:= Ascan(aAutFor,{|x| x[2]+x[3] == cCodPad+cCodProc})
	         If nPos == 0
		        aadd(aAutFor,{.T.,cCodPad,cCodProc,"","","","",0,BCS->(RetCodUsr()),Date(),Time()})
	         EndIf                 
	      EndIf        
	   EndIf                    
	EndIf
	
	//здддддддддддддддддддддддддддддддддддддддд©
	//ЁTratamento para os atendimento de retonoЁ
	//юдддддддддддддддддддддддддддддддддддддддды
	If !lRet 
	  If BBD->BBD_TIPO="2" // revisЦo     
	  	lRet:=.t.
	  EndIf
	EndIf
	

	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Se existir critica exibe dialogo...                                      Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If ( ! lRet .And. ! lPerFor ) .Or. ( ! lRet .And. ! lFLag )
	   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	   //Ё Monta aHisCri...                                                         Ё
	   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	   PLSMOVCRI("1",{cCodPad,cCodProc,BR8->BR8_DESCRI,cSequen},aHisCri)
	EndIf   
EndIf



	          
Return (lRet .or. lForcou)
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA315VLD Ё Autor ЁGeraldo Felix JuniorЁ Data Ё 29.01.02 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Valida a chegada de um usuario na agenda...               Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function PLSA315Vld(oHorarios,aHorMed,oMedicos,aSalas,dDtRec,cCodCon,bAtuDados,cDirImg,bBotao04,cCdAmbu)

Local nH    
Local nHC    
Local nHGrv
Local cFile
Local cFileC
Local cFoto
Local cNome
Local oSay 
Local oFoto
Local oGrupo
Local oGet01
Local oGet02
Local oCritica 
Local oDlgRes
Local aArea    := GetArea() 
Local nOpca    := 0
Local nLinHor  := oHorarios:nAt
Local nRecBBD  := aHorMed[nLinHor,6]
Local nRecBGF  := aSalas[oMedicos:nAt,7]
Local cMotBlo  := GetNewPar("MV_PLSREMR",'01')
Local cChkSem  := "F"+cConSem+AllTrim( Str(nRecBGF) )+".SMF"
Local cTitulo  := STR0279 //"Validacao do Paciente"
Local cMatrUsr := aHorMed[nLinHor,3]
Local cHorario := aHorMed[nLinHor,2]
Local cNomePac := aHorMed[nLinHor,4]
Local cNomMed  := aHorMed[nLinHor,8]                    
Local cCart01  := Space(100)
Local cCart02  := Space(100)
Local cPath    := AllTrim(GetMv("MV_PLSDIMG"))
Local cInterc  := GetNewPar("MV_PLSGEIN","0050")
Local cChkCon  := GetNewPar("MV_PLSCHKC","0000")
Local cPLSMCGG := GetNewPar("MV_PLSMCGG","1") 
Local aStatus  := {}
Local aCritica := {}
Local aMovim   := {.T.,Space( Len(BBD->BBD_NUMMOV) )}
Local aRet     := { .F. , "" , "" }  
Local bOK      := { || nOpca := 1,If(pl315vld(cCodPad,cCodProc,cHorario,cMatrUsr,dDtRec,aHorMed[nLinHor,1],BBD->BBD_CODSOL,BBD->BBD_CODLOC,BBD->BBD_ATERNA,BBD->BBD_CODESP),oDlgRes:End(),nOpca:=2),If(nOpca==1,oDlgRes:End(),.F.) } //"Existem Criticas para este usuario"
Local bCanc    := { || nOpca := 3,oDlgRes:End() }
Local cCodPad  := GETMV("MV_PLSTBPD")
Local cCodProc := CriaVar("BE2_CODPRO")

Private cCodPadPes := cCodPad

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se esta em alteracao 												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !PLSCHKSEM(cChkSem,STR0267) //"Sala sendo atualizado por outra estacao. Tente dentro de alguns segundos"
   Return
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se a sala esta aberta												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nRecBGF > 0
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza o Top															 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	TCREFRESH(RetSqlName("BGF"))    
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona no registro													 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BGF->( DbGoTo( nRecBGF ) )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё VerIfica se a sala esta fechada											 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If BGF->BGF_STATUS == "0"
	  MsgInfo(STR0281)    //"Esta sala foi fechada por outra estacao!"
	  Eval(bAtuDados)
	  Return
    EndIf
EndIf  
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fecha Area																				  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
//TrbBGF->(DbCloseArea())
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciono o horario																		  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->( DbGoTo( nRecBBD ) )
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё VerIfica se o usuario esta cadastrado no contrato/subcontrato especIfico para agendamento Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If cChkCon <> '0000' 
   If AllTrim(BBD->(BBD_CODEMP+BBD_CONEMP+BBD_VERCON+BBD_SUBCON+BBD_VERSUB)) == AllTrim(cChkCon)
      MsgAlert('Este usuario esta em um Contrato/Sub-Contrado invalido, favor verIficar!')
      Return
   EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFile := "F"+cConSem+AllTrim( Str(nRecBBD) )+".SMF"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tenta criar o arquivo													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nH := FCreate(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nH == -1
   Aviso(STR0197,STR0226,{STR0102}) //"Ocupado"###"HorАrio sendo usado por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
   Return
EndIf                                                                            
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Chama menu para mudanca de fase do usauario na recepcao...               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aStatus := PLSPOPUP(oHorarios,aHorMed,oMedicos,aSalas,dDtRec,bBotao04,bAtuDados)
//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciono o horario																		  Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BBD->( DbGoTo( nRecBBD ) )
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se ocorrer tudo bem nas validacoes e nao houver um estorno, grava na base|
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды                                            
If aStatus[2]
	If !aStatus[4]
		If aStatus[1] == "6"             
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Quando for usuario de intercambio eventual, pede para alterar dados cadastrais...|
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			If BBD->BBD_CODEMP == cInterc
				BA1->( DbSetorder(02) )
				If !BA1->( MsSeek(xFilial("BA1")+BBD->BBD_CODPAC) )
				    MsgAlert('Usuario nao encontrado BA1:'+BBD->BBD_CODPAC)
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Controle de transacao...                                                 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					FClose(nH)
					FErase(cFile)
				   	Return
				EndIf
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Alteracao de usuario													 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If !PL315ALTIE(.F.,BBD->BBD_CODPAC)
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Controle de transacao...                                                 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					FClose(nH)
					FErase(cFile)
				   	Return
				EndIf
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Testa disponibilidade de horario e caso esteja livre, reserva o horario..|
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			aRet := PLSACSATE(aHorMed)
			If aRet[1]
			   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			   //Ё Arquivo Semaforo															Ё
			   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			   nHC    := aRet[2]
			   cFileC := aRet[3]
			Else
			   FClose(nH)
			   FErase(cFile)
	 		   Return   
			EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Reposiciona																 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BBD->( DbGoto(nRecBBD) )
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Abre o semaforo...                                                               |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды			
			nHGrv := PLSAbreSem("SEMNUMATE.SMF")
			
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Inicia a Transacao													     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Begin Transaction                      
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Gera o numero do atendimento...                                                  |
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды			
				BBD->( RecLock("BBD", .F.) )
					If Empty(BBD->BBD_NUMATE)
						BBD->BBD_NUMATE := GetSx8Num("BBD","BBD_NUMATE")
					EndIf
					BBD->BBD_USUOPE	:= PLRETOPE() 
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Para garantir a integridade do Local de atendimento...                           |
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If BBD->BBD_CODLOC <> cLocal
						BB8->( DbSetorder(03) )
						If BB8->( MsSeek(xFilial("BB8")+BBD->BBD_CODIGO+BBD->BBD_CODINT+BBD->BBD_LOCAL) )
							BBD->BBD_CODLOC := BB8->BB8_CODLOC
						EndIf
					EndIf
				BBD->(MsUnlock())	
			End Transaction
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Imprissao de guias somente para consultas ou encaixes...                 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If BBD->BBD_TIPO $ '1,4' .And. cPLSMCGG == "1"
				    //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				    //Ё Quando encaminha o paciente para o consultorio, grava a movimentacao...  Ё
			    	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				    aMovim := PLSMOVMC( BBD->( Recno() ),"1",BBD->BBD_CODPAD,BBD->BBD_CODPRO,nil,BBD->BBD_CODLOC,BBD->BBD_CODESP )
				EndIf    
			
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Grava os dados referente a guia gerada no contas medicas...              |
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If ( cPLSMCGG == "1" .And. aMovim[1] ) .Or. ( cPLSMCGG <> "1" )
					Begin Transaction
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Troca o horario para atendido 											 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If ( ! ExistBlock("PLS315EA") ) .Or. (ExecBlock("PLS315EA",.F.,.F.,{"VP"}))
   					   PLSACOLATE(aHorMed)
   					EndIf   
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Reposiciono o horario													 Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					BBD->( DbGoto(nRecBBD) )
					
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Atualiza a consulta com os dados da guia...                              |
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				    BBD->(RecLock("BBD",.F.))
					    BBD->BBD_STATUS := '6'
						If cPLSMCGG == "1"
						   BBD->BBD_NUMMOV := aMovim[2]
						EndIf   
					    BBD->BBD_HORENT := Left(Time(),5)
						BBD->BBD_CODCAN	:= ''
						BBD->BBD_HORCAN	:= ''
						If BBD->( FieldPos("BBD_DATCAN") ) > 0
						   BBD->BBD_DATCAN := Ctod('')
						EndIf
						If BBD->( FieldPos("BBD_USUCAN") ) > 0
						   BBD->BBD_USUCAN := "" 
						EndIf
	    				BBD->BBD_USUOPE	:= PLRETOPE() 
					BBD->(MsUnlock())
					
					If ExistBlock("PLS315PC")
					   ExecBlock("PLS315PC",.F.,.F.,{bAtuDados,cCdAmbu,aSalas,oMedicos})
					EndIf
					
					End Transaction  
					
				Else
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Estorna a movimentacao devido a criticas encontradas no contas medicas...|
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					Begin Transaction
					BBD->(RecLock("BBD", .F.))
						BBD->BBD_NUMATE := Space(Len(BBD->BBD_NUMATE))
						BBD->BBD_USUOPE	:= PLRETOPE() 
					BBD->(MsUnlock())
					End Transaction
				EndIf
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Fim da Transacao													     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Fecha o semaforo...                                                              |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды						
			PLSFechaSem(nHGrv,"SEMNUMATE.SMF")
			    
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Libera o horario reservado pelo operador...                              Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			FClose(nH)
			FErase(cFile)
			If !Empty(cFileC)
			    FClose(nHC)
			    FErase(cFileC)					
			EndIf    
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Se  gerou movimento															 	 |
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды						
			If cPLSMCGG == "1" .And. aMovim[1]
				//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
				//Ё Imprissao de guias somente para consultas ou encaixes...                 Ё
				//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
				If BBD->BBD_TIPO $ '1,4'
					//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
					//Ё Imprime a guia do atendimento...                                         Ё
					//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
					If BBD->BBD_CODEMP == cInterc
						If Aviso(STR0223,STR0224,{STR0140,STR0139}) == 1 //"Impressao"###"Imprimir a guia agora ?"###"Sim"###"Nao"
						   PLSA090Ima()
						EndIf
					EndIf
				EndIf	
            Else
				Return
			EndIf	
		ElseIf aStatus[1] == "4"                             
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Inicia a Transacao													     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Begin Transaction
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Alteracao															  	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BBD->(RecLock("BBD", .F.))
				BBD->BBD_STATUS := '4'
				BBD->BBD_HORSAI := Left(Time(),5)
				BBD->BBD_CODCAN	:= ''
				BBD->BBD_HORCAN	:= ''
			    BBD->BBD_DATCAN := Ctod('')
				BBD->BBD_USUCAN	:= ""
				BBD->BBD_USUOPE	:= PLRETOPE() 
				BBD->BBD_CID := aStatus[6] 
			BBD->(MsUnlock())

			//зддддддддддддддддддддддддддддддддддддддддд©
			//ЁGrava o CID nas tabelas de Autorizacao   Ё
			//юддддддддддддддддддддддддддддддддддддддддды
			BEA->( DbSetorder(13) )			    
		    If !Empty(BBD->BBD_NUMATE) .And. BEA->( MsSeek(xFilial("BEA")+BBD->BBD_NUMATE) )
				BEA->(RecLock("BEA", .F.))				
					BEA->BEA_CID := aStatus[6]  
					BEA->BEA_TIPADM := "6"
					BEA->BEA_TIPPAC := IIf(BBD->( FieldPos("BBD_TIPPAC") ) > 0,BBD->BBD_TIPPAC, getNewPar("MV_PLSTPAA","9") )
					BEA->BEA_TRACON := "0"  
					BEA->BEA_TIPATE := "04"
					
				BEA->(MsUnlock())
			EndIf

			//зддддддддддддддддддддддддддддддд©
			//ЁGrava o CID nas tabelas de GuiaЁ
			//юддддддддддддддддддддддддддддддды
			BD5->(dbSetOrder(1))
			If BD5->( dbSeek( xFilial("BD5") + BBD->BBD_NUMMOV ) )
		
				BD5->(RecLock("BD5",.F.))
					BD5->BD5_CID := aStatus[6] 
					BD5->BD5_TIPPAC := IIf(BBD->( FieldPos("BBD_TIPPAC") ) > 0,BBD->BBD_TIPPAC, getNewPar("MV_PLSTPAA","9") )
				BD5->(MsUnlock())

				//зддддддддддддддддддддддддддддддд©
				//ЁBusca eventos do contas medicasЁ
				//юддддддддддддддддддддддддддддддды

				BD6->(dbSetOrder(1))
				If BD6->( dbSeek( xFilial("BD6") + BD5->BD5_CODOPE + BD5->BD5_CODLDP + BD5->BD5_CODPEG + BD5->BD5_NUMERO ) )
		
        			While BD6->( !Eof() ) .And. BD6->BD6_FILIAL == xFilial("BD6") .And. ;
        										BD6->BD6_CODOPE == BD5->BD5_CODOPE .And. ;
        										BD6->BD6_CODLDP == BD5->BD5_CODLDP .And. ;
        										BD6->BD6_CODPEG == BD5->BD5_CODPEG .And. ;
        										BD6->BD6_NUMERO == BD5->BD5_NUMERO

						BD6->(RecLock("BD6",.F.))
							BD6->BD6_CID := aStatus[6]
						BD6->(MsUnlock())


						BD7->(dbSetOrder(1))
						If BD7->( dbSeek( xFilial("BD7") + BD6->BD6_CODOPE + BD6->BD6_CODLDP + BD6->BD6_CODPEG + BD6->BD6_NUMERO + BD6->BD6_ORIMOV + BD6->BD6_SEQUEN ) )
				
		        			While BD7->( !Eof() ) .And. BD7->BD7_FILIAL == xFilial("BD6") .And. ;
		        										BD7->BD7_CODOPE == BD6->BD6_CODOPE .And. ;
		        										BD7->BD7_CODLDP == BD6->BD6_CODLDP .And. ;
		        										BD7->BD7_CODPEG == BD6->BD6_CODPEG .And. ;
		        										BD7->BD7_NUMERO == BD6->BD6_NUMERO .And. ;
		        										BD7->BD7_ORIMOV == BD6->BD6_ORIMOV .And. ;
		        										BD7->BD7_SEQUEN == BD6->BD6_SEQUEN

								BD7->(RecLock("BD7",.F.))
									BD7->BD7_CID := aStatus[6]
								BD7->(MsUnlock())
		

								BD7->( dbSkip() )
                    			
							EndDo
                    
						EndIf
						
						BD6->( dbSkip() )        										
						
					EndDo
					        										
				EndIf

			EndIf			

			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Fim da Transacao													     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			End Transaction
			
		ElseIf aStatus[1] == "7"
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Inicia a Transacao													     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Begin Transaction
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Alterar																	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BBD->(RecLock("BBD", .F.))
				BBD->BBD_STATUS := '7'
				BBD->BBD_CODCAN	:= cMotBlo
				BBD->BBD_HORCAN := Left(Time(),5)
			    BBD->BBD_DATCAN := Date()
				BBD->BBD_USUCAN	:= PlRetOpe()
				BBD->BBD_USUOPE	:= PLRETOPE() 
			BBD->(MsUnlock())
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Fim da Transacao													     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			End Transaction
		ElseIf aStatus[1] == "1"
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Inicia a Transacao													     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			Begin Transaction
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Alterar																	 Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			BBD->(RecLock("BBD",.F.))
				BBD->BBD_STATUS := '1'
				BBD->BBD_CODCAN	:= ''
				BBD->BBD_HORCAN	:= ''
			    BBD->BBD_DATCAN := Ctod('')
				BBD->BBD_USUCAN	:= ""
			BBD->(MsUnlock())
			//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
			//Ё Fim da Transacao													     Ё
			//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
			End Transaction
		EndIf
	EndIf
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	If aStatus[1] <> "5"
		Eval(bAtuDados)
		//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
		//Ё Controle de transacao...                                                 Ё
		//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
		FClose(nH)
		FErase(cFile)
		Return
	EndIf
Else      
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Controle de transacao...                                                 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	FClose(nH)
	FErase(cFile)
	Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona no usuario...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA1->(DbSetOrder(2))
If !BA1->(MsSeek(xFilial("BA1")+cMatrUsr))
   MsgAlert('Usuario nao encontrado BA1:'+cMatrUsr)
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Controle de transacao...                                                 Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   FClose(nH)
   FErase(cFile)
   Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona na familia...                                                  Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BA3->(DbSetOrder(1))
If !BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
   MsgAlert('Familia nao encontrada BA3:'+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC))
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Controle de transacao...                                                 Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   FClose(nH)
   FErase(cFile)
   Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Posiciona na vida...                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
BTS->(DbSetOrder(1))
If !BTS->(MsSeek(xFilial("BTS")+BA1->BA1_MATVID))
   MsgAlert('Vida nao encontrada BTS:'+BA1->BA1_MATVID)
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Controle de transacao...                                                 Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   FClose(nH)
   FErase(cFile)
   Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alimenta variavel														 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFoto := BTS->BTS_BITMAP
cNome := BTS->BTS_NOMUSR

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Pede para o usuario passar o cartao...                                   Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aCritica) > 0
	DEFINE MSDIALOG oDlgRes TITLE cTitulo FROM 005,005 TO 034, 100 OF GetWndDefault()
Else
	DEFINE MSDIALOG oDlgRes TITLE cTitulo From 0, 0 to 34, 50 of getwndDefault() 
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Dados da Foto do Paciente...                                             Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды

@ 195,003 GROUP oGrupo TO 250, 155 PIXEL OF oDlgRes LABEL STR0282  COLOR CLR_HBLUE, CLR_HRED        //" Foto "

If File(cPath+__cPrefFot+BA1->BA1_MATVID+".JPG")
   @ 200, 007 JPEG oFoto DISK cPath+__cPrefFot+BA1->BA1_MATVID+".JPG" OF oDlgRes SIZE 108,083 NOBORDER WHEN .F. PIXEL
EndIf   

/*
@ 148,003 GROUP oGrupo TO 219, 092 PIXEL OF oDlgRes LABEL STR0282  COLOR CLR_HBLUE, CLR_HRED        //" Foto "

If File(cPath+__cPrefFot+BA1->BA1_MATVID+".JPG")
   @ 155, 007 JPEG oFoto DISK cPath+__cPrefFot+BA1->BA1_MATVID+".JPG" OF oDlgRes SIZE 108,083 NOBORDER WHEN .F. PIXEL
EndIf   
*/             


//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta informacoes do horario/medico selecionado...                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 015,003 GROUP oGrupo TO 100, 155 PIXEL OF oDlgRes LABEL STR0283  COLOR CLR_HBLUE, CLR_HRED        //" Dados da Agenda "

@ 025,008 Say oSay Prompt STR0185 Size 150,008 PIXEL OF oDlgRes COLOR CLR_HBLUE          //"DATA"
@ 025,055 Say oSay Prompt dtoc(dDtRec) Size 150,008 PIXEL OF oDlgRes     
   
@ 040,008 Say oSay Prompt STR0284 Size 150,008 PIXEL OF oDlgRes COLOR CLR_HBLUE     //"HORаRIO"
@ 040,055 Say oSay Prompt TransForm(cHorario,"@!") Size 150,008 PIXEL OF oDlgRes        
   
@ 055,008 Say oSay Prompt STR0039 Size 100,008 PIXEL OF oDlgRes COLOR CLR_HBLUE     //"MиDICO"
@ 055,055 Say oSay Prompt cNomMed Size 100,008 PIXEL OF oDlgRes     

@ 070,008 Say oSay Prompt STR0054 Size 100,008 PIXEL OF oDlgRes COLOR CLR_HBLUE     //"PACIENTE"
@ 070,055 Say oSay Prompt TransForm(cMatrUsr,__cPictUsr) Size 100,008 PIXEL OF oDlgRes     
@ 077,055 Say oSay Prompt BBD->BBD_MATANT Size 100,008 PIXEL OF oDlgRes     

@ 085,008 Say oSay Prompt STR0285 Size 100,008 PIXEL OF oDlgRes COLOR CLR_HBLUE     //"NOME PACIENTE"
@ 085,055 Say oSay Prompt cNomePac Size 100,008 PIXEL OF oDlgRes     

@ 105,003 GROUP oGrupo TO 145, 155 PIXEL OF oDlgRes LABEL STR0286  COLOR CLR_HBLUE, CLR_HRED        //" Cartao "
oGet01 := TGet():New(115,009,{ | U | If( PCOUNT() == 0, cCart01, cCart01 := U ) },oDlgRes,140,008 ,"@!",nil,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cCart01)
oGet02 := TGet():New(127,009,{ | U | If( PCOUNT() == 0, cCart02, cCart02 := U ) },oDlgRes,140,008 ,"@!",{ || PLSA315VUs(oDlgRes,oCritica,aCritica) },nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,nil,cCart02)



@ 155,003 GROUP oGrupo TO 190, 155 PIXEL OF oDlgRes LABEL STR0308 COLOR CLR_HBLUE, CLR_HRED       //" Procedimento "  

@ 165,008 Say oSay Prompt STR0309 Size 100,008 PIXEL OF oDlgRes COLOR CLR_HBLUE    
oGet01 := TGet():New(165,055,{ | U | If( PCOUNT() == 0, cCodPad, cCodPad := U ) },oDlgRes,050,008 ,"@!",{|| BR4->(ExistCpo("BR4",cCodPad,1)) .And. RecpCodPad(cCodPad)} ,nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,"B41PLS",cCodPad)

@ 177,008 Say oSay Prompt STR0310 Size 100,008 PIXEL OF oDlgRes COLOR CLR_HBLUE    
oGet02 := TGet():New(177,055,{ | U | If( PCOUNT() == 0, cCodProc, cCodProc := U ) },oDlgRes,080,008 ,"@!",{ || Empty(cCodProc) .or. (BR8->(MsSeek(xFilial("BR8")+cCodPad+cCodProc))) },nil,nil,nil,nil,nil,.T.,nil,.F.,nil,.F.,nil,nil,.F.,nil,"BBDPL1",cCodProc)




//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Critica...                                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aCritica) > 0
	@ 130,300 BUTTON STR0287 SIZE 050,012 ACTION { || oDlgRes:nRight := 494 } PIXEL OF oDlgRes //"Fechar Critica"

	@ 015,180 GROUP oGrupo TO 146,368 PIXEL OF oDlgRes LABEL STR0288  COLOR CLR_HBLUE, CLR_HRED        //" Criticas "

	oCritica := TcBrowse():New( 025, 185, 180, 100,,,, oDlgRes,,,,,,,,,,,, .F.,, .T.,, .F., )
                         	                   
	oCritica:AddColumn(TcColumn():New(STR0289,	 {|| aCritica[oCritica:nAt,1] },"@!",nil,nil,nil,040,.F.,.F.,nil,nil,nil,.F.,nil))      //"Tipo"
	
	oCritica:AddColumn(TcColumn():New(STR0290,	 {|| aCritica[oCritica:nAt,2] },"@!",nil,nil,nil,020,.F.,.F.,nil,nil,nil,.F.,nil))      //"Codigo"

	oCritica:AddColumn(TcColumn():New(STR0291,{|| aCritica[oCritica:nAt,3] },"@!",nil,nil,nil,100,.F.,.F.,nil,nil,nil,.F.,nil))      //"Critica"

	oCritica:SetArray(aCritica)         
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o dialogo...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Len(aCritica) > 0
	ACTIVATE MSDIALOG oDlgRes ON INIT Eval( { || EnChoiceBar(oDlgRes,bOK,bCanc,.F.,{}) } ) Center
Else
	ACTIVATE MSDIALOG oDlgRes ON INIT Eval( { || EnChoiceBar(oDlgRes,bOK,bCanc,.F.,{}) } ) Center
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Testa confirmacao...                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Reposiciono																Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   BBD->( DbGoTo(nRecBBD) )
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Marco como em espera...                          Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If !BBD->( Eof() )
	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  //Ё Inicia a Transacao													     Ё
	  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	  Begin Transaction
	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  //Ё Alterar																	 Ё
	  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
      BBD->(RecLock("BBD", .F.))
		  BBD->BBD_STATUS := '5'
		  BBD->BBD_HORCHE := Left(Time(),5)
		  BBD->BBD_CODSAL := aSalas[oMedicos:nAt,11]
		  BBD->BBD_NSALA  := aSalas[oMedicos:nAt,1]
		  BBD->BBD_CDAMBU := cCdAmbu
		  BBD->BBD_CODCAN := ''
		  BBD->BBD_HORCAN := ''
	      BBD->BBD_DATCAN := Ctod('')
		  BBD->BBD_USUCAN := ""
		  BBD->BBD_USUOPE := PLRETOPE()
		  	// Troca o procedimento do paciente se for digitado na validaГЦo 
		 If !Empty(cCodPad) .and. !Empty(cCodProc)
			BBD->BBD_CODPAD := cCodPad
			BBD->BBD_CODPRO := cCodProc
		 Endif 
	  BBD->(MsUnlock())
	  //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	  //Ё Inicia a Transacao													     Ё
	  //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	  End Transaction
   EndIf
EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza tela...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Eval(bAtuDados)           

If ExistBlock("PLS315VLD")
	ExecBlock("PLS315VLD",.F.,.F.,{oHorarios})
EndIf

//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FClose(nH)
FErase(cFile)

RestArea(aArea)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPL315AGCH ╨Autor  ЁMicrosiga           ╨ Data Ё  01/15/05   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Chamado nao atendido                                       ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Function PL315AGCH(cPaciente, nRecBBD, cStatus, nRecBGF , bAtuDados)

Local nH
Local cFile
Local cTime   := Left(Time(),5)
Local cChkSem := "F"+cConSem+AllTrim( Str(nRecBGF) )+".SMF"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se o paciente foi selecionado											 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If Empty(cPaciente)
	MsgAlert(STR0292) //"Paciente nao selecionado!"
	Return(.F.)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Se esta em espera agendado e encaixe									 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !cStatus $ "5,1" 
	MsgAlert(STR0293) //"Opcao valida apenas para usuarios em espera!"
	Return(.F.)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se esta em alteracao 												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !PLSCHKSEM(cChkSem,STR0267) //"Sala sendo atualizado por outra estacao. Tente dentro de alguns segundos"
   Return(.F.)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFile :="F"+cConSem+AllTrim( Str(nRecBBD) )+".SMF"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tenta criar o arquivo													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nH := FCreate(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se o arquivo ja foi criado										 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nH == -1
   Aviso(STR0197,STR0294,{STR0102}) //"Ocupado"###"Espera sendo atualizada por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
   Return(.F.)
EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Confirmacao																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If MsgYesNo(STR0295+cPaciente+STR0296+cTime+" ? ") //"Confirma o chamado nao atendido para o paciente "###", as "
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Posiciona																 Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BBD->( DbGoto(nRecBBD) )
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Confirma o paciente...                                                   Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Begin Transaction
	  If !BBD->( Eof() )
	   	 BBD->( RecLock("BBD", .F.) )
		 BBD->BBD_CHAMAD ++
		 BBD->BBD_HORCMD := Alltrim(BBD->BBD_HORCMD)+cTime+','
		 BBD->( MsUnlock() )
	  EndIf
	End Transaction
EndIf             
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Atualiza																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Eval(bAtuDados)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FClose(nH)
FErase(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return(.T.)
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSA315CAN Ё Autor ЁGeraldo Felix JuniorЁ Data Ё 18.12.01 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Cancela uma agenda marcada...                             Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function PLSA315Can(oHorarios,aHorMed,bAtuDados,nBrw,aHorPro,oPronto,oLisEsp,aHorEsp,nRecBGF)

Local lFlag
Local nInd               
Local nH
Local nAux
Local cFile
Local cTitulo   
Local oDlgRes
Local oSay
Local oEnc
Local nRecBBD  := 0
Local nLinHor  := 0
Local nOpca    := 0
Local cNil     := ' '
Local cMatrUsr := ''
Local cHorario := ''
Local cNomePac := ''
Local cCodCre  := ''
Local cNomMed  := ''
Local cTelFon  := ''
Local cChkSem  := "F"+cConSem+AllTrim( Str(nRecBGF) )+".SMF"
Local aDadBHY  := {}
Local aCampos  := {}   
Local bOK      := { || nOpca := 1,If((Obrigatorio(aGets,aTela)),oDlgRes:End(),(nOpca:=3,.F.))}
Local bCanc    := { || nOpca := 3,oDlgRes:End() }

Private aGets  := {}
Private aTela  := {}

Default nBrw   := 1
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se esta em alteracao 												 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If !PLSCHKSEM(cChkSem,STR0267) //"Sala sendo atualizado por outra estacao. Tente dentro de alguns segundos"
   Return
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё lRefresh																 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды        
lRefresh := .F.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Alimenta as variaveis...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды        
If nBrw == 1    
	cTitulo  := STR0297 //"Cancelamento de Agenda"
	nLinHor  := oHorarios:nAt
	cMatrUsr := If(nLinHor>0,aHorMed[nLinHor,3],'')
	cHorario := If(nLinHor>0,aHorMed[nLinHor,2],'')
	cNomePac := If(nLinHor>0,aHorMed[nLinHor,4],'')
	cCodCre  := If(nLinHor>0,aHorMed[nLinHor,1],'')
	cNomMed  := If(nLinHor>0,aHorMed[nLinHor,8],'')
	cTelFon  := If(nLinHor>0,aHorMed[nLinHor,5],'')
	nRecBBD  := If(nLinHor>0,aHorMed[nLinHor,6],0)
ElseIf nBrw == 2
	cTitulo  := STR0298 //"Cancelamento do Pronto Atendimento"
	nLinHor  := oPronto:nAt
	cMatrUsr := If(nLinHor>0,aHorPro[nLinHor,02],'')
	cHorario := If(nLinHor>0,aHorPro[nLinHor,13],'')
	cNomePac := If(nLinHor>0,aHorPro[nLinHor,3],'')
	cCodCre  := ''
	cNomMed  := ''
	cTelFon  := ''
	nRecBBD  := If(nLinHor>0,aHorPro[nLinHor,5],0)
ElseIf nBrw == 3
	cTitulo  := STR0299 //"Cancelamento da Lista de Espera"
	nLinHor  := oLisEsp:nAt
	cMatrUsr := If(nLinHor>0,aHorEsp[nLinHor,02],'')
	cHorario := If(nLinHor>0,aHorEsp[nLinHor,12],'')
	cNomePac := If(nLinHor>0,aHorEsp[nLinHor,03],'')
	cCodCre  := ''
	cNomMed  := ''
	cTelFon  := ''
	nRecBBD  := If(nLinHor>0,aHorEsp[nLinHor,01],0)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Testa integridade...                                                     Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды 
If nLinHor == 0
   Return
EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Testa se foi atendido...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nBrw == 1                        
	If aHorMed[oHorarios:nAt,7] == "4"
	   MsgInfo(STR0300) //"HorАrio Atendido"
	   Return
	EndIf
	If aHorMed[oHorarios:nAt,7] == "6"
	   MsgInfo(STR0048) //"Em Atendimento"
	   Return
	EndIf
	If !Empty(aHorMed[oHorarios:nAt,10])
		MsgInfo(STR0301) //"Esta agenda ja foi cancelada!"
	    Return
	EndIf
EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Testa registro valido...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nRecBBD == 0
   MsgInfo(STR0302) //"HorАrio nao ocupado"
   Return
Else
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Posiciono																Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   BBD->( DbGoTo(nRecBBD) )
   //здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
   //Ё Checa integridade														Ё
   //юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
   If nBrw == 1 .And. !Empty(BBD->BBD_NUMATE)
	  MsgInfo(STR0303) //"HorАrio Atendido ou em atendimento"
	  Return
   EndIf
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
cFile :="F"+cConSem+AllTrim( Str(nRecBBD) )+".SMF"
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Tenta criar o arquivo													 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
nH := FCreate(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nH == -1
   Aviso(STR0197,STR0226,{STR0102}) //"Ocupado"###"HorАrio sendo usado por outra estacao. Tente dentro de alguns segundos"###"&Voltar"
   Return
EndIf   
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Define dialogo...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
DEFINE MSDIALOG oDlgRes TITLE cTitulo FROM 005,005 TO 030, 055
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta informacoes do horario/medico selecionado...                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
@ 020,005 Say oSay Prompt STR0185 Size 150,008 PIXEL OF oDlgRes COLOR CLR_HBLUE          //"DATA"
@ 020,040 Say oSay Prompt DtoC(BBD->BBD_DATA) Size 150,008 PIXEL OF oDlgRes     
   
@ 035,005 Say oSay Prompt STR0284 Size 150,008 PIXEL OF oDlgRes COLOR CLR_HBLUE     //"HORаRIO"
@ 035,040 Say oSay Prompt BBD->BBD_HORA Size 150,008 PIXEL OF oDlgRes        
   
@ 050,005 Say oSay Prompt STR0039 Size 100,008 PIXEL OF oDlgRes COLOR CLR_HBLUE     //"MиDICO"
@ 050,040 Say oSay Prompt cNomMed Size 100,008 PIXEL OF oDlgRes     
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta dados da enchoice...                                               Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
aadd(aCampos,"BBD_CODPAC")
aadd(aCampos,"BBD_NOME")
aadd(aCampos,"BBD_TELEFO")
aadd(aCampos,"BBD_TIPO")
aadd(aCampos,"BBD_MATANT")
aadd(aCampos,"BBD_CODCAN")
aadd(aCampos,"BBD_DESCAN")
aadd(aCampos,"BBD_OBSERV")  
aadd(aCampos,"BBD_ATERNA")  

M->BBD_ATERNA := BBD->BBD_ATERNA
M->BBD_OBSERV := BBD->BBD_OBSERV
M->BBD_CODPAC := BBD->BBD_CODPAC
M->BBD_NOME   := BBD->BBD_NOME
M->BBD_TELEFO := BBD->BBD_TELEFO
M->BBD_TIPO   := BBD->BBD_TIPO
M->BBD_MATANT := BBD->BBD_MATANT
M->BBD_CODCAN := Criavar("BBD_CODCAN")
M->BBD_DESCAN := Criavar("BBD_DESCAN")
RegtoMemory("BBD",.F.,.T.,.F.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Monta enchoice...                                                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
oEnc := BBD->(MSMGet():New("BBD",0,K_Alterar,,,,aCampos,{060,005,180,182},aCampos,,,,,oDlgRes,,,.T.))
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё No caso da agenda vou alterar o valid do campo BBD_NOME...              Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
For nInd := 1 To Len(oEnc:AENTRYCTRLS)
    If oEnc:AENTRYCTRLS[nInd]:cReadVar $ "M->BBD_CODPAC,M->BBD_TELEFO,M->BBD_TIPO,M->BBD_MATANT,M->BBD_NOME,M->BBD_ATERNA"
       oEnc:AENTRYCTRLS[nInd]:BWHEN := { || .F. }
    EndIf
Next    
DbSelectArea("BA1")
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Ativa o dialogo...                                                       Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
ACTIVATE MSDIALOG oDlgRes Center ON INIT EnChoiceBar(oDlgRes,bOK,bCanc,.F.)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё inicia transacao na base se confirmado operacao..                        Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If nOpca == K_OK
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Monta campos e seus conteudos...                                         Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Begin Transaction
	aadd(aDadBHY,{"BHY_CODIGO",BBD->BBD_CODIGO})
	aadd(aDadBHY,{"BHY_CODINT",BBD->BBD_CODINT})
	aadd(aDadBHY,{"BHY_DATA"  ,BBD->BBD_DATA})
	aadd(aDadBHY,{"BHY_HORA"  ,BBD->BBD_HORA})
	aadd(aDadBHY,{"BHY_TIPO"  ,BBD->BBD_TIPO})
	aadd(aDadBHY,{"BHY_ENCAIX",BBD->BBD_ENCAIX})
	aadd(aDadBHY,{"BHY_PRTATD",BBD->BBD_PRTATD})
	aadd(aDadBHY,{"BHY_CODESP",BBD->BBD_CODESP})
	aadd(aDadBHY,{"BHY_CODLOC",BBD->BBD_CODLOC})
	aadd(aDadBHY,{"BHY_LOCAL",BBD->BBD_LOCAL})
	aadd(aDadBHY,{"BHY_SIGLA",BBD->BBD_SIGLA})
	aadd(aDadBHY,{"BHY_NUMREG",BBD->BBD_ESTCR})
	aadd(aDadBHY,{"BHY_ESTCR",BBD->BBD_ESTCR})
	aadd(aDadBHY,{"BHY_CODPRF",BBD->BBD_CODPRF})
	aadd(aDadBHY,{"BHY_CODPAC",BBD->BBD_CODPAC})
	aadd(aDadBHY,{"BHY_NOME",BBD->BBD_NOME})
	aadd(aDadBHY,{"BHY_USUOPE",BBD->BBD_USUOPE})
	aadd(aDadBHY,{"BHY_CODCAN",M->BBD_CODCAN})
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Grava o cancelamento														Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	PLSCanAge(aDadBHY)
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Muda o Status para cancelado											    Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	BBD->(RecLock("BBD",.F.))
	BBD->BBD_STATUS 	:= "7"
	BBD->BBD_CODCAN	:= M->BBD_CODCAN
	BBD->BBD_HORCAN	:= Left(Time(),5)
	BBD->BBD_DATCAN := Date()
	BBD->BBD_USUCAN := PLRETOPE()
	BBD->BBD_USUOPE	:= PLRETOPE()
	BBD->(MsUnLock())
	End Transaction
	//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
	//Ё Atualiza o Browse														Ё
	//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
	Eval(bAtuDados)
EndIf
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Controle de transacao...                                                 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
FClose(nH)
FErase(cFile)
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
Return
/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLSCHKSEM  Ё Autor ЁAlexander		   Ё Data Ё 15.02.06 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Seca se tem algum arquivo de semaforo					 Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/            
Function PLSCHKSEM(cFile,cMsg)

Local nH               
Local lRet := .T.
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Checa se o arquivo ja foi criado Cancelamento							 Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды
If ( nH := FCreate(cFile) ) == -1
   Aviso(STR0197,cMsg,{STR0102}) //"Ocupado"###"&Voltar"
   lRet := .F.
Else
   FClose(nH)
   FErase(cFile)
EndIf 
//здддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//Ё Fim da Rotina...                                                         Ё
//юдддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды  
Return(lRet)
/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╩╠╠
╠╠╨	Fim do bloco de funcoes que fazem criacao de arquivo de semaforo	  ╨╠╠
╠╠хммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/  

/*
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁAjustaSxb ╨Autor  Ё Microssiga         ╨ Data Ё 05/03/2010  ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     Ё Cria perguntas padrao no dicionario de dados               ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё AP                                                         ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
*/
Static Function RecpCodPad(cCodPad)
cCodPadPes := cCodPad
Return(.T.)
/*/
эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддбдддддддбдддддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁPrograma  ЁMenuDef   Ё Autor Ё Darcio R. Sporl       Ё Data Ё04/01/2007Ё╠╠
╠╠цддддддддддеддддддддддадддддддадддддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescri┤┘o Ё Utilizacao de menu Funcional                               Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠Ё          Ё                                                            Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁRetorno   ЁArray com opcoes da rotina.                                 Ё╠╠
╠╠цддддддддддедддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁParametrosЁParametros do array a Rotina:                               Ё╠╠
╠╠Ё          Ё1. Nome a aparecer no cabecalho                             Ё╠╠
╠╠Ё          Ё2. Nome da Rotina associada                                 Ё╠╠
╠╠Ё          Ё3. Reservado                                                Ё╠╠
╠╠Ё          Ё4. Tipo de Transa┤└o a ser efetuada:                        Ё╠╠
╠╠Ё          Ё		1 - Pesquisa e Posiciona em um Banco de Dados           Ё╠╠
╠╠Ё          Ё    2 - Simplesmente Mostra os Campos                       Ё╠╠
╠╠Ё          Ё    3 - Inclui registros no Bancos de Dados                 Ё╠╠
╠╠Ё          Ё    4 - Altera o registro corrente                          Ё╠╠
╠╠Ё          Ё    5 - Remove o registro corrente do Banco de Dados        Ё╠╠
╠╠Ё          Ё5. Nivel de acesso                                          Ё╠╠
╠╠Ё          Ё6. Habilita Menu Funcional                                  Ё╠╠
╠╠цддддддддддедддддддддддддддбдддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё   DATA   Ё Programador   ЁManutencao efetuada                         Ё╠╠
╠╠цддддддддддедддддддддддддддедддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё          Ё               Ё                                            Ё╠╠
╠╠юддддддддддадддддддддддддддадддддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/
Static Function MenuDef() 

Private aRotina := {	{ 'Pesquisar'	, 'AxPesqui' , 0 , K_Pesquisar  	, 0, .F.},; //'Pesquisar'
						{ 'Visualizar'	, 'PL270MOV' , 0 , K_Visualizar 	, 0, Nil},; //'Visualizar'
						{ 'Incluir'		, 'PL270MOV' , 0 , K_Incluir    	, 0, Nil},; //'Incluir'
						{ 'Alterar'		, 'PL270MOV' , 0 , K_Alterar    	, 0, Nil},; //'Alterar'
						{ 'Excluir'		, 'PL270MOV' , 0 , K_Excluir    	, 0, Nil}}
Return(aRotina)

/*/
ээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠зддддддддддбддддддддддддбдддддддбддддддддддддддддддддбддддддбдддддддддд©╠╠
╠╠ЁFuncao    Ё PLS315OHOR Ё Autor ЁTulio Cesar         Ё Data Ё 15.02.06 Ё╠╠
╠╠цддддддддддеддддддддддддадддддддаддддддддддддддддддддаддддддадддддддддд╢╠╠
╠╠ЁDescricao Ё Devolva o objeto horario auxiliar    					 Ё╠╠
╠╠цддддддддддаддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠Ё            ATUALIZACOES SOFRIDAS DESDE A CONSTRU─AO INICIAL          Ё╠╠
╠╠цддддддддддддбддддддддбддддддбддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠ЁProgramador Ё Data   Ё BOPS Ё  Motivo da Altera┤└o                    Ё╠╠
╠╠цддддддддддддеддддддддеддддддеддддддддддддддддддддддддддддддддддддддддд╢╠╠
╠╠юддддддддддддаддддддддаддддддаддддддддддддддддддддддддддддддддддддддддды╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ
/*/            
Function PLS315HOR
Return(oPacientesAux)
/*эээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээээ
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
╠╠иммммммммммяммммммммммкмммммммяммммммммммммммммммммкммммммяммммммммммммм╩╠╠
╠╠╨Programa  ЁPl090PSSXB╨Autor  Ё                    ╨ Data Ё  23/05/12   ╨╠╠
╠╠лммммммммммьммммммммммймммммммоммммммммммммммммммммйммммммоммммммммммммм╧╠╠
╠╠╨Desc.     ЁExecuta a consulta padrao (especifica)                      ╨╠╠
╠╠╨          Ё                                                            ╨╠╠
╠╠лммммммммммьмммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╧╠╠
╠╠╨Uso       Ё                                                            ╨╠╠
╠╠хммммммммммомммммммммммммммммммммммммммммммммммммммммммммммммммммммммммм╪╠╠
╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠╠
ъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъъ*/
Function P315SXB()

Local cSql 	:= ""
Local aIndices 	:= {}
Local aHeader 	:= {}
Local lRet		:= .F.
Local oConsulta	:= Nil

//зддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддд©
//ЁMonta a query da consulta padrao																		Ё
//ЁConverte primeiro campo para string pois o mesmo eh chave na consulta padrao e na pesquisa do mesmo	Ё
//юддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддддды


cSql := " SELECT BSC_CDAMBU,BSD_DSAMBU  FROM "+RetSqlName("BSC")+" BSC,"+RetSqlName("BSD")+" BSD " 
cSql += " WHERE BSC_FILIAL = '"+xFilial("BSC")+"' AND BSD_FILIAL = '"+xFilial("BSD")+"' AND "     
cSql += " BSC_CODINT = '"+ mv_par01+"' AND BSC_CODLOC ='"+ mv_par02+"' AND " 
cSql += " BSC_CDAMBU  = BSD_CDAMBU AND "
cSql += " BSC.D_E_L_E_T_ = ' ' AND "
cSql += " BSD.D_E_L_E_T_ = ' ' "

//зддддддддддддддддддддддддддд©
//ЁMonta a aHeader da consultaЁ
//юддддддддддддддддддддддддддды     

SX3->( dbSetOrder( 2 ) ) 
SX3->( dbGotop(  ) ) 
If SX3->( dbSeek( "BSC_CDAMBU", .F. ) ) 
	Aadd(aHeader,{"Cod. Ambulatorio",SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"}) //"Id. Periodo"
	aAdd( aIndices, {"BSC_CDAMBU","Cod. Ambulatorio"}) 
Endif		

If SX3->( dbSeek( "BSD_DSAMBU", .F. ) ) 
	Aadd(aHeader,{"Desc. Ambulatorio",SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO	,SX3->X3_DECIMAL,"AlwaysTrue()"	,SX3->X3_USADO,"C","","V"}) //"Id. Periodo"
	aAdd( aIndices, {"BSD_DSAMBU","Desc. Ambulatorio"}) 
Endif

//зддддддддддддддддддддддд©
//ЁMonta a consulta padraoЁ
//юддддддддддддддддддддддды
oConsulta:=PlsIntSxb():New()
oConsulta:cTitle 		:= STR0026 					    								//Titulo da Consulta
oConsulta:cQuery 		:= cSql															//Query dos dados a serem apresentados
oConsulta:aIndex 		:= aIndices														//Indices disponiveis (deve usar os mesmos campos da query)
oConsulta:aHeader 		:= aHeader                      								//Header da grid presente consulta (deve usar os mesmos campos da query)
oConsulta:aReturn		:= {"BSC_CDAMBU"}	//Campos de retorno da consulta (deve usar os mesmos campos da query)
oConsulta:lDataBaseRM 	:= .T.															//Indica se a query eh executada na base do protheus ou da RM
oConsulta:Show()                                  

//здддддддддддддддд©
//ЁColeta o retornoЁ
//юдддддддддддддддды
If Len(oConsulta:aRetSXB) > 0
	cCodAmb := oConsulta:aRetSXB[1]
	lRet:=.t.
EndIf

Return lRet