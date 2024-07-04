#INCLUDE "ATFA360.CH"
#INCLUDE "Protheus.ch"

//********************************
// Controle de multiplas moedas  *
//********************************
Static lMultMoed := FindFunction("AtfMoedas")
STATIC lIsRussia	:= If(cPaisLoc$"RUS",.T.,.F.) // CAZARINI - Flag to indicate if is Russia location

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณ ATFA360	  ณ Autor ณ Alvaro Camillo Neto   ณ Data ณ 27/08/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Reavalia็ใo Anual de Ativos                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso		 ณ SIGAATF					                                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data     ณ BOPS     ณ Motivo da Alteracao                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณJonathan Glzณ 24/06/15 ณPCREQ-4256ณSe elimina actualizacion al help (SX1)ณฑฑ
ฑฑณ            ณ          ณ          ณen la funcion Af360Vld(),por motivo deณฑฑ
ฑฑณ            ณ          ณ          ณadecuacion a fuentes a nuevas estruc- ณฑฑ
ฑฑณ            ณ          ณ          ณturas SX para Version 12.             ณฑฑ
ฑฑณ            ณ          ณ          ณ                                      ณฑฑ
ฑฑณJonathan Glzณ09/10/15  ณPCREQ-4261ณMerge v12.1.8                         ณฑฑ
ฑฑณAlf. Medranoณ12/12/16  ณSERINN001-141ณcreaci๓n de tablas temporales se   ณฑฑ
ฑฑณ            ณ          ณ          ณasigna FWTemporaryTable en funciones  ณฑฑ
ฑฑณ            ณ          ณ          ณAF360Trb,AFR075Prc. en func AF360Sel  ณฑฑ
ฑฑณ            ณ          ณ          ณse selecciona el area de trabajo SX3  ณฑฑ
ฑฑณ            ณ          ณ          ณse modifica indice asignado a aChave  ณฑฑ
ฑฑณ            ณ          ณ          ณen funci๓n AF360Trb                   ณฑฑ
ฑฑณAlf. Medranoณ20/12/16  ณ          ณmerge 12.1.15 vs main                 ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ATFA360()
Private 	cPerg			:= "AFA360"
Private 	aRotina 		:= MenuDef()
Private 	cCadastro 	:= STR0018    //"Reavalia็ใo de Ativos"

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega as perguntas selecionadas:                                     ณ
//ณ mv_par01 - Seleciona bens ?          		                           ณ
//ณ mv_par02 - Data de Referencia ?                                        ณ
//ณ mv_par03 - C๓digo de ?                                                 ณ
//ณ mv_par04 - Item de ?                                                   ณ
//ณ mv_par05 - C๓digo at้ ?                                                ณ
//ณ mv_par06 - Item at้?                  		                           ณ
//ณ mv_par07 - 1 Mostra                                                    ณ
//ณ            2 Nao Mostra                                                ณ
//ณ mv_par08 - 1 Aglutina                                                  ณ
//ณ            2 Nao Aglutina                                              ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
Pergunte(cPerg,.F.)

#IFNDEF TOP
	Help("  ",1,"AF360TOP")
	Return .F.
#ENDIF

mBrowse( 6, 1,22,75,"SN3",,,,,, AtfLegenda("SN3"))

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF360Auto บAutor  ณAlvaro Camillo Neto บ Data ณ  28/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Processa a reavalia็ใo de ativos fixo                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAATF                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function AF360Auto(cAlias,nRecno,nOpc,lCancela)
Local aCampos	:= {}
Local oMark		:= Nil
Local aArea		:= GetArea()
Local cBaseI	:= ""
Local cBaseF	:= ""
Local cItemI	:= ""
Local cItemF	:= ""
Local lMostra	
Local lAglutina
Local dDataReav := Stod("")
Local lTela
Local lRet := .T.
Local dUltDepr		:= SuperGetMv("MV_ULTDEPR")                          
Local lMensal

If !Pergunte(cPerg,.T.)
	RestArea(aArea)
	Return .T.
EndIf        
If (mv_par09==1 .AND.(GetMv("MV_TIPDEPR") $ "345") ) .OR.(mv_par09==2 .AND.!(GetMv("MV_TIPDEPR") $ "345"))
	Help("  ",1,"AF360WRMNU")
	Return .F.
EndIf

lTela			:= MV_PAR01 == 1
dDataReav	:= MV_PAR02
cBaseI		:= MV_PAR03
cItemI		:= MV_PAR04
cBaseF		:= MV_PAR05
cItemF		:= MV_PAR06
lMostra		:= MV_PAR07 == 1
lAglutina	:= MV_PAR08 == 1
lMensal 	:= MV_PAR09 == 1

//Valida se a data de referencia ้ vแlida
If lMensal
	If lRet .And.  ( ((Month(dDataReav) <= Month(dUltDepr)) .and. (year(dDataReav)<=year(dUltDepr))  ).Or. (Month(dDataReav) > Month(dUltDepr) + 1))
		lRet := .F.
		Help(" ",1,"AF360DATAT") 
	Endif	
else
	If lRet .And.  ( Year(dDataReav) <= Year(dUltDepr) .Or. (Year(dDataReav) > Year(dUltDepr) + 1))
		lRet := .F.
		Help(" ",1,"AF360DATAT") 
	Endif		
Endif

If lRet
	If lTela
		MsgRun(STR0026,cCadastro,{|| AF360Sel(cBaseI,cItemI,cBaseF,cItemF,lMostra,lAglutina,dDataReav,lCancela)}) //"Selecionando Registros..."
	Else
		Processa( {|lEnd| AF360PROC("SN3",cBaseI,cItemI,cBaseF,cItemF,lMostra,lAglutina,dDataReav,lCancela,.F.,@lEnd)} , "","", .T. ) 
	EndIf 
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF360Sel  บAutor  ณALvaro Camillo Neto บ Data ณ  31/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra a tela de sele็ใo de registros                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA360                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF360Sel(cBaseI,cItemI,cBaseF,cItemF,lMostra,lAglutina,dDataReav,lCancela)
Local aCampos	:= {}
Local oMark		:= Nil
Local aArea		:= GetArea()
Local aAreaSN3	:= SN3->(GetArea())
Local aAreaSX3	:= SX3->(GetArea())
Local nOpca		:= 0
Local aSize		:= {}
Local oDlg		:= Nil
Local oPanel	:= Nil
Local oQtda		:= Nil
Local lInverte	:= .F.
Local cAlias	:= ""

Private cMarca := GetMark( )
Private nQtdBens := 0
private 	oTmpTable

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRealiza a monstagem do arquivo temporarioณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cAlias := AF360Trb(cBaseI,cItemI,cBaseF,cItemF,dDataReav,lCancela)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta os campo da markbrowseณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SX3")
DbSetOrder(1)
AADD(aCampos,{"N3_OK",,"  ",""})
SX3->(MsSeek("SN3"))
Do While SX3->X3_ARQUIVO == "SN3" .And. SX3->(!EOF()) 
	IF (X3USO(SX3->X3_USADO)  .AND. CNIVEL >= SX3->X3_NIVEL .AND. SX3->X3_CONTEXT # "V") .OR.;
		(SX3->X3_PROPRI == "U" .AND. SX3->X3_CONTEXT!="V" .AND. SX3->X3_TIPO <> 'M') .OR.;
		ALLTRIM(SX3->X3_CAMPO) $ "N3_CBASE#N3_ITEM"
		AADD(ACAMPOS,{SX3->X3_CAMPO,,SX3->(X3TITULO()) ,SX3->X3_PICTURE})
	Endif
	SX3->(dbSkip())
Enddo

nQtdBens := 0	  // quantidade de Bens,mostrado no rodap do browse
(cAlias)->(dbGoTop())
If (cAlias)->(!Eof())
	nOpca := 0
	Af360Marca(cAlias,cMarca,.F.,oQtda,cBaseI,cItemI,cBaseF,cItemF,dDataReav, .T. , lCancela)
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Faz o calculo automatico de dimensoes de objetos     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aSize := MSADVSIZE()	

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 TO aSize[6],aSize[5] OF oMainWnd  PIXEL 
	oDlg:lMaximized := .T.
	
	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,40,40,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP
	
	@1.9,.8 Say If(!lCancela,STR0019,STR0020)  OF oPanel  //"Total de Bens a Reavaliar..." ## "Total de Bens a cancelar..."
	@1.9,11 Say oQtda VAR nQtdBens  SIZE 50,10 OF oPanel 
	oMark := MsSelect():New(cAlias,"N3_OK",,aCampos,@lInverte,@cMarca,{35,oDlg:nLeft,oDlg:nBottom,oDlg:nRight})
	oMark:oBrowse:bAllMark := {|| Af360Marca(cAlias,cMarca,.T.,oQtda,cBaseI,cItemI,cBaseF,cItemF,dDataReav,.T.,lCancela)}
	oMark:bMark := { | | Af360Display(cMarca,lInverte,oQtda)}
	oMark:bAval	:= { | | Af360Marca(cAlias,cMarca,.T.,oQtda,cBaseI,cItemI,cBaseF,cItemF,dDataReav,.F.,lCancela) }
	oMark:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, {|| nOpca := 1,oDlg:End() },{|| nOpca := 0,oDlg:End()})
	
	If nOpca == 1
		Processa( {|lEnd| AF360PROC(cAlias,cBaseI,cItemI,cBaseF,cItemF,lMostra,lAglutina,dDataReav,lCancela,.T.,@lEnd)}, "","", .T. ) 
	Endif
Else
	Help(" ",1,"RECNO")	
Endif	

(cAlias)->( dbCloseArea() )

If oTmpTable <> Nil  
	oTmpTable:Delete() 
	oTmpTable := Nil 
Endif

RestArea(aAreaSX3)
RestArea(aAreaSN3)
RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF360Trb  บAutor  ณAlvaro Camillo Neto บ Data ณ  01/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava o arquivo temporario utilizado para a montagem e      บฑฑ
ฑฑบ          ณmanipula็ใo da MSSelect                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA360                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF360Trb(cBaseI,cItemI,cBaseF,cItemF,dDataReav,lCancela)
Local cAlias	:= GetNextAlias()
Local aStruSN3	:= SN3->(dbStruct())
Local cQuery	:= ""
Local aArea		:= GetArea()
Local aAreaSN3	:= SN3->(GetArea())
//ULocal aAreaSX3	:= SX3->(GetArea())
Local nX			:= 0
Local cTipoIn	:= IIF(lCancela, "'41','42'", "'01'")
Local dInidepr		:= Firstday(SuperGetMv("MV_ULTDEPR"))               
Local dFIMdepr		:= Lastday(SuperGetMv("MV_ULTDEPR"))               
Local aChave := {}
Local lMensal

lMensal 	:= MV_PAR09 == 1

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
EndIf

cQuery := " SELECT "
For nX := 1 to Len(aStruSN3)
	cQuery += " " + aStruSN3[nX][1] + " ,"
Next nX
cQuery := Left(cQuery,Len(cQuery)-1)
cQuery += " FROM " 
cQuery +=  	RetSQLTab("SN3")
cQuery += " WHERE  "
cQuery += " 	N3_CBASE >= '"+cBaseI+"' AND "
cQuery += " 	N3_ITEM	>= '"+cItemI+"' AND "
cQuery += " 	N3_CBASE <= '"+cBaseF+"' AND "
cQuery += " 	N3_ITEM	<= '"+cItemF+"' AND "
cQuery += " 	N3_TIPO IN("+cTipoIn+") AND "
cQuery += " 	N3_AQUISIC <= '"+dtoS(dDataReav)+"' AND "
cQuery += " 	(N3_BAIXA = '0'"           
If lMensal                                  	
	cQuery += " OR N3_DTBAIXA >='"+ dtoS(dInidepr) +"' AND N3_DTBAIXA <= '"+ dtoS(dFIMdepr)+ "' )AND "           
Else
	cQuery += ") 	AND "           
EndIf
cQuery += RetSQLCond("SN3")
cQuery += " ORDER BY "+ SqlOrder( SN3->(IndexKey(1) ) )

aChave:= STRTOKARR ( ALLTRIM( SN3->(IndexKey(1)) ) , "+" )
oTmpTable := FWTemporaryTable():New(cAlias)
oTmpTable:SetFields( aStruSN3 ) 
//crea indice
oTmpTable:AddIndex('T1ORD', aChave)
//Creacion de la tabla
oTmpTable:Create()
dbSelectArea( cAlias ) 
SqlToTrb(cQuery, aStruSN3, cAlias)

//RestArea(aAreaSX3)
RestArea(aAreaSN3)
RestArea(aArea)
Return(cAlias)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF360PROC บAutor  ณAlvaro Camillo Neto บ Data ณ  28/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณControla o processamento da rotina                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA360                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF360PROC(cAlias,cBaseI,cItemI,cBaseF,cItemF,lMostra,lAglutina,dDataReav,lCancela,lTela,lEnd)
Local aArea := GetArea()
Local lCtbInTran := CTBINTRAN(0,lMostra)// Se mostra os lan็amentos
Local nX		:= 0
Local bValida		:= nil
Local bPosiciona  := nil  
Local bWhile		:= nil
Local nBens			:= 0
Local lOk			:= .T.
// Variaveis para contabiliza็ใo
Private cArquivo 		:= ""
Private nTotal 		:= 0
Private nHdlPrv		:= 0
Private cPadrao   	:= ""
Private aCtbDia		:= {}   
Private aFlagCTB 		:= {}
Private cLoteAtf 		:= LoteCont("ATF")

Default lTela := .T.

If lTela
	bValida 		:= {|| (cAlias)->N3_OK == cMarca }
	bPosiciona  := {|| (cAlias)->(dbGoTop()) }
	bWhile  		:= {|| (cAlias)->(!Eof()) }
Else
	bValida 	   := {|| Af360Vld(SN3->N3_CBASE,SN3->N3_ITEM,SN3->N3_TIPO,SN3->N3_SEQ,dDataReav, .F.,lCancela )  } 
	bPosiciona 	:= {|| SN3->(MsSeek(xFilial("SN3") + cBaseI + cItemI , .T. )) } 
	bWhile 		:= {|| SN3->N3_FILIAL == xFilial("SN3") .And. SN3->N3_CBASE <= cBaseF .And. SN3->N3_ITEM <= cItemF .And. SN3->(!EOF()) } 
EndIf

If lCtbInTran
	BeginTran()
EndIf

ProcRegua(0) 

Eval(bPosiciona)
While Eval(bWhile) 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica existencia do Ativo 														ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IncProc(STR0030 + (cAlias)->N3_CBASE + STR0031 + (cAlias)->N3_ITEM )//"Processando Bem: "##" Item: " 
	
	ProcessMessage()
	If lEnd
		Exit
	EndIf
	
	IF !SN1->(MsSeek(xFilial("SN1")+(cAlias)->N3_CBASE+(cAlias)->N3_ITEM))
		(cAlias)->(dbSkip())
		Loop
	End

	IF !Empty(SN1->N1_DTBLOQ)    // Se o bem estiver bloqueado nao permite reavalia็ใo
		(cAlias)->(dbSkip())
		Loop
	End	
	
	If Eval(bValida)
		If lCancela
			lOk := Af360Canc((cAlias)->N3_CBASE,(cAlias)->N3_ITEM,(cAlias)->N3_TIPO,(cAlias)->N3_BAIXA,(cAlias)->N3_SEQ,dDataReav)	
		Else
			lOk := Af360Reav((cAlias)->N3_CBASE,(cAlias)->N3_ITEM,(cAlias)->N3_TIPO,dDataReav,(cAlias)->N3_BAIXA)	
		Endif
		
		If !lOk
			If lCtbInTran
				DisarmTran()
			EndIf
			Exit
		EndIf
		nBens++	
	End
	(cAlias)->(dbSkip())
EndDo

If nBens > 0 .and. nHdlPrv > 0
	RodaProva(nHdlPrv,nTotal)
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAtualiza o c๓digo de diแrioณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(aCtbDia) 
		cCodDiario := CtbaVerdia()
		For nX := 1 to Len(aCtbDia)
			aCtbDia[nX][3] := cCodDiario 
		Next nX
	EndIf
	
	cA100Incl( cArquivo,nHdlPrv, 2 /*nOpcx*/, cLoteAtf, lMostra,;
           lAglutina,;
           /*cOnLine*/, dDataReav, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, aCtbDia )
EndIf

If lCtbInTran
	EndTran()
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf360Canc บAutor  ณAlvaro Camillo Neto บ Data ณ  01/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cancela a reavalia็ใo anual                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA360                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Af360Canc(cBase,cItem,cTipo,cBaixa,cSeq,dDataReav)
Local lRet 		:= .T.
Local aArea		:= GetArea()
Local cPadrao 	:= "80B"
Local aValorMoed

SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
SN4->(dbSetOrder(1)) //N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+N4_DATA+N4_OCORR+N4_SEQ
SN5->(dbSetOrder(1)) //N5_FILIAL+N5_CONTA+N5_DATA+N5_TIPO

If SN3->(MsSeek(xFilial("SN3") + cBase + cItem + cTipo+ cBaixa + cSeq )) 
	// Cria a capado lote caso nใo tenha sido criada
	If VerPadrao(cPadrao) .And. Empty(nHdlPrv)
		nHdlPrv:=HeadProva(cLoteAtf,"ATFA360",Substr(cUsername,1,6),@cArquivo)
  	EndIf
  	
  	If VerPadrao(cPadrao) .And. nHdlPrv > 0 		
		nTotal += DetProva( nHdlPrv, cPadrao, "ATFA360", cLoteAtf, /*nLinha*/, /*lExecuta*/,;
		                    /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
		                    /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณApaga as movimenta็๕es do SN4ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//			
	If SN4->(MSSeek(xFilial("SN4")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO+DtoS(SN3->N3_AQUISIC)+"05"+SN3->N3_SEQ))
		While SN4->(N4_FILIAL+N4_CBASE+N4_ITEM+N4_TIPO+DtoS(N4_DATA)+N4_OCORR+N4_SEQ) ==;
				xFilial("SN4")+SN3->N3_CBASE+SN3->N3_ITEM+SN3->N3_TIPO+DtoS(SN3->N3_AQUISIC)+"05"+SN3->N3_SEQ .And.;
				SN4->(!EOF())
			RecLock("SN4",.F.)
			dbDelete()
			FkCommit()
			msUnlock()
			SN4->(dbSkip())
		EndDo
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ
	//ณEstorno os saldosณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤ

	//Reavalia็ใo
	If SN5->(MsSeek(xFilial("SN5")+SN3->N3_CCONTAB+DtoS(SN3->N3_AQUISIC)+"3"))
		//********************************
		// Controle de multiplas moedas  *
		//********************************
		If lMultMoed
			aValorMoed	:= AtfMultMoe("SN3","N3_VORIG")
		EndIf
		ATFSaldo(SN3->N3_CCONTAB,SN3->N3_AQUISIC,"3", SN3->N3_VORIG1,SN3->N3_VORIG2,SN3->N3_VORIG3,;
			SN3->N3_VORIG4,SN3->N3_VORIG5 ,"-",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed )
	Endif
	//Depreciacao acumulada
	
	If SN5->(MsSeek(xFilial("SN5")+SN3->N3_CCONTAB+DtoS(SN3->N3_AQUISIC)+"4"))
		//********************************
		// Controle de multiplas moedas  *
		//********************************	
		If lMultMoed
			aValorMoed	:= AtfMultMoe("SN3","N3_VRDACM")
		EndIf
		ATFSaldo(SN3->N3_CCDEPR ,SN3->N3_AQUISIC,'4', SN3->N3_VRDACM1,SN3->N3_VRDACM2,SN3->N3_VRDACM3 ,;
			SN3->N3_VRDACM4,SN3->N3_VRDACM5 ,"-",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4", aValorMoed )
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณApaga o registro do SN3ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	RecLock("SN3",.F.)
	SN3->(dbDelete())
	FkCommit()
	MsUnlock()
          
EndIf

RestArea(aArea)	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf360Reav บAutor  ณAlvaro Camillo Neto บ Data ณ  28/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a reavalia็ใo do bem                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA360                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Af360Reav(cBase,cItem,cTipo,dDataReav,cBaixa)   
Local lRet 		:= .T.
Local aArea		:= GetArea()
Local nX			:= 0
Local aValores	:= {}
Local cTipoN3	:= ""
Local cPadrao 	:= "80A"
Local cChaveSN3:= ""
Local cSeq	  	:= ""
Local cSeqReav	:= ""
Local aValorMoed
SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
SN1->(dbSetOrder(1)) //N1_FILIAL+N1_CBASE+N1_ITEM

If SN3->(MsSeek(xFilial("SN3") + cBase + cItem + cTipo + cBaixa)) .And. SN1->(MsSeek(xFilial("SN1") + cBase + cItem))
	
	// Cria a capado lote caso nใo tenha sido criada
	If VerPadrao(cPadrao) .And. Empty(nHdlPrv)
		nHdlPrv:=HeadProva(cLoteAtf,"ATFA360",Substr(cUsername,1,6),@cArquivo)
  	EndIf
  	
  	RegToMemory("SN3", .F.) 
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤeLฟ
	//ณDecide o tipo de bem de reavalia็ใo a ser criado               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤeLู
	If M->N3_VORIG1 > M->N3_VRDACM1    
		cTipoN3 := "41"
	Else
		cTipoN3 := "42"
	EndIf          
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRealiza o calculo dos valores de deprecia็ใo acumulada e ณ
	//ณvalor original do bem                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aValores := AF360Calc(cBase,cItem,dDataReav,M->N3_BAIXA)
	If aValores[1][1] > 0
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤี“
		//ณRealiza a grava็ใo do SN3ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤี“
		
		cSeq 		:= AF360UltReav(cBase,cItem,"N3_SEQ")  
		cSeqReav 	:= AF360UltReav(cBase,cItem,"N3_SEQREAV")
		cSeq		:= IIF(!Empty(cSeq),Soma1(cSeq),StrZero(1,TamSx3("N3_SEQ")[1])) 
		cSeqReav	:= IIF(!Empty(cSeqReav),Soma1(cSeqReav),StrZero(1,TamSx3("N3_SEQREAV")[1])) 
		
		RecLock("SN3",.T.)
			SN3->N3_FILIAL		:=	SN1->N1_FILIAL
			SN3->N3_CBASE 		:=	SN1->N1_CBASE
			SN3->N3_ITEM  		:=	SN1->N1_ITEM
			SN3->N3_TIPO		:= cTipoN3
			SN3->N3_BAIXA 		:=	M->N3_BAIXA
			SN3->N3_DTBAIXA 	:=	M->N3_DTBAIXA
			 
			SN3->N3_SEQ			:= cSeq
			SN3->N3_SEQREAV	:= cSeqReav
			SN3->N3_HISTOR		:=	STR0025 + DtoC(dDataReav) // "Reavalia็ใo anual realizada em "
			SN3->N3_CCONTAB	:=	M->N3_CCONTAB 
			SN3->N3_CUSTBEM	:=	M->N3_CUSTBEM 
			SN3->N3_CDEPREC	:=	M->N3_CDEPREC 
			SN3->N3_CCUSTO		:=	M->N3_CCUSTO
			SN3->N3_CCDEPR		:=	M->N3_CCDEPR 
			SN3->N3_CDESP		:=	M->N3_CDESP 
			SN3->N3_CCORREC	:=	M->N3_CCORREC
			SN3->N3_AQUISIC	:=	dDataReav
			SN3->N3_DINDEPR	:=	RetDinDepr(dDataReav) 
			SN3->N3_FIMDEPR	:=	M->N3_FIMDEPR  
			SN3->N3_CCDESP		:=	M->N3_CCDESP  
			SN3->N3_CCCDEP		:=	M->N3_CCCDEP  
			SN3->N3_CCCDES		:=	M->N3_CCCDES  
			SN3->N3_CCCORR		:=	M->N3_CCCORR   
			SN3->N3_SUBCTA		:=	M->N3_SUBCTA  
			SN3->N3_SUBCCON	:=	M->N3_SUBCCON  
			SN3->N3_SUBCDEP	:=	M->N3_SUBCDEP  
			SN3->N3_SUBCCDE	:=	M->N3_SUBCCDE  
			SN3->N3_SUBCDES	:=	M->N3_SUBCDES  
			SN3->N3_SUBCCOR	:=	M->N3_SUBCCOR  
			SN3->N3_FILORIG	:=	SN1->N1_FILIAL
			SN3->N3_CLVL 		:=	M->N3_CLVL  
			SN3->N3_CLVLCON	:=	M->N3_CLVLCON  
			SN3->N3_CLVLDEP	:=	M->N3_CLVLDEP  
			SN3->N3_CLVLCDE	:=	M->N3_CLVLCDE  
			SN3->N3_CLVLDES	:=	M->N3_CLVLDES  
			SN3->N3_CLVLCOR	:=	M->N3_CLVLCOR  
			SN3->N3_TPDEPR		:=	SuperGetMv("MV_TIPDEPR")
			SN3->N3_LOCAL		:=	SN1->N1_LOCAL
			SN3->N3_NOVO 		:=	"N"
			SN3->N3_QUANTD		:=	SN1->N1_QUANTD
	
			If cPaisLoc == "CHI"
				SN3->N3_CLVRCOA	:=	M->N3_CLVRCOA
				SN3->N3_CLVRDEA	:=	M->N3_CLVRDEA
			EndIf
			
			For nX := 1 to Len (aValores)
				SN3->&("N3_VORIG"+cValtoChar(nX))		:=	aValores[nX][1]
				SN3->&("N3_TXDEPR"+cValtoChar(nX))		:= IIF(cTipoN3 == '41', M->&("N3_TXDEPR"+cValtoChar(nX)), 0.00 )
				SN3->&("N3_VRDACM"+cValtoChar(nX))		:=	aValores[nX][2]
			Next nX					
		MsUnLock()
		cChaveSN3 := SN3->(N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ)
		//Grava o Movimento de reavalia็ใo de ativo - Conta do Bem 
		Af360GrSN4(cChaveSN3,'05','1')
		//Grava o Movimento de reavalia็ใo de ativo - Conta de deprecia็ใo acumulada
		Af360GrSN4(cChaveSN3,'05','4')
		
		//********************************
		// Controle de multiplas moedas  *
		//********************************	
		If lMultMoed
			aValorMoed	:= AtfMultMoe("SN3","N3_VORIG")
		EndIf
		// Atualiza os saldos do Bem
		//Faz o movimento do tipo reavalia็ใo
	 	ATFSaldo(	SN3->N3_CCONTAB,SN3->N3_AQUISIC,'3', SN3->N3_VORIG1,SN3->N3_VORIG2,SN3->N3_VORIG3 ,;
	 		SN3->N3_VORIG4,SN3->N3_VORIG5 ,"+",,SN3->N3_SUBCCON,,SN3->N3_CLVLCON,SN3->N3_CUSTBEM,"1", aValorMoed )
		//********************************
		// Controle de multiplas moedas  *
		//********************************	
		If lMultMoed
			aValorMoed	:= AtfMultMoe("SN3","N3_VRDACM")
		EndIf
		//Depreciacao acumulada 
		ATFSaldo(	SN3->N3_CCDEPR ,SN3->N3_AQUISIC,'4', SN3->N3_VRDACM1,SN3->N3_VRDACM2,SN3->N3_VRDACM3 ,;
			SN3->N3_VRDACM4,SN3->N3_VRDACM5 ,"+",,SN3->N3_SUBCCDE,,SN3->N3_CLVLCDE,SN3->N3_CCCDEP,"4",  )
									
		If VerPadrao(cPadrao) .And. nHdlPrv > 0 		
		
			nTotal += DetProva( nHdlPrv, cPadrao, "ATFA360", cLoteAtf, /*nLinha*/, /*lExecuta*/,;
			                    /*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
			                    /*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )
		EndIf
	EndIf
EndIf

RestArea(aArea)	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF360Calc บAutor  ณAlvaro Camillo Neto บ Data ณ  30/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza o calculo dos valores de deprecia็ใo acumulada e   บฑฑ
ฑฑบ          ณ valor original do bem                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA360                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF360Calc(cBase,cItem,dDataReav,cBaixa)
Local aValores := Array(5)
Local aArea		:= GetArea()
Local aValor	:= {}
Local dUltReav := AF360UltReav(cBase,cItem,"N3_AQUISIC",cBaixa)	
Local cAno		:= ""                                           
Local cMEs		:= ""
Local nVOrRea	:= 0 // Valor de aquisi็ใo da reavalia็ใo
Local nVDARea	:= 0 // Amortiza็ใo acumulada da reavalia็ใo
Local nCoef		:= 0 // Coeficiente de amortiza็ใo
Local nMoeda	:= 0 
Local nValAux	:= 0
Local nDepAux	:= 0                                          
Local lMensal
//********************************
// Controle de multiplas moedas  *
//********************************
Local __nQuantas := If(lMultMoed,AtfMoedas(),5)

// Retorn o coeficiente de acordo com o ano da ultima reavalia็ใo do bem
cAno	:= cValtoChar( Year( dUltReav ) )                              
lMensal 	:= MV_PAR09 == 1
if lMensal
	cMEs	:= Alltrim( Strzero(Month(dUltReav),2) )
	IF  cBaixa !="0"
		nCoef := Posicione("SIE",1,xFilial("SIE") + cAno + cMEs ,"IE_INDBAIX" )	
	ELSE
		nCoef := Posicione("SIE",1,xFilial("SIE") + cAno + cMEs ,"IE_INDICE" )
	ENDIF                                            
ELSE
	nCoef := Posicione("SIE",1,xFilial("SIE") + cAno,"IE_INDICE" )
ENDIF                                            	                                                 

// Retorna a soma da deprecia็ใo e do valor original na moeda 1
aValor := AF360RetVal(cBase,cItem,dDataReav,cBaixa)

//Realiza o calculo
nVOrRea := (aValor[1] * nCoef) - aValor[1] 
nVDARea := (aValor[2] * nCoef) - aValor[2] 
aValores[1] := {nVOrRea,nVDARea}             

//Corrige o valor para as outras moedas
//********************************
// Controle de multiplas moedas  *
//********************************
For nMoeda := 2 to __nQuantas
	nValAux := xMoeda(nVOrRea,1,nMoeda,dDataReav)
	nDepAux := xMoeda(nVDARea,1,nMoeda,dDataReav)
	aValores[nMoeda] := {nValAux,nDepAux}  
Next nMoeda  

RestArea(aArea)
Return aValores

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf360GrSN4บAutor  ณAlvaro Camillo Neto บ Data ณ  08/31/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a grava็ใo do movimento contแbil                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA360                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Af360GrSN4(cChaveSN3,cOccor,cTipCnt)
Local aArea := GetArea()
Local lUsaFlag	:= SuperGetMV( "MV_CTBFLAG" , .T. , .F. ) 
Local lUsaCorr :=  UsaSeqCor() .AND. Type("aCtbDia") == "A"

SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

If SN3->(MsSeek(cChaveSN3))
	RecLock("SN4",.T.)
		SN4->N4_FILIAL	:= SN3->N3_FILIAL
		SN4->N4_CBASE	:= SN3->N3_CBASE
		SN4->N4_ITEM 	:= SN3->N3_ITEM
		SN4->N4_TIPO 	:= SN3->N3_TIPO
		SN4->N4_OCORR	:= cOccor
		SN4->N4_TIPOCNT:= cTipCnt
		SN4->N4_DATA	:= SN3-> N3_AQUISIC
		SN4->N4_QUANTD	:= SN3-> N3_QUANTD
		SN4->N4_LOCAL	:= SN3->N3_LOCAL
		SN4->N4_SEQ		:= SN3->N3_SEQ    
		SN4->N4_SEQREAV:= SN3->N3_SEQREAV

		If cPaisLoc == "RUS"
			 SN4->N4_UID	:= RU01UUIDV4()
		EndIF
		If cTipCnt == '4' // Conta de depreciacao acumulada
			SN4->N4_CONTA	:= SN3->N3_CCDEPR

			//********************************
			// Controle de multiplas moedas  *
			//********************************
			If lMultMoed
				AtfMultMoe("SN4","N4_VLROC",{|x| SN3->&(If(x>9,"N3_VRDAC","N3_VRDACM")+Alltrim(Str(x))) })
			Else
				SN4->N4_VLROC1	:= SN3->N3_VRDACM1
				SN4->N4_VLROC2	:= SN3->N3_VRDACM2
				SN4->N4_VLROC3	:= SN3->N3_VRDACM3
				SN4->N4_VLROC4	:= SN3->N3_VRDACM4
				SN4->N4_VLROC5	:= SN3->N3_VRDACM5
			EndIf
			SN4->N4_CCUSTO	:= SN3->N3_CCCDEP
			SN4->N4_SUBCTA	:= SN3->N3_SUBCCDE
			SN4->N4_CLVL	:= SN3->N3_CLVLCDE
		Else // Contas do Bem
			SN4->N4_CONTA	:= SN3->N3_CCONTAB
			//********************************
			// Controle de multiplas moedas  *
			//********************************
			If lMultMoed
				AtfMultMoe("SN4","N4_VLROC",{|x| SN3->&("N3_VORIG"+Alltrim(Str(x))) })
			Else
				SN4->N4_VLROC1	:= SN3->N3_VORIG1
				SN4->N4_VLROC2	:= SN3->N3_VORIG2
				SN4->N4_VLROC3	:= SN3->N3_VORIG3
				SN4->N4_VLROC4	:= SN3->N3_VORIG4
				SN4->N4_VLROC5	:= SN3->N3_VORIG5
			EndIf
			SN4->N4_CCUSTO	:= SN3->N3_CUSTBEM
			SN4->N4_SUBCTA	:= SN3->N3_SUBCTA
			SN4->N4_CLVL	:= SN3->N3_CLVL
		EndIf 
	MsUnLock()

	If VerPadrao(cPadrao) .And. nHdlPrv > 0 
			
		If lUsaCorr  
			aAdd(aCtbDia,{"SN4",SN4->(RECNO()),"","N4_NODIA","N4_DIACTB"})
		EndIF
		  
		If lUsaFlag  
			aAdd( aFlagCTB, {"N4_DCONTAB", SN3->N3_AQUISIC , "SN4", SN4->( Recno() ), 0, 0, 0} ) 
		Else
			RecLock("SN4",.F.)
				SN4->	N4_DCONTAB	:= SN3->N3_AQUISIC
			MsUnlock()
		Endif
	EndIf
EndIf  

RestArea(aArea)
Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณaf360Displayณ Autor ณ Alvaro Camillo Netoณ Data ณ 28/08/09 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณAtualiza tela de seleao de registros da baixa autom tica 	ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ ATFA360														ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function af360Display(cMarca,lInverte,oQtda)

If IsMark("N3_OK",cMarca,lInverte)
	 nQtdBens++
Else
	 nQtdBens--
	 nQtdBens:= Iif(nQtdBens<0,0,nQtdBens)
End
oQtda:Refresh()

Return

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno	 ณaf360Marcaณ Autor ณ Alvaro Camillo Neto ณ Data ณ 28/08/09   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Marca e desmarca itens  									         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso		 ณ ATFA360												             	  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Af360Marca(cAlias,cMarca,lInverte,oQtda,cBaseI,cItemI,cBaseF,cItemF,dDataReav,lTodos, lCancela)
Local aArea := GetArea()

DEFAULT lInverte := .F.
DEFAULT lTodos := .T.

SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ

If lTodos
	(cAlias)->(dbGoTop())
Endif	

While !lTodos .Or. (cAlias)->(!EOF())
	If Af360Vld((cAlias)->N3_CBASE,(cAlias)->N3_ITEM,(cAlias)->N3_TIPO,(cAlias)->N3_SEQ,dDataReav, !lTodos,lCancela ) 
		RecLock(cAlias, .F. )
		If lInverte 
		 	If (cAlias)->N3_OK == cMarca
		 		(cAlias)->N3_OK := ""
		 		nQtdBens--
		 		nQtdBens:= Iif (nQtdBens <=0,0,nQtdBens) 
		 	Else
		 		 (cAlias)->N3_OK := cMarca
				 nQtdBens++
			EndIf  
			oQtda:Refresh()		 
		 Else
			 (cAlias)->N3_OK := cMarca
			 nQtdBens++
		 EndIf
		 MsUnLock()
	Endif		 
	If !lTodos
		Exit
	Endif
	(cAlias)->(dbSkip())
EndDo

If lTodos
	(cAlias)->(dbGoTop())
EndIf

RestArea(aArea)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAf360Vld บAutor  ณAlvaro Camillo Neto บ Data ณ  28/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFun็ใo que valida se a linha pode ser marcada               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ ATFA360                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
	Static Function Af360Vld(cBase,cItem,cTipo,cSeq, dDataReav, lMostraHelp,lCancela )
Local aArea   		:= GetArea()
Local lRet	  		:= .T.
Local cHelp	  		:= ""
Local cAnoBem 		:= ""
Local cMesBem 		:= ""
Local dUltReav		:= Stod("")
Local aValores 	:= {}
Local cTipVal		:= IIF(lCancela,"41/42","01")
Local dUltDepr		:= SuperGetMv("MV_ULTDEPR")   
Local lMensal

Default lMostraHelp := .T.

SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
SIE->(dbSetOrder(1)) //IE_FILIAL+IE_EXERCIC+IE_MES+
lMensal 	:= MV_PAR09 == 1

//Valida o tipo do bem
If lRet .And. !(cTipo $ cTipVal)
	lRet := .F.
	cHelp := "AF360TPIN"
EndIf

//Valida se o bem do tipo 01 existe e nใo estแ baixado 
If lRet .And. ( !SN3->(MsSeek(xFilial("SN3") + cBase + cItem + cTipo + "0" + cSeq )) .Or.  (SN3->N3_BAIXA > "0" )) 
	If (!lMensal).OR. (lRet .And. ( !SN3->(MsSeek(xFilial("SN3") + cBase + cItem + cTipo + "1" + cSeq )) .Or.((SN3->N3_DTBAIXA < FIRSTDAY(dUltDepr)) .or.((SN3->N3_DTBAIXA > LASTDAY(dUltDepr)) ))))
		lRet := .F.
		cHelp := "AF360NAOAC"
	EndIf		
EndIf

// Valida se o bem de reavalia็ใo a ser cancelado tem a sua data de aquisi็ใo depois do ultimo calculo de deprecia็ใo
If lRet .And. lCancela .And. dUltDepr > SN3->N3_AQUISIC
	lRet := .F.
	cHelp := "AF360DTIN"
EndIf

//Valida se o bem jแ foi reavaliado esse ano
If lRet .And. !lCancela
	dUltReav := AF360UltReav(cBase,cItem,"N3_AQUISIC")
	If lMensal 
		If Empty(dUltReav) .Or. ((Month(dUltReav) >= Month(dDataReav) ) .AND.(Year(dUltReav) >= Year(dDataReav) ))
			lRet := .F.
			cHelp := "AF360JAREA"
		EndIf 
	Else
		If Empty(dUltReav) .Or. Year(dUltReav) >= Year(dDataReav) 
			lRet := .F.
			cHelp := "AF360JAREA"
		EndIf 		
	EndIf
EndIf

//Valida se hแ coeficiente de corre็ใo monetaria para o bem
If lRet .And. !lCancela
	cAnoBem := cValToChar(Year(dUltReav)) 
	If lMensal
		cMesBem := Alltrim( Strzero(Month(dUltReav),2) )
		If !SIE->(MsSeek(xFilial("SIE") + cAnoBem + cMesBem ))
			lRet := .F.
			cHelp := "AF360COEF"
		EndIf 
	Else
		If !SIE->(MsSeek(xFilial("SIE") + cAnoBem ))
			lRet := .F.
			cHelp := "AF360COEF"
		EndIf
	EndIf 
EndIf 

// Valida se o bem jแ foi depreciado
If lRet .And. !lCancela
	aValores := AF360RetVal(cBase,cItem,dDataReav,SN3->N3_BAIXA)
	
	If Empty( aValores[2]  )  // Depreciacao na moeda 1  
		lRet := .F.     
		cHelp := "AF360NAODEP"
	EndIf
EndIf 

If !lRet .And. lMostraHelp
	Help(" ",1,cHelp)
EndIf 

RestArea(aArea)
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF360RetValบAutorณAlvaro Camillo Neto  บ Data ณ  28/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna os valores de aquisicao e depreciacao acumulada    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF360RetVal(cBase,cItem,dDataAq,cBaixa)
Local aArea 	:= GetArea()
Local aRet  	:= {0,0}
Local cQuery	:= ""
Local cTab		:= GetNextAlias()     
Local dInidepr		:= Firstday(SuperGetMv("MV_ULTDEPR"))               
Local dFIMdepr		:= Lastday(SuperGetMv("MV_ULTDEPR"))               
Local lMensal
Local cTypes10		:= IIF(lIsRussia,AtfNValMod({1}, "|"),"") // CAZARINI - 24/03/2017 - If is Russia, add new valuations models - main models
Local aTypes10		:= {}
Local nTypes10		:= 0

If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf        
lMensal 	:= MV_PAR09 == 1

cQuery += " SELECT N3_CBASE,N3_ITEM, "
cQuery += " SUM(N3_VORIG1) N3_VORIG1 ,"  
cQuery += " SUM(N3_VRDACM1) N3_VRDACM1 "
cQuery += " FROM " 
cQuery +=  	RetSQLTab("SN3")
cQuery += " WHERE  "
cQuery += " 	N3_CBASE = '"+cBase+"' AND "
cQuery += " 	N3_ITEM	= '"+cItem+"' AND "         
If !lIsRussia // CAZARINI - Flag to indicate if is Russia location
	cQuery += " 	N3_TIPO IN( '01','02','07','10','41','42','43') AND "
Else
	aTypes10 := Separa(cTypes10, '|', .f.)
		
	If len(aTypes10) = 0
		cQuery += " 	N3_TIPO IN( '01','02','07','10','41','42','43') AND "
	Else
		cQuery += " 	N3_TIPO IN( '01','02','07','10','41','42','43'"
					
		For nTypes10 := 1 to len(aTypes10)
			cQuery += ",'" + aTypes10[nTypes10] + "')"
		Next nTypes10
			
		cQuery += "			) AND "
	Endif
Endif
cQuery += " 	N3_AQUISIC <= '"+dtoS(dDataAq)+"' AND "              
If lMensal 
	cQuery += " 	N3_BAIXA	= '"+cValtoChar(cBaixa)+"' AND "         
	cQuery += " 	((N3_BAIXA = '0') or (N3_DTBAIXA >="+ dtoS(dInidepr) +" AND N3_DTBAIXA <= "+ dtoS(dFIMdepr)+ ")) AND "           
Else
	cQuery += " 	N3_BAIXA = '0' AND "
Endif
cQuery += RetSQLCond("SN3") 
cQuery += " GROUP BY "
cQuery += " 	N3_CBASE, "
cQuery += " 	N3_ITEM "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T., "TOPCONN",TCGenQry(,,cQuery), cTab, .F., .T.)

If (cTab)->(!EOF())
	aRet[1] := (cTab)->N3_VORIG1
	aRet[2] := (cTab)->N3_VRDACM1
EndIf 

If Select(cTab) > 0
	(cTab)->(dbCloseArea())
EndIf

RestArea(aArea)
Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAF360UltReavบAutorณALvaro Camillo Neto บ Data ณ  28/08/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna os dados da ultima movimenta็ใo do Bem              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AF360UltReav(cBase,cItem,cCpo,cBaixa)
Local xRet 		:= Nil
Local aArea		:= GetArea()
Local cTipoCpo := Posicione("SX3",2,cCpo,"X3_TIPO")
Local dInidepr		:= Firstday(SuperGetMv("MV_ULTDEPR"))
Local lMensal  := MV_PAR09 == 1
Default cBaixa := ""

If ValType(cTipoCpo) == "C"
	xRet := IIF(Empty(xRet),"",xRet)
ElseIf ValType(cTipoCpo) == "D"
	xRet := IIF(Empty(xRet),Stod(""),xRet)
ElseIf ValType(cTipoCpo) == "N"
	xRet := IIF(Empty(xRet),0,xRet)
EndIf
                                             

SN3->(dbSetOrder(1)) //N3_FILIAL+N3_CBASE+N3_ITEM+N3_TIPO+N3_BAIXA+N3_SEQ
SN3->(MsSeek( xFilial("SN3") + cBase + cItem ))

While SN3->(N3_FILIAL+N3_CBASE+N3_ITEM) == xFilial("SN3") + cBase + cItem .And. SN3->(!EOF())
	If lMensal 	
		If (((SN3->N3_BAIXA == '0') .OR. (month(SN3->N3_DTBAIXA)==month(dInidepr))) .AND. (cBaixa =="" .OR. cBaixa  == SN3->N3_BAIXA ) )
			xRet := SN3->&(cCpo) 
		EndIf
	Else
		If SN3->N3_BAIXA == '0'
			xRet := SN3->&(cCpo) 
		EndIf	
	EndIf
	SN3->(dbSkip())
EndDo  

If ValType(xRet) == "C"
	xRet := Alltrim(xRet)
EndIf

RestArea(aArea)
Return xRet 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma  ณMenuDef   ณ Autor ณ Ana Paula N. Silva     ณ Data ณ08/12/06 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Utilizacao de menu Funcional                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณArray com opcoes da rotina.                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณParametros do array a Rotina:                               ณฑฑ
ฑฑณ          ณ1. Nome a aparecer no cabecalho                             ณฑฑ
ฑฑณ          ณ2. Nome da Rotina associada                                 ณฑฑ
ฑฑณ          ณ3. Reservado                                                ณฑฑ
ฑฑณ          ณ4. Tipo de Transao a ser efetuada:                        ณฑฑ
ฑฑณ          ณ		1 - Pesquisa e Posiciona em um Banco de Dados     ณฑฑ
ฑฑณ          ณ    2 - Simplesmente Mostra os Campos                       ณฑฑ
ฑฑณ          ณ    3 - Inclui registros no Bancos de Dados                 ณฑฑ
ฑฑณ          ณ    4 - Altera o registro corrente                          ณฑฑ
ฑฑณ          ณ    5 - Remove o registro corrente do Banco de Dados        ณฑฑ
ฑฑณ          ณ5. Nivel de acesso                                          ณฑฑ
ฑฑณ          ณ6. Habilita Menu Funcional                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ          ณ               ณ                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef()
Local aRotina := { { STR0001,"AxPesqui"  , 0 , 1 , ,.F.},;  //"Pesquisar"
						{ STR0002, "ATFVISUAL"  , 0 , 2},;  		//"Visualizar"
						{ STR0003, 'AF360Auto("SN3",SN3->(Recno()),6,.F.)'  , 0 , 6},;  // "Reavaliar"
						{ STR0004, 'AF360Auto("SN3",SN3->(Recno()),6,.T.)'  , 0 , 6},;  // "Cancelar Reav"
						{ STR0005, "AtfLegenda", 0 , 3 , ,.F. } }		// "Legenda"						
Return(aRotina)
