#INCLUDE "PCOA201.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch" 
#INCLUDE "DbTree.ch"
#INCLUDE "RwMake.ch"
#INCLUDE "msgraphi.ch"
//Defini-se as constantes com os icones necessarios para a Tree
#DEFINE PCOICTREESTART		{"vermelho"	,"vermelho"	}
#DEFINE PCOICTREEINTER     	{"azul"		,"azul"	  	} //Icone usado para os nos que se repetem em todas as estruturas comparadas
#DEFINE PCOICTREEEND       	{"amarelo"	,"amarelo"	} //icone usado para os nos que se repetem na estrutura principal e em algumas arvores

Static cContaOrc	:= ""
Static nQtdEntid	:= Nil

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ PCOA201		 บAutor  ณFernando R. Muscalu บ Data ณ 10/09/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o MBrowse da AKR		                           	       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaPco                                                     	   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PCOA201()

Local aAliases		:= {"AK1","AK2","AK3","AKE","AKR","AKG","AKS","AKT"}

	Private cCadastro 	:= STR0001 //"Nova Simula็ใo"
	Private aRotina 	:= MenuDef()

	If ChkAccessMode(aAliases)                                              
		mBrowse(6,1,22,75,"AKR") 
	Endif
		
Return()

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ PCOA201		 บAutor  ณFernando R. Muscalu บ Data ณ 10/09/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se os acessos das tabelas sใo equivalentes     	       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                     	   บฑฑ
ฑฑบ	         ณ Parโmetros:                                                 	   บฑฑ
ฑฑบ	         ณ #1: Array das tabelas a serem comparadas	                  	   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ChkAccessMode(aTabelas)

Local nI			:= 0       
Local lRet			:= .T.
Local cMsg			:= ""  
Local aShare		:= {}
Local aExclusive	:= {}
Local cModoFil	:= ""

For nI := 1 To Len(aTabelas)
	If !Empty(cModoFil := FWModeAccess(aTabelas[nI],3))
		If cModoFil == "C"
			aAdd(aShare,aTabelas[nI])
		Else
			aAdd(aExclusive,aTabelas[nI])
		Endif		
	Else
		lRet := .f.
		Aviso("NoAlias", STR0036 + Alltrim(aTabelas[nI]) + STR0037 ,{STR0021})	// "O Alias " // " nใo existe no dicionแrio de dados SX2."
		Exit
	Endif	
Next nI         

If len(aShare) > 0 .and. len(aExclusive) > 0
	lRet := .f.
	
	cMsg := STR0038 + space(10) + STR0039 + chr(13) + chr(10) // "Tabela " // " Modo de Acesso "
	
	For nI := 1 to len(aShare)
		cMsg += Padr(aShare[nI],6) + space(10) + Padr(STR0040,15) + chr(13) + chr(10) //"Compartilhado"
	Next nI
	       
	For nI := 1 to len(aExclusive)
		cMsg += Padr(aExclusive[nI],6) + space(10) + Padr(STR0041,15) + chr(13) + chr(10) // "Exclusivo"
	Next nI
	
Endif

If !Empty(cMsg)
	Aviso(STR0042,STR0043 + CHR(13) + CHR(10)+ cMsg,{STR0021},3) // "Incompatibilidade de Acesso" // "Existem diferen็as nos modos de acessos dos arquivos."
Endif

Return(lRet)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ MenuDef		 บAutor  ณFernando R. Muscalu บ Data ณ 10/09/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o menu da MBrowse		                           	       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                     	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ 													     	       บฑฑ   
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Array - aRotina (Array com op็๕es da MBrowse)                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function MenuDef()

Local aRotina := { 	 {STR0002,"AxPesqui"			,0,1},; //"&Pesquisar" 
		             {STR0003,"PCOA201Simula(2)"	,0,2},;  //"&Visualizar"
		             {STR0004,"PCOA201New"			,0,3},;  //"&Incluir"
  		             {STR0005,"PCOA201New"			,0,4},;  //"&Alterar"
		             {STR0006,"PCOA201New"			,0,5},;  //"E&xcluir"
		             {STR0007,"PCOA201Simula(6)"	,0,4},;  //"&Simular" 6
		             {STR0008,"PCO200Eft"			,0,7}}   //"&Efetivar"
Return(aRotina)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ PCOA201New	 บAutor  ณFernando R. Muscalu บ Data ณ 10/09/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Inclusใo,Altera็ใo e Exclusใo de uma simula็ใo          	       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                     	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ cAlias = Alias da tabela, nReg = Recno, nOpc   = Op็ใo desejada บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ 												                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/              
Function PCOA201New(cAlias,nReg,nOpc)
	PCO200Dlg(cAlias,nReg,nOpc,)
Return()

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ PCOA201Simula บAutor  ณFernando R. Muscalu บ Data ณ 10/09/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Simula็ใo de Or็amentos						        	       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaPco                                                     	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametrosณ nOpc = Op็ใo a ser executada                              	   บฑฑ
ฑฑบ          ณ        [2] = Visualiza็ใo                                       บฑฑ
ฑฑบ          ณ        [6] = Simula็ใo										   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ 												                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA201Simula(nOpc)

Local cNewVer		:= AKR->AKR_REVISA
Local nWidth  		:= GetScreenRes()[1] - 20	
Local nHeight 		:= GetScreenRes()[2] - 55	
Local nCtrlCallOrc	:= 1
Local nI			:= 0
Local nPos 			:= 0

Local aAreaAKR		:= AKR->(GetArea())
Local aSizeDlg		:= FwGetDialogsize(oMainWnd)
Local aConfigTree	:= {}
Local aParamsSeek	:= {}	 
Local aAllTrees		:= array(2)
Local aOrcInTree	:= {}             
Local aLinhas		:= {}
Local aRetPCOPlan	:= {}
Local aAK2Fields	:= HeaderPlan()
Local aSubHeadGD	:= {}
Local aButtons		:= {}
Local aSeries		:= {}
Local aGdPlan1		:= {}	//Array com o aCols da planilha principal - subsituira o aGdContas
Local aGdOtherPlan	:= {}	//Array com o aCols das outras planilhas

Local dDataIni		:= CtoD("//")
Local dDataFim		:= CtoD("//")

Local lSetCentury	:= __SetCentury()

Local oTree			:= Nil
Local oGd			:= Nil		 
Local oSayDtIni     := Nil
Local oSayDtFim     := Nil
Local oFont			:= TFont():New('Verdana',,-10,,.T.) //TFont():New('Times New Roman',,-14,.T.)
Local oBtnAplic		:= Nil 

Local bRClicked		:= {|oObjTree,x,y| NewMenuPopUp(oObjTree,x,y,oScrLayer:GetWinPanel("TreeCol","TreeWin","TreeLin"),aAllTrees,@nCtrlCallOrc,aOrcInTree,aConfigTree,aAreaAKR,aGdOtherPlan,oGd,aSeries,aGdPlan1) }

Local bUpdate		:= {|nP|nP := aScan(aAllTrees[1]:aNodes,{|x| alltrim(x[2]) == Alltrim(aAllTrees[1]:CurrentNodeId) }),;
							cContaOrc := aAllTrees[1]:aCargo[nP,1],;
							A201UpdPlan(aAllTrees[1],{aGdPlan1,aGdOtherPlan},oGd) }

/*
Local bLoadGDPCO	:= {|lGrava,nP| lGrava := Iif( !(Alltrim(oScrLayer:oOwner:oCtlFocus:cName) $ "PCOTGET|PCOGETDADO") ,.T.,.F.),;
						A201UPDGD(lGrava,aGdPlan1,oGd,cContaOrc,cNewVer),;
						nP := aScan(aAllTrees[1]:aNodes,{|x| alltrim(x[2]) == Alltrim(aAllTrees[1]:CurrentNodeId) }),;
						IIf(nP > 0, Eval(aAllTrees[1]:aCargo[nP,2]),nil) }
  */
Local bLoadGDPCO	:= {|lGrava,nP|;
						A201UPDGD(.T.,aGdPlan1,oGd,cContaOrc,cNewVer)}
/*						;
						nP := aScan(aAllTrees[1]:aNodes,{|x| alltrim(x[2]) == Alltrim(aAllTrees[1]:CurrentNodeId) }),;
  						IIf(nP > 0, Eval(aAllTrees[1]:aCargo[nP,2]),nil) }
  */						
Local bAction		:= {|| Iif(!IsInCallStack("A201UPDGD"),(Eval(bLoadGDPCO),Eval(bUpdate)),nil ) , ZeraGraph(@dDataIni,@dDataFim,aRetPCOPlan) }

Local bVldDtIni		:= {|lRet| lRet := dDataIni >= RetDateSHead(aRetPCOPlan[1],1) .and.; 
								dDataIni <= RetDateSHead(aRetPCOPlan[len(aRetPCOPlan)],2),;
								Iif(!lRet,Aviso(STR0044,STR0045,{STR0021}),nil ),lRet} // "Aten็ใo" // "A data inserida estแ fora do periํdo da planilha or็amentแria" //"Ok"

Local bVldDtFim		:= {|lRet| lRet := ( dDataFim >= RetDateSHead(aRetPCOPlan[1],1) .and. ; 
										 dDataFim <= RetDateSHead(aRetPCOPlan[len(aRetPCOPlan)],2) ) .and. ;
										 dDataFim >= dDataIni ,	Iif(!lRet,Aviso(STR0044,STR0046,{STR0021}),nil), lRet} // "Aten็ใo" // "A Data inserida estแ fora do perํodo da planilha or็amentแria ou ้ inferior a Data Inicial digitada" // "Ok"
								
Local bBtnAction	:= {||	Iif(	Eval(bVldDtIni) .and. Eval(bVldDtFim),;
									GraphPerRange(aSeries,dDataIni,dDataFim,aAllTrees,oGd,aGdOtherPlan),;
									Aviso(STR0029,STR0030,{STR0021}) )}
									
Local bBtnNoGra		:= {|| Iif( ChkCtaSint(aAllTrees[1]) ,Eval(bBtnAction), Nil ) }

Local aTreeInDlg	:= {}

Local bBtnSav		:= {|nP|	nP := aScan(aAllTrees[1]:aNodes,{|x| alltrim(x[2]) == Alltrim(aAllTrees[1]:CurrentNodeId)}) ,;
								A201UPDGD(.T.,aGdPlan1,oGd,aAllTrees[1]:aCargo[nP,1],cNewVer) }

Local bBtnOk		:= {|| Eval(bBtnSav) , oDlg:End() }

Local bBtnCancel	:= {|| oDlg:End()}

Local bEnchBarOn	:= {|| EnchoiceBar(oDlg,bBtnOk,bBtnCancel,,aButtons)}

Local oPanel1 		:= Nil
Local oBtnFw		:= Nil
Local oBar			:= Nil
Local oBtnOk		:= Nil

Private oDlg	
Private oScrLayer	:= fwLayer():New()
Private oGetDtIni	:= Nil
Private oGetDtFim	:= Nil     
Private oChart		:= Nil
Private dDtIni
Private dDtFim
Private cTpPeriod

If lSetCentury
	SET CENTURY OFF
EndIf

Aadd(aButtons,{"S4WB011N",{|| FLEGENSIM()},STR0024}) //"Legenda"
Aadd(aButtons,{"GRAF3D"  ,{|| PCOA201AddPlan(aAllTrees,@nCtrlCallOrc,aOrcInTree,aConfigTree,aAreaAKR,aGdOtherPlan,oGd,aSeries)}, STR0014 }) // "Pl.Compar."
If nOpc == 2
	bRClicked	:= {||}
	aButtons	:= {}	
	bEnchBarOn	:= {|| EnchoiceBar(oDlg,{|| oDlg:End()},{|| oDlg:End()},,aButtons)}
Endif

aConfigTree := {	"AK3",;
					"AK3_CO",;
					"AK3_PAI",;
					{1},;
					{2,"AK3_CO"},;
					{"AK3_CO","AK3_DESCRI"},;
					bAction,;
					Iif(ALTERA,bRClicked,{||}),;
					{||},;
					PCOICTREESTART}

aParamsSeek := {	AKR->AKR_FILIAL,;
					AKR->AKR_ORCAME,;
					AKR->AKR_REVISA	}

aAdd(aOrcInTree,Padr(AKR->AKR_FILIAL,TamSx3("AKR_FILIAL")[1]) + Padr(AKR->AKR_ORCAME,TamSX3("AKR_ORCAME")[1]) + padr(AKR->AKR_REVISA,TamSX3("AKR_REVISA")[1]))

//montagem da tela - a montagem se utiliza de um objeto FWLAYER
DEFINE MSDIALOG oDlg FROM aSizeDlg[2],aSizeDlg[1] TO aSizeDlg[3],aSizeDlg[4]  TITLE STR0009 PIXEL STYLE DS_MODALFRAME of oMainWnd //"Simula็ใo"

    //Deixar o objeto "maximizado"
    oDlg:LMaximized := .T.
    
    //inicializo o layout da tela do objeto oDlg de acordo com a o objeto oSCRLayer
	oScrLayer:init(oDlg,.F.)

	//Janela com a arvore
	oScrLayer:addLine("TreeLin",65,.t.)
	oScrLayer:addCollumn("TreeCol",40,.F.,"TreeLin")	
	oScrLayer:addWindow("TreeCol","TreeWin",STR0010,100,.f.,.t.,{||},"TreeLin")	 //"Contas Or็amentแrias"
	// monta painel com botoes para adicionar planilhas e comparacao e saldos
	oPanel1:=oScrLayer:getWinPanel("TreeCol","TreeWin","TreeLin")
	oPanel1:FreeChildren()

    If !(cVersao <> "11")
		If ALTERA
			oBtnFw := FWFormBar():New(oPanel1) // s๓ na VERSAO 11
			oBtnFw:AddUserBtn("",STR0014,{|| PCOA201AddPlan(aAllTrees,@nCtrlCallOrc,aOrcInTree,aConfigTree,aAreaAKR,aGdOtherPlan,oGd,aSeries) },STR0014)			
			oBtnFw:AddUserBtn("",STR0024,{|| FLEGENSIM() },STR0024)
		Else
			oBtnFw := FWFormBar():New(oDlg)
			oBtnFw:AddUserBtn("",STR0024,{|| FLEGENSIM() },STR0024)
			oBtnFw:AddClose( bBtnCancel , STR0015, STR0015 )
		EndIf
		If nOpc != 2 
			oBtnFw:Activate()
		EndIf
	EndIf

    //Captura-se as dimensoes da tela
	nHeight := oScrLayer:GetWinPanel("TreeCol","TreeWin","TreeLin"):nClientHeight
	nWidth	:= oScrLayer:GetWinPanel("TreeCol","TreeWin","TreeLin"):nClientWidth
	
	aTreeInDlg	:= {nWidth,nHeight,oScrLayer:GetWinPanel("TreeCol","TreeWin","TreeLin")}
	
	//Constroi a estrutura da arvore
	PCOxTree(aConfigTree,aParamsSeek,aTreeInDlg,aAllTrees)		

    //quando monto a arvore com um noh, a propriedade CurrentNodeId vem em branco
    //entretanto o TreeSeek na propriedade aNodes[1,2] falha, por isto eu igualo o CurrentNodeId ao aNodes[1,2]	
	If Empty(aAllTrees[1]:CurrentNodeId)
		aAllTrees[1]:CurrentNodeId := aAllTrees[1]:aNodes[1,2]
	Endif
	
	aAllTrees[1]:cName := "PCOTREE"

	//Adiciona nova janela, para receber um objeto getdados.
	//Esta janela pertencera a mesma line da janela da arvore, porem em coluna separada
	oScrLayer:addCollumn("GetDadoCol",60,.F.,"TreeLin")	
	oScrLayer:addWindow("GetDadoCol","GetDadoWin",STR0011,100,.f.,.t.,{||},"TreeLin")	 //"Detalhes da Planilha"

	oGd	:= PCOa014():New(oScrLayer:GetWinPanel("GetDadoCol","GetDadoWin","TreeLin"),,,,,bBtnSav)	
    
	// alimenta os arrays aPlanBegin e aPlanAnother para a funcao FValConta
	oGd:SetPlans(aGdPlan1,aGdOtherPlan)

    AK1->(DbSetOrder(1)) 
    
    AK1->(DbSeek(xfilial("AK1") + AKR->AKR_ORCAME))
    
    nPos := aScan(aAllTrees[1]:aNodes, {|x| alltrim(x[2]) == aAllTrees[1]:CurrentNodeId} )
    
    aRetPCOPlan := PcoRetPer(AK1->AK1_INIPER,AK1->AK1_FIMPER,AK1->AK1_TPPERI)
	
	dDataIni := RetDateSHead(aRetPCOPlan[1],1)
    dDataFim := RetDateSHead(aRetPCOPlan[len(aRetPCOPlan)],2)

	aSubHeadGD := JoinArrayPCO(aAK2Fields,aRetPCOPlan,.T.)
	
	aLinhas := array(len(aSubHeadGD))

	oGd:AddPlan({aSubHeadGD,aLinhas}, Alltrim(AK1->AK1_DESCRI),IIF(nOpc == 6,aRetPCOPlan, nil))
    
	For nI := 1 to len(oGd:oGetdd[1]:aHeader)
		oGd:SetCampoGD(oGd:oGetdd[1]:aHeader[nI,2],1)	
	Next nI
	
	oGd:oGetdd[1]:oBrowse:cName				:= "PCOGETDADO"  
	oGd:otGet:cName 							:= "PCOTGET"
  	
	//Funcao que carrega o array aGdPlan1                            
	A201LoadAllCO(aAlltrees,oGd,aOrcInTree,aGdPlan1,dDataIni,dDataFim,aSeries)	

	//Adiciona-se uma nova linha e coluna de divisao da oDlg.
	//Nesta linha e coluna sera tratado o grafico                                
	oScrLayer:addLine("GraficLin",35,.t.)
	oScrLayer:addCollumn("GraficParCol",20,.F.,"GraficLin")	
	oScrLayer:addCollumn("GraficCol",80,.F.,"GraficLin")	
	
	oScrLayer:addWindow("GraficParCol","GraficParWin",STR0025,90,.F.,.T.,{||},"GraficLin")	 //"Parโmetros do Grแfico"
    
	oSayDtIni 	:= TSay():New(08,03, {|| STR0026},oScrLayer:GetWinPanel("GraficParCol","GraficParWin","GraficLin"),, oFont,,,, .T.) //'Data Inicial'
	oGetDtIni	:= TGet():New(05,40, {|u| IIF(PCOUNT() > 0, dDataIni := u, dDataIni) },oScrLayer:GetWinPanel("GraficParCol","GraficParWin","GraficLin"),35,10,"@D",bVldDtIni,,,,,,.T.,,,{||ALTERA},,,,.F.,.F.,,"dDataIni") 
	
	oSayDtFim 	:= TSay():New(28,03, {|| STR0027},oScrLayer:GetWinPanel("GraficParCol","GraficParWin","GraficLin"),, oFont,,,, .T.) //'Data Final'
	oGetDtFim	:= TGet():New(25,40, {|u| IIF(PCOUNT() > 0, dDataFim := u, dDataFim) },oScrLayer:GetWinPanel("GraficParCol","GraficParWin","GraficLin"),35,10,"@D",bVldDtFim,,,,,,.T.,,,{||ALTERA},,,,.F.,.F.,,"dDataFim") 
	
	//este e o botao que aplica o filtro de datas, logo o grafico devera ser atualizado
	oBtnAplic	:= tButton():New(45,03,STR0081,oScrLayer:GetWinPanel("GraficParCol","GraficParWin","GraficLin"),bBtnNoGra,55,12,,,,.T.,,,,{||ALTERA}) //"Gerar grแfico"###'&Aplicar'###"Data errada"###"Foi informado errado as datas. Verifique."###"Ok"	
	
	oScrLayer:addWindow("GraficCol","GraficWin",STR0031,90,.F.,.T.,{||},"GraficLin")	 //"Grแfico"

	PCOA201Gra() //cria o grafico
	
	//Executa o bloco de acao do no da arvore,
	//porque nele contem funcoes que atualizam as Getdados e os graficos
	Eval(bAction)
	
oDlg:Activate(,,,.T.,,,bEnchBarOn)	    
oGD:DeActivate()
FreeObj(oGd)
oGd := Nil  
lSetCentury := __SetCentury()
cContaOrc := ""
If !lSetCentury
	SET CENTURY ON
EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณ Fernando R. Muscaluบ Data ณ  10/09/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega em mem๓rias os dados das contas or็amentแrias      บฑฑ
ฑฑบ          ณ para a GetDados e para o grแfico na tela de simula็ใo.     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A201LoadAllCO(aAlltrees,oGd,aOrcInTree,aGdPlan1,dDataIni,dDataFim,aSeries)

Local nI		:= 0
Local aData		:= {}
Local aAuxSer   := {}

For nI := 1 to len(aAllTrees[1]:aCargo)
	
	aData := PCOA201GetData(aOrcInTree[1],aAllTrees[1]:aCargo[nI,1])

	aAdd(aGdPlan1,{ aAllTrees[1]:aCargo[nI,1],;
					aClone(aData[1]),; 
					aClone(aData[2]) })
	
	aAdd(aAuxSer,{	aAllTrees[1]:aCargo[nI,1],;
					STR0047 +strzero(1,2) + space(1) + aAllTrees[1]:aCargo[nI,1],; //"Planilha - aba "
					SumRange2(aAllTrees[1]:aCargo[nI,1],aGdPlan1),;
					aOrcInTree[1]})	

Next nI

aAdd(aSeries,aClone(aAuxSer))

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna                                                    บฑฑ
ฑฑบ          ณ aLin: ACols com dados dos acols dos itens de or็amento     บฑฑ
ฑฑบ          ณ (AK2) ou os saldos (PCORUNCUBE) do processamento do cubo   บฑฑ 
ฑฑบ          ณ aFormu: As f๓rmulas Excell que foram armazenadas na AK2    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOA201GetData(cChaveBusca,cCO,cCall,oGd,aPlanOrc,cCube,aParams)

Local cIdentify		:= ""
Local cConfigCube	:= ""
Local nPos			:= 0  
Local nX			:= 0
Local nPosHead		:= 0
Local nI			:= 0
Local aHeadPCOPlan	:= {}
Local aLin			:= {}
Local aItem			:= {}
Local aItemSld		:= {}
Local aPeriod		:= {}
Local aFixHead		:= {}
Local aFormulPCO	:= {}
Local aForm			:= {}
Local aArea			:= GetArea()
Local aAreaAK1		:= AK1->(GetArea())
Local dDtInicio
Local dDtFinal
Local cHrIni		:= ""
Local aMinMax		:= {}
Local aProcessa		:= {}
Local aFilStart		:= {}
Local aFilEnd		:= {}
Local nPConta		:= 0
Default cCall 		:= ""
Default cCube		:= ""
Default aPlanOrc	:= {}
Default aParams		:= {}

aFixHead			:= HeaderPlan()  

If cCall == "SALDO"                            
	
	cCube		:= Iif(len(aParams) >= 5, aParams[1], "")
	cConfigCube	:= Iif(len(aParams) >= 5, aParams[2], "")
	
	dDtIni		:= Iif(len(aParams) >= 5, aParams[3], "" )
	dDtFim		:= Iif(len(aParams) >= 5, aParams[4], "" )

	cTpPeriod	:= Iif(len(aParams) >= 5, If(ValType(aParams[5])=="N",CValToChar(aParams[5]),aParams[5]),"0" )
	
	If Empty(dDtIni) .and. Empty(dDtFim) .and. cTpPeriod == "0"
		
		AK1->(DbSetOrder(1)) 
		AK1->(DbSeek(xfilial("AK1") + AKE->AKE_ORCAME))	
	
		dDtIni		:= AK1->AK1_INIPER
		dDtFim		:= AK1->AK1_FIMPER
		cTpPeriod 	:= AK1->AK1_TPPERI
	EndIf           
	
	aPeriod	:= PcoRetPer(dDtIni,dDtFim,cTpPeriod)
	
	nPConta := aScan(aPlanOrc,{|x| alltrim(x[1]) == Alltrim(cCo)})
	
	If Len(aPlanOrc[nPConta,2]) > 1
	    
	    aMinMax		:= GetMinMaxCC(aPlanOrc[nPConta,2])
	    
		aFilStart	:= {Padr(cCo,TamSx3("AKR_ORCAME")[1]),Padr(aMinMax[1],TamSx3("AK2_CC")[1])}		
		aFilEnd		:= {Padr(cCo,TamSx3("AKR_ORCAME")[1]),PadR(aMinMax[2],TamSx3("AK2_CC")[1])}
		
		aProcessa 	:= PcoRunCube(cCube,len(aPeriod),"PCOA201PERSLD",cConfigCube,,,,aFilStart,aFilEnd,,,.f.)
	Endif	
	
	aHeadPCOPlan	:= JoinArrayPCO(aFixHead,aPeriod,.t.)
	
	If Len(aProcessa) > 0
		aProcessa 	:= SetFilterCube(cCube,aClone(aProcessa),cCo,aPlanOrc,aFixHead)	
	Endif	

    aAdd(aLin,aClone(aHeadPCOPlan))
    aAdd(aLin[len(aLin)],.f.)
	
	aItemSld := BuildStrucSld(cCube,aPeriod,aProcessa,aPlanOrc)		
	
	If len(aItemSld) == 0
		
		aItemSld := array(len(aHeadPCOPlan)+1)
		aItemSld[len(aItemSld)] := .f.	

		aSetDefaultValues(aItemSld)
		aAdd(aLin,aClone(aItemSld))
	Else
		For nI := 1 to len(aItemSld)	
			aAdd(aLin,aClone(aItemSld[nI])) 
		Next nI	
	Endif	
	
	aForm := aClone(aLin)

Else

	AKE->(dbSetOrder(1))
	AKE->(DbSeek(cChaveBusca+cCo))
	
	AK1->(DbSetOrder(1)) 
	AK1->(DbSeek(xfilial("AK1") + AKE->AKE_ORCAME))	
	
	aPeriod		 	:= PcoRetPer(AK1->AK1_INIPER,AK1->AK1_FIMPER,AK1->AK1_TPPERI)
	aHeadPCOPlan	:= JoinArrayPCO(aFixHead,aPeriod,.t.)
			
	aItem 		:= array(len(aHeadPCOPlan) + 1)
	aFormulPCO 	:= array(len(aHeadPCOPlan) + 1)
	
	For nX := 1 to len(aItem)
		If nX <> Len(aItem)
			aItem[nX] 		:= aHeadPCOPlan[nX]  
			aFormulPCO[nX]	:= aHeadPCOPlan[nX]
		Else
			aItem[nX] 		:= .f.	
			aFormulPCO[nX]	:= .f.	
		Endif
	Next nI
	
	aAdd(aLin,aClone(aItem))
	aAdd(aForm,aClone(aFormulPCO))
	
	aItem 		:= array(len(aHeadPCOPlan) + 1)
	aFormulPCO 	:= array(len(aHeadPCOPlan) + 1)
	
	AK2->(DbSetOrder(5)) //AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO+AK2_ID+DTOS(AK2_PERIOD)
	If AK2->(DbSeek(	xFilial("AK2") + ;
						Padr(AKE->AKE_ORCAME,TamSx3("AK2_ORCAME")[1]) + ;
						Padr(AKE->AKE_REVISA,TamSx3("AK2_VERSAO")[1]) + ;
						PadR(cCo,TamSx3("AK2_CO")[1]) ))
		
		cIdentify := AK2->AK2_ID
		
		While	AK2->(!Eof()) .and.; 
				AK2->AK2_FILIAL == xFilial("AK2") .and.;
				Alltrim(AK2->AK2_ORCAME) == Alltrim(AKE->AKE_ORCAME) .and.; 
				Alltrim(AK2->AK2_VERSAO) == Alltrim(AKE->AKE_REVISA) .and.;
				Alltrim(AK2->AK2_CO) == Alltrim(cCo) 
				
			For nX := 1 to len(aFixHead)
				aItem[nX] := PCOCasting(AK2->&(aFixHead[nX]),"C")				
			Next nX
			
			If (nPosHead := aScan(aHeadPCOPlan, {|X| substr(x,1,8) == dtoc(AK2->AK2_DATAI) }) ) > 0
				aItem[nPosHead] 		:= PCOCasting(AK2->AK2_VALOR,"C")
				aFormulPCO[nPosHead] 	:= PCOCasting(AK2->AK2_FORM,"C")
			Endif						
			
			cIdentify := AK2->AK2_ID	
			
			AK2->(dbSkip())
			
			If cIdentify <> AK2->AK2_ID
				
				aSetDefaultValues(aItem)
				aItem[Len(aItem)] := .f.
				aAdd(aLin,aClone(aItem))                  
	            
				aItem 		:= {}
				aItem 		:= Array(len(aHeadPCOPlan)+1)
				
				aSetDefaultValues(aFormulPCO)
				aAdd(aForm,aClone(aFormulPCO))
				
				aFormulPCO 	:= {}
				aFormulPCO 	:= array(len(aHeadPCOPlan)+1)
				
			Endif
		EndDo		
	
	EndIf       
	
	If len(aItem) > 0 .and. aItem[1] <> nil
		aSetDefaultValues(aItem)
		aItem[Len(aItem)] := .f.
		aAdd(aLin,aClone(aItem))                  
		
	 	aForm := {}
		aSetDefaultValues(aFormulPCO)
		
		aAdd(aForm,aClone(aLin[1]))
		aAdd(aForm,aClone(aFormulPCO))
	Endif
Endif         

RestArea(aArea)
RestArea(aAreaAK1)

Return({aLin,aForm})


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Posicionado numa conta or็amentaria, retorna o menor e o   บฑฑ
ฑฑบ          ณ maior centro de custo.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetMinMaxCC(aPlanOrc)

Local aRet		:= {}
Local aHeadAk2	:= HeaderPlan()
Local aAux		:= {}
Local nPCC		:= aScan(aHeadAk2,"AK2_CC")
Local nI		:= 0

For nI := 2 to len(aPlanOrc)
	aAdd(aAux,aPlanOrc[nI,nPCC])	
Next nI

aSort(aAux,,,{|x,y| x < y})

aRet := {aAux[1],aAux[len(aAux)]}

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza a getDados da entidades contแbeis para todas as   บฑฑ
ฑฑบ          ณ abas da planilha, de acordo com CO posicionada na estruturaบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A201UpdPlan(oTreePCO,aPlanilhas,oGd,lRefazGD,cDesFolder)

Local nPos			:= 0
Local nPos2			:= 0
Local nI			:= 0
Local nX			:= 0
Local nZ			:= 0
Local aArray		:= {}
Local cDescri		:= ""
Local dDataIni
Local dDataFim
Local nPosFolder	:= 0

Default lRefazGD    := .f.

/*
aPlanilhas - array com os arrays aGdPlan1 e aGdOtherPlan
	aPlanilhas[1] - aGdPlan1
	aPlanilhas[2] - aGdOtherPlan
	
aArray - array com os dados para atualizacao do objeto PCOA014
	aArray[n,1] - Nro da Folder a ser atualizada
	aArray[n,2] - Array que ira atualizar o aCols
	aArray[n,3] - Array que ira atualizar o vetor de formulas
*/

nPos := aScan(oTreePCO:aNodes, {|x| alltrim(x[2]) == Alltrim(oTreePCO:CurrentNodeId) })

For nI := 1 to len(aPlanilhas)

	If nPos > 0 
	
		If nI <> 1                           
			If len(aPlanilhas[nI]) > 0
				For nZ := 1 to len(aPlanilhas[nI])
					For nX := 1 to len(aPlanilhas[nI,nZ])
						If AllTrim(aPlanilhas[nI,nZ,nX,3]) == alltrim(oTreePCO:aCargo[nPos,1])
							aArray := {aPlanilhas[nI,nZ,nX,4],aPlanilhas[nI,nZ,nX,5]}
							aArray := {aClone(aPlanilhas[nI,nZ,nX,4]),aClone(aPlanilhas[nI,nZ,nX,5])}
							oGd:NewUpdPlan(aPlanilhas[nI,nZ,nX,1],aArray,lRefazGD)
							nPosFolder := aPlanilhas[nI,nZ,nX,1]
						Endif	
					Next nX
				Next nZ	
			Endif
		Else
			nPos2 := aScan(aPlanilhas[nI], {|x| alltrim(x[1]) == alltrim(oTreePCO:aCargo[nPos,1])} )
	
			If nPos2 > 0     
				aArray := {aPlanilhas[1][nPos2,2],aPlanilhas[1][nPos2,3]}
				aArray := {aClone(aPlanilhas[1][nPos2,2]),aClone(aPlanilhas[1][nPos2,3])}
				oGd:NewUpdPlan(1,aArray)
			Endif	
		Endif
	Endif
Next nI

If nPosFolder > 1
	oGd:OFOLDER:ADIALOGS[nPosFolder]:CCAPTION := cDesFolder
	oGd:OFOLDER:ADIALOGS[nPosFolder]:Refresh()
EndIf                                                                                     
If nPos > 0 
	oGd:cContaSelect := SubStr(oTreePCO:aNodes[nPos][4],1,At("-",oTreePCO:aNodes[nPos][4]) -1)
Endif
Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza o Grแfico da simula็ใo de acordo com as planilhas บฑฑ
ฑฑบ          ณ de or็amento e saldos                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A201UpdGraph(aSeries,aAllTrees)

Local nPTree	:= aScan(aAllTrees[1]:aNodes,{|x| alltrim(x[2]) == Alltrim(aAllTrees[1]:CurrentNodeId) })
Local nPos		:= 0
Local nI		:= 0

/*
aSeries - array com as series
	aSeries[n] - Array que representa cada planilha
		aSeries[n,x] - array que representa cada Conta
			aSeries[n,x,1] - nro da Conta
			aSeries[n,x,2] - descricao da barra do grafico ou da legenda
			aSeries[n,x,3] - valor
*/

//Exclui o objeto o grafico
oScrLayer:getWinPanel('GraficCol','GraficWin','GraficLin'):FreeChildren()
//Recria o objeto do grafico
PCOA201Gra()

If oChart <> nil

	oChart:aSeries := {}
	
	For nI := 1 to len(aSeries)    
		nPos := aScan(aSeries[nI], {|x| alltrim(x[1]) == alltrim(aAllTrees[1]:aCargo[nPTree,1])})
		oChart:AddSerie(aSeries[nI,nPos,2],aSeries[nI,nPos,3])	
	Next nI
	
	oChart:Refresh()
	
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณMicrosiga           บ Data ณ  12/22/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Consolida os valores de cada planilha para compor o grแficoบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function SumRange2(cCO,aArraySum,nStartShru,nEndShru)

Local nRetSum	:= 0
Local nI 		:= 0   

Local nX		:= 0
Local nP 		:= aScan(aArraySum,{|x| Alltrim(x[1]) == alltrim(cCO)})	
Local nFieldVal := Len(HeaderPlan()) + 1 

default nStartShru	:= nFieldVal
default nEndShru	:= len(aArraySum[nP,2,1]) - 1


For nI := 2 to len(aArraySum[nP,2]) //comecar da segunda linha, pois, a primeira linha representa o cabecalho
	For nX := nStartShru to nEndShru //por ser a soma do Acols, o ultimo elemento e booleano, este pode ser desconsiderado  
		If Valtype(aArraySum[nP,2,nI,nX]) == "C"
			nRetSum += Val(aArraySum[nP,2,nI,nX])
		Endif	
	Next nX
Next nI

Return(nretsum)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Atualiza grแfico de acordo com o perํodo informado nos     บฑฑ
ฑฑบ          ณ parโmetros do grแfico.                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GraphPerRange(aSeries,dDataIni,dDataFim,aAllTrees,oGd,aGdOtherPlan)

Local aAreaAK1		:= AK1->(GetArea())                                                                      
Local aArray		:= {}
Local aFieldsAk2    := HeaderPlan()
Local aPeriodo		:= {}
Local nFolder		:= 0
Local nFirst		:= 0
Local nLast			:= 0
Local nPTree		:= aScan(aAllTrees[1]:aNodes,{|x| alltrim(x[2]) == alltrim(aAllTrees[1]:CurrentNodeId)})
Local nPos 			:= Iif(nPTree > 0 , aScan(aSeries[1],{|x| alltrim(x[1]) == Alltrim(aAllTrees[1]:aCargo[nPTree,1]) } ), 0 )
Local nStart		:= 0
Local nEnd			:= 0
Local nX			:= 0
Local nI			:= 0
Local nSum			:= 0
Local nDeltaPer		:= 0                  
Local nDeltaRange   := 0
Local nDailyVal		:= 0
Local nPos2			:= 0
Local dFirst
Local dLast
Local dDefaultIni
Local dDefaultFim
Local cChave		:= ""	

Default aGdOtherPlan	:= {}

If nPos > 0

	//Atualizacao do grafico da primeira planilha
	//somando a Primeira Planilha, com os Valores Dentro do Range
	AK1->(DbSetOrder(1)) 
	AK1->(DbSeek(xFilial("AK1") + AKR->AKR_ORCAME))   
	
	aPeriodo	:= PcoRetPer(AK1->AK1_INIPER,AK1->AK1_FIMPER,AK1->AK1_TPPERI)
	
	dDefaultIni	:= RetDateSHead(aPeriodo[1],1)
	dDefaultFim	:= RetDateSHead(aPeriodo[Len(aPeriodo)],2)
	
	nFirst		:= GetPeriod(aPeriodo,dDataIni)
	nLast		:= GetPeriod(aPeriodo,dDataFim)
	
	dFirst		:= RetDateSHead(aPeriodo[nFirst],1)
	dLast		:= RetDateSHead(aPeriodo[nLast],2)  
	
	nStart	:= len(aFieldsAk2) + nFirst
	nEnd	:= nStart + (nLast-nFirst)
	
	aArray := {{aAllTrees[1]:aCargo[nPTree,1], oGd:oGetDD[1]:aCols, oGd:aPlanCopy[1]}}
	
	If dDataIni == dDefaultIni	.and. dDataFim == dDefaultFim            
		If nPTree > 0
			nFinishVal := SumRange2(aAllTrees[1]:aCargo[nPTree,1],aArray )
		Endif	
	Else
		nSum := SumRange2(aAllTrees[1]:aCargo[nPTree,1],aArray,nStart,nEnd )
	
		If dFirst <> dDataIni .or. dLast <> dDataFim
			nDeltaPer		:= dLast - dFirst
			nDeltaRange   	:= dDataFim - dDataIni
			
			If nDeltaPer > 0 .and. nDeltaRange > 0
				nDailyVal := nSum / nDeltaPer
			Endif
			
			nFinishVal := round(nDailyVal * nDeltaRange,2)
		Else
			nFinishVal := nSum
		Endif	
	Endif
	
	If nFinishVal > 0
		aSeries[1,nPos,3] := nFinishVal
	Endif	
	
	//Atualizacao dos demais graficos - outras planilhas
	For nX := 1 to len(aGdOtherPlan)  
	
		If (nPos2 := aScan(aGdOtherPlan[nX],{|x| alltrim(x[3]) == AllTrim(aAlltrees[1]:aCargo[nPtree,1])}) ) > 0
			
			If aGdOtherPlan[nX,nPos2,2] <> "SALDO"
			
				AK1->(DbSetOrder(1))
				cChave := substr(aGdOtherPlan[nX,nPos2,2],1,TamSx3("AK1_FILIAL")[1])+Substr(aGdOtherPlan[nX,nPos2,2],TamSx3("AK1_FILIAL")[1]+1,TamSx3("AK1_CODIGO")[1])
				AK1->(DBSEEK(cChave))
		
				aPeriodo := PcoRetPer(AK1->AK1_INIPER,AK1->AK1_FIMPER,AK1->AK1_TPPERI)
				
				nFirst	:= GetPeriod(aPeriodo,dDataIni)
				nLast	:= GetPeriod(aPeriodo,dDataFim)
				
				If nFirst > 0 .and. nFirst <= len(aPeriodo)
					dFirst	:= RetDateSHead(aPeriodo[nFirst],1)
				ElseIf nFirst == 0          
				 	dFirst := RetDateSHead(aPeriodo[1],1)	
				Elseif nFirst > len(aPeriodo)
					dFirst := RetDateSHead(aPeriodo[len(aPeriodo)],2)	
				Endif	
				
				If nLast > 0 .and. nLast <= len(aPeriodo)
					dLast	:= RetDateSHead(aPeriodo[nLast],2) 
				ElseIf nLast == 0
					dLast	:= RetDateSHead(aPeriodo[1],1)
				ElseIf nLast > len(aPeriodo)
					dLast	:= RetDateSHead(aPeriodo[len(aPeriodo)],2)
				Endif	
		
				nStart	:= len(aFieldsAk2) + nFirst
				nEnd	:= nStart + (nLast-nFirst)
		
				aArray := {{aGdOtherPlan[nX,nPos2,3],aGdOtherPlan[nX,nPos2,4],aGdOtherPlan[nX,nPos2,5]} }
				
				If dDataIni == dDefaultIni	.and. dDataFim == dDefaultFim            
					If nPTree > 0
						nFinishVal := SumRange2(aAllTrees[1]:aCargo[nPTree,1],aArray )
					Endif	
				Else
					nSum := SumRange2(aGdOtherPlan[nX,nPos2,3],aArray,nStart,nEnd)
					
					If dFirst <> dDataIni .or. dLast <> dDataFim
						nDeltaPer		:= dLast - dFirst
						nDeltaRange   	:= dDataFim - dDataIni
						
						If nDeltaPer > 0 .and. nDeltaRange > 0
							nDailyVal := nSum / nDeltaPer
						Endif
						
						nFinishVal := round(nDailyVal * nDeltaRange,2)
					Else
						nFinishVal := nSum
					Endif
				Endif
				
				If nFinishVal > 0      
					nFolder := aGdOtherPlan[nX,nPos2,1]
					nPos := aScan(aSeries[nFolder],{|x| alltrim(x[1]) == Alltrim(aAllTrees[1]:aCargo[nPTree,1]) } )
					aSeries[nFolder,nPos,3] := nFinishVal
				Endif	
			Endif	    
	    Endif
	Next nX
	
	A201UpdGraph(aSeries,aAllTrees)
	
	RestArea(aAreaAk1)

Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida a data informada nos parโmetros do grafico de       บฑฑ
ฑฑบ          ณ acordo com o periodo da planilha, retornado qual ้ a       บฑฑ
ฑฑบ          ณ posicao da get dados onde a data se encaixa.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetPeriod(aPeriod,dData)

Local dInicio	:= ctod("")
Local dFinal	:= ctod("")

Local nI		:= 0

For nI := 1 to len(aPeriod)
	
	dInicio := RetDateSHead(aPeriod[nI],1)
	dFinal	:= RetDateSHead(aPeriod[nI],2)    
	
	If dData >= dInicio .and. dData <= dFinal
		Exit
	Endif 
	
Next nI 

Return(nI)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cabe็alho os itens de or็amento (AK2)                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function HeaderPlan()      
Local aList	:= {}
Local nX	:= 0

If nQtdEntid == Nil
	If cPaisLoc == "RUS" 
		nQtdEntid := PCOQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor.
	Else
		nQtdEntid := CtbQtdEntd() //sao 4 entidades padroes -> conta /centro custo /item contabil/ classe de valor
	EndIf
EndIf

aAdd(aList, "AK2_CC")
aAdd(aList, "AK2_ITCTB")
aAdd(aList, "AK2_CLVLR")
Aadd(aList, "AK2_UNIORC")

For nX := 5 To nQtdEntid
	Aadd(aList, "AK2_ENT"+StrZero(nX,2))
Next nX

aAdd(aList, "AK2_CLASSE")
aAdd(aList, "AK2_DESCRI")
aAdd(aList, "AK2_OPER")
aAdd(aList, "AK2_CHAVE")
aAdd(aList, "AK2_MOEDA")

Return(aList)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se os dados da planilha foram alterados que seja  บฑฑ
ฑฑบ          ณ feita a armazena e atualiza e recarrega as variแveis de    บฑฑ
ฑฑบ          ณ mem๓ria.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A201UPDGD(lGrava,aGdPlan1,oGd,cCo,cNovaVersao,lAutoSave)

Local nPos			:= aScan( aGdPlan1, {|x| alltrim(x[1]) == Alltrim(cCO)} ) 
Local lSave			:= .f.
Local aArray		:= {}
Local aSyncGd		:= {}

Default	lAutoSave	:= .f. 

If nPos > 0

	aSyncGd	:= SyncData(oGd:oGetDD[1]:aCols,aGdPlan1[nPos,2],oGd:nFormLimit)
	
	If A201DiffAcols(aSyncGd,oGd:oGetDD[1]:aCols,oGd:nFormLimit) .or. lAutoSave
	
		If lGrava
			//efetua a Gravacao	
			If lAutoSave
				lSave := .t.
			Else	
				lSave := MSGYesNo(STR0012 + alltrim(cCo) + "?" + chr(10)+chr(13) + STR0013) //"Deseja efetivar a opera็ใo da conta "###"OBS: Nใo efetivar implicarแ na perda dos dados para esta conta."
			Endif
				
			If lSave
				PCOA2010Grv(cCO,oGd:oGetDD[1],oGd:aPlanCopy[1],cNovaVersao)
				aGdPlan1[nPos,2] := oGd:oGetDD[1]:aCols
				aGdPlan1[nPos,3] := oGd:aPlanCopy[1]
		
				aGdPlan1[nPos,2] := aClone(oGd:oGetDD[1]:aCols)
				aGdPlan1[nPos,3] := aClone(oGd:aPlanCopy[1])
			Endif
		Endif    
	
	Endif

Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua a chamada para a fun็ใo de armazenamento dos dados  บฑฑ
ฑฑบ          ณ na AK2 e salva a แrea da tabela AKR.                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOA2010Grv(cCO,oGetDados,aFormulas,cNovaVersao)

Local nRecAKR 		:= AKR->(Recno())
Local cPeriod		:= ""		

Begin Transaction  
	MsgRun(STR0053 + alltrim(cCO),,{ || NewGravaAK2(cCo,nRecAKR,cNovaVersao,oGetDados,aFormulas) })  // "Aguarde...Gravando os detalhes da simula็ใo. Planilha "                
End Transaction

AKR->(DbGoto(nRecAKR))		

Return()


/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ GravaAK2      บAutor  ณFernando R. Muscalu บ Data ณ 10/09/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava็ใo na AK2 								        	       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaPco                                                     	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros : # aAllTrees   = Array contendo a Tree                      	ฑฑบ
ฑฑบ              # nRecAKR     = Recno da AKR                               	ฑฑบ
ฑฑบ              # cNovaVersao = Nova versใo                               	 	ฑฑบ
ฑฑบ              # lNewRec     = Se ้ inclusใo,alter็ใo,exclusใo             	ฑฑบ
ฑฑบ              # aGdContas   = Array com as contas do or็amento que esta   	ฑฑบ
ฑฑบ              #               sendo simulado 								ฑฑบ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ 												                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NewGravaAK2(cCo,nRecAKR,cNovaVersao,oGetDados,aFormulas)

Local nI			:= 0
Local nY			:= 0
Local nX			:= 0
Local nVlrField		:= 0

Local aRetPCOPlan 	:= {}
Local aCampoAK2		:= HeaderPlan()
Local aSubHeadGD 	:= {}

Local lNewRecAK2	:= .T.

Local nPosPer		:= len(aCampoAk2) + 1

AKR->(DbGoto(nRecAKR))

AK1->(DbSetOrder(1)) 
    
AK1->(DbSeek(xfilial("AK1") + AKR->AKR_ORCAME ))
    
aRetPCOPlan := PcoRetPer(AK1->AK1_INIPER,AK1->AK1_FIMPER,AK1->AK1_TPPERI)

aSubHeadGD	:= JoinArrayPCO(aCampoAK2,aRetPCOPlan)

For nI := 2 to len(oGetDados:aCols)
	For nY := 1 to len(aRetPCOPlan)
	  	
	  	nVlrField := PCOCasting(oGetDados:aCols[nI,nY + len(aCampoAK2)+1],"N")
	  				  	
		AK2->(DbSetOrder(5)) //AK2_FILIAL+AK2_ORCAME+AK2_VERSAO+AK2_CO+AK2_ID+DTOS(AK2_PERIOD)
		If AK2->(DbSeek(	xFilial("AK2") +; 
							PadR(AKR->AKR_ORCAME,TamSX3("AK2_ORCAME")[1]) +; 
							PadR(cNovaVersao,TamSX3("AK2_VERSAO")[1]) +; 
							Padr(cCO,TamSX3("AK2_CO")[1]) +; 
							strzero(nI-1,TamSX3("AK2_ID")[1])+;
							dtos(RetDateSHead(aRetPCOPlan[nY],1)) ))
			lNewRecAK2 := .f.
		Else
			lNewRecAK2 := .t.
		Endif					
					
		RecLock("AK2",lNewRecAK2)	
		    
			If lNewRecAK2
				AK2->AK2_FILIAL		:= xFilial("AK2")
				AK2->AK2_ID			:= strzero(nI-1,TamSX3("AK2_ID")[1])
				AK2->AK2_ORCAME		:= AK1->AK1_CODIGO
				AK2->AK2_VERSAO		:= cNovaVersao
				AK2->AK2_CO			:= Alltrim(cCO)
				AK2->AK2_PERIOD		:= RetDateSHead(aRetPCOPlan[nY],1)
 				AK2->AK2_DATAI		:= RetDateSHead(aRetPCOPlan[nY],1)
				AK2->AK2_DATAF		:= RetDateSHead(aRetPCOPlan[nY],2)
											
				For nX := 1 to len(aCampoAk2) 
					AK2->&(aCampoAK2[nX]) := PCOCasting(oGetDados:aCols[nI,nX+1],Posicione("SX3",2,Alltrim(aCampoAK2[nX]),"X3_TIPO" ))
				Next nX
	  		Endif				
			
			AK2->AK2_DATAI	:= RetDateSHead(aRetPCOPlan[nY],1)
			AK2->AK2_DATAF	:= RetDateSHead(aRetPCOPlan[nY],2)
			AK2->AK2_FORM	:= aFormulas[nI,nPosPer+nY]
			AK2->AK2_VALOR	:= nVlrField
			
		AK2->(MSUnlock())

	Next nY
Next nI	

Return()

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ PCOCasting    บAutor  ณFernando R. Muscalu บ Data ณ 10/09/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Conversใo de valores							        	       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaPco                                                     	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros : 	# xValueIn  = Valor a ser convertido					   ฑฑบ
ฑฑบ             	# cTypeCast = Tipo da variavel xValueIn                    ฑฑบ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Valor convertido 							                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Function PCOCasting(xValueIn,cTypeCast)

Local xValueOut
Local cTypeIn 	:= ""	                            

cTypeIn := Valtype(xValueIn)

Do Case 
	Case cTypeIn == "C"
		If cTypeCast == "C" 
			xValueOut := xValueIn
		ElseIf cTypeCast == "N"
			If isDigit(xValueIn)
				xValueOut := Val(xValueIn)
			Else
				xValueOut := 0	
			Endif
		ElseIf cTypeCast == "D"
			xValueOut := ctod(xValueIn)		
		Endif
		
		If xValueOut == Nil 
			xValueOut := ""
		Endif
		
	Case cTypeIn == "N"
		If cTypeCast == "C"
			xValueout := Alltrim(str(xValueIn))
		ElseIf cTypeCast == "N"
			xValueOut := xValueIn
		ElseIf cTypeCast == "D"
			xValueOut := 0
		Endif
		
		If xValueOut == nil
			xValueOut := 0
		Endif
	Case cTypeIn == "D"
		If cTypeCast == "C"
			xValueOut := dtoc(xValueIn)
		ElseIf cTypeCast == "D"
			xValueOut := xValueIn	
		Endif	
		
		If xValueOut == nil
			xValueOut := xValueIn
		Endif	
	Case cTypeIn == "L"
		If cTypeCast == "C"
			xValueOut := Iif(xValueIn,".T.",".F.")
		ElseIf cTypeCast == "N"
			xValueOut := Iif(xValueIn,1,0)	
		Endif
		
		If xValueOut == nil
			xValueOut := xValueIn
		Endif		
End Case

Return(xValueOut)

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ RetDateSHead  บAutor  ณFernando R. Muscalu บ Data ณ 10/09/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Conversใo de datas							        	       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaPco                                                     	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros : 	# cSHeadDate   = variavel com as datas a serem separadas   ฑฑบ
ฑฑบ             	# nPosDate     = Informa qual data quer					   ฑฑบ
ฑฑบ                 # 				[1] = Data Inicial						   ฑฑบ
ฑฑบ					#				[2] = Data Final 						   ฑฑบ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ Data inicial ou final						                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
Static Function RetDateSHead(cSHeadDate,nPosDate)

Local dRetDate
Local aData		:= array(2)

//nPosDate := 1 para a data inicial; 2 para a data final
aData := StrTokArr(cSHeadDate,"-")
dRetDate := ctod(alltrim(aData[nPosDate]))

Return(dRetDate)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Menu do botใo direito ao clicar na แrvore(estrutura de COs)บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function NewMenuPopUp(oObjTree,x,y,oPanelTree,aAllTrees,nCtrlCallOrc,aOrcInTree,aConfigTree,aAreaAKR,aGdOtherPlan,oGd,aSeries,aGdPlan1)

Local oMenu

MENU oMenu POPUP
	MenuItem STR0083 Block {|| PCOA201AddPlan(aAllTrees,@nCtrlCallOrc,aOrcInTree,aConfigTree,aAreaAKR,aGdOtherPlan,oGd,aSeries) } //"Incluir Plan. Comp."	
ENDMENU

oMenu:Activate(x-45, y-190, oPanelTree)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Adiciona novas abas de or็amento(s) ou saldo               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOA201AddPlan(aAllTrees,nCtrlCallOrc,aOrcInTree,aCfgTree,aAreaAKR,aGdOtherPlan,oGd,aSeries,cCall,aPlanOrc)

Local InOrcam		:= ""
Local InOrcVer      := ""
Local InOrcCont     := ""
Local clDescri		:= ""
Local aParamsSeek 	:= {}
Local aRetPCOPlan	:= {}
Local aSubHeadGD	:= {}
Local aAK2Fields	:= HeaderPlan()
Local aLinha		:= {}
Local aRecPar		:= {}
Local nPos			:= 0
Local nTpPeriod		:= 3
Local lParamBox		:= .f.
Local lRefazSld		:= .f.
Local lUpdNow		:= .f.
Local lExistsPlan	:= .t.
Local lNotLoad		:= .f.                          
//Bloco de codigo que executara o Bloco bAction do No da arvore
Local bAction		:= {|nP| nP := aScan(aAllTrees[1]:aNodes, {|x| alltrim(x[2]) == aAllTrees[1]:CurrentNodeId}),;
						Eval(aAllTrees[1]:aCargo[nP,2]) }				
Local nInd	 		:= 0
Local cDesFolder	:= ""

Default cCall		:= ""
Default aPlanOrc	:= {}

If cCall <> "SALDO"
	lParamBox := ParamBox({	{1 ,STR0023 ,Space(TamSX3("AK1_CODIGO")[1]) ,"@!" ,'Vazio() .Or. ExistCpo("AK1",MV_PAR01,1)'          ,"AK1"   ,"" ,TamSX3("AK1_CODIGO")[1] ,.T.} ,; // "Or็amento"
							{1 ,STR0032 ,Space(TamSX3("AKE_REVISA")[1]) ,"@!" ,'Vazio() .Or. ExistCpo("AKE",MV_PAR01+MV_PAR02,1)' ,"AKEVS" ,"" ,TamSX3("AKE_REVISA")[1] ,.T.}},; // "Versใo"
							STR0055,; // "Consulta Planilhas Orcamentarias"
							aRecPar,;
							,;
							,;
							,;
							,;
							,;
							,;
							"PCOADDPLAN",;
							,;
							.T.)

Else			
	lParamBox := ParamBox({	{1 ,STR0056 ,Space(Tamsx3("AL1_CONFIG")[1]) ,"@!" ,'Vazio() .Or. ExistCpo("AL1",MV_PAR01,1)'          ,"AL1" ,"" ,TamSX3("AL1_CONFIG")[1] ,.T.},; // "Cubo"
							{1 ,STR0057 ,Space(Tamsx3("AL3_CODIGO")[1]) ,"@!" ,'Vazio() .Or. ExistCpo("AL3",MV_PAR01+MV_PAR02,3)' ,"AL3" ,"" ,TamSX3("AL3_CODIGO")[1] ,.T.},; //"Config. Cubo"
							{1 ,STR0058 ,CToD("")                       ,"@D" ,""                                                 ,""    ,"" ,8                       ,.F.},; // "Dt. Saldo de "
							{1 ,STR0059 ,CToD("")                       ,"@D" ,""                                                 ,""    ,"" ,8                       ,.F.},; // "Dt. Saldo ate "
							{2,STR0060,nTpPeriod,{"1="+STR0061,"2="+STR0062,"3="+STR0063,"4="+STR0064,"5="+STR0065,"6="+STR0066,"7="+STR0067},80,"",.F.}},; //"Tipo Periodo"###"1=Semanal"###"2=Quinzenal"###"3=Mensal"###"4=Bimestral"###"5=Semestral"###"6=Anual"##'7=Diario'},; //
							STR0068,; // "Consulta Saldos Orcamentarios"
							aRecPar,;
							,;
							,;
							,;
							,;
							,;
							,;
							"",;
							,;
							.T.)  
														
	If lParamBox						
		lParamBox := PCOCheckCubo(aRecpar[1])
	Endif	
Endif

If lParamBox			
	If cCall <> "SALDO"
		If nCtrlCallOrc <= GetMv("MV_LPLAPCO",,5) 
			aParamsSeek := {xfilial(aCfgTree[1]),aRecPar[1],aRecPar[2]}
			
			If aScan(aOrcInTree,;
						Padr(aParamsSeek[1],TamSx3("AKE_FILIAL")[1])+;
						Padr(aParamsSeek[2],TamSx3("AKE_ORCAME")[1])+;
						Padr(aParamsSeek[3],TamSx3("AKE_REVISA")[1])) == 0
								
				//Cria arvore com as contas orcamentarias da nova planilha
				PCOxTree(aCfgTree,aParamsSeek,,aAllTrees)		
				
				//Atualiza aArvore Corrente com as novas cores para os nos
				MergeTree(aAllTrees,aCfgTree,@nCtrlCallOrc,aAreaAKR)					
	
				//Adiciona no Array, para nao precisar refazer o objeto existente
				aAdd(aOrcInTree,;	
						Padr(aParamsSeek[1],TamSx3("AKE_FILIAL")[1])+;
						Padr(aParamsSeek[2],TamSx3("AKE_ORCAME")[1])+;
						Padr(aParamsSeek[3],TamSx3("AKE_REVISA")[1]))
						
				lExistsPlan := .f. 		
			Endif
		Else     
			lExistsPlan := .f. 		
			lNotLoad := .t.	
     	Endif
    Else
    	If aScan(aOrcInTree,"SALDO") == 0
    		aAdd(aOrcInTree,"SALDO")
    		lExistsPlan := .f. 
    	Else
    		lRefazSld 	:= .t.	
    		lExistsPlan := .t. 
    	Endif
    Endif	
    
    If ( !lExistsPlan ) .or. cCall == "SALDO"
	    If !lNotLoad

			If cCall == "SALDO"
			    cDesFolder := cDesFolder	:=  "PLN SALDO: " + AllTrim(AL3->(POSICIONE("AL3",3,xFilial("AL3")+aRecPar[1]+aRecPar[2],"AL3_DESCRI"))) +" "+ Alltrim(aRecPar[1])  // STR0072 "Saldo Realizado - Cubo "
			EndIf
	    
		    If !lRefazSld 
			    //Adicona uma nova aba  
				AddPlanOrc(oGd,aParamsSeek,aAllTrees,cCall,aRecPar,aOrcInTree,@cDesFolder)
				nInd := len(oGd:oGetDD)
			Else
				nInd := aScan(aOrcInTree,"SALDO")
			Endif
				
			LoadNewPlan(aGdOtherPlan,aOrcInTree[nInd],aAllTrees[1],nInd,cCall,aRecPar,oGd,aPlanOrc)
			
			AddPlanGraph(aSeries,aGdOtherPlan,aOrcInTree[nInd],cCall)
			A201UpdPlan(aAllTrees[1],{aPlanOrc,aGdOtherPlan},oGd,lRefazSld,cDesFolder)

		Else
			Aviso(	STR0017,;//"Mแximo Excedido"
					STR0018 +; //"A Quantidade mแxima de estruturas de planilhas or็amentแrias a serem comparadas "
					STR0019 + CHR(13) +;  //"excedeu seu limite. Limite definido no parโmetro MV_LPLAPCO."
					STR0020 + alltrim(Str(GetMV("MV_LPLAPCO",,5)) ),{STR0021},2 ) //"Valor parametrizado: "###"Ok"	
		Endif
	Else
		Aviso(STR0044, STR0069,{STR0021}) // "Aten็ใo" //"Esta planilha or็amentแria jแ foi incluํda." // Ok
	Endif
Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se o cubo selecionado de acordo com estruturas    บฑฑ
ฑฑบ          ณ pr้-definidas:                                             บฑฑ
ฑฑบ          ณ #1: Conta Or็amentแria + Centro de Custo + Tipo de Saldo   บฑฑ
ฑฑบ          ณ #2: Conta Or็amentแria + Centro de Custo + Classe de Valor บฑฑ
ฑฑบ          ณ + Tipo de Saldo											  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function	PCOCheckCubo(cCube)

Local lRet	:= .t.
Local cQry	:= ""

cQry := "SELECT " + chr(13) + chr(10)
cQry += "	1 AS RETORNO " + chr(13) + chr(10)
cQry += "FROM  " + chr(13) + chr(10)
cQry += "	" + RetSQLName("AKW") + " AKW " + chr(13) + chr(10)
cQry += "WHERE " + chr(13) + chr(10)
cQry += "	AKW_FILIAL = '" + xfilial("AKW") + "' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	AKW_COD = '" + cCube + "' " + chr(13) + chr(10)
cQry += "	AND " + chr(13) + chr(10)
cQry += "	(	AKW_CONCCH = 'AKD->AKD_CO+AKD->AKD_CC+AKD->AKD_TPSALD' " + chr(13) + chr(10)  
cQry += "		OR  " + chr(13) + chr(10)  
cQry += "		AKW_CONCCH = 'AKD->AKD_CO+AKD->AKD_CC+AKD->AKD_CLVLR+AKD->AKD_TPSALD') " + chr(13) + chr(10)  
cQry += "	AND " + chr(13) + chr(10)
cQry += "	D_E_L_E_T_ = ' ' " + chr(13) + chr(10)

If SELECT("TRBAKW") > 0
	TRBAKW->(DBCLOSEAREA())
Endif                                                       

cQry := ChangeQuery(cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TRBAKW",.T.,.T.)

lRet := (TRBAKW->RETORNO == 1)

If !lRet
	Aviso(STR0070, STR0071, {STR0021},3 ) // "Cubo invแildo" // "Aten็ใo, o cubo selecionado nใo possui a estrutura correta. Espera-se a seguinte estrutura: CO+Centro de Custo+TP.SALDO ou CO+Centro de Custo+CLASSE+TP.SALDO" //"OK"
Endif

TRBAKW->(DBCLOSEAREA())
Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Adiciona nova aba da planilha com os dados                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AddPlanOrc(oGd,aParamsSeek,aAllTrees,cCall,aRecPar,aOrcInTree,cDesFolder)

Local aAreaAk1		:= AK1->(GetArea())
Local aRetPCOPlan 	:= {}
Local aSubHeadGd	:= {}
Local aAK2Fields	:= {}
Local aLinhas		:= {}
Local aDados		:= {}

Default cCall	:= ""                
Default aRecPar	:= {}
	
If cCall <> "SALDO"
	AK1->(DbSetOrder(1)) 
	AK1->(DbSeek(Padr(aParamsSeek[1],TamSx3("AKE_FILIAL")[1])+	Padr(aParamsSeek[2],TamSx3("AKE_ORCAME")[1])))
	aRetPCOPlan := PcoRetPer(AK1->AK1_INIPER,AK1->AK1_FIMPER,AK1->AK1_TPPERI)
	cDesFolder := AllTrim(AK1->AK1_DESCRI)
Else
	aRetPCOPlan := PcoRetPer(aRecPar[3],aRecPar[4], Iif(valtype(aRecPar[5]) == "N",Alltrim(STR(aRecPar[5])),aRecPar[5]))	
Endif	

aAK2Fields	:= HeaderPlan()

aSubHeadGD 	:= JoinArrayPCO(aAK2Fields,aRetPCOPlan,.T.)

aLinhas := array(len(aSubHeadGD))

aAdd(aDados,aClone(aSubHeadGD))
aAdd(aDados,aClone(aLinhas))

oGd:AddPlan(aDados, cDesFolder ,aRetPCOPlan) 

oGd:oGetdd[Len(oGd:oGetDD)]:oBrowse:cName	:= "PCOGETDADO"
oGd:otGet:cName 							:= "PCOTGET"

RestArea(aAreaAk1)

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrego o array com os dados da Nova Planilha              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function LoadNewPlan(aGdOtherPlan,cChaveBusca,oTreeCO,nFolder,cCall,aParams,oGd,aPlanOrc)

Local cCube			:= ""
Local cConfigCube	:= ""	
Local nPos			:= 0
Local nI			:= 0
Local nX			:= 0	
Local aData			:= {} 
Local aAux			:= {}	
Local aPeriod		:= {}
Local lAddGraph		:= .f.
Local cTimeIni		:= ""
Local cTimeFim		:= ""
Local cDeltaTime	:= ""
Local aRunTime		:= {}   

If cCall == "SALDO"
	CursorWait()
Endif

cTimeIni	:= Time()

For nI := 1 to len(oTreeCO:aCargo) 
	aData := PCOA201GetData(cChaveBusca,oTreeCO:aCargo[nI,1],cCall,oGd,aPlanOrc,cCube,aParams)
	aAdd(aAux,{	nFolder,;														//Nro do Folder
				Iif(cCall <> "SALDO",cChaveBusca,"SALDO"),;					//Chave do Orcamento e Revisao da Planilha de comparacao	
				oTreeCO:aCargo[nI,1],; 											//Centro Orcamentario
				aClone(aData[1]),;												//Array com os dados do aCols
				aClone(aData[2])})												//Array com os dados da Formula
Next nI

cTimeFim	:= Time()

cDeltaTime := elapTime(cTimeIni,cTimeFim)

aAdd(aRunTime, {STR0073,cTimeIni,cTimefim,cDeltaTime}) //"Processo total - diversas chamadas a PCORunCube"

/*
 * Parโmetro que habilita a medi็ใo do tempo do processamento do cubo or็amentแrio
 */
If SuperGetMV("MV_PCOMED",,"2") == "1"
	PCOShowTime(aRunTime)
EndIf

If len(aGdOtherPlan) > 0 .and. cCall == "SALDO"
	For nI := 1 to len(aGdOtherPlan)                                       
		If aScan(aGdOtherPlan[nI],{|x| alltrim(x[2]) == "SALDO"}) > 0
			aGdOtherPlan[nI] := aClone(aAux)
			lAddGraph := .t.
			Exit
		Endif
	Next nI
			
Else 
	aAdd(aGdOtherPlan,aClone(aAux))
	lAddGraph := .t.
Endif	

If cCall == "SALDO"
	CursorArrow()
Endif

If !lAddGraph
	aAdd(aGdOtherPlan,aClone(aAux))
Endif

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mensura o tempo de procesamento do cubo em etapas:         บฑฑ
ฑฑบ          ณ//"Origem" //"Tempo Inicial" //"Tempo final" //"Delta Tempo"บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOShowTime(aList)

Local oListBox
Local oDlgCons

DEFINE MSDIALOG oDlgCons TITLE STR0074 FROM 000,000 TO 350,500 PIXEL OF oMainWnd // "Custo em tempo dos processos"

	@ 000,000 ListBox oListBox Fields ;
		HEADER STR0075,STR0076,STR0077,STR0078;  // "Origem" // "Tempo Inicial" // "Tempo final" // "Delta Tempo"
		Size 250,150 Of oDlgCons Pixel
    
	oListBox:SetArray(aList)
	oListBox:bLine := {|| {;
		aList[oListBox:nAT,01],;
		aList[oListBox:nAT,02],;
		aList[oListBox:nAT,03],;
		aList[oListBox:nAT,04]}}
							
	DEFINE SBUTTON FROM 160,220 TYPE 2 ENABLE OF oDlgCons ACTION oDlgCons:End() //Botao Cancelar
		
	                                            
ACTIVATE MSDIALOG oDlgCons CENTERED

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Adiciona nova barra no grแfico de novas abas acrescentadas บฑฑ
ฑฑบ          ณ a planilha quando conterem valor.                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function AddPlanGraph(aSeries,aGdOtherPlan,cChaveOrc,cCall)

Local nI 		:= 0 
Local nLastF	:= Len(aGdOtherPlan)
Local aAuxSer	:= {}
Local lRefresh	:= .f.

For nI := 1 to len(aGdOtherPlan[nLastF])   
		aAdd(aAuxSer,{	aGdOtherPlan[nLastF,nI,3],;
						STR0047 +strzero(aGdOtherPlan[nLastF,nI,1],2) + space(1) + aGdOtherPlan[	nLastF,nI,3],; // "Planilha - aba "
						SumRange2(aGdOtherPlan[nLastF,nI,3],{{aGdOtherPlan[nLastF,nI,3],aGdOtherPlan[nLastF,nI,4],aGdOtherPlan[nLastF,nI,5]} }),;
						Iif(cCall <> "SALDO",cChaveOrc,"SALDO") })	

Next nI

If cCall == "SALDO"
	For nI := 1 to len(aSeries) 
		If aScan(aSeries[nI], {|x| alltrim(x[4]) == "SALDO"}) > 0
			aSeries[nI] := aClone(aAuxSer)
			lRefresh := .t.
			Exit
		Endif
	Next nI
Endif                      

If !lRefresh
	aAdd(aSeries,aClone(aAuxSer))
Endif	

Return()

/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ MergeTree     บAutor  ณFernando R. Muscalu บ Data ณ 10/09/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ IAltera imagens da Tree conforme contas		        	       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaPco                                                     	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros : # aCfgTree  = Array com as configura็๕es da Tree 	           บฑฑ
ฑฑบ              # aAllTrees    = Array contendo a Tree                        บฑฑ
ฑฑบ              # nCtrlCallOrc = Variavel de controle de contas               บฑฑ
ฑฑบ              # aOrcInTree   = Array contendo a Filial+Or็amento+Versใo     บฑฑ
ฑฑบ              # oGd          = Objeto PCOPlan                               บฑฑ
ฑฑบ              # aAreaAKR     = Array de fechamento da tabela                บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ 												                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MergeTree(aAlltrees,aCfgTree,nCtrlCallOrc,aAreaAKR,aClone)

Local nI		:= 0
Local nX		:= 0
Local nPos		:= 0

Local aSeek		:= {}

Local oAuxTree	:= Nil                        

For nI := 1 to len(aAllTrees[1]:aCargo)

	aAllTrees[1]:TreeSeek(aAllTrees[1]:aCargo[nI,1])
	nPos := aScan(aAlltrees[1]:aNodes,{|x| alltrim(x[2]) == alltrim(aAllTrees[1]:CurrentNodeId) } )
	
	If nPos > 1
		If aAllTrees[2]:TreeSeek(aAllTrees[1]:aCargo[nI,1])
			If nCtrlCallOrc == 1
				aAllTrees[1]:aNodes[nPos,5] := PCOICTREEINTER[1] 
				aAllTrees[1]:aNodes[nPos,6] := PCOICTREEINTER[2]
			Else
				If aAllTrees[1]:aNodes[nPos,5] == PCOICTREESTART[1]
					aAllTrees[1]:aNodes[nPos,5] := PCOICTREEEND[1]
					aAllTrees[1]:aNodes[nPos,6] := PCOICTREEEND[2]						
				Endif	
			Endif	
		Else
			If nCtrlCallOrc > 1
				If aAllTrees[1]:aNodes[nPos,5] <> PCOICTREESTART[1]
					aAllTrees[1]:aNodes[nPos,5] := PCOICTREEEND[1]
					aAllTrees[1]:aNodes[nPos,6] := PCOICTREEEND[2]		
				Endif
			Endif		
		Endif
	endif
Next nI

oAuxTree := aAllTrees[1]
aAllTrees[1] := nil

RestArea(aAreaAKR)

aSeek := {	AKR->AKR_FILIAL,;
			AKR->AKR_ORCAME,;
			AKR->AKR_REVISA	}
			
PCOxTree(aCfgTree,aSeek,{0,0,oAuxTree:oParent},aAllTrees,oAuxTree)
aAllTrees[1]:cName := "PCOTREE"

If Empty(aAllTrees[1]:CurrentNodeId)
	aAllTrees[1]:CurrentNodeId := aAllTrees[1]:aNodes[1,2]
Endif

nCtrlCallOrc++

Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche array com valores padr๕es                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function aSetDefaultValues(aArray)

Local nI := 0

For nI := 1 to len(aArray)
	If aArray[nI] == nil
		aArray[nI] := ""
	Endif
Next nI

Return()
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Une os Header da AK2 com o Header dos perํodos das abas    บฑฑ
ฑฑบ          ณ das planilhas.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function JoinArrayPCO(aFixHead,aPeriod,lFieldByName)

Local aRet		:= array(len(aFixHead)+len(aPeriod))
Local nI		:= 0
Local aAuxHead	:= {}
Local cFields	:= ""

Default lFieldByName := .f.

If lFieldByName
	aEval(aFixHead,{|x| SX3->(DBSetOrder(2)), SX3->(DBSEEK(x)), cFields += ALLTRIM(SX3->X3_TITULO) + "|"})
	cFields := Substr(cFields,1,Rat("|",cFields)-1)
	aAuxHead := StrTokArr(cFields,"|")
Else
	aAuxHead := aClone(aFixHead)
Endif	

For nI := 1 to Len(aAuxHead)

	aRet[nI] := aAuxHead[nI]
	
Next nI

For nI := 1 to len(aPeriod) 
    aRet[Len(aAuxHead)+nI] := aPeriod[nI]
Next nI

Return(aRet)


/* 
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao    ณ FLEGENSIM     บAutor  ณRodrigo M. Pontes   บ Data ณ 17/09/2010  บฑฑ
ฑฑฬออออออออออุอออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ  Legenda da simula็ใo				     	         	       บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSigaPco                                                     	   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ Parametros : 															   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ 												                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/			
Static Function FLEGENSIM()
	BrwLegenda(cCadastro,STR0024, {  {"BR_VERMELHO"	,STR0033	},;  //"Legenda"###"S๓ existe na versใo de simula็ใo"
									 {"BR_AZUL"   	,STR0034	},;  //"Estrutura existe em todas as planilhas"
									 {"BR_AMARELO"	,STR0035	}})  //"Estrutura existe em algumas planilhas"
Return(.T.)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Filtra o cubo:conta or็amenta+cc        			          บฑฑ
ฑฑบ		     ณ #1: Conta Or็amentแria + Centro de Custo                   บฑฑ
ฑฑบ          ณ #2: Conta Or็amentแria + Centro de Custo+ Classe de Valor  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function SetFilterCube(cCube,aCube,cCo,aPlanPrincipal,aFieldAK2)

Local aEntCube		:= RetKeyInArray(cCube)
Local aCubeFiltered	:= {}
Local aPositions	:= 0
Local nI			:= 0
Local nX			:= 0
Local nPCube		:= 0
Local nPConta		:= 0
Local nPHead		:= 0
Local cSeekKey		:= ""

If ( nPConta := aScan(aPlanPrincipal,{|x| alltrim(x[1]) == Alltrim(cCo)}) ) > 0

	If Len(aPlanPrincipal[nPConta,2]) > 1
        
        nPosCO 		:= aScan(aEntCube,{|x| Alltrim(x[4]) == "CO" })    	
    	aPositions 	:= RetObjCube(aFieldAK2,aEntCube)
                
		For nI := 2 to len(aPlanPrincipal[nPConta,2])	
			
			cSeekKey 	:= Padr(cCo,aEntCube[nPosCO,10])
        	
        	For nX := 1 to len(aPositions)
        	    nPHead 		:= aScan(aFieldAk2,Alltrim(aPositions[nX,1]))
        		cSeekKey 	+= Padr(aPlanPrincipal[nPConta,2,nI,nPHead],aPositions[nX,2])
        	Next nX
        	
        	If ( nPCube := aScan(aCube,{|x| Alltrim(x[9]) == Alltrim(cSeekKey)}) ) > 0
        		aAdd(aCubeFiltered, aCube[nPCube]) 
        	Endif                                  
        	
        Next nI
        
	Endif

Endif

Return(aCubeFiltered)                                                                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o tamanho dos campos dentro do cubo de acordo      บฑฑ
ฑฑบ          ณ com os campos da AK2.                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function RetObjCube(aFieldAK2,aEntCube)

Local aRet	:= {}

Local nI	:= 0
Local nPos	:= 0

For nI := 1 to len(aFieldAK2)
	If ( nPos := aScan(aEntCube,{|x| Alltrim(substr(x[3],10)) == Alltrim(substr(aFieldAk2[nI],5))}) ) > 0
		aAdd(aRet,{aFieldAK2[nI],aEntCube[nPos,10]})
	Endif
Next nI

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta Estrutura de Saldos (aCols)                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function BuildStrucSld(cCube,aPeriodo,aProcessa,aPlanOrc)		

Local aRet			:= {}
Local aFldCube		:= RetKeyInArray(cCube)
Local aFieldsAK2    := HeaderPlan()
Local aItens		:= {}
Local aPosition		:= {}
Local aFields		:= {}
Local nI			:= 0
Local nX			:= 0
Local nPos			:= 0
Local nPosCC 		:= 0
Local nPosCO		:= 0
Local nCC			:= 0
Local nCO			:= 0
Local nPosIni		:= 0

/*aGdPlan1 - array que guarda os dados da Getdados
		aGdPlan1[n,1] - centro orcamentario
		aGdPlan1[n,2] - array com os dados do acols
		aGdPlan1[n,3] - array com os dados das formulas 	
*/
For nI := 1 to len(aProcessa)
		
	aFields := Separa(aProcessa[nI,3],"+") 
	
	nPosIni := 1
	
	For nX := 1 to len(aFields)
		nPos := aScan(aFldCube,{|x| alltrim(x[4]) == alltrim(aFields[nX])})
		If nPos > 0
			aAdd(aPosition,{aFields[nX],nPosIni,aFldCube[nPos,10]})
			nPosIni += aFldCube[nPos,10]
		Endif	
	Next nX
	
	nCO		:= aScan(aPosition, {|x| alltrim(x[1]) == "CO"})

	If nCO > 0 
		nPosCO 	:= aScan(aPlanOrc,{|x| alltrim(x[1]) == Alltrim(Substr(aProcessa[nI,9],aPosition[nCO,2],aPosition[nCO,3]))})
	Endif
	
	If nPosCO > 0
		
		aItens := array(len(JoinArrayPCO(aFieldsAK2,aPeriodo,.t.))+1)
		nCC		:= aScan(aPosition,{|x| alltrim(x[1]) == "Centro de Custo"})

		If nCC > 0
			nPosCC := aScan(aPlanOrc[nPosCO,2],{|x| alltrim(x[1]) == Alltrim(Substr(aProcessa[nI,9],aPosition[nCC,2],aPosition[nCC,3]))})
		Endif 
		
		If nPosCC > 0
			for nX := 1 to len(aFieldsAk2)
				aItens[nX] := aPlanOrc[nPosCO,2,nPosCC,nX]
			Next nX	
			
			For nX := 1 to len(aPeriodo)
				aItens[nX+Len(aFieldsAk2)] := PCOCasting(aProcessa[nI,2,nX],"C")
			Next nX               
			
			aItens[Len(aItens)] := .f.	
			
			aAdd(aRet,aClone(aItens))	
			aItens := {}
		Endif	
	Endif
	
Next nI

Return(aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Calcula os saldos do cubo de acordo com as configura็๕es   บฑฑ
ฑฑบ          ณ do mesmo e a chave: co+cc ou co+cc+clvl                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function PCOA201PERSLD(cConfig,cChave)

Local aRetorno	:= {}
Local aRetFim	:= {}
Local aPeriodo	:= {}
Local nCrdIni	:= 0
Local nDebIni	:= 0
Local nCrdFim	:= 0
Local nDebFim	:= 0
Local nY		:= 0
Local nSldIni	:= 0
Local nSldFim	:= 0

Local dIni, dFim	

aPeriodo := PcoRetPer(dDtIni,dDtFim,iif(valtype(cTpPeriod) == "N", cvaltochar(cTpPeriod),cTpPeriod))

For nY := 1 to Len(aPeriodo)
   
	nSldIni := 0

   	// PROCESSA CUBO SALDO INICIAL 
	dIni := RetDateSHead(aPeriodo[nY],1)

	aRetIni := PcoRetSld(cConfig,cChave,dIni-1)
	nCrdIni := aRetIni[1, 1] //valor na moeda 1
	nDebIni := aRetIni[2, 1]

	nSldIni := nCrdIni-nDebIni
   
   	// PROCESSA CUBO SALDO FINAL
	dFim := RetDateSHead(aPeriodo[nY],2)

	aRetFim := PcoRetSld(cConfig,cChave,dFim)
	nCrdFim := aRetFim[1, 1]
	nDebFim := aRetFim[2, 1]

	nSldFim := nCrdFim-nDebFim

	//retorna saldo final - saldo inicial
	aAdd(aRetorno,nSldFim-nSldIni)
	
Next nY

Return(aRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna um array com os dados do cubo                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RetKeyInArray(cCube)

Local aRet	:= {}
/*
MAPA do array aRet
aRet
	aRet[n,01] - Codigo do cubo
	aRet[n,02] - Nivel
	aRet[n,03] - Cod. Campo Entidade
 	aRet[n,04] - Descricao Entidade
 	aRet[n,05] - Cod. Entidades Concatenadas
 	aRet[n,06] - Desc. Entidades Concatenadas
 	aRet[n,07] - Alias (tabela) relacionado com a entidade
 	aRet[n,08] - Campo de relacao da tabela com a entidade
 	aRet[n,09] - Campo de descricao da tabela
 	aRet[n,10] - Tamanho do Campo da entidade (o campo do nivel)
*/

AKW->(DbSetOrder(1)) //AKW_FILIAL+AKW_COD+AKW_NIVEL

If AKW->(DbSeek(xFilial("AKW") + Padr(cCube,TamSX3("AKW_COD")[1])))

	While AKW->(!EOF()) .AND. alltrim(AKW->AKW_COD) == Alltrim(cCube)
	    aAdd(aRet,{	AKW->AKW_COD,;
	    			AKW->AKW_NIVEL,;
	    			AKW->AKW_CHAVER,;
	    			AKW->AKW_DESCRI,;
	    			AKW->AKW_CONCCH,;
	    			AKW->AKW_CONCDE,;
	    			AKW->AKW_ALIAS,;
	    			AKW->AKW_RELAC,;
	    			AKW->AKW_DESCRE,;
	    			AKW->AKW_TAMANH})
		AKW->(DbSkip())
	EndDo
Endif

Return(aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณFernando R. Muscalu บ Data ณ  22/12/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Compara array e verifica se arrays(acols) sใo id๊nticos    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function A201DiffAcols(a1,a2,nLimChar)

Local lRet		:= .f.
Local nI		:= 0
Local nX		:= 0

If len(a1) == len(a2)
    
	For nX := 1 to len(a1)
		If len(a1[nX]) == len(a2[nX])
			For nI := 1 to len(a1[nX])
				If PADR(Alltrim(a1[nX,nI]),nLimChar) <> PADR(AllTrim(a2[nX,nI]),nLimChar)
					lRet := .t.
					Exit
				Endif
			Next nI	
		Else     
			lRet := .t.
			Exit
		Endif
		
		If lRet
			Exit
		Endif	
	Next nX
		
Else
	lRet := .t.	
Endif          

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณTotvs               บ Data ณ  27/07/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Zera os dados do Grafico                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ZeraGraph(dDataIni,dDataFim,aRetPCOPlan)

If oChart <> nil

	oChart:aSeries := {}
	oChart:Refresh()

	dDataIni := RetDateSHead(aRetPCOPlan[1],1)
	dDataFim := RetDateSHead(aRetPCOPlan[len(aRetPCOPlan)],2)
	oGetDtIni:Refresh()
	oGetDtFim:Refresh()

Endif

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201   บAutor  ณMicrosiga           บ Data ณ  07/27/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se a conta eh analitica ou sintetica e retorna .T.บฑฑ
ฑฑบ          ณ ou .F. para chamar ou nao o grafico                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ChkCtaSint(oTree)
Local lRet := .F.
Local nPos := 0
Local cConta := ""
Local cTipo := ""

nPos := aScan(oTree:aNodes,{|x| alltrim(x[2]) == Alltrim(oTree:CurrentNodeId) } )

If nPos > 0
	cConta := oTree:aCargo[nPos,1]
EndIf

cTipo := GetAdvFVal("AK5","AK5_TIPO",AK5->(xFilial("AK5")+cConta),1)

If cTipo == "2"
	lRet := .T.
Else
	Help("   ",1,"NOPCOA201GRAPH",,STR0082,1,0)
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPCOA201GraบAutor  ณMicrosiga           บ Data ณ  15/06/12   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gera o grแfico das contas                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAPCO                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function PCOA201Gra()

//cria o grafico
oChart := FWChartFactory():New()
oChart := oChart:getInstance(0) //grafico de barra

//inicializa o grafico no painel
oChart:init( oScrLayer:getWinPanel( 'GraficCol', 'GraficWin', 'GraficLin' ) )
oChart:nTAlign := CONTROL_ALIGN_ALLCLIENT

//cria a legenda do grafico
oChart:SetLegend(CONTROL_ALIGN_RIGHT)

Return Nil
