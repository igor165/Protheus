#INCLUDE "PROTHEUS.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "FATA610.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FATA610     ³ Autor ³Eduardo Gomes Junior   ³ Data ³ 09/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Selecao de categoria e produtos					 			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aPrdSel - Array contendo os produtos selecionados		 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FATA610() 

Local aArea     	:= GetArea()
Local aSize     	:= MsAdvSize(.T.)
Local aInfo     	:= { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 5, 5 }
Local aObjects  	:= {{45,100,.T.,.T.},{55,100,.T.,.T.,.T.}}
Local aPosObj   	:= {}
Local nRecNo    	:= 0
Local oTree
Local oDlg
Local oPanel
Local aButtons 		:= {}													// Array usado para adicionar botoes na enchoice
Local oOkPrd     	:= LoadBitMap(GetResources(), "LBOK")
Local oNoPrd     	:= LoadBitMap(GetResources(), "LBNO")
Local aPrdItens		:= {}
Local aTitCampos 	:= {} 
Local oPrdItens
Local aPrdSel		:= {}
Local cCodVazio   	:= CriaVar("ACU_COD",.F.)
Local cProdVazio  	:= CriaVar("ACV_CODPRO",.F.)
Local cGrupoVazio 	:= Criavar("ACV_GRUPO",.F.)
Local cRecnoVazio 	:= StrZero(0,10)
Local nA			:= 0
Local lValGrupo		:= ExistBlock("FT610CAT") 								//Ponto de entrada para validar categoria de produtos selecionadas

Private cCadastro 	:= STR0001 												//"Selecao de categoria e produtos"

Aadd( aButtons, {"PESQUISA", {|| A610Pesq(@oPrdItens,@aPrdItens,@oTree ) }, STR0004 , STR0005 , {|| .T.}} ) 	//"Pesquisa categoria/produto"###"Pesquisa"
Aadd(aPrdItens,{.F.,Space(15),Space(30)}) 																		// Cria um linha em branco no array

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montagem da Interface                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aPosObj   := MsObjSize( aInfo,aObjects,.T.,.T.)

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

// Cria o Tree e preenche as informacoes
oTree := DbTree():New(aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4],oDlg,,,.T.)

A610MTree(oTree,cCodVazio,NIL,NIL,NIL,NIL,aPrdItens,cCodVazio,cProdvazio,cGrupoVazio,cRecnoVazio)

oPanel := TPanel():New(aPosObj[2,1],aPosObj[2,2],'',oDlg,oDlg:oFont,.T.,.T.,,,aPosObj[2,3],aPosObj[2,4],.T.,.T. )

oTree:bChange := {|| A610Produto(oTree,Substr(oTree:GetCargo(),2,6),aPrdItens,oPrdItens,aPrdSel) }

oPrdItens := TWBrowse():New( aPosObj[2,1]+5,aPosObj[2,2]+5,aPosObj[2,3]-10,aPosObj[2,4]-5,,{" ",STR0002,STR0003},,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,,)
oPrdItens:SetArray(aPrdItens)
oPrdItens:bLDblClick :=  { || aPrdItens[oPrdItens:nAt,1] := !aPrdItens[oPrdItens:nAt,1],A610ProdSel(aPrdItens,oPrdItens,aPrdSel)}
oPrdItens:bLine := { || {If(aPrdItens[oPrdItens:nAt,1],oOkPrd,oNoPrd),aPrdItens[oPrdItens:nAt,2],aPrdItens[oPrdItens:nAt,3]}}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End() } , {|| aPrdSel := {} , oDlg:End()},,aButtons)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para validar selecao de categoria e produtos ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If	lValGrupo

	lRetorno := ExecBlock( "FT610CAT", .F., .F.,{aPrdSel} )

	If 	ValType(lRetorno) <> "L"
		lRetorno := .F.
	Endif

	If	!lRetorno
		aPrdSel := {}
	Endif
	
Endif	

RestArea(aArea)

Return( aPrdSel )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A610MTree   ³ Autor ³Eduardo Gomes Junior   ³ Data ³ 09/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria Tree da categoria de produtos							³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum													 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oTree														³±±
±±³			 ³ cCodPai														³±±
±±³			 ³ lSeek1														³±±
±±³			 ³ cTexto														³±±
±±³			 ³ cCodCargo													³±±
±±³			 ³ lExplprod													³±±
±±³			 ³ aPrdItens													³±±
±±³			 ³ cCodVazio													³±±
±±³			 ³ cProdvazio													³±±
±±³			 ³ cGrupoVazio													³±±
±±³			 ³ cRecnoVazio													³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A610MTree(	oTree,			cCodPai,		lSeek1,			cTexto,;	
							cCodCargo,		lExplProd,		aPrdItens,		cCodVazio,;
							cProdvazio,		cGrupoVazio,	cRecnoVazio	)
Local nRec		:= 0
Local aArea		:= GetArea()
Local lCpBloq	:= (ACU->(FieldPos("ACU_MSBLQL")) > 0)
Local lFT610MT1 := ExistBlock("FT610MT1")
Local lFt610TXT	:= ExistBlock("FT610TXT")		//Ponto de Entrada para permitir a alteração da descrição da categoria
Local cProFil := ""
Local cFilTmp := ""

DEFAULT cTexto    := Space(130)
DEFAULT cCodCargo := ""
DEFAULT lExplProd := .F.
DEFAULT lSeek1    := .F.

dbSelectArea("ACV")
dbSetOrder(1)

dbSelectArea("ACU")
dbSetOrder(2)

If lFT610MT1
	cFilTmp := ExecBlock("FT610MT1",.F.,.F.,{cCodPai})
	If ValType("cFilTmp") == "C"
		cProFil := cFilTmp
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procura por uma categoria nao bloqueada (campo MSBLQL)³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lSeek1

	lSeek1:=MsSeek(xFilial("ACU")+cCodPai) .AND. (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))

	If !lSeek1 .AND. Found()
		While !lSeek1 .AND. !ACU->(Eof()) .AND. ACU->ACU_FILIAL == xFilial("ACU") .AND. ACU->ACU_CODPAI == cCodPai
			ACU->(DbSkip())
			lSeek1:= (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))			
		End
	EndIf

EndIf

If	lSeek1
	If !Empty(cCodPai) .And. !Empty(cTexto) .And. !Empty(cCodCargo)
		oTree:AddTree(cTexto,.T.,,,"BPMSEDT3","BPMSEDT3","1"+cCodCargo+cProdVazio+cGrupoVazio+cRecnoVazio)			
	Else
		oTree:AddTree(STR0001+Space(Len(ACU->ACU_DESC)+130),.T.,,,"BPMSEDT3","BPMSEDT3","1"+cCodVazio+cProdVazio+cGrupoVazio+cRecnoVazio)
	EndIf
                                                   
	While !EOF() .AND. ACU_FILIAL+ACU_CODPAI == xFilial("ACU")+cCodPai
		//Salta categorias bloqueadas
		If (lCpBloq  .AND. ACU->ACU_MSBLQL == '1')
			DbSkip()
			Loop
		End
		
		//Salta produtos que esta no filtro do produto retornado no ponto de entrada FT610MT1
		If !Empty(cProFil) .And. AllTrim(ACU_COD) $ cProFil
			DbSkip()
			Loop
		EndIf
		
		cCodCargo:=ACU_COD
		nRec:=Recno()
		cTexto:=ACU->ACU_DESC
        
		If lFt610Txt
		   cTexto := ExecBlock("FT610TXT",.F.,.F.)
		EndIf
		
		If ValType(cTexto) <> "C"
			cTexto := ACU->ACU_DESC
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Procura por uma categoria nao bloqueada (campo MSBLQL)³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lSeek1:=MSSeek(xFilial("ACU")+cCodCargo) .AND. (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))
		
		If !lSeek1 .AND. Found()
			While !lSeek1 .AND. !ACU->(Eof()) .AND. ACU->ACU_FILIAL == xFilial("ACU") .AND. ACU->ACU_CODPAI == cCodCargo
				ACU->(DbSkip())
				lSeek1:= (!lCpBloq .OR. (lCpBloq  .AND. ACU->ACU_MSBLQL <> '1'))			
			End
		EndIf	

		If !lSeek1
			If lExplProd .And. ACV->(MsSeek(xFilial("ACV")+cCodCargo))
				oTree:AddTree(cTexto,.T.,,,"BPMSEDT1","BPMSEDT1","1"+cCodCargo+cProdVazio+cGrupoVazio+cRecnoVazio)
				oTree:EndTree()
			Else
				oTree:AddTreeItem(cTexto,"BPMSEDT3","BPMSEDT3","1"+cCodCargo+cProdVazio+cGrupoVazio+cRecnoVazio)
			EndIf
		Else
			A610MTree(oTree,ACU_CODPAI,lSeek1,cTexto,cCodCargo,lExplProd,aPrdItens,cCodVazio,cProdvazio,cGrupoVazio,cRecnoVazio)
		EndIf
		dbGoto(nRec)
		dbSkip()
	End

	oTree:EndTree()	
	
EndIf

RestArea(aArea)

RETURN

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A610Produto ³ Autor ³Eduardo Gomes Junior   ³ Data ³ 09/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Carrega os produtos da categoria selecionada					³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oTree     													³±±
±±³          ³ cCod     													³±±
±±³          ³ aPrdItens													³±±
±±³          ³ oPrdItens													³±±
±±³          ³ aPrdSel														³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A610Produto(oTree,	cCod,	aPrdItens,	oPrdItens,;
							aPrdSel )

Local aArea		:= GetArea()
Local nD		:= 0
Local cQuery    
Local lFt610Wh2	:= ExistBlock("FT610WH2")
Local lFt610DPr	:= ExistBlock("FT610DPR")		//Ponto de Entrada para permitir a alteração da descrição do produto
Local cWherePE	:= ""
Local cDescProd := ""

For nD:=1 To Len(aPrdItens)
	Adel(aPrdItens,1)
	ASize(aPrdItens,Len(aPrdItens)-1)
Next nD		

If	Select("TR3")>0
	dbSelectArea("TR3")
	dbCloseArea()
Endif	

cQuery := "SELECT ACV.ACV_CATEGO, SB1.B1_DESC, SB1.B1_COD FROM "
cQuery += RetSqlName( "ACV" ) +  " ACV INNER JOIN "
cQuery += RetSqlName( "SB1" ) +  " SB1 "
cQuery += " ON (ACV.ACV_CODPRO = SB1.B1_COD) OR "
cQuery += " (ACV.ACV_GRUPO = SB1.B1_GRUPO AND "
cQuery += " SB1.B1_GRUPO <> ' ') " 
cQuery += " WHERE ACV.ACV_FILIAL = '"+ FWxFilial( 'ACV' ) +"' "
cQuery += " AND SB1.B1_FILIAL = '"+ FWxFilial( 'SB1' ) +"' "
cQuery += " AND ACV.ACV_CATEGO = '" + cCod + "' "

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Ponto de entrada para inclusao de clausulas no where³
//³da query                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFt610Wh2
	cWherePE	:= ExecBlock("FT610WH2",.F.,.F.) 
	If (ValType(cWherePE) == "C") .AND. !Empty(cWherePE)
		cQuery	+= " AND " + cWherePE + " "
	EndIf
EndIf

cQuery += " AND ACV.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' " 
cQuery += " GROUP BY ACV.ACV_CATEGO, SB1.B1_DESC, SB1.B1_COD "
cQuery += " ORDER BY SB1.B1_COD"

cQuery := ChangeQuery(cQuery)

dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), "TR3" , .F., .T. )

MsgRun( 'Carregando produtos...','Aguarde',{|| .T. })

dbSelectArea("TR3")

While TR3->(!EOF())

	cDescProd := TR3->B1_DESC
	
	If lFt610DPr
	   cDescProd := ExecBlock("FT610DPR",.F.,.F.,TR3->B1_COD)
	EndIf
	
	If ValType(cDescProd) <> "C"
		cDescProd := TR3->B1_DESC
	EndIf	

	Aadd( aPrdItens,{.F.,TR3->B1_COD,cDescProd,TR3->ACV_CATEGO } )

//	If	AScan( aPrdItens, { |x| x[2] == TR3->ACV_CODPRO } ) == 0
//		If	AScan( aPrdSel, { |x| x[1] == TR3->ACV_CODPRO } ) == 0
//			Aadd( aPrdItens,{.F.,TR3->ACV_CODPRO,TR3->B1_DESC,TR3->ACV_CATEGO } )
//		Else
//			Aadd( aPrdItens,{.T.,TR3->ACV_CODPRO,TR3->B1_DESC,TR3->ACV_CATEGO } )
//		Endif							
//	Endif

	dbSelectArea("TR3")
	dbSkip()

Enddo

If	Select("TRAUX")>0
	dbSelectArea("TRAUX") 
	dbCloseArea()
Endif

cQuery := "SELECT ACV_REFGRD"
cQuery += " FROM" + RetSqlName( "ACV" )
cQuery += " WHERE ACV_CATEGO ='" + cCod + "' AND"
cQuery += " ACV_REFGRD <> ' ' AND"
cQuery += " D_E_L_E_T_ = ' '"

cQuery := ChangeQuery(cQuery)
dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), "TRAUX" , .F., .T. )
dbSelectArea("TRAUX")

While TRAUX->(!EOF())

	If	Select("TR4")>0
		dbSelectArea("TR4") 
		dbCloseArea()
	Endif
	
	cQuery := "SELECT ACV_CATEGO,SB1.B1_DESC, SB1.B1_COD B1_COD "
	cQuery += " FROM "+RetSqlName( "ACV" )+" ACVAUX,"+RetSqlName( "SB1" )+" SB1" 
	cQuery += " WHERE" 
	cQuery += " ACVAUX.ACV_CATEGO = '" + cCod + "' AND"
	cQuery += " ACVAUX.ACV_REFGRD <> ' ' AND "
	cQuery += " ACVAUX.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' AND" 
	cQuery += " SB1.B1_COD LIKE RTRIM('"+TRAUX->ACV_REFGRD+"')||'%'"
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), "TR4" , .F., .T. )
	dbSelectArea("TR4")
	
	While TR4->(!EOF())
	
		cDescProd := TR4->B1_DESC
		
		If lFt610DPr
		   cDescProd := ExecBlock("FT610DPR",.F.,.F.,TR4->B1_COD)
		EndIf
		
		If ValType(cDescProd) <> "C"
			cDescProd := TR4->B1_DESC
		EndIf	
		If	AScan( aPrdItens, { |x| x[2] == TR4->B1_COD } ) == 0
			Aadd( aPrdItens,{.F.,TR4->B1_COD,cDescProd,TR4->ACV_CATEGO } )
		EndIf
	
		dbSelectArea("TR4")
		dbSkip()
	
	Enddo
	dbSelectArea("TRAUX")
	dbSkip()
Enddo
oPrdItens:nAt:=1
oPrdItens:Refresh()

//--Processo em CODEBASE ---- Desabilitado por enquanto.
/*
dbSelectArea("ACV")
dbSetOrder(1)

If	MsSeek(xFilial("ACV")+cCod)

	While xFilial("ACV")+cCod == ACV->ACV_FILIAL+ACV->ACV_CATEGO .AND. !Eof()

		If	AScan( aPrdItens, { |x| x[2] == ACV->ACV_CODPRO } ) == 0

			If	AScan( aPrdSel, { |x| x[1] == ACV->ACV_CODPRO } ) == 0
				Aadd( aPrdItens,{.F.,ACV->ACV_CODPRO,Posicione("SB1",1,xFilial("SB1")+ACV->ACV_CODPRO,"B1_DESC"),ACV->ACV_CATEGO } )
			Else
				Aadd( aPrdItens,{.T.,ACV->ACV_CODPRO,Posicione("SB1",1,xFilial("SB1")+ACV->ACV_CODPRO,"B1_DESC"),ACV->ACV_CATEGO } )
			Endif							

		Endif
		
		dbSkip()
		
	End
	
	oPrdItens:nAt:=1
	oPrdItens:Refresh()

EndIf
*/

If	Len(aPrdItens) == 0
	Aadd(aPrdItens,{.F.,Space(15),Space(30)}) // Cria um linha em branco no array	
Endif

oPrdItens:Refresh()

RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A610ProdSel ³ Autor ³Eduardo Gomes Junior   ³ Data ³ 09/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Armazena todos os produtos selecionados						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum													 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPrdItens - Array contendo os produtos para selecao			³±±
±±³          ³ oPrdItens - Objeto											³±±
±±³          ³ aPrdSel 	 - Array contendo os produtos selecionados			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A610ProdSel(aPrdItens,oPrdItens,aPrdSel)

Local aLimpKIT	:= {}
Local nL		:= 0
Local nPosPrd	:= 0 //Posicao do produto no array aPrdSel

If	Len(aPrdItens)>0 .AND. !Empty(aPrdItens[1,2])

	If		aPrdItens[oPrdItens:nAt,1] .AND. AScan( aPrdSel, { |x| x[1] == aPrdItens[oPrdItens:nAt,2] } ) == 0
	
			Aadd(aPrdSel,{aPrdItens[oPrdItens:nAt,2],aPrdItens[oPrdItens:nAt,3],aPrdItens[oPrdItens:nAt,4],"000000","P",1})
	
			//Valida a existencia de acessorios (KIT) para o produto selecionado
			A610Acessorio(aPrdItens[oPrdItens:nAt,2],aPrdItens[oPrdItens:nAt,4],aPrdSel)
	
	Else	
	
			//Apaga o produto principal
			nPosPrd := AScan( aPrdSel, { |x| x[1] == aPrdItens[oPrdItens:nAt,2]})
	
			Adel(aPrdSel,nPosPrd)
			ASize(aPrdSel,Len(aPrdSel)-1)
	
			//Apaga o produto do KIT caso exista
			aLimpKIT := A610Acessorio(aPrdItens[oPrdItens:nAt,2],aPrdItens[oPrdItens:nAt,4],aLimpKIT)
			
			If 	ValType(aLimpKIT) <> "A"
				aLimpKIT := {}
			EndIf
			
			If	Len(aLimpKIT)>0
			
				For nL:= 1 To Len(aLimpKIT)  
					nPosPrd := AScan( aPrdSel, { |x| x[1] == aLimpKIT[nL,1]})
	
					Adel(aPrdSel,nPosPrd)
					ASize(aPrdSel,Len(aPrdSel)-1)			
				
				Next nL
			
			Endif
		
	Endif 

Endif

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A610Pesq	  ³ Autor ³Eduardo Gomes Junior   ³ Data ³ 09/01/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Armazena todos os produtos selecionados						³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum													 	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPrdItens - Array contendo os produtos para selecao			³±±
±±³          ³ oPrdItens - Objeto											³±±
±±³          ³ aPrdSel 	 - Array contendo os produtos selecionados			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         	³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            	³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function A610Pesq(oPrdItens,aPrdItens,oTree)

Local aDados  	:= {}
Local aRet		:= {}
Local nPos 		:= 3
Local nTamDesc	:= 0
Local cCond 	:= ""
Local cQualF3 

If	Len( aPrdItens ) > 0 .AND. !Empty(aPrdItens[1,2]) .AND. !Empty(aPrdItens[1,3])
    cCadastro 	:= STR0006 //"Produtos"
    cQualF3		:= "SB1"  
    nTamCampo	:= 15
	nTamDesc	:= TamSx3("B1_DESC")[1]
Else
    cCadastro 	:= STR0007 //"Categoria"
	cQualF3		:= "ACU"
    nTamCampo	:= 06
	nTamDesc	:= TamSx3("ACU_DESC")[1]
Endif

aDados := {	{ 1 ,STR0008	,Space(nTamCampo),"@!","",cQualF3,"", 060 ,.F.},;  	// "Codigo"
		   	{ 1 ,STR0009	,Space(nTamDesc),"@!","","","", 100 ,.F.} } 			//"Descricao"
					
If  !ParamBox(aDados, STR0005 , @aRet) //"Pesquisa"
	Return(.T.)
EndIf
    
If	!Empty(aRet[1]) .And. Empty(aRet[2])
    cCond += 'x[2] == "'+aRet[1]+'"'
ElseIf	!Empty(aRet[2]) .And. Empty(aRet[1])
	cCond += '"'+ALLTRIM(aRet[2])+'" $ x[3]'
Elseif !Empty(aRet[1]) .And. !Empty(aRet[2])
	cCond += 'x[2] == "'+aRet[1]+'" .or. "'+ALLTRIM(aRet[2])+'" $ x[3]'
EndIf

cCond := Left(cCond, Len(cCond))
bCond := &('{|x| ' + Alltrim(cCond) + '}')
nPos  := aScan(aPrdItens,bCond)
  
//oTree:TreeSeek("")	

If  nPos == 0
	HELP(" ",1,"REGNOIS")
Else
	oPrdItens:nAt:=nPos
	oPrdItens:Refresh()
EndIf   

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A610Acessorio³ Autor ³Eduardo Gomes Junior   ³ Data ³ 27/03/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida a existencia de acessorios para o produto selecionado  ³±±
±±³			 ³ e caso tenha carrega eles para a proposta comercial e 	     ³±±
±±³			 ³ oportunidade de venda.								 	     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.													 	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodProd - Produto selecionado							     ³±±
±±³          ³ cCatProd	- Categoria do produto								 ³±±
±±³          ³ aPrdSel	- Array contendo os produtos selecionados			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            	 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A610Acessorio(cCodProd, cCatProd, aPrdSel)

Local aArea			:= GetArea()
Local cQuery
Local lAcessorio	:= SuperGetMV("MV_HABACES",,.F.) 	//Habilita uso do cadastro de acessorios
Local lFT610WHE		:= ExistBlock("FT610WHE") 			//Ponto de entrada para mudar o WHERE da query
Local cWhereQ
Local lRet			:= .F.
Local nPosProd		:= 0

Default	aPrdSel		:= {}

//Valida a existencia do produto na SUG (Acessorios) e do parametro
dbSelectArea("SUG")
dbSetOrder(2)
If	!dbSeek(xFilial("SUG")+cCodProd) .OR. !lAcessorio
	Return(.F.)
Endif

#IFDEF TOP

	If	lFT610WHE
		cWhereQ := ExecBlock( "FT610WHE",.F.,.F.,)
		If 	ValType(cWhereQ) <> "C"
			cWhereQ := ""
		EndIf
	Endif 
	
	If	Select("TR4") > 0
		dbSelectArea("TR4")
		dbCloseArea()
	Endif

	cQuery := "SELECT SUG.UG_CODACE, SUG.UG_PRODUTO, SU1.U1_CODACE, SU1.U1_ACESSOR, SU1.U1_QTD, SB1.B1_DESC FROM "
	cQuery += RetSqlName( "SUG" ) +  " SUG INNER JOIN "
	cQuery += RetSqlName( "SU1" ) +  " SU1 ON "
	cQuery += " (SUG.UG_CODACE=SU1.U1_CODACE) LEFT JOIN "
	cQuery += RetSqlName( "SB1" ) +  " SB1 ON "
	cQuery += " (SU1.U1_ACESSOR=SB1.B1_COD) "
	cQuery += " WHERE "	
	cQuery += " SUG.UG_PRODUTO = '"+cCodProd+"'
	
	If	!Empty(cWhereQ)
		cQuery += cWhereQ
    Endif

	cQuery += " AND SUG.D_E_L_E_T_ = ' ' AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " AND SU1.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY SUG.UG_PRODUTO, SUG.UG_CODACE"
	
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), "TR4" , .F., .T. )
	
	dbSelectArea("TR4")
	
	While !EOF()
	
		If	AScan( aPrdSel, { |x| x[1] == TR4->U1_ACESSOR } ) == 0
			Aadd(aPrdSel,{TR4->U1_ACESSOR,TR4->B1_DESC,cCatprod,TR4->UG_CODACE,"A",TR4->U1_QTD})
		Endif 			
	
		dbSelectArea("TR4")
		dbSkip()
		
		lRet := .T.
	
	Enddo

#ELSE    

	dbSelectArea("SUG")
	dbSetorder(2)
	If	dbSeek(xFilial("SUG")+cCodProd)
		
		dbSelectArea("SU1")
		dbSetOrder(1)
		If	dbSeek(xFilial("SUG")+SUG->UG_CODACE)
			
			While U1_CODACE == SUG->UG_CODACE .AND. !EOF()
				
				Aadd(aPrdSel,{SU1->U1_ACESSOR,Posicione("SB1",1,xFilial("SB1")+SU1->U1_ACESSOR,"B1_DESC"),cCatprod,SUG->UG_CODACE,"A",SU1->U1_QTD})
				
				dbSelectArea("SU1")
				dbSkip()
				
				lRet := .T.
				
			Enddo
			
		Endif
		
	Endif

#ENDIF

RestArea(aArea)

Return(aPrdSel)
