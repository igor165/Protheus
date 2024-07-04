#include 'protheus.ch' 
#Include "rwmake.ch" 
#include "apwizard.ch"
#include 'dbtree.ch'  
#include 'ctba011.ch'

#Define CLRLAYER		CLR_WHITE
#Define BMPSAIR			"FINAL.PNG"
#Define BMPMOEDCAL		"SIMULACAO.PNG"
#Define BMPCALSALDO		"S4SB014N.PNG"
#Define IMG_VISUAL		"VERNOTA"                                               
#Define BMPCONFIRMAR	"OK.PNG"
#Define BMPCANCELAR		"CANCEL.PNG"
#Define IMG_INCLUIR		"BMPINCLUIR"
#Define IMG_UPDATE		"NOTE"
#Define IMG_DELETE		"EXCLUIR"
#Define IMG_COPY		"S4WB005N"
#Define IMG_CUT			"s4wb006n" 
#Define IMG_INCLUIR		"BMPINCLUIR"
#Define IMG_MARCA		"NOCHECKED"
#Define IMG_MANUTEN		"INSTRUME"
#Define BMPPESQUISA		"PESQUISA.PNG"
#Define BMPCADEADO		"CADEADO.PNG"
#Define IMG_NO			"LBNO"
#Define IMG_OK			"LBOK"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³TOTVS               º Data ³  21/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela unificada de cadastro: Calendario,Moeda e Tipo Saldo  º±±
±±º          ³ Amarracoes:                                                º±±
±±º          ³ Moeda X Calendario                                         º±±
±±º          ³ Calendario X Tipo de Saldo                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CTBA011()

Local cTitulo			:= STR0001 // "Calendario X Moeda X Tipo de Saldo" 
Local aScreen			:= GetScreenRes()
Local nWStage			:= aScreen[1]-45
Local nHStage			:= aScreen[2]-225
Local aButtons			:= {}
Local oBarWinA			:= Nil
Local oBarWinB			:= Nil
Local nOpcBt			:= 0          
Local cAlias			:= ""
Local oSize				:= Nil
Local bSeek				:= {|_cAlias,_nOrdem,_cChave| DbSelectArea(_cAlias),(_cAlias)->(DbSetOrder(_nOrdem)),DbSeek(xFilial(_cAlias) + _cChave ) }
Local bSeekTp			:= {|_cChaveTp| Ascan(aColsTp, { |x| x[5] == _cChaveTp }) }
Local aDim				:= {}
Local aCoords			:= {}
Local nOpcao			:= 0

Private INCLUI 			:= .T. 
Private ALTERA			:= .F.
Private lBlqCadCalend	:= .T.
Private lBlqCadMoeda	:= .T. 
Private lBlqCadTpSaldo	:= .T.
Private lBlqAmarr		:= .T. 
Private aRotina			:= FWMVCMenu("CTBA011") //Variavel necessaria pela MSGetDados
Private oTreeCad1		:= Nil	//Obj Tree Cadastro CALENDARIO 
Private oTreeCad2		:= Nil	//Obj Tree Cadastro MOEDA
Private oTreeCad3		:= Nil	//Obj Tree Cadastro TIPO DE SALDO 
Private oTreeCad4		:= Nil	//Obj Tree Amarração
Private nTamRegSx5		:= 10	// numero total de registros na tabela SX5, utilizado para busca, no cliente Anhanguera no dia 16/02/2011 tinha 1.452.530 (registros)
Private oWndCadCalend	:= nil
Private aColsTp			:= {}
Private oDlgManu
Private nIniMoe			:= 4
Private nTamMoe         := TamSx3("CWG_MOEDA")[1] 
Private nIniCal         := nIniMoe+nTamMoe
Private nTamCal         := TamSx3("CWG_CALEND")[1]
Private nIniExe         := nIniCal+nTamCal
Private nTamExe         := TamSx3("CWG_EXERCI")[1]
Private nIniPer         := nIniExe+nTamExe
Private nTamPer         := TamSx3("CWG_PERIOD")[1]
Private nIniTps         := nIniPer+nTamPer
Private nTamTps         := TamSx3("CWG_TPSALD")[1]
Private oMenuMoe
Private	oMenuCal
Private	oMenuPer
Private	oMenuTps

Private cCadastro			:= "" //Criado pois estava dando erro
Private lExibmsg			:= .F.//Criado pois estava dando erro
Private __oWindowDet		:= nil

If !LockByName("CTBA011"+xFilial("CTG"),.F.,.F.)
	Help(" ",1,"CTBA011US",,STR0085,1,0) //"Outro usuario está usando a rotina "
	Return
EndIf

//[1]
aAdd(aButtons, { BMPPESQUISA 	,BMPPESQUISA	,"" , {||PesqCad4(oTreeCad4:GetCargo())}	,STR0008 }) // "Calendario X Tipo Saldo" 	 
//[2]
aAdd(aButtons, { BMPSAIR  		,BMPSAIR		,""	, {|| oDlgManu:End()}					,STR0009 }) // "Sair"
//[3]
aAdd(aButtons, { "MPWIZARD"  	,"MPWIZARD"		,""	, {||CT11WzTela(oWndDetalhe)}			,STR0010 }) // "Assistente" 

/*
 * Criação de classe para definição da proporção da interface
 */
oSize := FWDefSize():New(.T., , nOr(WS_VISIBLE,WS_POPUP) )
oSize:AddObject("TOP", 100, 100, .T., .T.)
oSize:aMargins:= {0,0,0,0}
oSize:Process()

DEFINE DIALOG oDlgManu TITLE cTitulo FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)

@ 	oSize:GetDimension("TOP", "LININI"),;
	oSize:GetDimension("TOP", "COLINI") BITMAP oContent RESOURCE "x.png" SIZE;
	oSize:GetDimension("TOP", "XSIZE"),;
	oSize:GetDimension("TOP", "YSIZE") ADJUST NO BORDER OF oDlgManu PIXEL
  
// Cria instancia do fwlayer
oFWLayer		:= FWLayer():New()
// Inicializa componente passa a Dialog criada,
// o segundo parametro é para criação de um botao de fechar utilizado para Dlg sem cabeçalho
oFWLayer:init( oDlgManu, .T. )

// Criação de duas colunas na Layer
// Coluna da esquerda que ocupa 30% da Dialog
oFWLayer:addCollumn( "ColEsq", 30, .T. )
// Coluna da direita que ocupa 70% da Dialog
oFWLayer:addCollumn( "ColDir", 70, .T. )

// Cria Painel na Coluna da Direita
oColDir		:= oFWLayer:getColPanel( "ColDir" )
// Cria Painel na Coluna da Esquerda
oColEsq		:= oFWLayer:getColPanel( "ColEsq" )

// Cria uma Layer com Painel da Esquerda
oLayEsq		:= FWLayer():New()
oLayEsq:init( oColEsq, .T. )

// Cria uma layer com o Painel da Direita
oLayDir := FWLayer():New()
oLayDir:init( oColDir, .T. )

/*
 * How To de Utilização do Método AddLine da FWLayer
 * para acrescentar caixa (box) e/ou linhas na tela:
 * @param1: IdLine: Identificação da linha da layer
 * @param2: nWidth: Tamanho (Altura) da linha da layer, informado em percentual (%) 
 * oLayer:addLine(IdLine,nWidth)
 */ 
oLayEsq:addLine( 'LinEsq1', 29 ) // 1ª Linha do box esquerdo do cadastro do Calendário Contábil
oLayEsq:addLine( 'LinEsq2', 29 ) // 2ª Linha do box esquerdo do cadastro de Moedas

oLayEsq:addLine( 'LinEsq3', 29 ) // 3ª Linha do box esquerdo do cadastro de Tipo de Saldo Contábil
oLayEsq:addLine( 'LinEsq4', 13 ) // 4ª Linha do box esquerdo com os botões de sair e Wizard

oLayDir:addLine( 'LinDir1', 100 ) // 1ª Linha do box direito da tela de detalhes

oLayEsq:addCollumn( 'ColEsq1', 100,,'LinEsq1') 
oLayEsq:addCollumn( 'ColEsq2', 100,,'LinEsq2')
oLayEsq:addCollumn( 'ColEsq3', 100,,'LinEsq3') 
oLayEsq:addCollumn( 'ColEsq4', 100,,'LinEsq4')
                                             
oLayDir:addCollumn( 'ColDet', 100,,'LinDir1')   

oLayEsq:addWindow( 'ColEsq1', "WinEsq01",STR0002 , 100, .F., .T., {||  }, 'LinEsq1' ) // "Moeda"	  
oLayEsq:addWindow( 'ColEsq2', "WinEsq02",STR0003 , 100, .F., .T., {||  }, 'LinEsq2' ) // "Calendário"
oLayEsq:addWindow( 'ColEsq3', "WinEsq03",STR0004 , 100, .F., .T., {||  }, 'LinEsq3' ) // "Tipo Saldo"  
oLayEsq:addWindow( 'ColEsq4', "WinEsq04", ""	  , 100, .F., .T., {||  }, 'LinEsq4' ) 

oLayDir:addWindow( 'ColDet' , "WinDet",STR0012 , 100, .F., .T., {||  }, 'LinDir1' ) // "Detalhes"   

oLinEsq1		:= oLayEsq:getLinePanel( 'LinEsq1' )
oLinEsq2		:= oLayEsq:getLinePanel( 'LinEsq2' )
oLinEsq3		:= oLayEsq:getLinePanel( 'LinEsq3' )      
oLinEsq4		:= oLayEsq:getLinePanel( 'LinEsq4' )     

oLinDir1		:= oLayDir:getLinePanel( 'LinDir1' )          

/*
 * Layer da tela de detalhes para tela de inclus]ao/alteraç]a/exclusão de registros
 */                                                                       
oWndDetalhe	:= oLayDir:getWinPanel('ColDet','WinDet','LinDir1')                                                                        
        
oWndCadMoed 	:= oLayEsq:getWinPanel('ColEsq1',"WinEsq01",'LinEsq1') 
oWndCadCalend   := oLayEsq:getWinPanel('ColEsq2',"WinEsq02",'LinEsq2') 
oWndCadTpSaldo	:= oLayEsq:getWinPanel('ColEsq3',"WinEsq03",'LinEsq3') 
oWndEnchoice	:= oLayEsq:getWinPanel('ColEsq4',"WinEsq04",'LinEsq4')


DEFINE FONT oFont NAME "Mono AS" SIZE 5,12


DEFINE BUTTONBAR oBarCadCalend SIZE 15,15 3D BOTTOM OF oWndDetalhe
nOpcBt			:= 1
oButton2		:= TBtnBmp():NewBar( aButtons[nOpcBt,1],aButtons[nOpcBt,2],,,aButtons[nOpcBt,3], aButtons[nOpcBt,4],.T.,oBarCadCalend,,,aButtons[nOpcBt,5])
oButton2:cTitle	:= aButtons[nOpcBt,3]
oButton2:Align := CONTROL_ALIGN_LEFT
                                    
DEFINE BUTTONBAR oBarEnchoice SIZE 15,15 3D BOTTOM OF oWndEnchoice       
nOpcBt			:= 2
oBtnEnch		:= TBtnBmp():NewBar( aButtons[nOpcBt,1],aButtons[nOpcBt,2],,,aButtons[nOpcBt,3], aButtons[nOpcBt,4],.T.,oBarEnchoice,,,aButtons[nOpcBt,5])
oBtnEnch:cTitle	:= aButtons[nOpcBt,3]
oBtnEnch:Align	:= CONTROL_ALIGN_LEFT

nOpcBt			:= 3
oBtnEnch		:= TBtnBmp():NewBar( aButtons[nOpcBt,1],aButtons[nOpcBt,2],,,aButtons[nOpcBt,3], aButtons[nOpcBt,4],.T.,oBarEnchoice,,,aButtons[nOpcBt,5])
oBtnEnch:cTitle	:= aButtons[nOpcBt,3]
oBtnEnch:Align	:= CONTROL_ALIGN_RIGHT

MENU oMenuPop1 POPUP
		MenuItem STR0013 	Block {|| Eval(bSeek,"CTG",1,Left(oTreeCad1:GetCargo(),3)), Ctba011Cal(2,oWndDetalhe),oWndDetalhe:Show()} Resource IMG_VISUAL // "Visualizar" 
		MenuItem STR0014	Block {|| Eval(bSeek,"CTG",1,Left(oTreeCad1:GetCargo(),3)), Ctba011Cal(4,oWndDetalhe),oWndDetalhe:Show()} Resource IMG_UPDATE // "Alterar" 
		MenuItem STR0015	Block {|| Eval(bSeek,"CTG",1,Left(oTreeCad1:GetCargo(),3)), Ctba011Cal(5,oWndDetalhe),oWndDetalhe:Show()} Resource IMG_DELETE // "Excluir" 	
		MenuItem STR0086 Block {|| Eval(bSeek,"CTG",1,Left(oTreeCad1:GetCargo(),3)), Ctba011Blc()} Resource IMG_UPDATE // "Bloqueio de Processo"	
	
ENDMENU
  
MENU oMenuPop1a POPUP
		MenuItem STR0045    Block {|| Eval(bSeek,"CTG",1,Left(oTreeCad1:GetCargo(),3)), Ctba011Cal(3,oWndDetalhe),oWndDetalhe:Show()} Resource IMG_INCLUIR // "Incluir"
ENDMENU

Ct011LCalend() 

/*
 * Menu Pop-Up do Cadastro de Moedas ao clicar no botão direito do mouse
 */
 
aCoords := FWGetCoorsAbsolute(oWndDetalhe) 
aDim :=  {aCoords[2],aCoords[1],aCoords[2]+oWndDetalhe:nHeight,aCoords[1]+oWndDetalhe:nWidth} 

MENU oMenuPop2 POPUP
		MenuItem STR0013 	Block {||	INCLUI:= .F.,; // "Visualizar"
										ALTERA:= .T.,;	
										Eval(bSeek,"CTO",1,PesqTabela('CTO',Val(Right(oTreeCad2:GetCargo(),nTamRegSx5)),,,'CTO_MOEDA')),;
										AxVisual("CTO",CTO->(Recno()),4,,,,,,,,.T.,oWndDetalhe,,.T.,aDim,,),;
										oWndDetalhe:Show()} Resource IMG_VISUAL	
		MenuItem STR0014 	Block {|| 	INCLUI:= .F.,; // "Alterar"
										ALTERA:= .T.,;
										Eval(bSeek,"CTO",1,PesqTabela('CTO',Val(Right(oTreeCad2:GetCargo(),nTamRegSx5)),,,'CTO_MOEDA')),;
										CTB140Alt("CTO",CTO->(Recno()),3,.T.,oWndDetalhe),;
										oWndDetalhe:Show()} Resource IMG_UPDATE	
		MenuItem STR0015	Block {|| 	INCLUI:= .F.,; // "Excluir"
										ALTERA:= .F.,;
										Eval(bSeek,"CTO",1,PesqTabela('CTO',Val(Right(oTreeCad2:GetCargo(),nTamRegSx5)),,,'CTO_MOEDA')),;
										Ctb140Exc("CTO",CTO->(Recno()),5,.T.,oWndDetalhe),;
										oWndDetalhe:Show()} Resource IMG_DELETE
																	
ENDMENU

MENU oMenuPop2a POPUP
		MenuItem STR0045    Block {|| 	INCLUI :=.T.,; // Incluir 
										ALTERA :=.F.,;
								   		Ctb140Inc("CTO",0,2,.T.,,,oWndDetalhe),;
									  	oWndDetalhe:Show()} Resource IMG_INCLUIR 
ENDMENU

Ct011LCadMoe()


MENU oMenuPop3 POPUP
		MenuItem STR0013 	Block {||  xCtb130Man(4, @aColsTp, Ascan(aColsTp, { |x| x[5] == oTreeCad3:GetCargo()}), STR0013),oWndDetalhe:Show()} Resource IMG_VISUAL // "Visualizar" 
		MenuItem STR0014	Block {||  xCtb130Man(2, @aColsTp, Ascan(aColsTp, { |x| x[5] == oTreeCad3:GetCargo()}), STR0014),oWndDetalhe:Show()} Resource IMG_UPDATE // "Alterar" 
		MenuItem STR0015	Block {||  xCtb130Man(3, @aColsTp, Ascan(aColsTp, { |x| x[5] == oTreeCad3:GetCargo()}), STR0015),oWndDetalhe:Show()} Resource IMG_DELETE // "Excluir" 	
ENDMENU
  

MENU oMenuPop3a POPUP
		MenuItem STR0045    Block {||  xCtb130Man(1, @aColsTp, 0, STR0045),oWndDetalhe:Show()} Resource IMG_INCLUIR // "Incluir"
ENDMENU

Ct011LTpSld() 

MENU oMenuMoe POPUP
		MenuItem STR0013 	Block {||	INCLUI :=.F.,; // "Visualizar" 
										ALTERA :=.F.,;
										Eval(bSeek,"CTO",1,PesqTabela('CTO',Val(Right(oTreeCad4:GetCargo(),nTamRegSx5)),,,'CTO_MOEDA')),;
										AxVisual("CTO",CTO->(Recno()),2,,,,,,,,.T.,oWndDetalhe,,.T.,aDim,,),;
										oWndDetalhe:Show()} Resource IMG_VISUAL	
		MenuItem STR0055	Block {|| CapCalend(oTreeCad4:GetCargo()), oWndDetalhe:Show()} Resource IMG_MANUTEN // "Amarrar Calend." 	
ENDMENU

MENU oMenuCal POPUP
		MenuItem STR0013 	Block {|| Eval(bSeek,"CTG",1,SubStr(oTreeCad4:GetCargo(),nIniCal,nTamCal)), Ctba011Cal(2,oWndDetalhe),oWndDetalhe:Show()} Resource IMG_VISUAL // "Visualizar" 
		MenuItem STR0056	Block {|| ExcCalend(oTreeCad4:GetCargo()), oWndDetalhe:Show()} Resource IMG_DELETE // "Excluir amarração c/ Moeda"
		MenuItem STR0057	Block {|| CapTpSaldo(oTreeCad4:GetCargo(),.T.),oWndDetalhe:Show()} Resource IMG_MANUTEN // "Amarrar Tp.Saldo" 	 	
ENDMENU

MENU oMenuPer POPUP
		MenuItem STR0013 	Block {|| Eval(bSeek,"CTG",1,SubStr(oTreeCad4:GetCargo(),nIniCal,nTamCal)), Ctba011Cal(4,oWndDetalhe),oWndDetalhe:Show()} Resource IMG_VISUAL // "Visualizar" 
		MenuItem STR0057	Block {|| CapTpSaldo(oTreeCad4:GetCargo(),.F.), oWndDetalhe:Show()} Resource IMG_MANUTEN // "Amarrar Tp.Saldo" 	
ENDMENU

MENU oMenuTps POPUP
		MenuItem STR0013 	Block {||  xCtb130Man(4, @aColsTp, Ascan(aColsTp, { |x| x[5] == "TPS"+SubStr(oTreeCad4:GetCargo(),nIniTps+1)}), STR0013),oWndDetalhe:Show()} Resource IMG_VISUAL // "Visualizar" 
		MenuItem STR0058	Block {|| ExcTpSaldo(oTreeCad4:GetCargo()), oWndDetalhe:Show()} Resource IMG_DELETE // "Excluir amarração c/ Periodo" 	
		MenuItem STR0059	Block {|| StsTpSaldo(oTreeCad4:GetCargo()),oWndDetalhe:Show()} Resource BMPCADEADO //  "Bloquear / Desbloquear" 	
ENDMENU

Ct011LAmarr()

ACTIVATE DIALOG oDlgManu CENTERED

UnLockByName("CTBA011"+xFilial("CTG"),.F.,.F.)

Return() 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ct011LCalendºAutor  ³TOTVS               º Data ³  21/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Calendario, cria arvores                                     º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ct011LCalend()
Local aArea 	:= GetArea()
Local cCalandAtu:= ""
Local cCodId	:= "" 


oTreeCad1				:= XTree():New( 000, 000, 000, 000, oWndCadCalend )
oTreeCad1:Align			:= CONTROL_ALIGN_ALLCLIENT
oTreeCad1:bValid		:= {|| lBlqCadCalend }
oTreeCad1:bWhen			:= {|| lBlqCadCalend }	
oTreeCad1:BrClicked		:= {|x,y,z| Iif( oTreeCad1:GetCargo()!='###'+Replicate('0',nTamRegSx5), oMenuPop1:Activate( y-50, z-390, oWndCadCalend ),oMenuPop1a:Activate( y-50, z-350, oWndCadCalend )) }

oTreeCad1:AddTree(	STR0003,; // "Calendário"		
						"BMPINCLUIR",; 		
						"BMPINCLUIR",; 	   	
						'###'+Replicate('0',nTamRegSx5),;  		   	
						,; 						
						,;
						,;
						)


DbSelectArea('CTG')
DbSetOrder(1)

If DbSeek( xFilial('CTG') )
	While CTG->(!Eof()) .And. CTG->CTG_FILIAL == xFilial('CTG')
		cCalandAtu 	:= CTG->CTG_CALEND 		
		cCodId 		:= cCalandAtu+Replicate('0',nTamRegSx5)	                     
		
		oTreeCad1:AddTree( 	CTG->CTG_CALEND, BMPCALSALDO, BMPCALSALDO,	cCodId, Nil, Nil, Nil, Nil )  									       
		
		While CTG->(!Eof()) .And. CTG->CTG_FILIAL == xFilial('CTG') .And. cCalandAtu == CTG->CTG_CALEND 		
			cCodId	:= cCalandAtu+StrZero(CTG->(Recno()),nTamRegSx5)
	  		
	  		oTreeCad1:AddTreeItem( CTG->CTG_PERIOD + ' - ' + DtoC(CTG->CTG_DTINI) + ' a ' + DtoC(CTG->CTG_DTFIM) + " ["+X3COMBO('CTG_STATUS',CTG->CTG_STATUS)+"]",;
	  							"",;
	  							cCodId,;
	  		                    Nil,;
	  		                    Nil,;
	  		                    Nil)
	  	   	                                       
			CTG->(DbSkip())					
		EndDo 				
		oTreeCad1:EndTree() 	
	EndDo
EndIf

oTreeCad1:EndTree()
RestArea(aArea)
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctba011Cal  ºAutor  ³TOTVS               º Data ³  21/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Enchoice de dados                                            º±±
±±º          ³                                                              º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±± 
±±ºParametros³ nOpc     - Opcao                                             º±±
±±º          ³ oWndDet  - Janela de apresentacao					        º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctba011Cal(nOpc,oWndDet)  

Local aSaveArea:= GetArea()
Local dData
Local nOpca := 0 
Local oDlgDetalhe 
Local oPanelDetalhe
Local oWindow  

Local cIdCalend := oTreeCad1:GetCargo()

Local cExerc  
Local oCalend 
Local cCalendCTB 
Local oCalendCTB 
Local oGet     
Local aButtons := {}                             
Local aDlg	:= {}    

Local bOkDetalhe   := {||Iif(Obrigatorio(aGets,aTela) .And. Ct010TudOk(nOpc),(nOpca:=1,oDlgDetalhe:End()),NIL)}
Local bCancDetalhe := {||nOpca:=0,oDlgDetalhe:End()}

Local lIsEnchoice 	:= .T. 
Local lSplitBar		:= .F.
Local lLegenda		:= .F. 
Local aButText		:= {} 

Private aTELA[0][0],aGETS[0],aHeader[0]
Private aCols	:= {}
Private nUsado := 0

Private nPosDtIni, nPosDtFim, nPosStatus

If nOpc == 3
	cExerc		:= Str(Year(dDataBase),4)
	cCalendCTB	:= CriaVar("CTG_CALEND")
Else            
	cExerc		:= CTG->CTG_EXERC                
	cCalendCTB	:= CTG->CTG_CALEND
	If nOpc == 2 
		bOkDetalhe := Nil
	EndIf		
EndIf

CTB010Ahead()
Ctb010Acols(nOpc,cExerc,cCalendCTB) 

//--- Cria objeto MsDialog e Panel   
aDlg:= MontaOdlg(STR0027,oWndDet) // "Calendário Contabil"  
                                              
oDlgDetalhe 	:= aDlg[1]
oPanelDetalhe   := aDlg[2] 

	@ 005,010 Say OemToAnsi(STR0003) OF oPanelDetalhe PIXEL // 'Calendário'
	@ 005,045 MSGET oCalendCTB VAR cCalendCTB When nOpc == 3 Valid NaoVazio(cCalendCTB) .AND. Ct010DgCod(@ccalendctb,@oCalendCTB)  .and. Ct010Calend(cCalendCTB,nOpc) .And. FreeForUse("CTG",cCalendCTB) SIZE 020,08 OF oDlgDetalhe PIXEL

	@ 005,100 Say OemToAnsi(STR0028) OF oPanelDetalhe PIXEL //'Exercício Contábil'
	@ 005,150 MSGET cExerc When nOpc == 3 Valid NaoVazio(cExerc) SIZE 035,08 OF oDlgDetalhe PIXEL

	oCalend:=MsCalend():New(17/*35*/,10,oDlgDetalhe)

	oCalend:bChange := {|| At010ChgDia(@oCalend,@oGet,@dData), oDlgDetalhe:Refresh()}
		
	oGet := MSGetDados():New(17/*035*/,155,090/*102*/,320,IIF(nOpc==4,2,IIf(nOpc==2,4,nOpc)),"Ct010LinOK","Ct010TudOK","+CTG_PERIOD",.T.)   
	
aDim := DLGinPANEL(oWndDet)	
// define dimensao da dialog
oDlgDetalhe:nWidth := aDim[4]-aDim[2]

ACTIVATE MSDIALOG oDlgDetalhe ON INIT (FaMyBar(oDlgDetalhe , bOkDetalhe, bCancDetalhe, /*aButtons*/, aButText, lIsEnchoice, lSplitBar,lLegenda), oDlgDetalhe:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1]) )					

RestArea(aSaveArea)

If nOpca == 1 .And. nOpc <> 2   
	BEGIN TRANSACTION
		If Ctb010Grava(nOpc,cExerc,cCalendCTB)
			Ctba011AtCal(oWndDet)
			If nOpc <> 3
				Ct011AtAmarr(1,Nil) 
			EndIf
		EndIf			
	END TRANSACTION
EndIf


Return( nOpca ) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctba011Cal  ºAutor  ³TOTVS               º Data ³  21/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Enchoice de dados                                            º±±
±±º          ³                                                              º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±± 
±±ºParametros³ nOpc     - Opcao                                             º±±
±±º          ³ oWndDet  - Janela de apresentacao					        º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctba011AtCal()  

oTreeCad1:Reset()

//???// Não deveria precisar desse trecho, mas o oTreeCad1:GetCargo() esta se perdendo apos recarregar o objeto 
oTreeCad1				:= XTree():New( 000, 000, 000, 000, oWndCadCalend )
oTreeCad1:Align			:= CONTROL_ALIGN_ALLCLIENT
oTreeCad1:bValid		:= {|| lBlqCadCalend }
oTreeCad1:bWhen			:= {|| lBlqCadCalend }	
oTreeCad1:BrClicked		:= {|x,y,z| Iif( oTreeCad1:GetCargo()!='###'+Replicate('0',nTamRegSx5), oMenuPop1:Activate( y-50, z-390, oWndCadCalend ),oMenuPop1a:Activate( y-50, z-350, oWndCadCalend )) }
//???// Fim do trecho


// Cria novamente
oTreeCad1:BeginUpdate()
oTreeCad1:Hide()
oTreeCad1:AddItem(STR0003,'###'+Replicate('0',nTamRegSx5),BMPCALSALDO,BMPCALSALDO,1)

CTG->( DbSetOrder(1) )                 
CTG->(DbSeek( xFilial('CTG')))
While CTG->(!Eof()) .And. CTG->CTG_FILIAL == xFilial('CTG') 

	oTreeCad1:TreeSeek('###'+Replicate('0',nTamRegSx5))
	
	cAtualiz := CTG->CTG_CALEND
	cCodPai := cAtualiz+Replicate('0',nTamRegSx5) 
			
	oTreeCad1:AddItem(CTG->CTG_CALEND,cCodPai,BMPCALSALDO,BMPCALSALDO, 2, Nil,Nil,Nil )
	
	While CTG->(!Eof()) .And. CTG->CTG_FILIAL = xFilial('CTG') .And. CTG->CTG_CALEND == cAtualiz
	
		cCodId := cAtualiz+StrZero(CTG->(Recno()),nTamRegSx5)

		oTreeCad1:TreeSeek(cCodPai) 		
		oTreeCad1:AddItem( CTG->CTG_PERIOD + ' - ' + DtoC(CTG->CTG_DTINI) + ' a ' + DtoC(CTG->CTG_DTFIM) + " ["+X3COMBO('CTG_STATUS',CTG->CTG_STATUS)+"]",cCodId, "","",2,Nil,Nil,Nil ) 
    
		CTG->(DbSkip())    					
	EndDo

EndDo
oTreeCad1:EndUpdate()
oTreeCad1:Show()
			 		
Return()


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MontaOdlg(cTexto,oWndAtivo)
Local aPosWnd := FWGETCOORSABSOLUTE( oWndAtivo ) 
Local oBjetoDlg
Local oPanel

DEFINE MSDIALOG oBjetoDlg TITLE OemToAnsi(cTexto) STYLE nOr(WS_VISIBLE,WS_POPUP) 
	oBjetoDlg:nTop    := aPosWnd[2]//+20
	oBjetoDlg:nLeft   := aPosWnd[1]
	oBjetoDlg:nWidth  := oWndAtivo:nWidth
	oBjetoDlg:nHeight := oWndAtivo:nHeight//-20 
	@ 000,000 MSPANEL oPanel OF oBjetoDlg
	oPanel:nClrPane := CLR_HGRAY	//CLR_YELLOW
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT	

Return({oBjetoDlg,oPanel,aPosWnd})  

 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


Static Function Ct011LCadMoe()

Local aArea 	:= GetArea()
Local cCodId	:= ""

__oWindowDet	    := oWndDetalhe

/*
 * Criação da Árvore do Cadastro de Moedas
 */  
oTreeCad2			:= XTree():New( 000, 000, 000, 000, oWndCadMoed )
oTreeCad2:Align		:= CONTROL_ALIGN_ALLCLIENT
oTreeCad2:bValid	:= {|| lBlqCadMoeda }
oTreeCad2:bWhen		:= {|| lBlqCadMoeda }	
oTreeCad2:BrClicked	:= {|x,y,z| Iif( oTreeCad2:GetCargo() !='###'+Replicate('0',nTamRegSx5), oMenuPop2:Activate( y-50, z-140, oWndCadMoed ),oMenuPop2a:Activate( y-50, z-140, oWndCadMoed )) }


oTreeCad2:AddTree(STR0002,"BMPINCLUIR","BMPINCLUIR",'###'+Replicate('0',nTamRegSx5),Nil,Nil,Nil,) // "Moeda"	  

DbSelectArea('CTO')
DbSetOrder(1)   

If DbSeek( xFilial('CTO') )
		
	While CTO->(!Eof())	 .And. CTO->CTO_FILIAL == xFilial('CTO') 
	
		cCodId := "MOE" + StrZero(CTO->(Recno()),nTamRegSx5)
		
  		oTreeCad2:AddTreeItem(CTO->CTO_MOEDA + ' - ' + CTO->CTO_DESC ,;                                                     
  							BMPMOEDCAL,;
  							cCodId,;
  							,;
  							,)							
  							
		CTO->(DbSkip())
	EndDo	                
EndIf

oTreeCad2:EndTree() 
RestArea(aArea)

Return() 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PesqTabela   ºAutor  ³TOTVS               º Data ³  21/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Pesquisa registro na tabela                                   º±±
±±º          ³                                                               º±±  
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±± 
±±ºParametros³ cAlias    - Alias                                             º±±
±±º          ³ nReg      - Recno            			    		         º±±    
±±º          ³ cSeek     - parametro de pesquisa		    		         º±±    
±±º          ³ nOrdem    - numero da ordem        		    		         º±±   
±±º          ³ cCampo    - campo de retorno      		    		         º±±   
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PesqTabela(cAlias,nReg,cSeek,nOrdem,cCampo)
Local aAreaAtu := GetArea()
Local aAreaAlias := &(cAlias)->(GetArea()) 
Local xRetorno

DbSelectArea(cAlias)
If nReg != Nil
	If nReg != 0
		DbGoTo(nReg)
	Else
		If cCampo != Nil
			xRetorno := ""
		Else
			xRetorno := .F.
		EndIf 
		RestArea(aAreaAlias)
		RestArea(aAreaAtu)
		Return xRetorno 		
	EndIf		
Else
	DbSetOrder(nOrdem)
	DbSeek(xFilial(cAlias)+cSeek)	
EndIf                           

If Found() .Or. nReg != Nil
	If cCampo != Nil
		xRetorno := Alltrim((cAlias)->&(cCampo))
	Else
		xRetorno := .T.
	EndIf		
Else                
	If cCampo != Nil
		xRetorno := ""	
	Else
		xRetorno := .F.	
	EndIf		
EndIF

RestArea(aAreaAlias)
RestArea(aAreaAtu)
Return xRetorno  
						


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Ctba011AtMoe(nOpc) 

Local cAtualiz
Local cCodId  

oTreeCad2:Reset()

//???// Não deveria precisar desse trecho, mas o oTreeCad1:GetCargo() esta se perdendo apos recarregar o objeto 
oTreeCad2			:= XTree():New( 000, 000, 000, 000, oWndCadMoed )
oTreeCad2:Align		:= CONTROL_ALIGN_ALLCLIENT
oTreeCad2:bValid	:= {|| lBlqCadMoeda }
oTreeCad2:bWhen		:= {|| lBlqCadMoeda }	
oTreeCad2:BrClicked	:= {|x,y,z| Iif( oTreeCad2:GetCargo() !='###'+Replicate('0',nTamRegSx5), oMenuPop2:Activate( y-50, z-140, oWndCadMoed ),oMenuPop2a:Activate( y-50, z-140, oWndCadMoed )) }

//???// Fim do trecho

// Cria novamente
oTreeCad2:BeginUpdate()
oTreeCad2:Hide()
oTreeCad2:AddItem(STR0002,'###'+Replicate('0',nTamRegSx5),"BMPINCLUIR","BMPINCLUIR",1)

CTO->( DbSetOrder(1) )                 
CTO->(DbSeek( xFilial('CTO')))
While CTO->(!Eof()) .And. CTO->CTO_FILIAL == xFilial('CTO') 

	cAtualiz := "MOE" + StrZero(CTO->(Recno()),nTamRegSx5)
	cCodId := cAtualiz//+Replicate('0',nTamRegSx5)

	oTreeCad2:TreeSeek('###'+Replicate('0',nTamRegSx5)) 
	oTreeCad2:AddItem(CTO->CTO_MOEDA + ' - ' + CTO->CTO_DESC,cCodId,BMPMOEDCAL,BMPMOEDCAL, 2)                                    					                                                                              
					            					
	CTO->(DbSkip()) 	
EndDo

lReord := .T. //variavel usada para possibilitar a manipulação da moeda correta via menu pop de moedas

oTreeCad2:EndUpdate()
oTreeCad2:Show()

If nOpc <> 4
	Ct011AtAmarr(1,Nil)
Else
	oTreeCad4:ChangePrompt( CTO->CTO_MOEDA + ' - ' + CTO->CTO_DESC, "MOE" +CTO->CTO_MOEDA+"000"+"00"+"0"+ StrZero(CTO->(Recno()),nTamRegSx5) )
EndIf

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ct011LTpSld ºAutor  ³TOTVS               º Data ³  21/07/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tipo de Saldo, cria arvores                                  º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ct011LTpSld()

Local aArea	:= GetArea()
Local cCodId:= ""
Local cCor

/*
 * Criação da Árvore do Cadastro de Tipo de Saldo de Contábil
 */    
oTreeCad3				:= XTree():New( 000, 000, 000, 000, oWndCadTpSaldo )
oTreeCad3:Align			:= CONTROL_ALIGN_ALLCLIENT
oTreeCad3:bValid		:= {|| lBlqCadTpSaldo }
oTreeCad3:bWhen			:= {|| lBlqCadTpSaldo }	
oTreeCad3:BrClicked		:= {|x,y,z| Iif( oTreeCad3:GetCargo() !='###'+Replicate('0',nTamRegSx5), oMenuPop3:Activate( y-50, z-140, oWndCadMoed ),oMenuPop3a:Activate( y-50, z-140, oWndCadMoed )) }

/*
 * Criação do nó principal da árvore com a opção de manutenção do cadastro de tipo de saldo contábil
 */
oTreeCad3:AddTree( 	STR0004 ,"BMPINCLUIR","BMPINCLUIR",'###'+Replicate('0',nTamRegSx5),Nil,Nil,Nil,Nil	) // "Tipo de Saldo"


DbSelectArea('SX5')
DbSetOrder(1)	// X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_

If DbSeek( xFilial('SX5') + 'SL' )
	While SX5->(!Eof()) .And. SX5->X5_FILIAL == xFilial('SX5') .And. SX5->X5_TABELA = 'SL'
		cCodId := "TPS" + StrZero(SX5->(Recno()),nTamRegSx5)                                  
		cCor := CtbLegRes(Left(SX5->X5_CHAVE, 1))
		oTreeCad3:AddTreeItem( Alltrim(SX5->X5_CHAVE)+ " - "+SX5->X5_DESCRI ,cCor,cCodId,Nil,Nil)							
  		Aadd(aColsTp, { Left(SX5->X5_CHAVE, 1), X5Descri(),SX5->(Recno()), cCor,cCodId })
  		SX5->(DbSkip())		
	EndDo	
EndIf 

oTreeCad3:EndTree() 

RestArea(aArea)
Return()


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb130Man ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 20.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Manutencao na tabela de saldos contabeis - "SL"            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb130Man()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Ctba130                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Opcao de edicao [INCLUSAO/EDICAO/EXCLUSAO]         ³±±
±±³          ³ ExpA1 = Matriz com os saldos contabeis                     ³±±
±±³          ³ ExpO1 = Objeto de LIST BOX de manutencao dos saldos        ³±±
±±³          ³ ExpC1 = Descricao da acao sendo executada INCLUIR,ALTERAR..³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function xCtb130Man(nOpcao, aCols, nAt, cAcao)

Local nOpc 		:= 0, oDlg
Local lRet		:= .T. 
Local nCols 	:= IIf(nOpcao == 1, 0, nAt)
Local cCod130 	:= IIf(nOpcao == 1, " ", aCols[nCols][1])
Local cDesc130	:= IIf(nOpcao == 1, Space(Len(X5Descri())), aCols[nCols][2])
Local aCores	:=Ct130CorSl() // Função padrão de legenda e cores de Saldo	 | Caption and colors Balance Standard  function
Local aItens	:= {}, nItens
Local lSldInt	:= IIf(nOpcao == 2 .or. nOpcao == 3, Ctb130SldInt(cCod130), .F.)
Local cResource := CtbLegRes(cCod130)
Local cCor130	:= ""
Local cIdioma   := ""

For nItens := 1 To Len(aCores)
	Aadd(aItens, AllTrim(Str(nItens, 2)) + "-" + aCores[nItens][2] )
Next

nItens := Ascan(aCores, { |x| x[1] == cResource })
If nItens == 0
	cCor130 := aItens[1]
Else
	cCor130 := aItens[nItens]
Endif

If !lSldInt

	DEFINE 	MSDIALOG oDlg FROM  86,1 TO 205,400;
			TITLE STR0049 + cAcao PIXEL // "Edição dos Saldos Contabéis - " 
	
	@ 05, 04 TO 55, 154 LABEL STR0050 OF oDlg PIXEL // "Saldo Contábil" 
	
	@ 14, 08 SAY STR0051	SIZE 53, 07 OF oDlg PIXEL // "Código" 
	@ 27, 08 SAY STR0047	SIZE 53, 07 OF oDlg PIXEL // "Descricao" 
	@ 40, 08 SAY STR0048 	SIZE 53, 07 OF oDlg PIXEL // "Legenda"
	
	@ 12, 68 MSGET cCod130		SIZE 18, 10 OF oDlg PIXEL Picture "@";
			 When nOpcao = 1 .And. ! lSldInt;
			 Valid 	! Empty(cCod130) .And. If(Ascan(aCols, { |x| x[1] = cCod130} ) > 0,;
			 		(HELP(" ", 1, "JAGRAVADO"), .F.), .T.)
	@ 25, 68 MSGET cDesc130	SIZE 63, 10 OF oDlg PIXEL Valid ! Empty(cDesc130);
	 		 When nOpcao < 3 .And. ! lSldInt
	
	@ 38, 68 	MSCOMBOBOX oCores VAR cCor130 ITEMS aItens SIZE 68,08	PIXEL;
				Valid !('Reservado' $ cCor130) .And. Ctb130ChkCor(	cCor130, aItens, aCores, aCols,;
									If(nOpcao = 1, 0, aCols[nCols][3]));
				When nOpcao < 3 .And. ! lSldInt
	
	DEFINE 	SBUTTON oBtnOk FROM 07,160 TYPE 1 ENABLE OF oDlg;
			Action (nOpc:=1,If(Ctb130ChkCor(	cCor130, aItens, aCores, aCols,;
							 If(nOpcao = 1, 0, aCols[nCols][3])), oDlg:End(), nOpc:=0))
	DEFINE 	SBUTTON oBtnCn FROM 21,160 TYPE 2 ENABLE OF oDlg Action (nOpc:=0,oDlg:End())
	ACTIVATE MSDIALOG oDlg Centered

EndIf 

If nOpc == 1                    
	//Se for exclusao e saldo interno, nao gravar nada. 
	If nOpcao == 3 
		If lSldInt
			lRet := .F.	
	    Else
	    	If AmTpSaldo(cCod130)
	    		lRet := .F.
	    		MsgAlert(STR0060) //"Não é possivel excluir este Tipo de Saldo, pois o mesmo possui amarração com calendário. "	    
	    	EndIf
	    EndIf
	ElseIf nOpcao == 4 
		lRet := .F.	 
	EndIf
	
	If lRet
		If nCols = 0
			Aadd(aCols, { cCod130, cDesc130, 0, "","" })
			nCols := Len(aCols)
		Else
			aCols[nCols][1] := cCod130
			aCols[nCols][2] := cDesc130
		Endif
	
		If aCols[nCols][3] > 0
			SX5->(MsGoto(aCols[nCols][3]))
		Endif
		RecLock("SX5", aCols[nCols][3] = 0) 
		If nOpcao = 1
			FwPutSX5("", "SL", aCols[nCols][1])
		Endif
	
		// Procuro a cor escolhida na matriz de escolhas
		lSldInt	:= Ctb130SldInt(cCod130, .F.)
		nItens 	:= Ascan(aItens, cCor130)
		cCor130 := ""
	
		// Caso seja saldo interno e tenha alterado a cor ou nao for saldo interno
		// Eh gravado nas 11 posicoes final do X5_DESCRI o resource da legenda
	
		If (lSldInt .And. cResource <> aCores[nItens][1]) .Or. ! lSldInt
			cCor130 := aCores[nItens][1]
		Endif
	
		If nOpcao < 3
			cIdioma  := Upper( Left( FWRetIdiom(), 2 ) )
			If cIdioma == 'PT'
				//FwPutSX5(cFlavour, cTabela, cChave, cTextoPor, cTextoEng, cTextoEsp, cTextoAlt)
				FwPutSX5("", "SL", aCols[nCols][1], aCols[nCols][2])
			ElseIf cIdioma == 'ES'
				FwPutSX5("", "SL", aCols[nCols][1],,,aCols[nCols][2])
			ElseIf cIdioma == 'EN'
				FwPutSX5("", "SL", aCols[nCols][1],,aCols[nCols][2])
			Endif
		Else
			SX5->(DbDelete())
		Endif
		aCols[nCols][3] := SX5->(Recno())
		aCols[nCols][4] := CtbLegRes(aCols[nCols][1])
		aCols[nCols][5] := "TPS" + StrZero(SX5->(Recno()),nTamRegSx5)
		
		SX5->(MsUnLock())
		
		If nOpcao <> 3 .And. ! Empty(cCor130)
			FwPutSX5("", "SM", aCols[nCols][1], cCor130)
		ElseIf SX5->(DbSeek(xFilial() + "SM" + aCols[nCols][1]))
			RecLock("SX5", .F.)
			SX5->(DbDelete())
			SX5->(MsUnLock())
		Endif
		
		Ctba011AtTp()
		//Atualizar painel de amarração quando alteração
		If nOpcao == 2
			Ct011AtAmarr(1,Nil)
		EndIf							
	EndIf
Endif

Return .T. 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/08/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ctba011AtTp()

Local aArea	:= GetArea()
Local cCodId:= ""
Local cCor
aColsTp := {}

oTreeCad3:Reset()
                                            
oTreeCad3				:= XTree():New( 000, 000, 000, 000, oWndCadTpSaldo )
oTreeCad3:Align			:= CONTROL_ALIGN_ALLCLIENT
oTreeCad3:bValid		:= {|| lBlqCadTpSaldo }
oTreeCad3:bWhen			:= {|| lBlqCadTpSaldo }	
oTreeCad3:BrClicked		:= {|x,y,z| Iif( oTreeCad3:GetCargo() !='###'+Replicate('0',nTamRegSx5), oMenuPop3:Activate( y-50, z-140, oWndCadMoed ),oMenuPop3a:Activate( y-50, z-140, oWndCadMoed )) }


// Cria novamente
oTreeCad3:BeginUpdate()
oTreeCad3:Hide()
oTreeCad3:AddItem(STR0004,'###'+Replicate('0',nTamRegSx5),"BMPINCLUIR","BMPINCLUIR",1)
	       
SX5->( DbSetOrder(1) )                 
SX5->(DbSeek( xFilial('SX5') + 'SL'))
While SX5->(!Eof()) .And. SX5->X5_FILIAL = xFilial("SX5") .And. SX5->X5_TABELA = "SL" 

	cAtualiz := SX5->X5_CHAVE 
	cCodId := "TPS" + StrZero(SX5->(Recno()),nTamRegSx5)
    cCor := CtbLegRes(Left(SX5->X5_CHAVE, 1))
	oTreeCad3:TreeSeek('###'+Replicate('0',nTamRegSx5)) 
	oTreeCad3:AddItem(AllTrim(SX5->X5_CHAVE) + ' - ' + AllTrim(SX5->X5_DESCRI),cCodId,cCor,cCor, 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )
    Aadd(aColsTp, { Left(SX5->X5_CHAVE, 1), X5Descri(),SX5->(Recno()), cCor,cCodId })                                					            					
	SX5->(DbSkip()) 	

EndDo

oTreeCad3:EndUpdate()
oTreeCad3:Show()

RestArea(aArea)

Return  



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ct011LAmarr()

Local aArea 	:= GetArea()
Local oBjeto	:= Nil  
Local cCodId	:= ""
Local cCodId1	:= ""
Local cCodId2	:= ""
Local cCodId3	:= ""
Local cCodId4	:= ""
Local cStatus	:= ""

/*
 * Criação da Árvore do Cadastro de Moedas
 */  
oTreeCad4			:= XTree():New( 000, 000, 000, 000, oWndDetalhe )
oTreeCad4:Align		:= CONTROL_ALIGN_ALLCLIENT
oTreeCad4:bValid	:= {|| lBlqAmarr }
oTreeCad4:bWhen		:= {|| lBlqAmarr }	
oTreeCad4:BrClicked	:= {|x,y,z| MenuAmarra(x,y,z,Substr(oTreeCad4:GetCargo(),1,2)) }

	  
                                                                     
DbSelectArea('CTO')
DbSetOrder(1)   

If DbSeek( xFilial('CTO') )
		
	While CTO->(!Eof())	 .And. CTO->CTO_FILIAL == xFilial('CTO') 
		cCodId :=  "MOE" +CTO->CTO_MOEDA+Space(nTamCal)+Space(nTamExe)+Space(nTamPer)+Space(nTamTps)+ StrZero(CTO->(Recno()),nTamRegSx5) 
		oTreeCad4:AddTree(CTO->CTO_MOEDA + ' - ' + CTO->CTO_DESC ,BMPMOEDCAL,BMPMOEDCAL,cCodId,Nil,Nil,Nil,) // "Moeda"
		DbSelectArea('CTE')
		DbSetOrder(1)
		DbSeek(xFilial('CTE')+CTO->CTO_MOEDA) 
		While CTE->(!Eof()) .And. CTE->CTE_FILIAL+CTE->CTE_MOEDA == xFilial('CTE')+CTO->CTO_MOEDA 
			DbSelectArea('CTG')
			DbSetOrder(1)
			If DbSeek( xFilial('CTG')+CTE->CTE_CALEND )
				cCodId := "CLD"+CTO->CTO_MOEDA+CTE->CTE_CALEND+CTG->CTG_EXERC+Space(nTamPer)+Space(nTamTps)+Replicate('0',nTamRegSx5)                  			
				oTreeCad4:AddTree( 	CTG->CTG_CALEND, BMPCALSALDO, BMPCALSALDO,	cCodId, Nil, Nil, Nil, Nil )  									       
				While CTG->(!Eof()) .And. CTG->CTG_FILIAL == xFilial('CTG') .And. CTE->CTE_CALEND == CTG->CTG_CALEND 		
					cCodId	:= "PRD"+CTO->CTO_MOEDA+CTE->CTE_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD+Space(nTamTps)+StrZero(CTG->(Recno()),nTamRegSx5)		  		
			  		oTreeCad4:AddTree( 	CTG->CTG_PERIOD + ' - ' + DtoC(CTG->CTG_DTINI) + ' a ' + DtoC(CTG->CTG_DTFIM) /*+ " ["+X3COMBO('CTG_STATUS',CTG->CTG_STATUS)+"]"*/,;
			  		 					"", "",	cCodId, Nil, Nil, Nil, Nil )  	

		  	   		DbSelectArea("CWG")
					CWG->(dbSetOrder(1))	//CWG_FILIAL+ CWG_MOEDA+CWG_CALEND+CWG_PERIOD+CWG_TPSALD                                       
					CWG->(dbSeek(xFilial("CWG")+CTO->CTO_MOEDA+CTE->CTE_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD))
					While CWG->(!Eof()) .And. CWG->(CWG_FILIAL+CWG_MOEDA+CWG_CALEND+CWG_EXERCI+CWG_PERIOD) == xFilial("CWG")+CTO->CTO_MOEDA+CTE->CTE_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD 	
                                                           
						DbSelectArea('SX5')
						DbSetOrder(1)	// X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_
						If DbSeek( xFilial('SX5') + 'SL' + CWG->CWG_TPSALD )
								cCodId := "TPS" +CTO->CTO_MOEDA+CTE->CTE_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD+Left(SX5->X5_CHAVE, nTamTps)+StrZero(SX5->(Recno()),nTamRegSx5)                                  
								cCor := CtbLegRes(Left(SX5->X5_CHAVE, nTamTps))
								cStatus := Iif( Empty(CWG->CWG_STATUS),"",X3Combo("CWG_STATUS",CWG->CWG_STATUS))
								oTreeCad4:AddTreeItem( Alltrim(SX5->X5_CHAVE)+ " - "+AllTrim(SX5->X5_DESCRI) + " ["+cStatus+"]" ,cCor,cCodId,Nil,Nil)								
						EndIf 
						CWG->(DbSkip())	
					EndDo
										
					oTreeCad4:EndTree() 
					CTG->(DbSkip())					
				EndDo 				
				oTreeCad4:EndTree() 		
			EndIf
		
			CTE->(DbSkip())
		EndDo 
				
		oTreeCad4:EndTree() 
		CTO->(DbSkip())
	EndDo	                
EndIf

RestArea(aArea)

Return()  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function MenuAmarra(x,y,z,cNivel)

Do Case
	Case cNivel == "MO"
		oMenuMoe:Activate( y-100, z-140, oWndDetalhe )
	Case cNivel == "CL"
		oMenuCal:Activate( y-100, z-140, oWndDetalhe )
	Case cNivel == "PR"
		oMenuPer:Activate( y-100, z-140, oWndDetalhe )
	Case cNivel == "TP"
		oMenuTps:Activate( y-100, z-140, oWndDetalhe )
EndCase 


Return


 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CapCalend(cCodIdMoed)

Local aSaveArea		:= GetArea()
Local aAreaCTO		:= CTO->(GetArea())
Local nOpc 			:= 0  
Local oDlg, oBtnOk, oBtnCn 
Local aX3Cal 		:= SX3Inf("CTE_CALEND")
Local cCodMoeda 	:= ""
Local cCalend 		:= ""
Private INCLUI 		:= .T. 
Private ALTERA		:= .F. 


RegToMemory("CTE",.F.)

M->CTE_MOEDA 	:= SubStr(cCodIdMoed,nIniMoe,nTamMoe)
M->CTE_CALEND 	:= Space(aX3Cal[2])

dbSelectArea("CTO")
dbSetOrder(1)
If !MsSeek(xFilial("CTO")+M->CTE_MOEDA) .Or. !SoftLock("CTO")
	Return
EndIf

DEFINE 	MSDIALOG oDlg FROM  86,1 TO 205,400;
		TITLE STR0061 PIXEL //"Moeda x Calendário"

@ 14, 08 SAY aX3Cal[1]	SIZE 53, 07 OF oDlg PIXEL 

@ 12, 68 MSGET M->CTE_CALEND	SIZE 18, 10 OF oDlg PIXEL Picture aX3Cal[3] ;
		 F3 aX3Cal[4]	Valid !Empty(M->CTE_CALEND) .And. &(aX3Cal[5])       

DEFINE 	SBUTTON oBtnOk FROM 07,160 TYPE 1 ENABLE OF oDlg Action (nOpc:=1, oDlg:End())
DEFINE 	SBUTTON oBtnCn FROM 21,160 TYPE 2 ENABLE OF oDlg Action (nOpc:=0, oDlg:End()) 

ACTIVATE MSDIALOG oDlg Centered

If nOpc == 1
	dbSelectArea("CTE")
	CTE->(dbSetOrder(1))
	If Ctb200TOK()  //se tudo ok grava a amarracao de moeda x calendario 
		RecLock("CTE", .T.)
		CTE->CTE_FILIAL	:= xFilial("CTE")
		CTE->CTE_MOEDA	:= M->CTE_MOEDA
		CTE->CTE_CALEND	:= M->CTE_CALEND
		MsUnLock()

		cCodMoeda 	:= CTE->CTE_MOEDA
		cCalend 	:= CTE->CTE_CALEND
	
		// ponto de entrada para depois da gravacao	
		If ExistBlock("CTB200Inc") 
			ExecBlock( "CTB200Inc",.F.,.F.,{cCodMoeda, cCalend}) 
		EndIf
		
		//Atualiza Arvore
	    Ct011AtAmarr(2,cCodIdMoed)
	    	    
	Endif
        
	RestArea(aSaveArea)
EndIf

CTO->(MsUnLock()) 
RestArea(aAreaCTO)

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function SX3Inf(cCampo)

Local aArea 	:= GetArea()
Local aAreaSX3 
Local cValid	:= ""
Local cTitulo	:= ""
Local nTam		:= 0
Local cPicture	:= ""
Local cF3		:= "" 	

If ValType(cCampo) == "C" 
	
	aAreaSX3 	:= SX3->(GetArea())
	
	dbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	If SX3->(dbSeek(cCampo))
		cTitulo 	:= X3TITULO()
		nTam		:= SX3->X3_TAMANHO
		cPicture 	:= SX3->X3_PICTURE
		
		cValid := IIf(!Empty(SX3->X3_VALID),Alltrim(SX3->X3_VALID),"")
		cValid += IIf(!Empty(SX3->X3_VALID).And.!Empty(SX3->X3_VLDUSER)," .And. ","")
		cValid += IIf(!Empty(SX3->X3_VLDUSER),Alltrim(SX3->X3_VLDUSER),"")
		
		cF3 := SX3->X3_F3
	EndIf
    
	RestArea(aAreaSX3)

EndIf
	
If Empty(cValid)
	cValid := ".T."
Endif

RestArea(aArea)

Return {cTitulo, nTam, cPicture, cF3, cValid}


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ct011AtAmarr(nOpAcao,cCodIdPai)

Local aArea 	:= GetArea()
Local oBjeto	:= Nil  
Local cCodId1	:= ""
Local cCodId2	:= ""
Local cCodId3	:= ""
Local cCodId4	:= ""
Local cStatus	:= ""
Local nPosFilho
Local nPosPai
Local nCodIdNo
Local cCodMoeda
Local cCodCalend
Local cCodExerc
Local cCodPeriodo


If nOpAcao == 1
	oTreeCad4:Reset()
	 
	oTreeCad4			:= XTree():New( 000, 000, 000, 000, oWndDetalhe )
	oTreeCad4:Align		:= CONTROL_ALIGN_ALLCLIENT
	oTreeCad4:bValid	:= {|| lBlqAmarr }
	oTreeCad4:bWhen		:= {|| lBlqAmarr }	
	oTreeCad4:BrClicked	:= {|x,y,z| MenuAmarra(x,y,z,Substr(oTreeCad4:GetCargo(),1,2)) }
EndIf	

// Cria novamente
oTreeCad4:BeginUpdate()
oTreeCad4:Hide()

If nOpAcao == 1	//Atualiza a arvore toda  
	DbSelectArea('CTO')
	DbSetOrder(1)   
	
	If DbSeek( xFilial('CTO') )
			
		While CTO->(!Eof())	 .And. CTO->CTO_FILIAL == xFilial('CTO') 
			oTreeCad4:TreeSeek(cCodId1)
			cCodId1 := "MOE" +CTO->CTO_MOEDA+Space(nTamCal)+Space(nTamExe)+Space(nTamPer)+Space(nTamTps)+ StrZero(CTO->(Recno()),nTamRegSx5) 
			oTreeCad4:AddItem(CTO->CTO_MOEDA + ' - ' + CTO->CTO_DESC ,cCodId1,BMPMOEDCAL,BMPMOEDCAL, 1, /*bAction*/,/*bRClick*/,/*bDblClick*/ )
	        
			DbSelectArea('CTE')
			DbSetOrder(1)
			DbSeek(xFilial('CTE')+CTO->CTO_MOEDA) 
			While CTE->(!Eof()) .And. CTE->CTE_FILIAL+CTE->CTE_MOEDA == xFilial('CTE')+CTO->CTO_MOEDA 
				DbSelectArea('CTG')
				DbSetOrder(1)
				If DbSeek( xFilial('CTG')+CTE->CTE_CALEND )
					cCodId2 := "CLD"+CTO->CTO_MOEDA+CTE->CTE_CALEND+CTG->CTG_EXERC+Space(nTamPer)+Space(nTamTps)+Replicate('0',nTamRegSx5)	                     											       
					oTreeCad4:TreeSeek(cCodId1)
					oTreeCad4:AddItem(CTG->CTG_CALEND ,cCodId2,BMPCALSALDO,BMPCALSALDO, 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )
					While CTG->(!Eof()) .And. CTG->CTG_FILIAL == xFilial('CTG') .And. CTE->CTE_CALEND == CTG->CTG_CALEND 		
						cCodId3	:= "PRD"+CTO->CTO_MOEDA+CTE->CTE_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD+Space(nTamTps)+StrZero(CTG->(Recno()),nTamRegSx5)			  		
				   		oTreeCad4:TreeSeek(cCodId2)
				   		oTreeCad4:AddItem(CTG->CTG_PERIOD + ' - ' + DtoC(CTG->CTG_DTINI) + ' a ' + DtoC(CTG->CTG_DTFIM) /*+ " ["+X3COMBO('CTG_STATUS',CTG->CTG_STATUS)+"]"*/,;
				   	   						cCodId3,"","", 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )                  
	            
				  	   	DbSelectArea("CWG")
						CWG->(dbSetOrder(1))	//CWG_FILIAL+ CWG_MOEDA+CWG_CALEND+CWG_PERIOD+CWG_TPSALD                                       
						CWG->(dbSeek(xFilial("CWG")+CTO->CTO_MOEDA+CTE->CTE_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD))
						While CWG->(!Eof()) .And. CWG->(CWG_FILIAL+CWG_MOEDA+CWG_CALEND+CWG_EXERCI+CWG_PERIOD) == xFilial("CWG")+CTO->CTO_MOEDA+CTE->CTE_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD 	
                                      
							DbSelectArea('SX5')
							DbSetOrder(1)	// X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_
							If DbSeek( xFilial('SX5') + 'SL' + CWG->CWG_TPSALD )
									cCodId4 := "TPS" +CTO->CTO_MOEDA+CTE->CTE_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD+Left(SX5->X5_CHAVE, nTamTps)+StrZero(SX5->(Recno()),nTamRegSx5)                                  
									cCor := CtbLegRes(Left(SX5->X5_CHAVE, nTamTps))							
							  		oTreeCad4:TreeSeek(cCodId3)
							  		cStatus := Iif( Empty(CWG->CWG_STATUS),"",X3Combo("CWG_STATUS",CWG->CWG_STATUS))
				  			  		oTreeCad4:AddItem(Alltrim(SX5->X5_CHAVE)+ " - "+AllTrim(SX5->X5_DESCRI) + " ["+cStatus+"]" ,cCodId4,cCor,cCor, 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )
							EndIf 										
							CWG->(DbSkip())
						EndDo
						CTG->(DbSkip())					
					EndDo 						
				EndIf
				CTE->(DbSkip())
			EndDo 
			CTO->(DbSkip())
		EndDo	                
	EndIf

Else
    
    // Deleta os Filhos
    nPosPai := Ascan(oTreeCad4:aCargo, { |x| x[1] == cCodIdPai} )
    If nPosPai > 0 
    	nCodIdNo 	:= oTreeCad4:aNoDes[nPosPai,2]
    	nPosFilho 	:= Ascan(oTreeCad4:aNoDes, { |x| x[1] == nCodIdNo} ) 
    	While nPosFilho <> 0
    		If oTreeCad4:TreeSeek(oTreeCad4:aCargo[nPosFilho,1]) 
    			oTreeCad4:DelItem() 
    		EndIf
    		nPosFilho 	:=	Ascan(oTreeCad4:aNoDes, { |x| x[1] == nCodIdNo} )//ajustar, se necessario 	
    	EndDo
    EndIf
	
	cCodMoeda := SubStr(cCodIdPai,nIniMoe,nTamMoe)

	If nOpAcao == 2	    
    
		//Atualiza a xtree com amarração 
	    DbSelectArea('CTE')
		DbSetOrder(1)
		DbSeek(xFilial('CTE')+cCodMoeda) 
		While CTE->(!Eof()) .And. CTE->CTE_FILIAL+CTE->CTE_MOEDA == xFilial('CTE')+cCodMoeda 
			DbSelectArea('CTG')
			DbSetOrder(1)
			If DbSeek( xFilial('CTG')+CTE->CTE_CALEND )
				cCodId2 := "CLD"+cCodMoeda+CTE->CTE_CALEND+CTG->CTG_EXERC+Space(nTamPer)+Space(nTamTps)+Replicate('0',nTamRegSx5)	                     											       
				oTreeCad4:TreeSeek(cCodIdPai)
				oTreeCad4:AddItem(CTG->CTG_CALEND ,cCodId2,BMPCALSALDO,BMPCALSALDO, 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )
				While CTG->(!Eof()) .And. CTG->CTG_FILIAL == xFilial('CTG') .And. CTE->CTE_CALEND == CTG->CTG_CALEND 		
					cCodId3	:= "PRD"+cCodMoeda+CTE->CTE_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD+Space(nTamTps)+StrZero(CTG->(Recno()),nTamRegSx5)			  		
			   		oTreeCad4:TreeSeek(cCodId2)
			   		oTreeCad4:AddItem(CTG->CTG_PERIOD + ' - ' + DtoC(CTG->CTG_DTINI) + ' a ' + DtoC(CTG->CTG_DTFIM) /*+ " ["+X3COMBO('CTG_STATUS',CTG->CTG_STATUS)+"]"*/,;
			   	   						cCodId3,"","", 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )                  
	            
			  	   	DbSelectArea("CWG")
					CWG->(dbSetOrder(1))	//CWG_FILIAL+ CWG_MOEDA+CWG_CALEND+CWG_PERIOD+CWG_TPSALD                                       
					CWG->(dbSeek(xFilial("CWG")+cCodMoeda+CTE->CTE_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD))
					While CWG->(!Eof()) .And. CWG->(CWG_FILIAL+CWG_MOEDA+CWG_CALEND+CWG_EXERCI+CWG_PERIOD) == xFilial("CWG")+cCodMoeda+CTE->CTE_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD 	
						DbSelectArea('SX5')
						DbSetOrder(1)	// X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_
						If DbSeek( xFilial('SX5') + 'SL' + CWG->CWG_TPSALD )
								cCodId4 := "TPS" +cCodMoeda+CTE->CTE_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD+Left(SX5->X5_CHAVE, nTamTps)+StrZero(SX5->(Recno()),nTamRegSx5)                                  
								cCor := CtbLegRes(Left(SX5->X5_CHAVE, nTamTps))							
						  		oTreeCad4:TreeSeek(cCodId3)
						  		cStatus := Iif( Empty(CWG->CWG_STATUS),"",X3Combo("CWG_STATUS",CWG->CWG_STATUS))
			  			  		oTreeCad4:AddItem(Alltrim(SX5->X5_CHAVE)+ " - "+AllTrim(SX5->X5_DESCRI) + " ["+cStatus+"]" ,cCodId4,cCor,cCor, 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )	
						EndIf 										
						CWG->(DbSkip())
					EndDo
					
					CTG->(DbSkip())					
				EndDo 						
			EndIf
			CTE->(DbSkip())
		EndDo
		
	ElseIf nOpAcao == 3	    
	    
		cCodCalend	:= SubStr(cCodIdPai,nIniCal,nTamCal)
		
		//Atualiza a xtree com amarração 
		DbSelectArea('CTG')
		DbSetOrder(1)
		If DbSeek( xFilial('CTG')+cCodCalend )                   											       
			While CTG->(!Eof()) .And. CTG->CTG_FILIAL == xFilial('CTG') .And. cCodCalend == CTG->CTG_CALEND 		
				cCodId3	:= "PRD"+cCodMoeda+CTG->CTG_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD+Space(nTamTps)+StrZero(CTG->(Recno()),nTamRegSx5)			  		
		   		oTreeCad4:TreeSeek(cCodIdPai)
		   		oTreeCad4:AddItem(CTG->CTG_PERIOD + ' - ' + DtoC(CTG->CTG_DTINI) + ' a ' + DtoC(CTG->CTG_DTFIM) /*+ " ["+X3COMBO('CTG_STATUS',CTG->CTG_STATUS)+"]"*/,;
		   	   						cCodId3,"","", 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )                  
	            
		  	   	DbSelectArea("CWG")
				CWG->(dbSetOrder(1))	//CWG_FILIAL+ CWG_MOEDA+CWG_CALEND+CWG_PERIOD+CWG_TPSALD                                       
				CWG->(dbSeek(xFilial("CWG")+cCodMoeda+CTG->CTG_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD))
				While CWG->(!Eof()) .And. CWG->(CWG_FILIAL+CWG_MOEDA+CWG_CALEND+CWG_EXERCI+CWG_PERIOD) == xFilial("CWG")+cCodMoeda+CTG->CTG_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD 	
					DbSelectArea('SX5')
					DbSetOrder(1)	// X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_
					If DbSeek( xFilial('SX5') + 'SL' + CWG->CWG_TPSALD )
							cCodId4 := "TPS" +cCodMoeda+CTG->CTG_CALEND+CTG->CTG_EXERC+CTG->CTG_PERIOD+Left(SX5->X5_CHAVE, nTamTps)+StrZero(SX5->(Recno()),nTamRegSx5)                                  
							cCor := CtbLegRes(Left(SX5->X5_CHAVE, nTamTps))							
					  		oTreeCad4:TreeSeek(cCodId3)
					  		cStatus := Iif( Empty(CWG->CWG_STATUS),"",X3Combo("CWG_STATUS",CWG->CWG_STATUS))
		  			  		oTreeCad4:AddItem(Alltrim(SX5->X5_CHAVE)+ " - "+AllTrim(SX5->X5_DESCRI) + " ["+cStatus+"]" ,cCodId4,cCor,cCor, 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )	
					EndIf 										
					CWG->(DbSkip())
				EndDo
				
				CTG->(DbSkip())					
			EndDo 						
		EndIf	 	    
	ElseIf nOpAcao == 4	    
	    
		cCodCalend	:= SubStr(cCodIdPai,nIniCal,nTamCal)
		cCodExerc	:= SubStr(cCodIdPai,nIniExe,nTamExe)
		cCodPeriodo	:= SubStr(cCodIdPai,nIniPer,nTamPer)
		
		//Atualiza a xtree com amarração 
		DbSelectArea('CTG')
		DbSetOrder(1)
		DbSeek( xFilial('CTG')+cCodCalend )                   											       
	  	While CTG->(!Eof()) .And. CTG->CTG_FILIAL == xFilial('CTG') .And. cCodCalend == CTG->CTG_CALEND 		
	  	    If CTG->CTG_PERIOD == cCodPeriodo
		  	   	DbSelectArea("CWG")
				CWG->(dbSetOrder(1))	//CWG_FILIAL+ CWG_MOEDA+CWG_CALEND+CWG_PERIOD+CWG_TPSALD                                       
				CWG->(dbSeek(xFilial("CWG")+cCodMoeda+cCodCalend+cCodExerc+cCodPeriodo))
				While CWG->(!Eof()) .And. CWG->(CWG_FILIAL+CWG_MOEDA+CWG_CALEND+CWG_EXERCI+CWG_PERIOD) == xFilial("CWG")+cCodMoeda+cCodCalend+cCodExerc+cCodPeriodo 	
					DbSelectArea('SX5')
					DbSetOrder(1)	// X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_
					If DbSeek( xFilial('SX5') + 'SL' + CWG->CWG_TPSALD )
							cCodId4 := "TPS" +cCodMoeda+cCodCalend+cCodExerc+cCodPeriodo+Left(SX5->X5_CHAVE, nTamTps)+StrZero(SX5->(Recno()),nTamRegSx5)                                  
							cCor := CtbLegRes(Left(SX5->X5_CHAVE, nTamTps))							
					  		oTreeCad4:TreeSeek(cCodIdPai)
					  		cStatus := Iif( Empty(CWG->CWG_STATUS),"",X3Combo("CWG_STATUS",CWG->CWG_STATUS))
		  			  		oTreeCad4:AddItem(Alltrim(SX5->X5_CHAVE)+ " - "+AllTrim(SX5->X5_DESCRI) + " ["+cStatus+"]" ,cCodId4,cCor,cCor, 2, /*bAction*/,/*bRClick*/,/*bDblClick*/ )	
					EndIf 										
					CWG->(DbSkip())
				EndDo						
			EndIf	 	    
			CTG->(DbSkip())
		EndDo
	EndIf
EndIf

oTreeCad4:PTRefresh()
oTreeCad4:EndUpdate()
oTreeCad4:Show()

RestArea(aArea)

Return()  



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ExcCalend(cCodNo)

Local aArea		:= GetArea()
Local cCodMoeda := SubStr(cCodNo,nIniMoe,nTamMoe)
Local cCalend	:= SubStr(cCodNo,nIniCal,nTamCal) 
Private INCLUI 	:= .F.
Private ALTERA 	:= .F.

If MsgYesNo(STR0062) //"Confirma exclusão da amarração com Moeda?"
	
	dbSelectArea("CTE")
	CTE->(dbSetOrder(1))
	CTE->( DbSeek(xFilial('CTE') + cCodMoeda + cCalend ) )  
	
	If Ctb200TOk()
   		RecLock("CTE", .F.)
		CTE->(DbDelete())
		MsUnLock()
		 
		If ExistBlock("CTB200Del") 
			ExecBlock( "CTB200Del",.F.,.F.,{cCodMoeda, cCalend}) 
		EndIf
	   
   		oTreeCad4:BeginUpdate()
   		If oTreeCad4:TreeSeek(cCodNo)
			oTreeCad4:DelItem()   
		EndIf
		oTreeCad4:EndUpdate()

	Endif
Endif

RestArea(aArea)

Return 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/09/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function CapTpSaldo(cCodIdNo,lTodos)

Local aSaveArea		:= GetArea()
Local aAreaCTE		:= CTE->(GetArea())
Local nOpc 			:= 0  
Local oDlg, oBtnOk, oBtnCn 
Local cCodTpS 		:= " "
Local cCodMoeda		:= SubStr(cCodIdNo,nIniMoe,nTamMoe)
Local cCodCaled		:= SubStr(cCodIdNo,nIniCal,nTamCal)
Local cCodExec		:= SubStr(cCodIdNo,nIniExe,nTamExe)
Local cPeriodo		:= SubStr(cCodIdNo,nIniPer,nTamPer)
Local lOk			:= .F.
Private INCLUI 		:= .T. 
Private ALTERA		:= .F.
Default lTodos		:= .F. 

dbSelectArea("CTE")
CTE->(DbSetOrder(1))
If !MsSeek(xFilial("CTE")+cCodMoeda+cCodCaled) .Or. !SoftLock("CTE")
	Return
EndIf 

DEFINE 	MSDIALOG oDlg FROM  86,1 TO 205,400;
		TITLE STR0063 PIXEL //"Calendário x Tipo de Saldo" 

@ 14, 08 SAY STR0004	SIZE 53, 07 OF oDlg PIXEL //"Tipo de Saldo" 

@ 12, 68 MSGET cCodTpS	SIZE 18, 10 OF oDlg PIXEL Picture "9" ;
		 F3 "SL"	Valid !Empty(cCodTpS) .And. ExistCpo("SX5","SL"+cCodTpS)     

DEFINE 	SBUTTON oBtnOk FROM 07,160 TYPE 1 ENABLE OF oDlg Action (nOpc:=1, oDlg:End())
DEFINE 	SBUTTON oBtnCn FROM 21,160 TYPE 2 ENABLE OF oDlg Action (nOpc:=0, oDlg:End()) 

ACTIVATE MSDIALOG oDlg Centered

If nOpc == 1
	
	DbSelectArea('CTG')
	CTG->(DbSetOrder(1))
	CTG->(DbSeek( xFilial('CTG')+cCodCaled+cCodExec))
	
	DbSelectArea("CWG")
	CWG->(dbSetOrder(1))	//CWG_FILIAL+ CWG_MOEDA+CWG_CALEND+CWG_PERIOD+CWG_TPSALD
	
	If lTodos
		While CTG->(!Eof()) .And. CTG->CTG_FILIAL == xFilial('CTG') .And.  CTG->CTG_CALEND == cCodCaled .And. CTG->CTG_EXERC == cCodExec		    
	 		If CWG->(dbSeek(xFilial("CWG")+cCodMoeda+cCodCaled+cCodExec+CTG->CTG_PERIOD+cCodTpS))		    
	        	Alert(STR0064+CTG->CTG_PERIOD+STR0065)//"Tipo de saldo já encontrado para o periodo " //". Sistema continuará a gravação para os demais periodos."
	        Else
	        	RecLock("CWG", .T.)
				CWG->CWG_FILIAL	:= xFilial("CWG")
				CWG->CWG_MOEDA	:= cCodMoeda
				CWG->CWG_CALEND	:= cCodCaled
				CWG->CWG_EXERCI	:= cCodExec
				CWG->CWG_PERIOD	:= CTG->CTG_PERIOD
				CWG->CWG_TPSALD	:= cCodTpS
				CWG->CWG_STATUS	:= CriaVar("CWG_STATUS")
				MsUnLock()
				lOK := .T.   
	        EndIf
			CTG->(dbSkip())
		EndDo    
		
		//Atualiza somente o calendário
		If lOK
			Ct011AtAmarr(3,cCodIdNo)
		EndIf 
	Else
		If CWG->(dbSeek(xFilial("CWG")+cCodMoeda+cCodCaled+cCodExec+cPeriodo+cCodTpS))		    
			Alert(STR0064+CTG->CTG_PERIOD+".")//"Tipo de saldo já encontrado para o periodo "
	  	Else
	   		RecLock("CWG", .T.)
			CWG->CWG_FILIAL	:= xFilial("CWG")
			CWG->CWG_MOEDA	:= cCodMoeda
			CWG->CWG_CALEND	:= cCodCaled
			CWG->CWG_EXERCI	:= cCodExec
			CWG->CWG_PERIOD	:= cPeriodo
			CWG->CWG_TPSALD	:= cCodTpS	
			CWG->CWG_STATUS	:= CriaVar("CWG_STATUS")
			MsUnLock()

			Ct011AtAmarr(4,cCodIdNo)
		EndIf
	EndIf
	
	RestArea(aSaveArea)
	
EndIf

CTE->(MsUnLock())
RestArea(aAreaCTE)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function ExcTpSaldo(cCodNo)

Local aArea		:= GetArea()
Local cCodMoeda := SubStr(cCodNo,nIniMoe,nTamMoe)
Local cCalend	:= SubStr(cCodNo,nIniCal,nTamCal)
Local cCodExec	:= SubStr(cCodNo,nIniExe,nTamExe)
Local cPeriodo	:= SubStr(cCodNo,nIniPer,nTamPer)
Local cTpSaldo	:= SubStr(cCodNo,nIniTps,nTamTps)
Local lExclui	:= .T. 
Local cFiltro := ""

If MsgYesNo(STR0066) //"Confirma exclusão da amarração com este Período do Calendário?"
	    
	dbSelectArea("CTG")
	CTG->(dbSetOrder(1))
	If CTG->(dbSeek(xFilial("CTG")+cCalend+cCodExec+cPeriodo))
		// Verifica se existem laçamentos contábeis para o período a ser excluído
		cFiltro := "CQ1_TPSALD = '"+cTpSaldo+"'"
		IF ExiSalCQ("CTG",cFiltro,CTG->CTG_DTINI,CTG->CTG_DTFIM,/*cConta*/,/*cCC*/,/*cItem*/,/*cClasse*/)
			Help(" ",1,"EXISTELAN")
			lExclui := .F.
		EndIf
	EndIf
		
	If lExclui
		dbSelectArea("CWG")
		CWG->(dbSetOrder(1))
		If CWG->( DbSeek(xFilial('CWG') + cCodMoeda + cCalend + cCodExec + cPeriodo + cTpSaldo ))  
	   		RecLock("CWG", .F.)
			CWG->(DbDelete())
			MsUnLock()
			 		   
	   		oTreeCad4:BeginUpdate()
	   		If oTreeCad4:TreeSeek(cCodNo)
				oTreeCad4:DelItem()   
			EndIf
			oTreeCad4:EndUpdate()		
		EndIf
	EndIf
Endif

RestArea(aArea)

Return 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/10/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function StsTpSaldo(cCodNo)

Local aArea		:= GetArea()
Local cCodMoeda := SubStr(cCodNo,nIniMoe,nTamMoe)
Local cCalend	:= SubStr(cCodNo,nIniCal,nTamCal)
Local cCodExec	:= SubStr(cCodNo,nIniExe,nTamExe)
Local cPeriodo	:= SubStr(cCodNo,nIniPer,nTamPer)
Local cTpSaldo	:= SubStr(cCodNo,nIniTps,nTamTps)
Local cStatus	:= ""
Local cDesStatus:= ""

dbSelectArea("CWG")
CWG->(dbSetOrder(1))
CWG->( DbSeek(xFilial('CWG') + cCodMoeda + cCalend + cCodExec+ cPeriodo + cTpSaldo ))  

cStatus := CWG->CWG_STATUS	

If cStatus == "1" 
	If MsgYesNo(STR0067) //"Confirma o bloqueio do Tipo de Saldo?"	
		If !(cTpSaldo $ "09") //Validar tipo de saldo 0 - Orcado, 9 - Previsto
	   		RecLock("CWG", .F.)
			CWG->CWG_STATUS := "4"
			MsUnLock()
			 		   	   		
	   		DbSelectArea('SX5')
			DbSetOrder(1)	// X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_
			If DbSeek( xFilial('SX5') + 'SL' + cTpSaldo )
	   			cDesStatus := Iif( Empty(CWG->CWG_STATUS),"",X3Combo("CWG_STATUS",CWG->CWG_STATUS))
	   			oTreeCad4:BeginUpdate()
				oTreeCad4:ChangePrompt( Alltrim(SX5->X5_CHAVE)+ " - "+AllTrim(SX5->X5_DESCRI) + " ["+cDesStatus+"]", cCodNo )
				oTreeCad4:EndUpdate()
			EndIf
		Else
			MsgAlert(STR0069)
		Endif
	Endif

ElseIf cStatus == "4"
	If MsgYesNo(STR0068)//"Confirma a abertura do Tipo de Saldo?"	
		If !(cTpSaldo $ "09") //Validar tipo de saldo 0 - Orcado, 9 - Previsto
	   		RecLock("CWG", .F.)
			CWG->CWG_STATUS := "1"
			MsUnLock()
			 		   
	   		DbSelectArea('SX5')
			DbSetOrder(1)	// X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_
			If DbSeek( xFilial('SX5') + 'SL' + cTpSaldo )
	   			cDesStatus := Iif( Empty(CWG->CWG_STATUS),"",X3Combo("CWG_STATUS",CWG->CWG_STATUS))
	   			oTreeCad4:BeginUpdate()
				oTreeCad4:ChangePrompt( Alltrim(SX5->X5_CHAVE)+ " - "+AllTrim(SX5->X5_DESCRI) + " ["+cDesStatus+"]", cCodNo )
				oTreeCad4:EndUpdate()
			EndIf
		Else
	   		MsgAlert(STR0069)
		Endif
	Endif
Else
	MsgAlert(STR0069) //"Tipo de Saldo não pode ter alteração de status."
EndIf

RestArea(aArea)

Return 



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/14/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function PesqCad4(cCodIdNo)

Local aSaveArea		:= GetArea()
Local oDlg, oBtnOk, oBtnCn 
Local cCodMoeda		:= Space(nTamMoe)
Local cCodCaled		:= Space(nTamCal)
Local cPeriodo		:= Space(nTamPer)
Local cExerc		:= Space(nTamExe)
Local cCodTpS 		:= Space(nTamTps)
Local nPosAtu
Local nPosPeq


DEFINE 	MSDIALOG oDlg FROM  86,1 TO 240,400;
		TITLE STR0070  PIXEL 

@ 10, 08 SAY STR0002	SIZE 53, 07 OF oDlg PIXEL //"Moeda" 
@  8, 68 MSGET cCodMoeda		SIZE 18, 10 OF oDlg PIXEL Picture PesqPict("CWG","CWG_MOEDA") 

@ 24, 08 SAY STR0003	SIZE 53, 07 OF oDlg PIXEL //"Calendário" 
@ 22, 68 MSGET cCodCaled		SIZE 18, 10 OF oDlg PIXEL Picture PesqPict("CWG","CWG_CALEND")

@ 38, 08 SAY STR0071	SIZE 53, 07 OF oDlg PIXEL //"Exercício" 
@ 36, 68 MSGET cExerc			SIZE 18, 10 OF oDlg PIXEL Picture PesqPict("CWG","CWG_EXERCI") 

@ 52, 08 SAY STR0072	SIZE 53, 07 OF oDlg PIXEL //"Período" 
@ 50, 68 MSGET cPeriodo			SIZE 18, 10 OF oDlg PIXEL Picture PesqPict("CWG","CWG_PERIOD") 

@ 66, 08 SAY STR0004	SIZE 53, 07 OF oDlg PIXEL //"Tipo de Saldo" 
@ 64, 68 MSGET cCodTpS			SIZE 18, 10 OF oDlg PIXEL Picture PesqPict("CWG","CWG_TPSALD")
 

DEFINE 	SBUTTON oBtnOk FROM 07,160 TYPE 1 ENABLE OF oDlg Action (nOpc:=1, oDlg:End())
DEFINE 	SBUTTON oBtnCn FROM 21,160 TYPE 2 ENABLE OF oDlg Action (nOpc:=0, oDlg:End()) 

ACTIVATE MSDIALOG oDlg Centered


nPosAtu := Ascan(oTreeCad4:aCargo, { |x| x[1] == cCodIdNo} ) 
nPosPeq := Ascan(oTreeCad4:aCargo, { |x| 	IIf(!Empty(cCodMoeda),SubStr(x[1],nIniMoe,nTamMoe),"")+;
											IIf(!Empty(cCodCaled),SubStr(x[1],nIniCal,nTamCal),"")+; 
											IIf(!Empty(cExerc),SubStr(x[1],nIniExe,nTamExe),"")+;
											IIf(!Empty(cPeriodo),SubStr(x[1],nIniPer,nTamPer),"")+;
											IIf(!Empty(cCodTpS),SubStr(x[1],nIniTps,nTamTps),"") ==;
											IIf(!Empty(cCodMoeda),cCodMoeda,"")+;
											IIf(!Empty(cCodCaled),cCodCaled,"")+;
											IIf(!Empty(cExerc),cExerc,"")+;
											IIf(!Empty(cPeriodo),cPeriodo,"")+;
											IIf(!Empty(cCodTpS),cCodTpS,"")},;
											nPosAtu+1) 

If nPosPeq > 0 
	oTreeCad4:TreeSeek(oTreeCad4:aCargo[nPosPeq,1]) 
Else
	MsgInfo(STR0073)//"Objeto de pesquisa não encontrado. Para pequisar na árvore inteira posicione no primeiro registro."
EndIf


RestArea(aSaveArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT11WzTela ºAutor  ³TOTVS               º Data ³  27/10/11    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Tela de inicializacao do assistente                          º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CT11WzTela(oDlg) 

Local aX3Moed 	:= SX3Inf("CTE_MOEDA")
Local aX3Cale 	:= SX3Inf("CTE_CALEND")
Local cVar     	:= Nil
Local lMark    	:= .F.
Local oOk      	:= LoadBitmap( GetResources(), "LBOK" )   //CHECKED    //LBOK  //LBTIK
Local oNo      	:= LoadBitmap( GetResources(), "LBNO" ) //UNCHECKED  //LBNO
Local oChk     	:= Nil

Private lChk     	:= .F.
Private oLbx 		:= Nil
Private aVetor 		:= {} 
Private oWizard, oPanel

RegToMemory("CTE",.F.)

M->CTE_MOEDA 	:= Space(aX3Moed[2])
M->CTE_CALEND 	:= Space(aX3Cale[2])

SX5->( DbSetOrder(1) )                 
SX5->( DbSeek( xFilial('SX5') + 'SL'))
While SX5->(!Eof()) .And. SX5->X5_FILIAL = xFilial("SX5") .And. SX5->X5_TABELA = "SL" 
	aAdd( aVetor, { lMark, CtbLegRes(Left(SX5->X5_CHAVE, 1)), SX5->X5_CHAVE, SX5->X5_DESCRI })                               					            					
	SX5->(DbSkip()) 	
EndDo

DEFINE WIZARD oWizard TITLE STR0074 ; //"Amarração Moeda x Calendário x Tipo de Saldo"
       HEADER STR0075 ;   //"Wizard de Amarração Moeda x Calendário x Tipo de Saldo."
       MESSAGE "" ;
    	TEXT STR0076 ; //"Este assistente irá auxilia-lo no montagem da amarração Moeda x Calendário x Tipo de Saldo"
	   	NEXT {|| .T. } ;
		FINISH {|| .T. } ;
		PANEL 
		oPanel := oWizard:GetPanel(1)
             
   		CREATE PANEL oWizard ;
     	HEADER STR0075 ; //"Wizard de Amarração Moeda x Calendário x Tipo de Saldo." 
        MESSAGE STR0078 ; //"Informe a Moeda que deseja criar a Amarração"
        BACK {|| .T.  } ;
        NEXT {|| !Empty(M->CTE_MOEDA) } ;
        FINISH {|| .F. } ;
       	PANEL
       	oPanel := oWizard:GetPanel(2)
       	@ 25,40 SAY STR0002+"*" SIZE 30,8 PIXEL OF oPanel COLOR CLR_BLUE  //"Moeda"
   	 	@ 22,75 MSGET M->CTE_MOEDA PICTURE aX3Moed[3] F3 aX3Moed[4] VALID AmMoeCal(M->CTE_MOEDA,M->CTE_CALEND) .Or. &(aX3Moed[5]) SIZE 20,10 PIXEL OF oPanel

       	    
 		CREATE PANEL oWizard ;
   		HEADER STR0075 ;//"Wizard de Amarração Moeda x Calendário x Tipo de Saldo." 
        MESSAGE STR0077 ;     //"Informe a Calendário que deseja criar a Amarração"
        BACK {|| .T. } ;
        NEXT {|| !Empty(M->CTE_CALEND)  } ;
        FINISH {|| .T. } ;
        PANEL 
   		oPanel := oWizard:GetPanel(3)
	    @ 25,40 SAY STR0003+"*" SIZE 30,8 PIXEL OF oPanel COLOR CLR_BLUE  //"Calendário"
   	 	@ 22,75 MSGET M->CTE_CALEND PICTURE aX3Cale[3] F3 aX3Cale[4] VALID Vazio() .Or. AmMoeCal(M->CTE_MOEDA,M->CTE_CALEND) .Or. &(aX3Cale[5]) SIZE 20,10 PIXEL OF oPanel 
   	   	@ 40,75 BUTTON STR0045 SIZE 20,10 OF oPanel PIXEL ACTION  {||M->CTE_CALEND := CTB010WIZ(.T.,,)} //Incluir	 

   	 	
   	 	CREATE PANEL oWizard ;
   		HEADER STR0075 ;//"Wizard de Amarração Moeda x Calendário x Tipo de Saldo." 
        MESSAGE STR0079 ;//"Selecione os Tipos de Saldo para finalizar a Amarração" 
        BACK {|| .T. } ;
        NEXT {|| .T. } ;
        FINISH {|| Ctb11Grv(M->CTE_MOEDA,M->CTE_CALEND,aVetor) } ;
        EXEC {|| .T. };
        PANEL 
   		oPanel := oWizard:GetPanel(4)
	    
	    @ 10,10 LISTBOX oLbx VAR cVar FIELDS HEADER ;
   		" ", STR0080,STR0081, STR0047; //"Leg." //"Tipo" //"Descrição"
   		SIZE 230,095 OF oPanel PIXEL ON dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1],oLbx:Refresh())

		oLbx:SetArray( aVetor )
		oLbx:bLine := {|| {Iif(aVetor[oLbx:nAt,1],oOk,oNo),;
                       LoadBitmap( GetResources(), aVetor[oLbx:nAt,2]),;
                       aVetor[oLbx:nAt,3],;
                       aVetor[oLbx:nAt,4]}}
	    
	    @ 110,10 CHECKBOX oChk VAR lChk PROMPT STR0082 SIZE 60,007 PIXEL OF oPanel ; //"Marca/Desmarca"
         ON CLICK(aEval(aVetor,{|x| x[1]:=lChk}),oLbx:Refresh())
	    	  	
		
ACTIVATE WIZARD oWizard CENTERED

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/15/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function AmMoeCal(cCodMoeda,cCalend)

Local aArea := GetArea()
Local lRet := .F.

dbSelectArea("CTE")
CTE->(dbSetOrder(1))
If CTE->( DbSeek(xFilial('CTE') + cCodMoeda + cCalend ) )  
	lRet := .T.
EndIf
           
RestArea(aArea)

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/15/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Ctb11Grv(cCodMoeda,cCalend,aTpSld)
      
Local aArea	:= GetArea()
Local lRet	:= .T. 
Local nX

//Valida e Grava amarração Moeda x Calendário
dbSelectArea("CTE")
CTE->(dbSetOrder(1))
If CTE->( !DbSeek(xFilial('CTE') + cCodMoeda + cCalend ) )  
	If Ctb200TOK()  //se tudo ok grava a amarracao de moeda x calendario 
		RecLock("CTE", .T.)
		CTE->CTE_FILIAL	:= xFilial("CTE")
		CTE->CTE_MOEDA	:= cCodMoeda
		CTE->CTE_CALEND	:= cCalend
		MsUnLock()
	
		// ponto de entrada para depois da gravacao	
		If ExistBlock("CTB200Inc") 
			ExecBlock( "CTB200Inc",.F.,.F.,{cCodMoeda, cCalend}) 
		EndIf
    Else
    	lRet := .F.
    EndIf
EndIf

//Valida e Grava amarração Moeda x Calendário (Periodo) x Tipo de Saldo
If lRet		
	For nX := 1 To Len(aTpSld)	
		If aTpSld[nX,1]
			DbSelectArea('CTG')
			CTG->(DbSetOrder(1))
			CTG->(DbSeek( xFilial('CTG')+cCalend))
	
			DbSelectArea("CWG")
			CWG->(dbSetOrder(1))	//CWG_FILIAL+ CWG_MOEDA+CWG_CALEND+CWG_PERIOD+CWG_TPSALD
			
			While CTG->(!Eof()) .And. CTG->CTG_FILIAL == xFilial('CTG') .And.  CTG->CTG_CALEND == cCalend 		    
				If CWG->(dbSeek(xFilial("CWG")+cCodMoeda+cCalend+CTG->CTG_EXERC+CTG->CTG_PERIOD+aTpSld[nX,3]))		    
					MsgAlert(STR0004 + " "+AllTrim(aTpSld[nX,3])+STR0083+CTG->CTG_PERIOD+STR0084)//"Tipo de saldo "//" já encontrado para o periodo " //". Sistema continuará a gravação para os demais periodos."
			  	Else
			   		RecLock("CWG", .T.)
					CWG->CWG_FILIAL	:= xFilial("CWG")
					CWG->CWG_MOEDA	:= cCodMoeda
					CWG->CWG_CALEND	:= cCalend
					CWG->CWG_EXERCI	:= CTG->CTG_EXERC	
					CWG->CWG_PERIOD	:= CTG->CTG_PERIOD
					CWG->CWG_TPSALD	:= aTpSld[nX,3]
					CWG->CWG_STATUS	:= CriaVar("CWG_STATUS")	
					MsUnLock()
			  	EndIf
				CTG->(dbSkip())
			EndDo    
		EndIf
	Next
	
	Ctba011AtMoe(1) //Atualiza Painel Moeda e Amarração 
	Ctba011AtCal()	//Atualiza Painél Calendário 
	Ctba011AtTp() 	//Atualiza painel Tipo de Saldo
EndIf

RestArea(aArea)

Return lRet  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/15/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function AmTpSaldo(cTpSaldo)

Local aArea 	:= GetArea()
Local aAreaCWG  := CWG->(GetArea())
Local lRet 		:= .F.

DbSelectArea("CWG")
CWG->(dbSetOrder(2))	//CWG_FILIAL+CWG_TPSALD+CWG_MOEDA+CWG_CALEND+CWG_PERIOD                                       
If CWG->(dbSeek(xFilial("CWG")+cTpSaldo))
	lRet := .T.
EndIf

RestArea(aAreaCWG)           
RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA011   ºAutor  ³Microsiga           º Data ³  01/15/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function VldMoeCal(cMoeda,cCalend)

Local aArea 	:= GetArea()
Local aAreaCWG  := CWG->(GetArea())
Local lRet 		:= .F.

DbSelectArea("CWG")
CWG->(dbSetOrder(1))	//CWG_FILIAL+CWG_TPSALD+CWG_MOEDA+CWG_CALEND+CWG_PERIOD                                       
If CWG->(dbSeek(xFilial("CWG")+cMoeda+cCalend))
	lRet := .T.
EndIf

RestArea(aAreaCWG)           
RestArea(aArea)

Return lRet


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ctba011Blc
Funcao que chama a tela do bloquei do processo

@author   Mayara Alves	 
@version   12
@since     18/03/15

/*/
//------------------------------------------------------------------------------------------
Static Function Ctba011Blc()
Local lIncCT12:= INCLUI
Local lAltCT12:= ALTERA

//Forca variaveis para a tela abrir como alteracao
INCLUI:=.F.
ALTERA:=.T.

//Chama a tela de Bloqueio de Processo
CTBA012("CTG",CTG->(Recno()),6)

//Volta o conteudo das variaveis
INCLUI:=lIncCT12
ALTERA:=lAltCT12
			
Return	