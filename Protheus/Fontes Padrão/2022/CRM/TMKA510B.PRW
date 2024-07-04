#INCLUDE "PROTHEUS.CH"      
#INCLUDE "TMKA510B.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออหอออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHelpDeskSubjectDialog บAutorณVendas Cliente   บ Data ณ  11/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออสอออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     |Funcoes de tela para o cadastro de Assuntos.                       บฑฑ 
ฑฑบ          ณ                                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/
Class HelpDeskSubjectDialog


Method new() Constructor  
Method showDialog()
Method openBrowse()
EndClass     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออหอออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณopenBrowse            บAutorณVendas Cliente   บ Data ณ  11/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออสอออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     |Inicia o Browse para lista de assuntos por Grupo de Atendimento.   บฑฑ 
ฑฑบ          ณ                                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                              บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿     
*/ 
Method openBrowse() Class HelpDeskSubjectDialog

Local aIndexSU0 := {}

Private cCadastro 	:= STR0001	//	"Assuntos x Grupos de Atendimento"
Private aRotina		:= {{ 	STR0002	,"AxPesqui" ,0,1 },; 	// 	"Pesquisar"
						{	STR0003	,"TK510Opc" ,0,2 },;   //	"Visualizar"
					 	{ 	STR0004 ,"TK510Opc" ,0,4 }}   	//	"Alterar"

SU0->(DbSetOrder(1))                          
FilBrowse("SU0",@aIndexSU0,"Empty(SU0->U0_FILORI) .AND. Empty(SU0->U0_GRPORI)")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Endereca a funcao de BROWSE                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู    
MBrowse(,,,,"SU0")

EndFilBrw("SU0",aIndexSU0)

Return Nil      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNew          บAutor  ณVendas Cliente   บ Data ณ  15/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMetodo construtor da classe.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method new() Class HelpDeskSubjectDialog  

Return Self        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณshowDialog   บAutor  ณVendas Cliente   บ Data ณ  15/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe a tela de edicao dos assuntos x grupo de atendimento  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Method showDialog(nGroup, nOpc) Class HelpDeskSubjectDialog  

Local aArea		:= GetArea()
Local aObjects 	:= {}
Local aSize		:= MsAdvSize(.T.,.F.,400)	//Array com as dimensoes da tela
Local nOpcA 	:= 0
Local nCol          
Local cSeek		:= ""
Local cWhile         
Local cQuery	:= ""     
Local bAfterCols := Nil  
Local bCond    
Local aColsSKK := {}
Local aHeaderSKK := {}
Local nHeader	:= 0
Local aGrpComp	:= {}						// Lista de replicas do grupo atual em outras filiais
Local aAreaSU0	:= {}
Local aAreaSM0	:= {}
Local cGrupoAtu	:= ""
Local cFilterSU0:= ""
Local cFilSM0	:= ""
Local nFil		:= 0  
Local cFilAtu	:= cFilAnt
Local aAssxGrp	:= {}
Local nPosAssunt:= 0 
Local nPos		:= 0
Local nTamFil	:= FWSizeFilial()

Private aTela 	:= {} 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCalculo de coordenadas dos objetos da tela de acordo com as coordenada do painel.ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู  
aObjects := {}

AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo       := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPosObj     := MsObjSize( aInfo, aObjects,  , .F. )

DbSelectArea("SU0")         
DbSetOrder(1)
DbGoTo(nGroup)

cGrupoAtu	:= SU0->U0_CODIGO 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMonta lista das replicas deste grupo em outras filiaisณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aAreaSU0 := SU0->(GetArea())

DbSelectArea("SIX")
DbSetOrder(1)

If DbSeek("SU04") .AND. AllTrim(SIX->CHAVE) == "U0_FILIAL+U0_FILORI+U0_GRPORI" 
    
    aAreaSM0 	:= SM0->(GetArea())                             
 	cFilterSU0	:= SU0->(DbFilter()) 	
 	SU0->(DbClearFilter())
	
	DbSelectArea("SU0")
	DbSetOrder(4) //U0_FILIAL+U0_FILORI+U0_GRPORI  
	
	SM0->(DbSetOrder(1))
	SM0->(DbSeek(cEmpAnt))  
	
	While SM0->(!Eof()) .AND. SM0->M0_CODIGO == cEmpAnt
		cFilSM0 := Left(SM0->M0_CODFIL,nTamFil)
		If cFilSM0 <> cFilAnt .AND. SU0->(DbSeek(cFilSM0 + cFilAnt + cGrupoAtu))
			AAdd(aGrpComp,{ cFilSM0, SU0->U0_CODIGO })
		EndIf
		SM0->(DbSkip())
	End 

	RestArea(aAreaSM0)
	
	DbSelectArea("SU0")
	Set Filter To &cFilterSU0
	
EndIf   

RestArea(aAreaSU0)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณMontagem aHeader, aColsณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
#IFDEF TOP
	cQuery := "SELECT * " //KK_FILIAL, KK_CODSU0, KK_CODSKQ,
	cQuery += "FROM "+RetSqlName("SKK")+" SKK  WHERE "
	cQuery += "SKK.KK_FILIAL = '" + xFilial("SKK") + "' AND "
	cQuery += "SKK.KK_CODSU0 = '" + SU0->U0_CODIGO + "' AND "
	cQuery += "SKK.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY SKK.KK_CODSKQ "	
#ENDIF	    
cSeek	:= xFilial("SKK") + SU0->U0_CODIGO
cWhile	:= "SKK->KK_FILIAL + SKK->KK_CODSU0"
bCond	:= {||IIf(SKK->KK_FILIAL == xFilial("SKK") .AND. SKK->KK_CODSU0 == SU0->U0_CODIGO,.T.,.F.)}    

If nOpc == 2 .Or. nOpc == 3 .OR. nOpc == 4
	bAfterCols := {||TK510AfterCols(nOpc)}
EndIf

DbSelectArea("SKK")
DbCloseArea() 
				
aHeader := {}
aCols	:= {} 
FillGetDados(	nOpc /*nOpcX*/, "SKK"/*cAlias*/, 1/*nIndex*/, cSeek/*cSeek*/,; 
				{||&(cWhile)}/*{||&cWhile}*/, bCond/*{|| bCond,bAct1,bAct2}*/, /*aNoFields*/,; 
				/*aYesFields*/, /*lOnlyYes*/, cQuery/*cQuery*/, /*bMontAcols*/, .F./*lEmpty*/,; 
				@aHeaderSKK/*aHeaderAux*/, @aColsSKK/*aColsAux*/, bAfterCols/*bAfterCols*/, /*bBeforeCols*/,;
				/*bAfterHeader*/, /*cAliasQry*/)				

RegToMemory("SU0",.F.)

DEFINE MSDIALOG oDlg TITLE STR0005 FROM  aSize[7], 0 TO aSize[6],aSize[5]  PIXEL OF oMainWnd // "Grupo de Atendimento x Assunto"
	Zero()
	nOpcA:=EnChoice("SU0",	nGroup,	2,	,	,;
					,,aPosObj[1],,,;
					,,,,,;
					,,,,) 					
	oGet:= MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"Tk510BLiOk()","Tk510BTdOk()","",.T.)						
				
                                	
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| (nOpcA := 1,oDlg:End())},{|| oDlg:End()} ) VALID Iif(!Tk510BTdOk(),(nOpcA := 0,.F.),.T.)

If nOpcA == 1

	DbSelectArea("SKK")
	DbSetOrder(1)   //KK_FILIAL+KK_CODSU0
	DbSeek(xFilial("SKK")+SU0->U0_CODIGO)	
	While(!EOF() .AND. SKK->KK_FILIAL == xFilial("SKK") .AND. SKK->KK_CODSU0 == SU0->U0_CODIGO)
		RecLock("SKK",.F.,.T.)
		DbDelete()
		MsUnlock()
		DbSkip()
	End	                            
	aColsSKK := aCols//oGet:aCols
	For nCol:=1 To Len(aColsSKK)              
		If !aColsSKK[nCol][Len(aColsSKK[nCol])]
			RecLock("SKK", .T.)		
			For nHeader:=1 To Len(aHeaderSKK)
				If (aHeaderSKK[nHeader][10] <> "V") 		// X3_CONTEXT				
					REPLACE SKK->&(aHeaderSKK[nHeader][2]) WITH aColsSKK[nCol][nHeader]				
				Endif		
			Next nHeader				
			REPLACE SKK->KK_CODSU0 WITH SU0->U0_CODIGO
			REPLACE SKK->KK_FILIAL WITH xFilial("SKK")
			MsUnlock()			
		EndIf
	Next nCol

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCompatilbiliza com a replica do grupo em outra filialณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(SKK->(DbFilter()))
		SKK->(DbClearFilter())
	EndIf
	
	nPosAssunt := aScan(aHeaderSKK,{|x| AllTrim(x[2]) == "KK_CODSKQ" })
	
	For nFil := 1 to Len(aGrpComp)
		
		aAssxGrp 	:= {}
		cFilAnt		:= aGrpComp[nFil,1]
	 	SKK->(DbSeek(xFilial("SKK")+aGrpComp[nFil,2]))
	 	
	 	While !SKK->(Eof()) .AND. SKK->KK_FILIAL == xFilial("SKK") .AND. SKK->KK_CODSU0 == aGrpComp[nFil,2]
	 		AAdd(aAssxGrp,{ SKK->KK_CODSKQ, SKK->(Recno()) })
	 		SKK->(DbSkip())
	 	End
	 	
	 	For nCol := 1 to Len(aColsSKK)

	 		nPos := 0

	 		If !aColsSKK[nCol][Len(aColsSKK[nCol])] .AND. (nPos := aScan(aAssxGrp,{|x| x[1] == aColsSKK[nCol][nPosAssunt]})) == 0
	 			//Grava assunto novo
				RecLock("SKK", .T.)		
				For nHeader:=1 To Len(aHeaderSKK)
					If (aHeaderSKK[nHeader][10] <> "V") 		// X3_CONTEXT				
						REPLACE SKK->&(aHeaderSKK[nHeader][2]) WITH aColsSKK[nCol][nHeader]				
					Endif		
				Next nHeader				
				REPLACE SKK->KK_CODSU0 WITH aGrpComp[nFil,2]
				REPLACE SKK->KK_FILIAL WITH xFilial("SKK")
				MsUnlock()
			ElseIf nPos > 0
				//Remove asuntos preexistentes da lista
				aDel(aAssxGrp,nPos)
				aSize(aAssxGrp,Len(aAssxGrp)-1)
	 		EndIf

	 	Next nCol
	 	
	 	//Remove assuntos que nao sao mais atendidos
	 	For nCol := 1 to Len(aAssxGrp)
	 		SKK->(DbGoTo(aAssxGrp[nCol,2]))
	 		RecLock("SKK",.F.)
	 		DbDelete()
	 		MsUnLock()
	 	Next nCol
	
	Next nX
	
	cFilAnt := cFilAtu

EndIf		
     
RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK510AfterColsบAutor ณVendas Clientes  บ Data ณ  22/01/08   บฑฑ
ฑฑฬออออออออออุออออออออออออออสออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPreenche o acols.                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function TK510AfterCols(nOpc) 

Local nItems  := 1
Local nRecno	:= Len(aHeader)

Local lCond	:= .F.

If nOpc == 2	//Visualziar
	lCond	:= Len(aCols) > 0 .AND. !Empty(aCols[1][nItems])
Else	//Alterar e demais opera็๕es
	lCond	:= Len(aCols) > 0 .AND. aCols[nItems,nRecno] > nRecno
EndIf

If lCond
	
	For nItems := 1 To Len(aHeader)
	
		If AllTrim(aHeader[nItems][2]) == "KK_CODSKQ"
			aCols[Len(aCols)][nItems] := SKK->KK_CODSKQ
		EndIf
		If AllTrim(aHeader[nItems][2]) == "KK_NMSKQ"
			aCols[Len(aCols)][nItems] := Alltrim(POSICIONE('SX5',1,xFilial('SX5')+'T1'+SKK->KK_CODSKQ,'X5DESCRI()'))
		EndIf
		
	Next nItems
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTK510Opc     บAutor  ณMichel W. Mosca  บ Data ณ  31/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe a tela para associar a lista de assuntos.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TK510Opc(cAlias,	nReg,	nOpc,	aEnchoice)   


If nOpc == 2
	oObj:showDialog(nReg, nOpc)	//"Visualizar"
ElseIf nOpc == 3	     
	oObj:showDialog(nReg, nOpc)	//"Visualizar"
ElseIf nOpc == 4	     
	oObj:showDialog(nReg, nOpc)	//"Visualizar"
EndIf
Return .T.                                         

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัอออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTMKA510B     บAutor  ณMichel W. Mosca  บ Data ณ  14/01/08   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯอออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExibe a tela para associar a lista de assuntos.             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP10                                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TMKA510B()    
Static oObj := HelpDeskSubjectDialog():New()

oObj:openBrowse()
Return .T.   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510BLiOkบAutor  ณVendas CRM          บ Data ณ  08/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao das linhas da getdados                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510B                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk510BLiOk()

Local lOk 		:= .T.
Local nLinAtu	:= N
Local nPAssunt	:= aScan(aHeader,{|x|AllTrim(x[2]) == "KK_CODSKQ"})
Local nX		:= 0

If nPAssunt > 0 .AND. !aTail(aCols[N])
	For nX := 1 to Len(aCols)
		If !aTail(aCols[nX]) .AND. (nX <> N) .AND. (aCols[N][nPAssunt] == aCols[nX][nPAssunt])
			lOk := .F.
			MsgAlert(STR0006 + aCols[N][nPAssunt] + STR0007 + cValToChar(nX) ) //"O assunto "###" jแ foi utilizado na linha "
		EndIf
	Next nX 
EndIf

Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTk510BTdOkบAutor  ณVendas CRM          บ Data ณ  08/08/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValidacao de toda a tela ao finalizar a edicao.             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณTMKA510B                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tk510BTdOk()
Local lRet := Tk510BLiOk()
Return lRet