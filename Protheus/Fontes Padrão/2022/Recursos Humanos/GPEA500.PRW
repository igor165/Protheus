#INCLUDE "PROTHEUS.CH"
#INCLUDE "GPEA500.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออหออออออัออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณGPEA500   บAutor  ณNatie                  บ Data ณ  21/09/07            บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออสออออออฯออออออออออออออออออออออนฑฑ
ฑฑบDesc.     ณRotina de Cadastro Padrao de Periodos                                   บฑฑ
ฑฑบ          ณ                                                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGenerico                                                                บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณProgramador ณ Data   ณ FNC            ณ  Motivo da Alteracao                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณMohanad Odehณ13/03/13ณM12RH01   RQ2002ณUnifocacao dos fontes V12                   ณฑฑ
ฑฑณ            ณ        ณ                ณLiberacao da rotina para todos os paises    ณฑฑ  
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function GPEA500(nOpcAuto)
Local aAreaRG5		:= RG5->( GetArea() )
Local aIndexRG5		:= {}
Local cFiltraRG5	:= ""

Local bBlock
Local nPos

PRIVATE aRotina 	:= MenuDef() 					//-- ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
Private bFiltraBrw	:= { || NIL }
Private cCadastro	:= OemToAnsi(STR0009)			//-- Padrao de Periodos  
Private	lF3Criter	:= .F.                          // variแvel que verifica se a chamada da consulta do crit้rio foi efetuada a partir do F3 ou nใo

Begin Sequence
	
	IF ( nOpcAuto <> NIL )
	
		aRotSetOpc( "RG5" , NIL , nOpcAuto , .F. )
		nPos := aScan( aRotina , { |x| x[4] == nOpcAuto } )
		IF ( nPos == 0 )
			Break
		EndIF
		dbSelectArea( "RG5" )
		bBlock := &( "{ |a,b,c,d| " + aRotina[ nPos , 2 ] + "(a,b,c,d) }" )
		Eval( bBlock , "RG5" , RG5->( Recno() ) , nPos )
	Else
 
		/*/
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	  	ณ Inicializa o filtro utilizando a funcao FilBrowse                      ณ
     	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
		cFiltraRh	:= Chkrh( "GPEA500" , "RG5" , "1" )
		bFiltraBrw 	:= { || FilBrowse( "RG5" , @aIndexRG5 , @cFiltraRH ) }
		Eval( bFiltraBrw )
	
		/*/
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณ Endereca a funcao de BROWSE                                  ณ
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
		dbSelectArea("RG5")     
		mBrowse( 006 , 001 , 022 , 075 , "RG5"  )
	
		/*/
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณ Deleta o filtro utilizando a funcao FilBrowse                     	 ณ
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
		EndFilBrw("RG5",aIndexRG5)

    EndIF

End Sequence

RestArea( aAreaRG5 )
	
Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPEA500   บAutor  ณNatie               บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMantencao do cad. Padrao de periodos                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MP 10                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GpeA500Atu( cAlias , nReg , nOpcX , aObjSize , oDlg )

Local aArea				:= GetArea()
Local aSvKeys			:= GetKeys()
Local aButtons			:= {}
Local bSet15			:= { || NIL }
Local bSet24			:= { || NIL }

Local oFont				:= NIL
Local oGroup			:= NIL	

Local cQuery			:= ""
Local nOpcA				:= 0
Local nLenRG5			:= 0 			//-- var. de controle 
Local nX				:= 0 			//-- var. de controle  
Local nPosRec			:= 0 

Local cFilRG5			:= If(nOpcx=3, xFilial("RG5"), RG5->RG5_FILIAL) 
Local cPdperiodo		:= If(nOpcx=3 ," " , RG5->RG5_PDPERI ) 
Local cKeySeek 	 		:= ""
Local bKey				:= { || NIL }

/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Variaveis de dimensionamento da tela                		   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
Local aAdvSize			:= {}
Local aInfoAdvSize		:= {}
Local aObjCoords		:= {}
Local aPos				:= {}

Local nUsado			:= 0
	
Private nOpcX1			:= nOpcx

/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Variaveis da enchoice                               		   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
Private aColsRG5		:= {}				//-- aCols do Cad.padrao Peridos - Cabecalho 
Private aSvColsRG5		:= {}				//-- 
Private aEnchoiceRG5 	:= {} 				//-- Enchoice 
Private aRG5VirtChoice  := {}				//-- Campos Virtuais 
Private aRG5Visual		:= {}				//-- Campos Visuais 
Private aFields			:= {}				//-- Campos Editaveis 
Private aAltera			:= {} 				//-- Campos alteraveis
Private aNaoAltera		:= {} 				//-- Campos nao alteraveis
Private oEnchoiceRG5	


/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Variaveis da GetDados                              		   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
Private aColsRG6		:= {} 				//-- aCols do RG6 
Private aHeaderRG6		:= {} 				//-- aHeader do RG6
Private aRG6Virtual   	:= {} 				//-- Campos Vistuais 
Private aRG6Visual  	:= {} 				//-- Campos Visuais
Private aRG6Recnos		:= {} 				//-- Recnos 
Private aNotFields		:= {} 				//-- Campos que nใo constarใo no aHeader
Private oGetRG6

Private nOpcNewGd			:= IF( (  nOpcx == 2  .or.  nOpcx == 5  ) , 0 , GD_INSERT + GD_UPDATE + GD_DELETE )

Begin Sequence
    
	
	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Na Inclusao Coloca o Ponteiro dos arquivos RG5 e RG6 em Eof  ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	IF ( nOpcx == 3 )
		PutFileInEof( "RG5" )
		PutFileInEof( "RG6" , @nReg)
	EndIF
	

	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Monta os Dados para a Enchoice							   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	aColsRG5	:= RG5->( GdMontaCols( @aEnchoiceRG5 , NIL , @aRG5VirtChoice , @aRG5Visual , "RG5" , { "RG5_FILIAL" } , NIL , "RG5" ) )
	aSvColsRG5	:= aClone( aColsRG5 )

	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Cria as Variaveis de Memoria e Carrega os Dados Conforme o arณ
	ณ quivo														   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	nLenRG5 := Len( aEnchoiceRG5 )
	For nX := 1 To nLenRG5
		aAdd( aFields , aEnchoiceRG5[ nX , 02 ] )
		Private &( "M->"+aEnchoiceRG5[ nX , 02 ] ) := aColsRG5[ 01 , nX ]
	Next Nx
	
	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Verifica se Pode Excluir o Padrao                            ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
	IF ( nOpcX== 5 )
		IF !( Gp500DelChk( "RG5", nReg , nOpcX , GetMemVar( "RG5_PDPERI" )  ) ) 
			Break
		EndIF
	EndIF

	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณDefine os Campos Editaveis na Enchoice Apenas na Inclusao( 3 )ณ
	ณou Alteracao(4)											   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	If nOpcX == 4 .or. nOpcX == 3
		/*/
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณ Define os Campos Editaveis								   ณ
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
		nLenRG5 := Len( aRG5Visual )
		For nX := 1 To nLenRG5
			aAdd( aNaoAltera , aRG5Visual[ nX ] )
		Next nX

		If nOpcX == 4
			aAdd( aNaoAltera , "RG5_PDPERI")
			aAdd( aNaoAltera , "RG5_DESCR" )
		Endif 	
	
		nLenRG5 := Len( aFields )
		For nX := 1 To nLenRG5
			IF ( aScan( aNaoAltera , { |cNaoA| cNaoA == aFields[ nX ] } ) == 0 )
				aAdd( aAltera , aFields[ nX ] )
			EndIF
		Next nX
	Endif

	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Monta os Dados para a GetDados							   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	aAdd( aNotFields , "RG6_FILIAL")
	aAdd( aNotFields , "RG6_PDPERI")
	aAdd( aNotFields , "RG6_DESCRI" )

	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Monta Query para a Selecao das Informacoes em GdMontaCols    ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	#IFDEF TOP 
		cQuery 	:= "RG6_FILIAL='"  + cFilRG5    + "' " 
		cQuery 	+= " AND "
		cQuery 	+= "RG6_PDPERI='"  + cPdperiodo + "' "  
		cQuery 	+= " AND "
		cQuery 	+= "D_E_L_E_T_=' ' " 
	#ENDIF 
	
	DbSelectArea( "RG6" )
	DbSetOrder( RetOrder( "RG6", "RG6_FILIAL + RG6_PDPERI") )
	If nOpcx <> 3
		cKeySeek	:= (cFilRG5 + cPdperiodo )
		bKey		:= { |cKey| RG6->(RG6_FILIAL+RG6_PDPERI)   == cKeySeek  } 
	Endif 
	aColsRG6 := RG6->( GdMontaCols(@aHeaderRG6 		,;	// 01 -> Array com os Campos do Cabecalho da GetDados
								 @nUsado 		,;	// 02 -> Numero de Campos em Uso
								 @aRG6Virtual 	,;	// 03 -> [@]Array com os Campos Virtuais
								 @aRG6Visual 	,;	// 04 -> [@]Array com os Campos Visuais
								 NIL			,;	// 05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
								 aNotFields 	,;	// 06 -> Opcional, Campos que nao Deverao constar no aHeader
								 @aRG6Recnos 	,;	// 07 -> [@]Array unidimensional contendo os Recnos
								 "RG5"			,;	// 08 -> Alias do Arquivo Pai
								 cKeySeek		,;	// 09 -> Chave para o Posicionamento no Alias Filho
								 bKey			,;	// 10 -> Bloco para condicao de Loop While
								 NIL 			,;	// 11 -> Bloco para Skip no Loop While
								 NIL			,;	// 12 -> Se Havera o Elemento de Delecao no aCols 
								 NIL			,;	// 13 -> Se cria variaveis Publicas
								 NIL			,;	// 14 -> Se Sera considerado o Inicializador Padrao
								 NIL			,;	// 15 -> Lado para o inicializador padrao
								 NIL			,;	// 16 -> Opcional, Carregar Todos os Campos
								 NIL			,;	// 17 -> Opcional, Nao Carregar os Campos Virtuais
								 cQuery			,;	// 18 -> Opcional, Utilizacao de Query para Selecao de Dados
								 NIL			,;	// 19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP ) - utilizado com o parametro 10
								 .T.			,;	// 20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP ) - utilizado com o parametro 11
								 .F.			,;	// 21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
								 NIL			,;	// 22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
								 NIL			,;	// 23 -> Verifica se Deve Checar se o campo eh usado
								 NIL			,;	// 24 -> Verifica se Deve Checar o nivel do usuario
								 NIL			,;	// 25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
								 NIL			,;	// 26 -> [@]Array que contera as chaves conforme recnos
								 NIL			,;	// 27 -> [@]Se devera efetuar o Lock dos Registros
								 NIL			,;	// 28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
						         NIL			,;	// 29 -> Numero maximo de Locks a ser efetuado
								 .F.			 ;	// 30 -> Utiliza Numeracao na GhostCol
							     ) )
							     
	aSvRG6Cols := aClone( aColsRG6 )

		/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Cria as Variaveis de Memoria e Carrega os Dados Conforme o arณ
	ณ quivo														   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	nLenRG6 := Len( aHeaderRG6 )
	For nX := 1 To nLenRG6
		Private &( "M->"+aHeaderRG6[ nX , 02 ] ) := aColsRG6[ 01 , nX ]
	Next Nx
	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Monta as Dimensoes dos Objetos         					   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 030 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	aPos := {aObjSize[1,1],aObjSize[1,2],aObjSize[1,3],aObjSize[1,4]}

	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Monta o Dialogo Principal                                    ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0009 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

		oEnchoiceRG5	:= MsmGet():New( "RG5" ,;
		                                  nReg  ,;
		                                  nOpcx ,;
		                                  NIL   ,;
		                                  NIL   ,;
		                                  NIL   ,;
		                                  aFields, ;
		                                  aPos , ;
		                                  aAltera , ;
		                                  NIL   ,;
		                                  NIL   ,; 
		                                  NIL   ,;
		                                  oDlg  ,;
		                                  NIL   ,;
		                                  .F. )
                      
	  	oGetRG6 := MsNewGetDados():New(aObjSize[2,1],;	// nTop
									 aObjSize[2,2]	,;  // nLelft
									 aObjSize[2,3]	,;	// nBottom
		                             aObjSize[2,4]	,;	// nRright
									 nOpcNewGd      ,;  // controle do que podera ser realizado na GetDado - nstyle
									 "Gpea500LinOk"	,;	// funcao para validar a edicao da linha - ulinhaOK
									 "Gpea500TudoOk",;	// funcao para validar todas os registros da GetDados - uTudoOK
	  								 NIL			,;	// cIniCPOS
									 NIL			,;	// aAlter
									 0				,; 	// nfreeze
									 99999			,;  // nMax
									 NIL			,;	// cFieldOK
									 NIL			,;	// usuperdel
									 If(nOpcx=2 .Or. nOpcx=5,.F.,.T.),;		// udelOK
									 @oDlg			,; 	// objeto de dialogo - oWnd
									 @aHeaderRG6    ,;	// Vetor com Colunas - AparHeader
									 @aColsRG6		;	// Vetor com Header - AparCols
									)
		oGetRG6:Refresh()
		nPosRec:=GdfieldPos("RG6_REC_WT",oGetRG6:aHeader)
		
		/*/
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณ Define o Bloco para o Botao Confirma           			   ณ
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
		bSet15		:= { ||IF( Obrigatorio( oEnchoiceRG5:aGets , oEnchoiceRG5:aTela ).AND. EnchoTudOk( oEnchoiceRG5 ) .and. oGetRG6:TudoOk() ,  ; 
   		                                    ( nOpcA := 1.00 , oDlg:End() ) , ;
   		                                    ( nOpcA := 0.00 , .F. ) ;
   		                 ) }
        	
		/*/
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณ Define o Bloco para o Botao Cancela            			   ณ
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
		bSet24	:= {|| nOpcA:=0 , oDlg:End()}
		  
		ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 , NIL ) CENTERED 

	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณQuando Confirmada a Opcao e Nao for Visualizacao Grava ou   Exณ
	ณclui as Informacoes             							   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
	IF ( ( nOpcA = 1 .and. nOpcX!= 2 ) .or. ( nOpcX == 5 ) )
		Gpea500GvTudOk(	nOpcX,;
						nReg			,;
						aColsRG5		,;
						aEnchoiceRG5	,;
						aRG5VirtChoice 	,;
						aSvRG6Cols		,;
						nPosRec    )
							
						
					
	EndIF

End Sequence 

RestArea( aArea )
Return( )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGpea500GvTudOk   บAutor  ณMicrosiga           บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua grava็oes dos dados                                        บฑฑ
ฑฑบ          ณ                                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function  Gpea500GvTudOk(nOpc            ,;
                                nReg  		    ,;
								aColsRG5		,;
								aEnchoiceRG5	,;
								aRG5VirtChoice 	,;
								aSvRG6Cols		,;
								nPosRec	    )
								
Local cKey		:= ""
Local nX		:= 0 
Local nY		:= 0         
Local nZ		:= 0 
Local nChoices 	:= Len(aEnchoiceRG5) 
Local lGravouOk := .F. 
Local lTravou 	:= .F. 
Local nMaxArray	:= Len(oGetRG6:aHeader)
Local nPosCrit	:= GdFieldPos("RG6_CRITER",oGetRG6:aHeader) 
Local nPosSeq	:= GdFieldPos("RG6_SEQUE" ,oGetRG6:aHeader)     

/* 
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Se for Exclusao ( nOpc == 5 )								   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
IF ( nOpc == 5 )
	Begin Transaction
		IF !Empty( nReg )
			RG5->( dbGoto( nReg ) )
			cKey	:= 	RG5->(RG5_FILIAL + RG5_PDPERI) 
			RecLock( "RG5" , .F. , .F. )
			If fDeletaItens(cKey)
				RG5->( dbDelete() )
			Endif 
			RG5->( MsUnLock() )
		Endif
	End Transaction
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Se for Inclusao/Alteracao ( nOpc == 3 .or. nOpc == 4 )	   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Else
	For nX := 1 To nChoices
		aColsRG5[ 01, nX ] := &( "M->"+aEnchoiceRG5[ nX, 02 ] )
	Next nX
	
	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Verifica se houve alteracao                                  ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	If nOpc == 4 .and. fCompArray(aColsRG5, aSvColsRG5) .and. ; 
	   fCompArray( oGetRG6:aCols, aSvRG6Cols)
		Return (lGravouOk) 
	Endif 

	Begin Transaction
	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Grava Enchoice - Padrao de Calendario                        ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/

	IF !Empty( nReg )				//-- ALTERACAO 
		RG5->( dbGoto( nReg ) )
		RecLock( "RG5" , .F. , .F. )
	Else							//-- INCLUSAO 
		RecLock( "RG5" , .T. , .F. )
		RG5->RG5_FILIAL := xFilial( "RG5" )
	EndIF

	For nX := 1 To nChoices
		IF ( aScan( aRG5VirtChoice  , { |cCpo| ( cCpo == aEnchoiceRG5[ nX , 02 ] ) } ) == 0.00 )
			RG5->( &( aEnchoiceRG5[ nX , 02 ] ) ) := &( "M->"+aEnchoiceRG5[ nX , 02 ] )
		EndIF
		
	Next nX
	RG5->( MsUnLock() )
	
	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Grava GetDados - Itens do Padrao de Calendario               ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	DbSelectArea("RG6")
	For nX:=1 TO Len(oGetRG6:aCols)	
		If oGetRG6:Acols[nX][nPosRec] > 0
	    	dbGoto(oGetRG6:Acols[nX][nPosRec])
			RecLock("RG6", .F.,.T.)
			If oGetRG6:Acols[nX][Len(oGetRG6:Acols[nX])] 				//-- Ver se esta deletado 
				dbDelete()
				Loop 
			Endif 
			lTravou:=.T.
		Else
			If !(oGetRG6:Acols[nX][Len(oGetRG6:Acols[nX])])
				RecLock("RG6",.T.)
				RG6->RG6_FILIAL := xFilial("RG6") 
				RG6->RG6_PDPERI := M->RG5_PDPERI
				lTravou:=.T.      
			Else 
				Loop
			EndIf
		Endif
		If lTravou
	        //--Verifica se esta deletado
			For nY := 1 To nMaxArray 
				cCampo    		:= Trim(oGetRG6:aHeader[nY][2]) 
 				RG6->(&cCampo) 	:= oGetRG6:Acols[nX,nY]
			Next nY 
		Endif
		lGravouOk := .T. 
		RG6->(MsUnlock())
	Next nX
	
	End Transaction

EndIf 

Return(lGravouOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfDeletaItens     บAutor  ณMicrosiga           บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua Delecao dos itens da Tab. de Padrao                         บฑฑ
ฑฑบ          ณ                                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fDeletaItens(cKey) 
Local lDeletou 	:= .F.

dbSelectArea("RG6")
If dbSeek( cKey )
	While !RG6->(eof()) .AND. RG6->(RG6_FILIAL + RG6_PDPERI)  ==  cKey 
		RecLock( "RG6" , .F. , .F. )
		RG6->( dbDelete() )
		RG6->( MsUnLock() )
		RG6->( dbSkip()) 
		lDeletou	:= .T. 
	Enddo
Else
	lDeletou := .T.
EndIf

Return( lDeletou ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGpea500LinOk     บAutor  ณMicrosiga           บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua consistencia das linhas da get Dados                        บฑฑ
ฑฑบ          ณ                                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Gpea500LinOk( oBrowse )

Local lLinOk		:= .T. 

Local nPosCod		:= GdFieldPos("RG6_CODIGO",oGetRG6:aHeader)
Local nPosNpag		:= GdFieldPos("RG6_NUMPAG",oGetRG6:aHeader)
Local nPosDPer		:= GdFieldPos("RG6_DIAPER",oGetRG6:aHeader)
Local nX 			:= 0 
Local nLenCols 		:= Len( oGetRG6:aCols )

IF !oGetRG6:aCols[ oGetRG6:nAt , Len( oGetRG6:aCols[ oGetRG6:nAt ] ) ]
    
	If Empty(oGetRG6:aCols[ oGetRG6:nAt , nPosCod] ) .or. ; 
          Empty(oGetRG6:aCols[ oGetRG6:nAt , nPosDPer]) .or. ;
          (oGetRG6:aCols[ oGetRG6:nAt , nPosDPer] = 0 ) 
		MsgAlert( OemToAnsi( STR0021 ) , OemToAnsi( STR0013 ) ) 			// "Informe o codigo de referencia do padrao e os dias do periodo "#"Atencao"
		lLinOk := .F.
	EndIf
	
	If Empty(oGetRG6:aCols[oGetRG6:nAt , nPosNpag] )
		MsgAlert( OemToAnsi( STR0040 ) , OemToAnsi( STR0013 ) ) 			// "Informe o n๚mero de pagamento."#"Atencao"
		lLinOk := .F.
	EndIf  
	
	For nX := 1 To nLenCols
		If oGetRG6:aCols[ oGetRG6:nAt , nPosCod ] + oGetRG6:aCols[ oGetRG6:nAt , nPosNpag ] == oGetRG6:aCols[ nX , nPosCod ]+ oGetRG6:aCols[ nX , nPosNpag ] .and.;
			!oGetRG6:aCols[ nX , Len( oGetRG6:aCols[ nX ] ) ] .and. oGetRG6:nAt # nX 
			MsgAlert( OemToAnsi( STR0014 ) , OemToAnsi( STR0013 ) ) 		// "Codigo referencia e numero de pagamento ja cadastrados"#"Atencao"
			lLinOk := .F.
		EndIf
	Next nX  
	
	If lLinOk
		M->RG6_SEQUE  := ""
		M->RG6_CRITER := ""   
		lF3Criter	  := .F.	
	EndIf
	
EndIf 

Return( lLinOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGpea500TudoOk    บAutor  ณMicrosiga           บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua consistencia dos dados                                     บฑฑ
ฑฑบ          ณ                                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Gpea500TudoOk( oBrowse )

Local lTudoOk	:= .T. 
Local nLoop		:=0
Local nLoops 	:= Len( oGetRG6:aCols )

Begin Sequence

	For nLoop := 1 To nLoops
		oGetRG6:nAt := nLoop
		IF !( lTudoOk := Gpea500LinOk( oBrowse ) )
			Break
		EndIF
	Next nLoop

End Sequence

Return( lTudoOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGp500DelChk      บAutor  ณMicrosiga           บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica relacionamentos para certificar-se se  pode efetuar a    บฑฑ
ฑฑบ          ณ delecao do registro                                               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function Gp500DelChk(cAlias, nReg, nOpc, cKeyDel)
Local lDelReg	:= .T.  

Begin Sequence
	// verificar se a tabela nao possui registros relacionados //
	lDelReg := ChkDelRegs(	cAlias			,;	// 1-Alias do Arquivo Principal
						nReg				,;	// 2-Registro do Arquivo Principal
						nOpc				,;	// 3-Opcao para a AxDeleta
						xFilial( "RG5")		,;	// 4-Filial do Arquivo principal para Delecao
						cKeyDel				,;	// 5-Chave do Arquivo Principal para Delecao
						NIL 				,;	// 6-Array contendo informacoes dos arquivos a serem pesquisados
						NIL					,;	// 7-Mensagem para MsgYesNo
						NIL					,;	// 8-Titulo do Log de Delecao
						NIL					,;	// 9-Mensagem para o corpo do Log
						.F.				 	,;	// 10-Se executa AxDeleta
						.T.     			,;	// 11-Se deve Mostrar o Log
						NIL					,;	// 12-Array com o Log de Exclusao
						NIL				 	,;	// 13-Array com o Titulo do Log
						NIL					,;	// 14-Bloco para Posicionamento no Arquivo
						NIL					,;	// 15-Bloco para a Condicao While
						NIL					,;	// 16-Bloco para Skip/Loop no While
						.T.					,;	// 17-Verifica os Relacionamentos no SX9
						{"RG6"}				,;	// 18-Alias que nao deverao ser Verificados no SX9
						NIL				 	 ;	// 19-Se faz uma checagem soft
					 )

End Sequence

Return (lDelReg) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfSeleCrit บAutor  ณNatie               บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSeleciona os criterios de acumulacao e suas respectivas     บฑฑ
ฑฑบ          ณsequencias de acumulacao                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GPEA500-Perido Padrao e GPEA400- Cad.Periodos              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function fSeleCriterio() 
Local lFromPeriodo	:= IsInCallStack( "GPEA400" ) 
Local cLabelGroup	:= ""
Local cCodCrit		:= ""
Local cCodSeq		:= "" 

Local nOpNewGd		:= GD_UPDATE 

Local aAltera		:= {"RG9_QTDSEQ"}					//-- Permite a altera็ใo
Local aCriterios	:= {}
Local aColsRG9		:= {} 
Local aHeaderRG9	:= {} 
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aCoords		:= {}
	
Local cCodCritRG6	:= ""
Local nSvPosGd		:= 0	// Posicao da Getdados 
Local nX			:= 0 
Local nCont			:= 0
Local nOpca			:= 0 
Local nUsado 		:= 0 
Local nLenAcols		:= 0 
Local nPos			:= 0
Local nPosCrit		:= 0
Local nPosPer		:= 0 
Local nPosNPag		:= 0
Local nPosSeq		:= 0
Local nPosCod		:= 0 
Local nPosDtFech	:= 0 
Local nTamCrit		:= ( TamSx3( "RG6_CRITER" )[1] ) 
Local nTamSequ		:= ( TamSx3( "RG6_SEQUE"  )[1] ) 
Local nRG9PosCrit	:= "" 
Local nRG9PosSeq	:= "" 
Local oDlg1 
Local oGroup
Local oFont			:= NIL 

Local cVar 			:= ALLTRIM(substr(ReadVar(),4,10)) 
Local cConteudo		:= &( ReadVar() )

Local bSet15_		:= { || NIL }
Local bSet24_		:= { || NIL }

/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ variaveis auxiliares que dependem  de onde a Fc eh chamada   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
Local aColsAux		:= {}
Local aHeaderAux	:= {}
Local nAT			:= 0       

Private oGetRG9   

If Type("lF3Criter") =="U"
	Private lF3Criter := .F.	
Endif      

If (!lFromPeriodo .And. oGetRG6 <> Nil ) .Or. (lFromPeriodo .And. oGetRCH <> Nil )
	nSvPosGd	:= n
   	lF3Criter 	:= .T. 
	
	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Verifica se fc foi chamada atraves do periodo padrao ou      ณ
	ณ Cadastro de periodos                                         ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	If !lFromPeriodo 
		nPosCrit		:= GdFieldPos("RG6_CRITER",oGetRG6:aHeader)
		nPosNPag		:= GdFieldPos("RG6_NUMPAG",oGetRG6:aHeader)
		nPosSeq			:= GdFieldPos("RG6_SEQUE" ,oGetRG6:aHeader)
		nPosCod			:= GdFieldPos("RG6_CODIGO",oGetRG6:aHeader)
		aColsAux		:= aClone(oGetRG6:aCols )
		aHeaderAux		:= aClone(oGetRG6:aHeader) 
		nAT				:= oGetRG6:nAt 
		cLabelGroup		:=aHeaderAux[nPosCod,1] + " - " +  aColsAux[nAT,nPosCod] + "    "+ aHeaderAux[nPosNpag,1]+ " - " + aColsAux[nAT,nPosNpag] 
	Else
		nPosCrit		:= GdFieldPos("RCH_CRITER",oGetRCH:aHeader) 
		nPosSeq			:= GdFieldPos("RCH_SEQUE" ,oGetRCH:aHeader)     
		nPosPer 		:= GdFieldPos("RCH_PER"   ,oGetRCH:aHeader)
		nPosNPag		:= GdFieldPos("RCH_NUMPAG",oGetRCH:aHeader) 
		nPosDtFech		:= GdFieldPos("RCH_DTFECH",oGetRCH:aHeader) 
		nPosStatus		:= GdFieldPos("RCH_STATUS",oGetRCH:aHeader)
		aColsAux		:= aClone(oGetRCH:aCols ) 
		aHeaderAux		:= aClone(oGetRCH:aHeader )
		nAT				:= oGetRCH:nAt 
      If nPosPer <> 0 .and. nPosNPag <> 0
		    cLabelGroup :=aHeaderAux[nPosPer,1] + " - " +  aColsAux[nAT,nPosPer] + "    "+ aHeaderAux[nPosNpag,1]+ " - " + aColsAux[nAT,nPosNpag]	
      EndIf	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Nao permite a manutencao do crit/sequencia p/periodo em      ณ
		//ณ processo de fechamento                                       ณ	
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If aColsAux[nAT, nPosStatus] == "4" 
			MsgAlert( OemToAnsi( STR0038 ) , OemToAnsi( STR0013 ) ) // "Este perํodo esta em  processo de Fechamento e portanto nao ้ possivel a manutencao deste campo"    "#"Atencao"
			Return(.F.)
		Endif 
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Nao permite a manutencao p/periodos fechados                 ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty(aColsAux[nAt,nPosDtFech]) 
			MsgAlert( OemToAnsi( STR0037 ) , OemToAnsi( STR0013 ) ) // "Este perํodo jแ foi encerrado e nใo serแ possํvel sua manuten็ใo "    "#"Atencao"
			Return(.F.)
		Endif 
	Endif
	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Nao abre tela de sel.crit. se nao ouver cadastro de crit.    ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	dbSelectArea("RG9")
	IF !( ChkVazio("RG9"))
		If !Empty(cConteudo ) 
			&( ReadVar() ) := Space( nTamCrit )
		Endif 
			
		If(!lFromPeriodo, oGetRG6:oBrowse:Refresh(),oGetRCH:oBrowse:Refresh()) 
			
		Return(.F.) 
	EndIF
	
	If UPPER( cVar ) == ( aHeaderAux[nPosCrit, 2] )
		cCodCrit	:= cConteudo
		cCodSeq		:= aColsAux[nAT,nPosSeq]
	ElseIf 	UPPER( cVar ) == ( aHeaderAux[nPosSeq, 2] )
		cCodSeq		:= cConteudo
		cCodCrit	:= aColsAux[nAT,nPosCrit]
	Endif 
	
Endif
/* 
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Monta o aHeader                        					   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
fMontaHeader(@aHeaderRG9) 

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Monta o aCOLS com os criterio e suas respectivas sequencias  ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
fMontaCols(aHeaderRG9,@aColsRG9,nUsado)

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Monta o vetor com  os criterios e sequencias ;               ณ
ณ atribui as sequencias ao criterios escolhidos                ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
aCriterios	:= fMontaCritSeq(aColsRG9, aHeaderRG9, cCodCrit, cCodSeq )

nRG9PosCrit	:= GdFieldPos("RG9_CODCRI",aHeaderRG9) 
nRG9PosSeq	:= GdFieldpos("RG9_QTDSEQ",aHeaderRG9) 

For nX:= 1 to Len(aColsRG9)
	nPos :=  Ascan(aCriterios,{|x| x[1]== aColsRG9[nX,nRG9PosCrit] } )  
	If  nPos > 0  
		aColsRG9[nX,nRG9PosSeq]:= aCriterios[nPos,2] 
	Else 
		aColsRG9[nX,nRG9PosSeq]:= "  "	
	Endif 
Next nX 
 
aAdvSize	:= MsAdvSize( ,.T.,370)
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
If !lFromPeriodo
	aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. }  )
Else		
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. }  )
EndIf	
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

If !lFromPeriodo
	aCoords		:= {aObjSize[2,1],aObjSize[2,2],aObjSize[2,3],aObjSize[2,4]}
Else
    aCoords		:= {aObjSize[1,1],aObjSize[1,2],aObjSize[1,3],aObjSize[1,4]}
EndIf 
  
DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD 
DEFINE MSDIALOG oDlg1 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE oemToAnsi(STR0020) PIXEL 

	If !lFromPeriodo
		@ aObjSize[1,1],aObjSize[1,2] GROUP oGroup TO aObjSize[1,3],aObjSize[1,4]  LABEL OemToansi(STR0009) OF oDlg1 PIXEL 
		@ aObjSize[1,1]+10,aObjSize[1,2]+10 SAY cLabelGroup  SIZE 120,07 PIXEL FONT oFont COLOR CLR_BLUE //##"	
	EndIf

	oGetRG9 := MsNewGetDados():New(	aCoords[1]		,;	// nTop 
								    aCoords[2]		,;  // nLelft 
								    aCoords[3]		,;	// nBottom 
	                                aCoords[4]		,;	// nRright
 							 	nOpNewGd     	,;  // controle do que podera ser realizado na GetDado - nstyle
							 	"GpeRG9LinOk"	,;	// funcao para validar a edicao da linha - ulinhaOK
							 	"GpeRG9TudOk"	,;	// funcao para validar todas os registros da GetDados - uTudoOK
							 	NIL				,;	// cIniCPOS
							 	aAltera			,;	// aAlter
				 				2				,; 	// nfreeze
							 	99999			,;  // nMax
							 	NIL				,;	// cFieldOK
							 	NIL				,;	// usuperdel
							 	If(nOpcX1=2 .Or. nOpcX1=5,.F.,.T.),;		// udelOK	
							 	@oDlg1			,; 	// objeto de dialogo - oWnd
							 	@aHeaderRG9   	,;	// Vetor com Colunas- AparHeader
							 	@aColsRG9		;	// Vetor com Header - AparCols
							) 

	oGetRG9:bChange := { |lChange|; 
								oGetRG9:oBrowse:nColPos:= 3 ; 
				  				}
		
	bSet15_		:= { ||IF(  GpeRG9TudOk(), ; 
		                        ( nOpcA := 1 , oDlg1:End() ) , ; 
		                        ( nOpcA := 0 , .F. ); 
	                      )}
	
	bSet24_ := {||oDlg1:End() } 
	    
ACTIVATE MSDIALOG oDlg1 ON INIT EnchoiceBar( oDlg1 , bSet15_ , bSet24_ )   CENTERED 

IF nOpcA = 1 .and. nOpcX1!= 2 
	cCodCrit	:= ""
	cCodSeq		:= "" 
	nRG9PosCrit	:= GdFieldPos("RG9_CODCRI",oGetRG9:aHeader) 
	nRG9PosSeq	:= GdFieldPos("RG9_QTDSEQ",oGetRG9:aHeader) 
	nLenAcols	:= len(oGetRG9:aCols)
		
	For nX:= 1 to nLenAcols 
		If !empty(oGetRG9:aCols[nX,nRG9PosSeq])
			nCont++ 
			cCodCrit	+= If(nCont # 1,"/","")+ oGetRG9:aCols[nX,nRG9PosCrit] 
			cCodSeq		+= If(nCont # 1,"/","")+ oGetRG9:aCols[nX,nRG9PosSeq]  
		Endif  
	Next nX 
	
	cCodCrit:=	PadR(cCodCrit, nTamCrit)
	cCodSeq:=	PadR(cCodSeq, nTamSequ)

	If !lFromPeriodo  .And. oGetRG6 <> Nil
		aColsAux[nAT,nPosCrit]:= cCodCrit
		aColsAux[nAT,nPosSeq ]:= cCodSeq

		aCols[nAT,nPosCrit]:= cCodCrit
		aCols[nAT,nPosSeq ]:= cCodSeq

		SetMemVar( "RG6_CRITER",aColsAux[nAT,nPosCrit])
		SetMemVar( "RG6_SEQUE" ,aColsAux[nAT,nPosSeq] )

//		oGetRG6:aCols		:= aClone(aColsAux)
		oGetRG6:aCols		:= aClone(aCols)
		oGetRG6:aHeader	:= aClone(aHeaderAux) 
		oGetRG6:Refresh() 
	ElseIf oGetRCH <> Nil 
		aColsAux[nAT,nPosCrit]:= cCodCrit
		aColsAux[nAT,nPosSeq ]:= cCodSeq

		aCols[nAT,nPosCrit]:= cCodCrit
		aCols[nAT,nPosSeq ]:= cCodSeq

		SetMemVar( "RCH_CRITER",aColsAux[nAT,nPosCrit]) 
		SetMemVar( "RCH_SEQUE" ,aColsAux[nAT,nPosSeq] ) 
		
//		oGetRCH:aCols		:= aClone(aColsAux) 
		oGetRCH:aCols		:= aClone(aCols) 
		oGetRCH:aHeader	:= aClone(aHeaderAux) 
		oGetRCH:Refresh() 
	Else
		If lFromPeriodo .AND. MV_MODFOL == "2"
			SetMemVar( "RG6_CRITER",cCodCrit)
			SetMemVar( "RG6_SEQUE" ,cCodSeq )		
		Else
			SetMemVar( "RCH_CRITER",cCodCrit)
			SetMemVar( "RCH_SEQUE" ,cCodSeq )
		Endif
	Endif
Else
	Return .F.
Endif         

n := nSvPosGd 
	
Return(.T.) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfValidCriter     บAutor  ณMicrosiga           บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua consistencia dos dados                                     บฑฑ
ฑฑบ          ณ                                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function fValidCriter()
	Local lRetOk:= .T.
	Local nCount
	Local cFieldCrit	:= StrTran(ReadVar(), "M->", "")
	Local cFieldSeq
	Local aCritAux
	Local aSequencias
	
	If Type("lF3Criter") =="U"
		Private lF3Criter := .F.	
	Endif     
	
	Do Case
		Case (cFieldCrit == "RCH_CRITER")
			cFieldSeq:= "RCH_SEQUE"
		Case (cFieldCrit == "RG6_CRITER")
			cFieldSeq:= "RG6_SEQUE"
	EndCase
	
	aCritAux := StrToArray( &("M->" + cFieldCrit), "/", { |x| !Empty(x)} )
	aSequencias:= StrToArray( &("M->" + cFieldSeq),  "/", { |x| !Empty(x)} )
	
	lRetOk:= (Len(aCritAux) == Len(aSequencias) )
	
	If lRetOk
		For nCount:= 1 To Len(aCritAux)
			If !ExistCpo("RG9", aCritAux[nCount], 1, NIL, .F.)
				lRetOk:= .F.
				Exit
			EndIf
		Next nCount
	EndIf	                                         
	
	If !lRetOk .And. !lF3Criter 
		lRetOk:= fSeleCriterio()
	Else
		lF3Criter := .F.
	EndIf

	If !lRetOk
		IF ( Type( "oEnchoice" ) == "O" )
			SetMemVar(cFieldCrit, Space(GetSx3Cache(cFieldCrit,"X3_TAMANHO")) )
			SetMemVar(cFieldSeq,  Space(GetSx3Cache(cFieldSeq, "X3_TAMANHO")) )
			
			oEnchoice:Refresh()
			oEnchoice:SetFocus()
			nCount:= Ascan(oEnchoice:aEntryCtrls, { |oItem| oItem:cReadVar == "M->" + cFieldCrit})
			If nCount > 0
				oEnchoice:aEntryCtrls[ nCount ]:SetFocus()
			EndIF					
		EndIF				
	EndIF	

Return .T.



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGpeRG9LinOk      บAutor  ณMicrosiga           บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua consistencia dos dados                                     บฑฑ
ฑฑบ          ณ                                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GpeRG9LinOk(oBrowse) 
Local lRetOk	:= .T. 

Return(lRetOk) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGpeRG9TudOk      บAutor  ณMicrosiga           บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua consistencia dos dados                                     บฑฑ
ฑฑบ          ณ                                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function GpeRG9TudOk(oBrowse)

Local lTudoOk	:= .T. 
Local nLoop		:= 0 
Local nLoops 	:= Len( oGetRG9:aCols ) 

Begin Sequence

	For nLoop := 1 To nLoops
		n := nLoop
		IF !( lTudoOk := GpeRG9LinOk( oBrowse ) )
			Break
		EndIF
	Next nLoop

End Sequence

Return( lTudoOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfValidSeq บAutor  ณMicrosiga           บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a sequencia digitada.Verfica se a sequencia esta de  บฑฑ
ฑฑบ          ณacordo com  a qtde de sequencias do RG9                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function fValidSeq( cCriterio)
Local lRet 			:= .T.  
//Local lFromPeriodo	:= IsInCallStack( "GPEA400" ) 
Local nSequenc		:= 0
Local nTamSx3 		:= GetSx3Cache( "RG9_QTDSEQ", "X3_TAMANHO" ) 
Local nPosMesPer	:= 0 

cSequenc:= &(ReadVar()) 

nSequenc	:= Val(cSequenc) 

If nSequenc = 0 
	Return(.F.) 
Endif

If RG9->( DbSeek(xFilial("RG9") + cCriterio )) 
	If nSequenc > RG9->RG9_QTDSEQ 
		MsgAlert( OemToAnsi( STR0018 ) , OemToAnsi( STR0013 ) ) // "Verifique se a sequencia digitada e compativel com  a permitida no Cadastro de Criterios"#"Atencao"	
		lRet 	:= .F.  
	Endif 
	
	/*
 	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Retirada a validacao de sequencia, pois e permitido acum.	   ณ
	ณ para diferentes meses conforme o inicio definido no RCH	   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	*/
	
 	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Valida a primeira sequencia de acumulacao- sempre deve 	     ณ
	//ณ iniciar-se no "01"                                     	     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	/*If !lFromPeriodo 
		If !Empty(cSequenc)  .and. ( oGetRG6:nAt = 1) .and. cSequenc <> '01' 
			MsgAlert( OemToAnsi( STR0019 ) , OemToAnsi( STR0013 ) ) // "A sequencia devera iniciar-se em '01'. "#"Atencao"	
			lRet 	:= .F. 	
		Endif 
	Endif */
	
Endif 
cSequenc := If( nSequenc > 0 , StrZero( nSequenc, nTamSx3 ),  cSequenc ) 

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfMontaHeaderบAutor  ณMicrosiga           บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMontagem  do aheader                                          บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                           บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fMontaHeader(aHeaderRg9)
Local nUsado 	:= 0 
Local aField	:= {"RG9_FILIAL"} 

dbSelectArea("SX2")
dbSetOrder(1)
dbseek("RG9")
	
dbSelectArea("SX3")
dbSetOrder(1)
dbseek("RG9")

While !EOF() .And. (x3_arquivo == "RG9") 
	IF x3uso(x3_usado) .AND. cNivel >= x3_nivel .and. ! ASCAN(aField,Trim(x3_campo)) > 0
		NUsado++ 
		Aadd(aHeaderRG9,{ Trim(X3Titulo()), x3_campo,x3_picture,x3_tamanho,;
			    			 x3_decimal, x3_valid, x3_usado, x3_tipo, x3_arquivo,X3_F3}) 
		If aHeaderRG9[nUsado,2] == "RG9_QTDSEQ"
			aHeaderRG9[nUsado,1] := OemtoAnsi(STR0016)					      //-- Sequencia 
			aHeaderRG9[nUsado,3] := "99"								      //-- Picture 
			aHeaderRG9[nUsado,4] := 2										  //-- Tamanho
			aHeaderRG9[nUsado,6] := "fValidSeq( oGetRG9:aCols[oGetRG9:nAt,1] )"
			aHeaderRG9[nUsado,8] :=	"C" 
			aHeaderRG9[nUsado,9] :=	"" 
		Endif
	Endif 
	dbSkip()
EndDo  

  
Return 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfMontaColsบAutor  ณMicrosiga           บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMontagem  do Acols RG9                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function  fMontaCols(aHeaderRG9,aColsRG9) 
Local aArea			:= GetArea()
Local aPerFecha		:= {} 
Local lFromPeriodo	:= IsInCallStack( "GPEA400" ) 
Local cCritRCH		:= ""
Local nPos			:= 0 
Local nPosDtFech	:= 0 
Local nPosPer		:= 0 
Local nPosNPag		:= 0 
Local nPosCrit		:= 0 
Local nPosPerSel	:= 0 
Local nPosPdPeri	:= 0 
Local cFilRG9		:= xFilial("RG9")

If lFromPeriodo .And. oGetRCH <> Nil
	nPosDtFech	:= GdFieldPos("RCH_DTFECH" , oGetRCH:aHeader ) 
	nPosPer		:= GdFieldPos("RCH_PER"    , oGetRCH:aHeader ) 
	nPosNPag	:= GdFieldPos("RCH_NUMPAG" , oGetRCH:aHeader ) 
	nPosCrit	:= GdFieldPos("RCH_CRITER" , oGetRCH:aHeader ) 	
	nPosPerSel	:= GdFieldPos("RCH_PERSEL" , oGetRCH:aHeader )
	nPosPdPeri	:= GdFieldPos("RCH_PDPERI" , oGetRCH:aHeader )
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se periodo nao foi gerado do padrao :                        ณ
	//ณ Pegar os criterios iguais ao do ultimo periodo aberto ou     ณ
	//ณ periodo fehado imediatamente anterior                        ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If 	Empty( oGetRCH:aCols[oGetRCH:nAt,nPosPdPeri] ) 
	
		If( nPos:=(  ascan(oGetRCH:aCols, {|x| x[nPosPerSel]="1" }  ) )) > 0 
			cCritRCH:= 	oGetRCH:aCols[nPos, nPosCrit]
		Endif 
		
		IF Empty( cCritRCH )
			aEval( oGetRCH:aCols, {|x| If(!Empty(x[nPosDtFech]),  aadd(aPerFecha,{  GetMemVar("RFQ_PERIOD"),  GetMemVar("RFQ_NUMPAG")  ,x[nPosDtFech],x[nPosCrit] } ) ,""  ) }  ) 
			If !Empty(aPerFecha)
				aSort( aPerFecha,,,{ |x,y| x[1]+x[2]+Dtos(x[3]) > y[1]+y[2]+Dtos(y[3]) } )		
				cCritRCH	:= aPerFecha[Len(aPerfecha), 4] 
			Endif 
		Endif 
	Endif 
	
Endif
			
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta os Dados para a GetDados							     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea("RG9") 
If dbseek(xFilial("RG9"))  

	While !EOF() .And.RG9->RG9_FILIAL== cFilRG9 
		IF lFromPeriodo .and. !empty(cCritRCH) 
			If RG9->RG9_CODCRI $ cCritRCH
				aadd(aColsRG9, {RG9_CODCRI,RG9_DESCRI," " ,RG9_MESINI, .F. } ) 
			Endif 
		Else 
			aadd(aColsRG9, {RG9_CODCRI,RG9_DESCRI," " ,RG9_MESINI, .F. } )  
		Endif 	
		RG9->(dbSkip())
	EndDo
Endif
             
RestArea(aArea)
Return () 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfMontaCritSeq    บAutor  ณMicrosiga           บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Monta o vetor com  os criterios e sequencias de acumuladao        บฑฑ
ฑฑบ          ณ                                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fMontaCritSeq(aColsRG9, aHeaderRG9,cCriterio, cSequenc ) 

Local nX			:= 0 
Local nPosCri		:= 0
Local aCriterio		:= {}

/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Carrega os Criterios de acumulacao 						   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
cCriterio	:= Alltrim(cCriterio)
If !empty(cCriterio)
	For nX:= 1 to Len(cCriterio) step 3 
		aadd(aCriterio,{ Substr(cCriterio,nX,2), Substr(cSequenc,nX,2) } ) 
	Next nX
Else
	nPosCri	:= GdfieldPos("RG9_CODCRI",aHeaderRG9) 
	For nX:= 1 to Len(aColsRG9 ) 
		aadd(aCriterio,{aColsRG9[nX,nPosCri], "  " } )
	Next nX
Endif

If Empty(aCriterio)
	aadd(aCriterio,{ "  ", "  " } ) 
Endif

Return (aCriterio)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณMicrosiga           บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIsola Opcoes de Menu para que as opcoes da rotina possam    บฑฑ
ฑฑบ          ณser lidas pelas bibliotecas FrameWork                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function MenuDef()

/*/
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Define array contendo as Rotinas a executar do programa      ณ
ณ ----------- Elementos contidos por dimensao ------------     ณ
ณ 1. Nome a aparecer no cabecalho                              ณ
ณ 2. Nome da Rotina associada                                  ณ
ณ 3. Usado pela rotina                                         ณ
ณ 4. Tipo de Transao a ser efetuada                          ณ
ณ    1 - Pesquisa e Posiciona em um Banco de Dados             ณ
ณ    2 - Simplesmente Mostra os Campos                         ณ
ณ    3 - Inclui registros no Bancos de Dados                   ณ
ณ    4 - Altera o registro corrente                            ณ
ณ    5 - Remove o registro corrente do Banco de Dados          ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
 Local aRotina :={;
						{ STR0004 , "PesqBrw"		, 0 , 1, ,.F. } ,;	//"Pesquisar"
						{ STR0005 , "GpeA500Atu"	, 0 , 2 } ,;		//"Visualizar"
						{ STR0006 , "GpeA500Atu"	, 0 , 3 } ,;		//"Incluir"  
						{ STR0007 , "GpeA500Atu"	, 0 , 4 } ,;		//"Alterar"  
						{ STR0008 , "GpeA500Atu"	, 0 , 5 } }			//"Excluir"  
 
Return aRotina