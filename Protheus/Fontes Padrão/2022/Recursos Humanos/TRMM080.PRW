#INCLUDE "TOTVS.CH"
#INCLUDE "TRMM080.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TRMM080    ³ Autor ³ Flavio S. Correa             ³ Data ³ 02/12/09   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Sugestão de treinamento de acordo com as habilidades                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM                                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC            ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³28/07/14³TPZWA0          ³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³                ³da a limpeza.                             ³±±
±±³Renan Borges³26/02/15³TRPAMU          ³Ajuste para carregar habilidades do cargo ³±±
±±³            ³        ³       	 	 ³corretamente.                             ³±± 
±±³Oswaldo L   ³01/03/17³DRHPONTP-9³Nova funcionalidade de tabelas temporarias  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TRMM080()
Local cFunction		:= "TRMM080"
Local cTitle    	:= STR0001 //"Sugestão de treinamento"
Local bProcess	  	:= {|oSelf| M080PROC(oSelf)}
Local cDescription	:= STR0001 //"Sugestão de treinamento"

PRIVATE aFldRot 	:= {'RA_NOME'}
PRIVATE aOfusca	 	:= If(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) //[1] Acesso; [2]Ofusca
PRIVATE lOfuscaNom 	:= .F. 
PRIVATE aFldOfusca	:= {}

If aOfusca[2]
	aFldOfusca := FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRot ) // CAMPOS SEM ACESSO
	IF aScan( aFldOfusca , { |x| x:CFIELD == "RA_NOME" } ) > 0
		lOfuscaNom := FwProtectedDataUtil():IsFieldInList( "RA_NOME" )
	ENDIF
EndIf

//Mostra tela de processamento
Pergunte("TRMM080", .F.)
tNewProcess():New(cFunction,cTitle,bProcess,cDescription,"TRMM080",,,,,,.T.)   

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M080PROC	 ³ Autor ³ Flavio S. Correa 	³ Data ³ 02/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³sugestão de treinamentos de acordo com as habilidades		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M080PROC(oSelf)   
Local aArea			:= GetArea()
Local cFilDe		:= ""
Local cFilAte		:= ""
Local cMatDe		:= ""
Local cMatAte		:= ""
Local cCargoDe		:= ""
Local cCargoAte		:= ""
Local cSRAAlias		:= "QSRA"
Local cCurso		:= ""
Local aCargo		:= {}
Local aCargos		:= {}
Local aHabil		:= {}
Local aResult		:= {}
Local aFunc			:= {}
Local nPosHabil		:= 0
Local nI			:= 1
Local nQtd			:= 0
Local cDesc1		:= ""
Local cDesc2		:= ""

Private oTmpTabFO1
Private cTM1Alias := GetNextAlias()



//Carrega Parametros do Pergunte
cFilDe		:= mv_par01
cFilAte		:= mv_par02
cMatDe		:= mv_par03
cMatAte		:= mv_par04
cCargoDe	:= mv_par05
cCargoAte	:= mv_par06

//CONSULTA SRA(FUNCIONARIOS) FILTRANDO PELOS PARAMETROS
BeginSql alias cSRAAlias
	SELECT Count(1) AS TOTAL
	FROM %table:SRA% SRA 	
	INNER JOIN %table:SQ3% SQ3 ON SRA.RA_CARGO = SQ3.Q3_CARGO
	WHERE 
	SRA.RA_CARGO <> %exp:''% AND ( SRA.RA_CARGO >= %exp:cCargoDe% AND SRA.RA_CARGO <= %exp:cCargoAte% )
	AND ( SRA.RA_FILIAL >= %exp:cFilDe% AND SRA.RA_FILIAL <= %exp:cFilAte% )
	AND ( SRA.RA_MAT >= %exp:cMatDe% AND SRA.RA_MAT <= %exp:cMatAte% )
	AND SRA.%notDel%
	AND SQ3.%notDel%      
EndSql
If !(cSRAAlias)->(Eof())
	nQtd := (cSRAAlias)->TOTAL
EndIf
(cSRAAlias)->(dbCloseArea())

BeginSql alias cSRAAlias
	SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_CARGO ,SQ3.Q3_DESCSUM
	FROM %table:SRA% SRA 	
	INNER JOIN %table:SQ3% SQ3 ON SRA.RA_CARGO = SQ3.Q3_CARGO
	WHERE 
	SRA.RA_CARGO <> %exp:''% AND ( SRA.RA_CARGO >= %exp:cCargoDe% AND SRA.RA_CARGO <= %exp:cCargoAte% )
	AND ( SRA.RA_FILIAL >= %exp:cFilDe% AND SRA.RA_FILIAL <= %exp:cFilAte% )
	AND ( SRA.RA_MAT >= %exp:cMatDe% AND SRA.RA_MAT <= %exp:cMatAte% )
	AND SRA.%notDel%
	AND SQ3.%notDel%      
	ORDER BY SRA.RA_FILIAL, SRA.RA_MAT
EndSql

oSelf:SetRegua1(nQtd)  
oSelf:SaveLog(STR0003)	//Inicio de processamento - sugestao de curso

//Cria tabela temporaria de cursos
CriaTabela()
                                           
While !(cSRAAlias)->(Eof())
     
	//Busca Habilidades do cargo
	aCargo := BuscaCargo((cSRAAlias)->RA_CARGO,@aCargos)

	//Busca habilidades do funcionário
   	aHabil := BuscaHabil((cSRAAlias)->RA_FILIAL,(cSRAAlias)->RA_MAT)

	//compara habilidades
	If Len(aCargo) > 0
		For nI := 2 To Len(aCargo)
			cHabil := aCargo[nI][03] //habilidade do cargo
			//verifica se o funcionario tem essa habilidade
			nPosHabil := aScan(aHabil,{|x| Alltrim(x[1]) == Alltrim(cHabil) })
			MontaFunc(aFunc,cSRAAlias)
			cCurso := GetCurso(aCargo[nI][1],aCargo[nI][2],aCargo[nI][3])
			
			If nPosHabil > 0
				If aHabil[nPosHabil][03] < aCargo[nI][05] 
					//habilidade abaixo do exigido pelo cargo
					MontaResult(@aResult,aHabil[nPosHabil],aCargo[nI],cSRAAlias,"qmt_cond",cCurso)//medio
					If !Empty(aCargo[nI][08])
						cDesc1 := Posicione("RA1",1,xFilial("RA1")+aCargo[nI][08],"RA1_DESC")
						GravaTM1((cSRAAlias)->RA_FILIAL,(cSRAAlias)->RA_MAT,aCargo[nI][01],aCargo[nI][02],aCargo[nI][03],aCargo[nI][08],cDesc1)
					EndIf
					If !Empty(cCurso) .And. cCurso != aCargo[nI][08]
						cDesc2 := Posicione("RA1",1,xFilial("RA1")+cCurso,"RA1_DESC")
						GravaTM1((cSRAAlias)->RA_FILIAL,(cSRAAlias)->RA_MAT,aCargo[nI][01],aCargo[nI][02],aCargo[nI][03],cCurso,cDesc2)
					EndIf
				Else                               
					//superou a habilidade exigida pelo cargo
					MontaResult(@aResult,aHabil[nPosHabil],aCargo[nI],cSRAAlias,"qmt_ok")//bom
				EndIf
			Else                                  
				//sem habilidade exigida pelo cargo
				MontaResult(@aResult,Nil,aCargo[nI],cSRAAlias,"qmt_no",cCurso)//ruim
				If !Empty(aCargo[nI][08])
					cDesc1 := Posicione("RA1",1,xFilial("RA1")+aCargo[nI][08],"RA1_DESC")
					GravaTM1((cSRAAlias)->RA_FILIAL,(cSRAAlias)->RA_MAT,aCargo[nI][01],aCargo[nI][02],aCargo[nI][03],aCargo[nI][08],cDesc1)
				EndIf
				If !Empty(cCurso) .And. cCurso != aCargo[nI][08]
					cDesc2 := Posicione("RA1",1,xFilial("RA1")+cCurso,"RA1_DESC")
					GravaTM1((cSRAAlias)->RA_FILIAL,(cSRAAlias)->RA_MAT,aCargo[nI][01],aCargo[nI][02],aCargo[nI][03],cCurso,cDesc2)
				EndIf
			EndIf
		Next nI
	EndIf
	oSelf:IncRegua1(OemToAnsi(STR0004)+": "+(cSRAAlias)->RA_MAT + If(lOfuscaNom,''," - " + (cSRAAlias)->RA_NOME))
	
	(cSRAAlias)->(dbSkip())
EndDo
(cSRAAlias)->(dbCloseArea())

If Len(aResult) > 0
	ShowTela(aFunc,aResult)
Else
	oSelf:SaveLog(STR0005)	//"Sem dados para processar."
	Aviso(STR0006,STR0007,{"OK"})//"Aviso"#"Sem dados para processar."
EndIf

oSelf:SaveLog(STR0008)	//"Fim de processamento - sugestao de curso"

//Apaga tabela temporaria de cursos      
(cTM1Alias)->(dbCloseArea())

If Valtype(oTmpTabFO1) == "O"
    oTmpTabFO1:Delete()
    Freeobj(oTmpTabFO1)
EndIf 

RestArea(aArea)
Return .T.                                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ShowTela	 ³ Autor0 ³ Flavio S. Correa 	³ Data ³ 05/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Tela de sugestao de curso									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ShowTela(aData,aResult)
Local aHeader		:= {}
Local aCampos		:= {}
Local cTitulo		:= ""
Local nI			:= 1
Local aCoors := FWGetDialogSize(oMainWnd)
Local bBotao01	:= { || lOk := .T., oDlg:End() }
Local bCancela	:= { || lOk := .F., oDlg:End() }
Local lOk 	:= .F.

Local aHeader2 := {}
Local aCampos2 := {}
Local cTitulo2 := ""

Private aTree	:= {}
Private oBrowse		                                 
Private oBrowse2
Private oTree

Private oDlg
Private oFWLayer
Private oPanelUP
Private oPanelLeft
Private oPanelRight

DEFINE MSDIALOG oDlg TITLE STR0001 FROM aCoors[1],aCoors[2] TO aCoors[3]-50,aCoors[4] PIXEL //"Sugestao de Treinamento"

oFWLayer := FWLayer():New()
oFWLayer:Init(oDlg,.F.,.T.)

//Painel superior
oFWLayer:addLine("UP",40,.F.)
oFWLayer:AddCollumn("ALL",100,.T.,"UP")
oFWLayer:AddWindow("ALL","oPanelUP",STR0004,95,.F.,.T.,,"UP",{ || })//"Funcionários"
oPanelUP := oFWLayer:GetWinPanel("ALL","oPanelUP","UP")         

//Painel da esquerda - TREE
oFWLayer:addLine("DOWN",60,.F.)
oFWLayer:AddCollumn("LEFT",30,.T.,"DOWN")
oFWLayer:AddWindow("LEFT","oPanelLeft",STR0009,95,.F.,.T.,,"DOWN",{ || })//"Tree"
oPanelLeft := oFWLayer:GetWinPanel("LEFT","oPanelLeft","DOWN")

//Painel da direita - Browse de curos
oFWLayer:AddCollumn("RIGHT",70,.T.,"DOWN")
oFWLayer:AddWindow("RIGHT","oPanelRight",STR0010,95,.F.,.T.,,"DOWN",{ || })//"Cursos"
oPanelRight := oFWLayer:GetWinPanel("RIGHT","oPanelRight","DOWN")

//Browse de funcionarios
aCampos :={ "RA_FILIAL", "RA_MAT", "RA_NOME", "RA_CARGO","Q3_DESCSUM"}
dbselectarea("SX3")                   
nI :=1
cTitulo := Alltrim(RetTitle(aCampos[nI]))  
aadd(aHeader,{cTitulo,{ |X| aData[oBrowse:At(),01] },GetSx3Cache( aCampos[nI] , "X3_TIPO" ),GetSx3Cache( aCampos[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos[nI] , "X3_DECIMAL" )})
nI :=2
cTitulo := Alltrim(RetTitle(aCampos[nI]))  
aadd(aHeader,{cTitulo,{ |X| aData[oBrowse:At(),02] },GetSx3Cache( aCampos[nI] , "X3_TIPO" ),GetSx3Cache( aCampos[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos[nI] , "X3_DECIMAL" )})
nI :=3
cTitulo := Alltrim(RetTitle(aCampos[nI]))  
aadd(aHeader,{cTitulo,{ |X| aData[oBrowse:At(),03] },GetSx3Cache( aCampos[nI] , "X3_TIPO" ),GetSx3Cache( aCampos[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos[nI] , "X3_DECIMAL" )})
nI :=4
cTitulo := Alltrim(RetTitle(aCampos[nI]))  
aadd(aHeader,{cTitulo,{ |X| aData[oBrowse:At(),04] },GetSx3Cache( aCampos[nI] , "X3_TIPO" ),GetSx3Cache( aCampos[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos[nI] , "X3_DECIMAL" )})
nI :=5
cTitulo := Alltrim(RetTitle(aCampos[nI]))  
aadd(aHeader,{cTitulo,{ |X| aData[oBrowse:At(),05] },GetSx3Cache( aCampos[nI] , "X3_TIPO" ),GetSx3Cache( aCampos[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos[nI] , "X3_DECIMAL" )})

//tree de habilidades
oTree := DbTree():New(0,0,160,260,oPanelLeft,,,.T.)

//Browse de funcionarios - principal
If Valtype(oBrowse) == "O"
	oBrowse:deActivate()
EndIf
oBrowse := FWBrowse():New()
oBrowse:SetDataArray()
oBrowse:SetArray(aData)
oBrowse:SetColumns(aHeader)
oBrowse:SetAlias("TMP")
oBrowse:SetOwner(oPanelUP)   
oBrowse:bChange := {|| MontaTree(aResult),MontaBrowse() } 
oBrowse:DisableConfig()
oBrowse:DisableReport()
oBrowse:Activate()

//Browse de cursos
aCampos2 :={ "RBJ_CODCOM", "RBJ_ITECOM", "RBJ_HABIL", "RA1_CURSO","RA1_DESC"}
dbselectarea("SX3")                   
nI :=1
cTitulo2 := Alltrim(RetTitle(aCampos2[nI]))  
aadd(aHeader2,{cTitulo2,{ |X| (cTM1Alias)->(TM1_CODCOM) },GetSx3Cache( aCampos2[nI] , "X3_TIPO" ),GetSx3Cache( aCampos2[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos2[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos2[nI] , "X3_DECIMAL" )})
nI :=2
cTitulo2 := Alltrim(RetTitle(aCampos2[nI]))  
aadd(aHeader2,{cTitulo2,{ |X| (cTM1Alias)->(TM1_ITECOM) },GetSx3Cache( aCampos2[nI] , "X3_TIPO" ),GetSx3Cache( aCampos2[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos2[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos2[nI] , "X3_DECIMAL" )})
nI :=3
cTitulo2 := Alltrim(RetTitle(aCampos2[nI]))  
aadd(aHeader2,{cTitulo2,{ |X| (cTM1Alias)->(TM1_HABIL) },GetSx3Cache( aCampos2[nI] , "X3_TIPO" ),GetSx3Cache( aCampos2[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos2[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos2[nI] , "X3_DECIMAL" )})
nI :=4
cTitulo2 := Alltrim(RetTitle(aCampos2[nI]))  
aadd(aHeader2,{cTitulo2,{ |X| (cTM1Alias)->(TM1_CODCUR) },GetSx3Cache( aCampos2[nI] , "X3_TIPO" ),GetSx3Cache( aCampos2[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos2[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos2[nI] , "X3_DECIMAL" )})
nI :=5
cTitulo2 := Alltrim(RetTitle(aCampos2[nI]))  
aadd(aHeader2,{cTitulo2,{ |X| (cTM1Alias)->(TM1_CURSO) },GetSx3Cache( aCampos2[nI] , "X3_TIPO" ),GetSx3Cache( aCampos2[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos2[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos2[nI] , "X3_DECIMAL" )})
	
If Valtype(oBrowse2) == "O"
	oBrowse2:deActivate()
EndIf
If Valtype(oBrowse2) <> "O"	
	oBrowse2 := FWBrowse():New()
	oBrowse2:SetOwner(oPanelRight)   
EndIf
oBrowse2:AddMarkColumns( { || if((cTM1Alias)->(TM1_MARCA) == 1,"LBOK","LBNO") },{ || Marca()})
oBrowse2:SetAlias(cTM1Alias) 
oBrowse2:SetColumns(aHeader2)
oBrowse2:SetFilterDefault("TM1_FILFUN+TM1_MATFUN == '" + obrowse:getcolumndata(1)+obrowse:getcolumndata(2) + "'")
oBrowse2:SetDataTable()
oBrowse2:DisableConfig()   
oBrowse2:DisableReport()     
oBrowse2:Activate()

ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, bBotao01, bCancela))
If lOk := .T.
	Solicita()
EndIf

Return    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MontaBrowse³ Autor ³ Flavio S. Correa 	³ Data ³ 07/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Browse de cursos									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MontaBrowse()
Local nI		:= 1
Local aCampos	:= {}
Local aHeader1		:= {}
Local cTitulo	:= ""                        
                
	//Browse de cursos
	aCampos :={ "RBJ_CODCOM", "RBJ_ITECOM", "RBJ_HABIL", "RA1_CURSO","RA1_DESC"}
	dbselectarea("SX3")                   
	nI :=1
	cTitulo := Alltrim(RetTitle(aCampos[nI]))  
	aadd(aHeader1,{cTitulo,{ |X| (cTM1Alias)->(TM1_CODCOM) },GetSx3Cache( aCampos[nI] , "X3_TIPO" ),GetSx3Cache( aCampos[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos[nI] , "X3_DECIMAL" )})
	nI :=2
	cTitulo := Alltrim(RetTitle(aCampos[nI]))  
	aadd(aHeader1,{cTitulo,{ |X| (cTM1Alias)->(TM1_ITECOM) },GetSx3Cache( aCampos[nI] , "X3_TIPO" ),GetSx3Cache( aCampos[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos[nI] , "X3_DECIMAL" )})
	nI :=3
	cTitulo := Alltrim(RetTitle(aCampos[nI]))  
	aadd(aHeader1,{cTitulo,{ |X| (cTM1Alias)->(TM1_HABIL) },GetSx3Cache( aCampos[nI] , "X3_TIPO" ),GetSx3Cache( aCampos[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos[nI] , "X3_DECIMAL" )})
	nI :=4
	cTitulo := Alltrim(RetTitle(aCampos[nI]))  
	aadd(aHeader1,{cTitulo,{ |X| (cTM1Alias)->(TM1_CODCUR) },GetSx3Cache( aCampos[nI] , "X3_TIPO" ),GetSx3Cache( aCampos[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos[nI] , "X3_DECIMAL" )})
	nI :=5
	cTitulo := Alltrim(RetTitle(aCampos[nI]))  
	aadd(aHeader1,{cTitulo,{ |X| (cTM1Alias)->(TM1_CURSO) },GetSx3Cache( aCampos[nI] , "X3_TIPO" ),GetSx3Cache( aCampos[nI] , "X3_PICTVAR" ),1,GetSx3Cache( aCampos[nI] , "X3_TAMANHO" ),GetSx3Cache( aCampos[nI] , "X3_DECIMAL" )})
	
	If Valtype(oBrowse2) == "O"
		oBrowse2:deActivate()
	EndIf
	
	If Valtype(oBrowse2) <> "O"	
		oBrowse2 := FWBrowse():New()
		oBrowse2:SetOwner(oPanelRight)  
	endif 
	oBrowse2:AddMarkColumns( { || if((cTM1Alias)->(TM1_MARCA) == 1,"LBOK","LBNO") },{ || Marca()})
	oBrowse2:SetAlias(cTM1Alias) 
	oBrowse2:SetColumns(aHeader1)
	oBrowse2:SetFilterDefault("TM1_FILFUN+TM1_MATFUN == '" + obrowse:getcolumndata(1)+obrowse:getcolumndata(2) + "'")
	oBrowse2:SetDataTable()
	oBrowse2:DisableConfig()   
	oBrowse2:DisableReport() 
	   
	oBrowse2:Activate()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Marca		 ³ Autor ³ Flavio S. Correa 	³ Data ³ 12/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Marca Browse de cursos									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Marca() 
Local aArea	:= GetArea()
Local nMarca	:= 0

If (cTM1Alias)->(TM1_MARCA) == 0      
	nMarca := 1
EndIf
reclock(cTM1Alias,.F.)
(cTM1Alias)->(TM1_MARCA) := nMArca
(cTM1Alias)->(msUnlock())      

RestArea(aArea)
Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MontaTree  ³ Autor ³ Flavio S. Correa 	³ Data ³ 07/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta Tree de habilidades									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MontaTree(aResult)
Local nPos 	:= 0
Local nI	:= 1
Local nK	:= 1
Local nJ	:= 1

oTree:Reset()
nPos := aScan(aResult,{|x| x[1]+x[2] == obrowse:getcolumndata(1)+obrowse:getcolumndata(2)})
aTree := aClone(aResult[nPos])

// Insere itens
For nI := 1 To Len(aTree[3])
	oTree:AddItem(aTree[3][nI][1] + " - " + aTree[3][nI][3] ,"c"+aTree[3][nI][1], /*"qmt_no"*/ ,,,,1) //competencia
	If oTree:TreeSeek("c"+aTree[3][nI][1]) 
		For nJ := 1 To Len(aTree[3][nI][2])
			oTree:TreeSeek("c"+aTree[3][nI][1]) 
			oTree:AddItem(aTree[3][nI][2][nJ][1] + " - " + aTree[3][nI][2][nJ][5],"i"+aTree[3][nI][2][nJ][1], /*aTree[3][nI][2][nJ][4]*/,,,,2)	//item
			If oTree:TreeSeek("i"+aTree[3][nI][2][nJ][1])
				For nK := 1 To Len(aTree[3][nI][2][nJ][2])//Habilidade
					oTree:AddItem(aTree[3][nI][2][nJ][2][nK][1] + " - " + aTree[3][nI][2][nJ][2][nK][8] ,aTree[3][nI][2][nJ][2][nK][1], aTree[3][nI][2][nJ][2][nK][7],,,,3)	
			  	Next nK
			EndIf
		Next nJ
	 EndIf                     
Next nI
oTree:EndTree()

oTree:Refresh()
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BuscaCargo ³ Autor ³ Flavio S. Correa 	³ Data ³ 02/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca as habilidades de um cargo							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function BuscaCargo(cCargo,aCargos)
Local aArea		:= GetArea()
Local cAlias	:= "QRBH"
Local aCargo	:= {}
Local nPosCargo		:= 0

nPosCargo := Ascan(aCargos,{|x| Alltrim(x[1]) == Alltrim(cCargo)})
If nPosCargo > 0
   	aCargo := aClone(aCargos[nPosCargo])
Else



	BeginSql alias cAlias
		SELECT RBH.*,RDM.RDM_DESC,RD2.RD2_DESC,RD2.RD2_CURSO,RBG.RBG_DESC
		FROM %table:RBH% RBH 
		INNER JOIN %table:RD2% RD2 ON RBH.RBH_FILIAL = RD2.RD2_FILIAL AND RBH.RBH_CODCOM = RD2.RD2_CODIGO AND RBH.RBH_ITECOM = RD2.RD2_ITEM
		INNER JOIN %table:RDM% RDM ON RBH.RBH_FILIAL = RDM.RDM_FILIAL AND RBH.RBH_CODCOM = RDM.RDM_CODIGO
		INNER JOIN %table:RBG% RBG ON RBH.RBH_FILIAL = RBG.RBG_FILIAL AND RBH.RBH_HABIL = RBG.RBG_HABIL
		WHERE 
		RBH.RBH_FILIAL = %xfilial:RBH%
		AND RBH.RBH_CARGO = %exp:cCargo%
		AND RD2.%notDel%
		AND RBG.%notDel%
		AND RDM.%notDel%
		AND RBH.%notDel%

	EndSql                               
	While !(cAlias)->(Eof())
	
		nPosCargo := Ascan(aCargos,{|x| Alltrim(x[1]) == Alltrim(cCargo)})
		If nPosCargo > 0
			aadd(aCargos[nPosCargo],{;
						(cAlias)->RBH_CODCOM,;
						(cAlias)->RBH_ITECOM,;
						(cAlias)->RBH_HABIL,;
						(cAlias)->RBH_ESCALA,;
						(cAlias)->RBH_ITESCA,;
						(cAlias)->RDM_DESC,;
						(cAlias)->RD2_DESC,;
						(cAlias)->RD2_CURSO,;
						(cAlias)->RBG_DESC;
						})
		Else
			aadd(aCargos,{ (cAlias)->RBH_CARGO,{; 
						(cAlias)->RBH_CODCOM,; //01
						(cAlias)->RBH_ITECOM,; //02
						(cAlias)->RBH_HABIL,; //03
						(cAlias)->RBH_ESCALA,; //04
						(cAlias)->RBH_ITESCA,; //05
						(cAlias)->RDM_DESC,; //06
						(cAlias)->RD2_DESC,; //07
						(cAlias)->RD2_CURSO,; //08
						(cAlias)->RBG_DESC}; //09
						})
	    EndIf
		(cAlias)->(dbSkip())
	EndDo
	(cAlias)->(dbCloseArea())
	
	If Len(aCargos) > 0
		aCargo := aClone(aCargos[Len(aCargos)])
	EndIf
EndIf	

RestArea(aArea)
Return aCargo

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³BuscaHabil ³ Autor ³ Flavio S. Correa 	³ Data ³ 02/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Busca as habilidades de um funcionario					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function BuscaHabil(cFilMat,cMat)
Local aArea		:= GetArea()
Local aHabil	:= {}
Local cAlias	:= "QRBI"

BeginSql alias cAlias
	SELECT RBI.*
	FROM %table:RBI% RBI 
	WHERE RBI.RBI_MAT = %exp:cMat%
	AND RBI.RBI_FILIAL = %exp:cFilMat%
	AND RBI.%notDel%
EndSql                               
While !(cAlias)->(Eof())
	AAdd(aHabil,{ (cAlias)->RBI_HABIL, (cAlias)->RBI_ESCALA, (cAlias)->RBI_ITESCA })
	(cAlias)->(dbSkip())
EndDo
(cAlias)->(dbCloseArea())

RestArea(aArea)
Return aClone(aHabil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MontaResult³ Autor ³ Flavio S. Correa 	³ Data ³ 02/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array com resultado do processamento				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MontaResult(aResult,aHabil,aCargo,cAlias,cStatus,cCurso)
Local nPos1 	:= 0
Local nPos2		:= 0
Local nPos3		:= 0
Local nPos4		:= 0
Local cFilFun	:= (cAlias)->RA_FILIAL
Local cMat		:= (cAlias)->RA_MAT

               
//Funcionario
nPos1 := aScan(aResult,{ |x| x[1]+x[2] == cFilFun+cMat })
If nPos1 == 0
	Aadd(aResult, {cFilFun,cMat,{}})
	nPos1 := Len(aResult)
EndIf


//Competencia
If Len(aResult[nPos1][3]) > 0
	nPos2 := aScan(aResult[nPos1][3],{ |x| x[1] == aCargo[1] })
EndIf
If nPos2 == 0
	Aadd(aResult[nPos1][3], {aCargo[1],{},aCargo[6] })
	nPos2 := Len(aResult[nPos1][3])
EndIf

//Item da Competencia
If Len(aResult[nPos1][3][nPos2][2]) > 0
	nPos3 := aScan(aResult[nPos1][3][nPos2][2],{ |x| x[1] == aCargo[2] }) 
EndIf
If nPos3 == 0
	Aadd(aResult[nPos1][3][nPos2][2], {aCargo[2],{},aCargo[9],cStatus,aCargo[7]})
	nPos3 := Len(aResult[nPos1][3][nPos2][2])
EndIf

//habilidade
If Len(aResult[nPos1][3][nPos2][2][nPos3][2]) > 0 
	nPos4 := aScan(aResult[nPos1][3][nPos2][2][nPos3][2],{ |x| x[1] == aCargo[3] })
EndIf
If nPos4 == 0
	If ValType(aHabil) == "U"
		Aadd(aResult[nPos1][3][nPos2][2][nPos3][2], {aCargo[3],aCargo[4],aCargo[5],""/*escala*/,""/*item escala*/,cCurso,cStatus,aCargo[9]})
	Else
		Aadd(aResult[nPos1][3][nPos2][2][nPos3][2], {aCargo[3],aCargo[4],aCargo[5],aHabil[2],aHabil[3],cCurso,cStatus,aCargo[9]})
	EndIf
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GetCurso	 | Autor ³ Flavio S. Correa 	³ Data ³ 07/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Pega o curso relacionado com Comp, Item e Habilidade		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GetCurso(cCompet,cItem,cHabil)
Local aArea		:= GetArea()
Local cCurso    := ""

dbSelectArea("RBJ") 
RBJ->(dbSetOrder(1))//RBJ_FILIAL+RBJ_CODCOM+RBJ_ITECOM+RBJ_HABIL
If RBJ->(dbSeek(xFilial("RBJ")+cCompet+cItem+cHabil))
	cCurso := RBJ->RBJ_CURSO
EndIf

RestArea(aArea)
Return cCurso
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MontaFunc	 | Autor ³ Flavio S. Correa 	³ Data ³ 02/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta array com funcionarios do processamento				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MontaFunc(aFunc,cSRAAlias)
If aScan(aFunc,{|x| x[1]+x[2] == (cSRAAlias)->RA_FILIAL+(cSRAAlias)->RA_MAT}) == 0
	aadd(aFunc,{ (cSRAAlias)->RA_FILIAL,(cSRAAlias)->RA_MAT, If(lOfuscaNom,Replicate('*',15),(cSRAAlias)->RA_NOME), (cSRAAlias)->RA_CARGO, (cSRAAlias)->Q3_DESCSUM})
EndIf
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CriaTabela | Autor ³ Flavio S. Correa 	³ Data ³ 12/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria tabela temporaria de cursos							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CriaTabela()
Local aStruct	:= {}
Local aLstIndices := {}

// Cria arquivo de Cursos
Aadd(aStruct,{"TM1_MARCA"	,"N",01,0})
Aadd(aStruct,{"TM1_FILFUN"	,"C",GetSx3Cache( "RA_FILIAL" , "X3_TAMANHO" ),0})
Aadd(aStruct,{"TM1_MATFUN"	,"C",GetSx3Cache( "RA_MAT" , "X3_TAMANHO" ),0})
Aadd(aStruct,{"TM1_CODCOM"	,"C",GetSx3Cache( "RBJ_CODCOM" , "X3_TAMANHO" ),0})
Aadd(aStruct,{"TM1_ITECOM"	,"C",GetSx3Cache( "RBJ_ITECOM" , "X3_TAMANHO" ),0})
Aadd(aStruct,{"TM1_HABIL"	,"C",GetSx3Cache( "RBJ_HABIL" , "X3_TAMANHO" ),0})
Aadd(aStruct,{"TM1_CODCUR"	,"C",GetSx3Cache( "RA1_CURSO" , "X3_TAMANHO" ),0})
Aadd(aStruct,{"TM1_CURSO"	,"C",GetSx3Cache( "RA1_DESC" , "X3_TAMANHO" ),0})


Aadd(aLstIndices, {"TM1_FILFUN","TM1_MATFUN"} )

oTmpTabFO1 := RhCriaTrab(cTm1Alias, aStruct, aLstIndices)

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GravaTM1	 | Autor ³ Flavio S. Correa 	³ Data ³ 12/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava tabela temporaria de cursos							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GravaTM1(cFilFun,cMatFun,cCodCOM,cItecom,cHabil,cCodCur,cCurso)

recLock(cTM1Alias,.T.)
(cTM1Alias)->(TM1_MARCA)	:= 0
(cTM1Alias)->(TM1_FILFUN)	:= cFilFun
(cTM1Alias)->(TM1_MATFUN)	:= cMatFun
(cTM1Alias)->(TM1_CODCOM)	:= cCodCOM
(cTM1Alias)->(TM1_ITECOM)	:= cItecom
(cTM1Alias)->(TM1_HABIL)	:= cHabil
(cTM1Alias)->(TM1_CODCUR)	:= cCodCur
(cTM1Alias)->(TM1_CURSO)	:= cCurso
(cTM1Alias)->(msUnlock())

Return   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Solicita	 | Autor ³ Flavio S. Correa 	³ Data ³ 14/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Solicitacao de treinamentos								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Solicita()

Local nQtd	:= 0

dbSelectArea(cTM1Alias) //arquivo temporario de cursos
dbSelectArea("RA3") 

RA3->(dbSetOrder(1))                                                                                 

(cTM1Alias)->(dbGotop())
While !(cTM1Alias)->(Eof()) 
	If (cTM1Alias)->(TM1_MARCA) == 1
		If !RA3->(dbSeek(xFilial("RA3")+(cTM1Alias)->(TM1_MATFUN)+(cTM1Alias)->(TM1_CODCUR) ))
			RecLock("RA3",.T.)
			RA3->RA3_FILIAL := xFilial("RA3")
			RA3->RA3_MAT	:= (cTM1Alias)->(TM1_MATFUN)
			RA3->RA3_CURSO	:= (cTM1Alias)->(TM1_CODCUR)
			RA3->RA3_RESERV	:= "S"
			RA3->(msUnlock())
			nQtd++
		EndIf
	EndIf
	(cTM1Alias)->(dbSkip())
EndDo

If nQtd == 0
	Aviso(STR0006,STR0013,{"OK"})//"Aviso"#"Não existem cursos a serem solicitados."
Else
	Aviso(STR0006,STR0014,{"OK"})//"Aviso"#"Cursos solicitados."
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TRMM080	 ³ Autor ³ Flavio S. Correa 	³ Data ³ 02/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Criação do MenuDef. 										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³SIGATRM                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function MenuDef()
	Local aRotina := {}
	aAdd(aRotina, {STR0002,	"TRMM080",	0, 3, 0, NIL})		//"Processar"
Return aRotina
