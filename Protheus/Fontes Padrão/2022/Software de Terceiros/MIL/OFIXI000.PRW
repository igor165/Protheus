#INCLUDE "protheus.ch"        
#INCLUDE "DbTree.ch"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "OFIXI000.CH"
#INCLUDE "TOPCONN.CH"

/*
===============================================================================
###############################################################################
##+----------+------------+-------+-----------------------+------+----------+##
##|Funcao    | OFIXI000   | Autor | Thiago		          | Data | 17/03/16 |##
##+----------+------------+-------+-----------------------+------+----------+##
##|Descricao | Painel de Exportacao do SIR.                                 |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina/Veiculo                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OFIXI000()

Private lDebug := .F.
Private cPerg := "OXI000"
//
// Local nOpcGetFil := GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY
// // Data Inicial
// aAdd(aRegs,{STR0019,STR0019,STR0019,"MV_CH1","D", 8,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
// // Data Final
// aAdd(aRegs,{STR0020,STR0020,STR0020,"MV_CH2","D", 8,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
// // Dir Ger do Arquivo <ENTER> ?
// aAdd(aRegs,{STR0021,STR0021,STR0021,"MV_CH3","C",99,0,0,"G","!Vazio().or.(Mv_Par03:=cGetFile('Arquivos |*.*','',,,,"+AllTrim(Str(nOpcGetFil))+"))","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","",""})
// // Codigo da concessionaria ?
// aAdd(aRegs,{STR0022,STR0022,STR0022,"MV_CH4","N", 6,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""	,"S","","","999999"})
// // Tipo de Arquivo ?
// aAdd(aRegs,{STR0023,STR0023,STR0023,"MV_CH5","N", 1,0,0,"C","","mv_par05","Teste","","","","","Producao","","","","","","","","","","","","","","","","","","","",""	,"S","","","9"})
// // Marca ?
// aAdd(aRegs,{STR0024,STR0024,STR0024,"MV_CH6","C", 3,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","VE1",""	,"S","","",""})
// // Campo utilizado para DDD Cel
// aAdd(aRegs,{STR0017,STR0017,STR0017,"MV_CH7","C",15,0,0,"G","","mv_par07",,"","","","",,"","","","",,"","","","",,"","","","","","","","","",""	,"S","","",""})
// // Campo utilizado para Celular
// aAdd(aRegs,{STR0018,STR0018,STR0018,"MV_CH8","C",15,0,0,"G","","mv_par08",,"","","","",,"","","","",,"","","","",,"","","","","","","","","",""	,"S","","",""})
//
Pergunte(cPerg,.f.)
//
BatchProcess(STR0014,STR0015,,{ || OFIXI00P(MV_Par01,MV_Par02,MV_Par03,MV_Par04,MV_Par05,MV_Par06,MV_Par07,MV_Par08) }) //"Gerao de dados do SIR" # "Este processo funciona via agendador e é responsvel por gerar arquivos do SIR"
//
Return .T.

/*/{Protheus.doc} SchedDef
	Funo padro scheduler

	@author Vinicius Gati
	@since 16/01/2018
	@type function
/*/
Static Function SchedDef()
Local aParam := {;
	"P",;
	"OXI000",;
	"",;
	"",;
	"" ;
	}
Return aParam


Function OFIXI00P()
// Objeto de Tamanho de Tela 
Local oSize
Local oMenuTree
Local nFor := 0
//
Private aFilial    := {} 
Private nOpc  := 0
Private lPainel := .t.
Private cBkpFilial := cFilAnt

If !FWGetRunSchedule() // não está sendo chamada pelo Schedule
	// Objetos da Tela 
	Private oDlgPanOfi
	Private oLayer
	Private cAliasAtu
	Private aCBoxBrw := {}
	Private oBrwPainel	// MBrowse do Painel 
	
	SetStartMod(.t.) // Variavel interna para funcionamento correto dos campos MEMOS na Visualizacao por outras Rotinas

	oSize := FwDefSize():New(.f.)

	cAliasAtu := ""

	DEFINE MSDIALOG oDlgPanOfi TITLE STR0001 PIXEL ; 
		FROM oSize:aWindSize[1], oSize:aWindSize[2] TO oSize:aWindSize[3], oSize:aWindSize[4] // "Painel Exportação do SIR"

	//Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botão de fechar
	oLayer := FWLayer():new()
	oLayer:Init(oDlgPanOfi,.f.)

	//Cria as colunas do Layer
	oLayer:addCollumn('Menu',100,.T.)
	//oLayer:addCollumn('Browse',80,.F.)  

	//Adiciona Janelas as colunas
	oLayer:addWindow('Menu','Menu_W01',STR0002,100,.F.,.F., /* bAction */ ,, /* bGotFocus */ )		// "Menu Painel SIR"
	//oLayer:addWindow('Browse','Browse_W01',"Notas Fiscais",100,.F.,.F., /* bAction */ ,, /* bGotFocus */ )	// "Notas Fiscais"

	//Coloca o botão de split na coluna
	oLayer:setColSplit('Menu',CONTROL_ALIGN_RIGHT)

	// Cria Menu Lateral //	
	OXI000CMENU(oMenuTree)
		
	//OXI000CBROWSE("SF2")

	oDlgPanOfi:Activate()

Else // Schedule


	OXI000FIL()
	For nFor := 1 to Len(aFilial) 
		// "OFIXI018" - Exportar Ordens de Serviço    
		cFilAnt := aFilial[nFor,2]
		SetFunName("OFIXI018")
		dbSelectArea("SF2")
		dPar01 := dDataBase - 7
		dPar02 := dDataBase - 1
		OFIXI018(lPainel,aFilial[nFor,5],dPar01,dPar02,MV_Par03,MV_Par04,MV_Par05,MV_Par06,MV_Par07,MV_Par08)
		// "OFIXI019" - Exportar Notas Fiscais de Serviço    
		SetFunName("OFIXI019")
		dbSelectArea("SF2")
		OFIXI019(lPainel,aFilial[nFor,5],dPar01,dPar02,MV_Par03,MV_Par04,MV_Par05,MV_Par06,MV_Par07,MV_Par08)
		// "OFIXI020" - Exportar Notas Fiscais de Peças
		SetFunName("OFIXI020")
		dbSelectArea("SF2")
		OFIXI020(lPainel,aFilial[nFor,5],dPar01,dPar02,MV_Par03,MV_Par04,MV_Par05,MV_Par06,MV_Par07,MV_Par08)
		// "VEIXI003" - Exportar Notas Fiscais de Veículos
		SetFunName("VEIXI003")
		dbSelectArea("SF2")
		VEIXI003(lPainel,aFilial[nFor,5],dPar01,dPar02,MV_Par03,MV_Par04,MV_Par05,MV_Par06,MV_Par07,MV_Par08)
		// "VEIXI004" - Exportar Estoque de Seminovos
		SetFunName("VEIXI004")
		dbSelectArea("VV1")
		VEIXI004(lPainel,aFilial[nFor,5],MV_Par03,MV_Par04)
	Next

	cFilAnt := cBkpFilial

Endif

Return
                                                              
/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Funcao    | OXI000CMENU | Autor |  Thiago		          | Data | 17/03/16 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descricao | Cria Menu do Painel                                          |##
##+----------+--------------------------------------------------------------+##
##|Parametro | oMenuTree -> Objeto do Menu                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina/Veiculo                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OXI000CMENU(oMenuTree)

//Local aAuxAcesso
Local nCont
Local aMenu := {}

oMenuTree := Xtree():New(0, 0, 0, 0, oLayer:getWinPanel('Menu','Menu_W01'))
oMenuTree:Align := CONTROL_ALIGN_ALLCLIENT

/*
  Estrutura da Matriz aMenu
  
  [01] - Nome do Menu
  [02] - Nome do Pai
  [03] - Descricao (Menu)
  [04] - Tabela para Browse
  [05] - Funcao para analisar no Acesso no Menu (XNU)
  [06] - Funcao executada ao selecionar opcao do menu 
  [07] - nOpc da Rotina 
  [08] - Indica se é uma opcao de Inclusao (utilizado so para reposicionar browse)
*/

aAuxAcesso := FMX_LEVXNU(14)

// Menu de Ordem de Servico //
AADD( aMenu , { "NODE_OF"     ,""          ,"SIR","SF2",""        ,"",0,.f.} )          // SIR   
AADD( aMenu , { "NODE_OF_OS"  ,"NODE_OF",STR0016,"SF2","OFIXI018","OFIXI018",0,.f.} )   // Exportar Ordens de Serviço        
AADD( aMenu , { "NODE_OF_PC"  ,"NODE_OF",STR0003,"SF2","OFIXI019","OFIXI019",0,.f.} )   // Exportar Notas Fiscais de Serviço        
AADD( aMenu , { "NODE_OF_SV"  ,"NODE_OF",STR0004,"SF2","OFIXI020","OFIXI020",2,.f. } )  // Exportar Notas Fiscais de Peças       
AADD( aMenu , { "NODE_OF_AB_A","NODE_OF",STR0005,"SF2","VEIXI003","VEIXI003",2,.f. } )  // Exportar Notas Fiscais de Veículos     
AADD( aMenu , { "NODE_OF_AB_A","NODE_OF",STR0006,"VV1","VEIXI004","VEIXI004",2,.f. } )  // Exportar Estoque de Seminovos

For nCont := 1 to Len(aMenu)
	If Empty(aMenu[nCont,2])
		OXI000ADDM(aMenu[nCont],aMenu,oMenuTree)
	EndIf
Next nCont

            
// Adiciona opcao SAIR
oMenuTree:AddTree ( STR0007 , "final", "FINAL", "NODE_SAIR", { || oDlgPanOfi:End() } , /*bRClick*/, /* */ )
oMenuTree:EndTree()
//

Return

/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Funcao    | OXI000ADDM  | Autor |  Thiago	             | Data | 17/03/16 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descricao | Adiciona Item no Menu                                        |##
##+----------+--------------------------------------------------------------+##
##|Parametro | aParMenu  -> Linha da aMenu a ser Adicionada                 |##
##|          | aMenu     -> Matriz com opcoes do menu                       |##
##|          | oMenuTree -> Objeto do Menu                                  |##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina/Veiculo                                              |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function OXI000ADDM(aParMenu,aMenu,oMenuTree)

Local nPosAcesso
Local nCont
                          
If !Empty(aParMenu[6])  
	nPosAcesso := aScan( aAuxAcesso , { |x| x[1] == aParMenu[5] } )
	If nPosAcesso > 0 .and. SubStr(aAuxAcesso[nPosAcesso,2],aParMenu[7],1) == "x"
		oMenuTree:AddTreeItem ( aParMenu[3] , "PMSTASK4", aParMenu[1] , &("{ || OXI000EXEC('" + aParMenu[4] + "','" + aParMenu[6] + "'," + Str(aParMenu[7],2) + "," + IIf(aParMenu[8],".t.",".f.") + ") }"), /*bRClick*/ , &("{ || OXI000EXEC('" + aParMenu[4] + "','" + aParMenu[6] + "'," + Str(aParMenu[7],2) + "," + IIf(aParMenu[8],".t.",".f.") + ") }") )
	Else
		oMenuTree:AddTreeItem ( aParMenu[3] , "PMSTASK1", aParMenu[1] , &("{ || Help(,1,'SEMPERM',,'"+aParMenu[5]+"',4,1) }") )
	EndIf
Else
	oMenuTree:AddTree ( aParMenu[3], "folder5", "FOLDER6", aParMenu[1], , /*bRClick*/, /* */ )
	For nCont := 1 to Len(aMenu)
		If aMenu[nCont,2] == aParMenu[1]
  			OXI000ADDM(aMenu[nCont],aMenu,oMenuTree)
		EndIf
	Next nCont
	oMenuTree:EndTree()
EndIf	

Return

/*
===============================================================================
###############################################################################
##+----------+----------------+-------+-------------------+------+----------+##
##|Funcao    | OXI000EXEC     | Autor |  Thiago		       | Data | 17/03/16 |##
##+----------+----------------+-------+-------------------+------+----------+##
##|Descricao | Func. auxiliar para criacao do objeto de Browse              |##
##+----------+--------------------------------------------------------------+##
##|Parametro | cAuxAlias  -> Alias do Browse                                |##
##|          | cAuxRotina -> Rotina a ser executada                         |##
##|          | nAuxOpc    -> nOpc da rotina                                 |##
##|          | lInclusao  -> Indica se é inclusao (Para reposicionar browse)|##
##+----------+--------------------------------------------------------------+##
##|Uso       | Oficina                                                      |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXI000EXEC( cAlias, cAuxRotina , nAuxOpc , lInclusao)

Local cBkpFunName := FunName()
Local nRegAtu := 0  
Local i := 0 

If !lInclusao
	nRegAtu := Recno()
EndIf

OXI000FIL()  

Do Case
Case cAuxRotina == "OFIXI018" // Exportar Ordens de Serviço    
	For i := 1 to Len(aFilial) 
		if aFilial[i,1]
			cFilAnt := aFilial[i,2]
			SetFunName("OFIXI018")
			dbSelectArea("SF2")
			OFIXI018(lPainel,aFilial[i,5])
			lPainel := .t.  
		Endif	
	Next
	cFilAnt := cBkpFilial
Case cAuxRotina == "OFIXI019" // Exportar Notas Fiscais de Serviço    
	For i := 1 to Len(aFilial) 
		if aFilial[i,1]
			cFilAnt := aFilial[i,2]
			SetFunName("OFIXI019")
			dbSelectArea("SF2")
			OFIXI019(lPainel,aFilial[i,5])
			lPainel := .t.  
		Endif	
	Next
	cFilAnt := cBkpFilial
Case cAuxRotina == "OFIXI020" // Exportar Notas Fiscais de Peças
	For i := 1 to Len(aFilial) 
		if aFilial[i,1]
			cFilAnt := aFilial[i,2]
			SetFunName("OFIXI020")
			dbSelectArea("SF2")
			OFIXI020(lPainel,aFilial[i,5])
			lPainel := .t.  
		Endif	
	Next
	cFilAnt := cBkpFilial
Case cAuxRotina == "VEIXI003" // Exportar Notas Fiscais de Veículos
	For i := 1 to Len(aFilial) 
		if aFilial[i,1]
			cFilAnt := aFilial[i,2]
			SetFunName("VEIXI003")
			dbSelectArea("SF2")
			VEIXI003(lPainel,aFilial[i,5])
			lPainel := .t.  
		Endif	
	Next
	cFilAnt := cBkpFilial
Case cAuxRotina == "VEIXI004" // Exportar Estoque de Seminovos
	For i := 1 to Len(aFilial) 
		if aFilial[i,1]
			cFilAnt := aFilial[i,2]
			SetFunName("VEIXI004")
			dbSelectArea("VV1")
			VEIXI004(lPainel,aFilial[i,5])
			lPainel := .t.  
		Endif	
	Next
	cFilAnt := cBkpFilial
EndCase

if nOpc == 0 
	Return(.f.)
Endif

SetFunName(cBkpFunName)

Return

/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Funcao    | OXI000FIL   | Autor |  Thiago	             | Data | 21/03/16 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descricao | Filiais.					                                        |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Function OXI000FIL()
Local aFilAtu    := FWArrFilAtu() // carrega os dados da Filial logada ( Grupo de Empresa / Empresa / Filial ) 
Local aSM0       := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Levanta todas as Filiais da Empresa logada (vetor utilizado no FOR das Filiais)
Local nCont      := 0    
Local aSM0Emp    := {}
Local oOkTik   := LoadBitmap( GetResources() , "LBTIK" )
Local oNoTik   := LoadBitmap( GetResources() , "LBNO" )
Local cBkpFil  := cFilAnt

aFilial := {}
For nCont := 1 to Len(aSM0)      
	aSM0Emp := FWArrFilAtu(cEmpAnt,aSM0[nCont]) 
	cFilAnt := aSM0[nCont]
	If !FWGetRunSchedule() // não está sendo chamada pelo Schedule
		aAdd( aFilial, {.f.,aSM0[nCont],aSM0Emp[7],aSM0Emp[18],GetNewPar("MV_MIL0083",0)} )
	Else
		aAdd( aFilial, {.t.,aSM0[nCont],aSM0Emp[7],aSM0Emp[18],GetNewPar("MV_MIL0083",0)} )
	Endif
Next   
cFilAnt := cBkpFil

If !FWGetRunSchedule() // não está sendo chamada pelo Schedule
	DEFINE MSDIALOG oDlgFil TITLE "" From 5,25 to 22,92     of oMainWnd
	@ 001,001 LISTBOX oLbl FIELDS HEADER "",STR0008,STR0009,STR0010,STR0011 COLSIZES 10,60,80,40,40 SIZE 265,112 OF oDlgFil PIXEL ON DBLCLICK FS_MARCA(oLbl:nAt)
	oLbl:SetArray(aFilial)
	oLbl:bLine := { || { IIf(aFilial[oLbl:nAt,1],oOkTik,oNoTik),;
	aFilial[oLbl:nAt,2],;
	aFilial[oLbl:nAt,3],;
	aFilial[oLbl:nAt,4],;
	aFilial[oLbl:nAt,5]}}

	DEFINE SBUTTON FROM 116,170 TYPE 1 ACTION ( nOpca := 1, oDlgFil:End() ) ENABLE OF oDlgFil
	DEFINE SBUTTON FROM 116,200 TYPE 2 ACTION ( nOpca := 0, oDlgFil:End() ) ENABLE OF oDlgFil

	ACTIVATE MSDIALOG oDlgFil CENTER

Endif

Return

/*
===============================================================================
###############################################################################
##+----------+-------------+-------+----------------------+------+----------+##
##|Funcao    | FS_MARCA    | Autor |  Thiago	             | Data | 21/03/16 |##
##+----------+-------------+-------+----------------------+------+----------+##
##|Descricao | Validacao Marca.		                                        |##
##+----------+--------------------------------------------------------------+##
###############################################################################
===============================================================================
*/
Static Function FS_MARCA(nLin)

if aFilial[nLin,1] 
	aFilial[nLin,1] := .f.
Else	
	aFilial[nLin,1]  := .t.
Endif           
oLbl:Refresh()


Return(.t.)

