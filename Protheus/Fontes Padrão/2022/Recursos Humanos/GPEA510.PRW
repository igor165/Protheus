#include "PROTHEUS.CH"
#include "GPEA510.CH"
#include "HEADERGD.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออออัออออออออออหอออออออออออัอออออออออออออออออออออออหออออออัออออออออออออออปฑฑ
ฑฑบPrograma    ณGPEA510   บAutor      ณNatie                  บ Data ณ  23/10/07    บฑฑ
ฑฑฬออออออออออออุออออออออออสอออออออออออฯอออออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
ฑฑบDesc.       ณCorrespondencia entre periodos                                      บฑฑ
ฑฑบ            ณ                                                                    บฑฑ
ฑฑฬออออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso         ณGenerico                                                            บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ               ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador ณ Data   ณ BOPS        ณ  Motivo da Alteracao                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function GPEA510()                  
/* 
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Declaracao de variaveis...                                          ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Local aIndex		:= {}
Local cFiltra		:= ""
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Variaveis Modelo do SIGAGPE                                         ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Private cAlias_		:= "RCH" 

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Declara็ใo de variaveis do sistema                                  ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Private aRotina 	:= MenuDef() 													// ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina

Private bFiltraBrw	:= { || NIL }
Private cCadastro   := OemToAnsi( STR0001 ) 										//"Correspondencia de Periodos"

dbSelectArea(cAlias_) 

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ          
ณ Inicializa o filtro utilizando a funcao FilBrowse                      ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

cFiltra		:= ChkRh( FunName() , cAlias_ , "1" ) 
bFiltraBrw 	:= { || FilBrowse( cAlias_ , @aIndex , @cFiltra ) }
Eval( bFiltraBrw )

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Chama a Funcao de Montagem do Browse                                   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
mBrowse( 6 , 1 , 22 , 75 , cAlias_ , , , , , , )
	
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Deleta o filtro utilizando a funcao FilBrowse                     	 ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
EndFilBrw( cAlias_, aIndex )

Return( NIL ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPEA510   บAutor  ณMicrosiga           บ Data ณ  10/23/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function  GPA510Manu( cAlias , nReg , nOpcX )

Local aAreaRG8	:= RG8->(GetArea()) 
Local nSvREc	:= RCH->(RECNO()) 

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Variaveis de dimensionamento da tela                		   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Local aAdvSize			:= {} 
Local aInfoAdvSize		:= {}
Local aObjCoords		:= {} 

Local cFilRG8			:=	xFilial("RG8") 
Local cKeyRG8			:= cModulo + RCH->( RCH_PER + RCH_NUMPAG+RCH_PROCES+ RCH_ROTEIR )
Local cDescProc			:= "-" + fDesc( "RCJ" ,RCH_PROCES, "RCJ_DESCRI") 
Local dDtIni			:= RCH->RCH_DTINI	
Local dDtFim			:= RCH->RCH_DTFIM 

Local cKeySeek			:= "" 
Local bSkip				:= {|| NIL  }
Local bRG8DelOk			:= { || GpRG8DelOk() }

Local nOpcAlt			:= 0.00		// variavel de controle das alteracoes - utilizada para a gravacao
Local nPosRec			:= 0 

Local nLenCh			:= 0 
Local nX				:= 0 
Local nCnt 				:= 0
Local nPosMod			:= 0

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณObjetos          ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Local oFont
Local oGroup
Local oProcesso			
Local oPeriodo			
Local oNunPag			
Local oRoteiro			

Private nOpcNewGd		:= IF( (  nOpcx == 2  .or.  nOpcx == 5  ) , 0 , GD_INSERT + GD_UPDATE + GD_DELETE ) 
Private nUsado 			:= 0 

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Variaveis do display                              		   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Private cPeriodoOri		:= RCH->RCH_PER   
Private cNumPagOri		:= RCH->RCH_NUMPAG
Private cRoteiroOri		:= RCH->RCH_ROTEIR
Private cProcessoOri	:= RCH->RCH_PROCES 
Private cMes			:= RCH->RCH_MES
Private cAno			:= RCH->RCH_ANO
Private cModuloFlt		:= RCH->RCH_MODULO
Private cPeriodo		:= Space( TamSx3( "RG8_PERCOR" )[1] )
Private cNumPag			:= Space( TamSx3( "RG8_NPGCOR" )[1] )
Private cRoteiro		:= Space( TamSx3( "RG8_ROTCOR" )[1] )
Private cProcesso		:= Space( TamSx3( "RG8_PROCOR" )[1] )

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Variaveis da GetDados                              		   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Private aColsRG8 		:= {}										// Vetor com os Campos da  GetDados
Private aHeaderRG8		:= {}										// Vetor com os Campos do Cabecalho da GetDados
Private aSvRG8Cols 		:= {} 
Private aRG8Virtual 	:= {}										// Vetor com os Campos Virtuais
Private aRG8Visual 	    := {}										// Vetor com os Campos Visuais
Private aNotFields 		:= {}										// Campos que nao Deverao constar no aHeader
Private aRG8Recnos 		:= {}										// Vetor unidimensional contendo os Recnos
Private oGetRG8 

Private oDLg 
Private bChange     := {|| NIL}

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Verifica se existe algum dado no arquivo                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
dbSelectArea( "RG8" ) 
RG8->(dbSeek( cFilRG8 + cKeyRG8 ) ) 
nCnt := 0
RG8->(dbEval({||nCnt++},,{|| RG8_FILIAL +RG8_MODORI+RG8_PERORI +RG8_NPGORI +RG8_PRCORI + RG8_ROTORI == cFilRG8 + cKeyRG8 }))
 
If nCnt > 0  .And. nOpcx = 3    		//--Quando Inclusao e existir Registro
	Aviso(STR0010,STR0018,{'OK'}) 		//"Atencao"###""Ja existe padrao correspondente para este periodo. Utilize a opcao 'Alterar' 
	Return Nil 
ElseIf nCnt = 0 .And. nOpcx # 3  		//--Quando Nao for Inclusao e nao existir Registro
      Aviso(STR0010,STR0019,{'OK'}) 	//"Atencao"###"Nao existe padrao correspondente para este periodo.Utilize a opcao 'Incluir' "	
	Return Nil 
ElseIf !ChkVazio("RCH")
	Return Nil
EndIf

Begin Sequence
     
	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Monta as Dimensoes dos Objetos         					   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 020 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
	
	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Na Inclusao Coloca o Ponteiro do arquivo RG8 em EOF          ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
	If ( nOpcx == 3 )
		PutFileInEof( "RG8" , @nReg)
	EndIf
    
	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Campos da GetDados                                           ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
	aadd(aNotFields , "RG8_FILIAL")
	aadd(aNotFields , "RG8_MODORI")
	aadd(aNotFields , "RG8_PERORI")
	aadd(aNotFields , "RG8_NPGORI")
	aadd(aNotFields , "RG8_PRCORI")
	aadd(aNotFields , "RG8_ROTORI") 
	aadd(aNotFields , "RG8_MESORI")  
	aadd(aNotFields , "RG8_ANOORI") 

	If nOpcx<> 3 		//-- se nao for inclusao 
		cKeySeek	:= (cFilRG8 + cKeyRG8 )
		bSkip 	:= { ||  &("RG8_FILIAL") + &("RG8_MODORI") + &("RG8_PERORI") + &("RG8_NPGORI") + &("RG8_PRCORI")+ &("RG8_ROTORI") <> cKeySeek }
	EndIf 		

	aColsRG8 := RG8->( GdMontaCols(@aHeaderRG8 	,;	// 01 -> Array com os Campos do Cabecalho da GetDados
								 @nUsado 		,;	// 02 -> Numero de Campos em Uso
								 @aRG8Virtual 	,;	// 03 -> [@]Array com os Campos Virtuais
								 @aRG8Visual 	,;	// 04 -> [@]Array com os Campos Visuais
								 NIL			,;	// 05 -> Opcional, Alias do Arquivo Carga dos Itens do aCols
								 aNotFields 	,;	// 06 -> Opcional, Campos que nao Deverao constar no aHeader
								 @aRG8Recnos 	,;	// 07 -> [@]Array unidimensional contendo os Recnos
								 "RG8"			,;	// 08 -> Alias do Arquivo Pai
								 cKeySeek		,;	// 09 -> Chave para o Posicionamento no Alias Filho
								 NIL			,;	// 10 -> Bloco para condicao de Loop While
								 bSKIP			,;	// 11 -> Bloco para Skip no Loop While
								 NIL			,;	// 12 -> Se Havera o Elemento de Delecao no aCols 
								 NIL			,;	// 13 -> Se cria variaveis Publicas
								 NIL			,;	// 14 -> Se Sera considerado o Inicializador Padrao
								 NIL			,;	// 15 -> Lado para o inicializador padrao
								 NIL			,;	// 16 -> Opcional, Carregar Todos os Campos
								 NIL			,;	// 17 -> Opcional, Nao Carregar os Campos Virtuais
								 NIL			,;	// 18 -> Opcional, Utilizacao de Query para Selecao de Dados
								 NIL			,;	// 19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP ) - utilizado com o parametro 10
								 .T.			,;	// 20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP ) - utilizado com o parametro 11
								 NIL			,;	// 21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
								 .F.		     ;	// 22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos 
							     ) )
	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณAltera o aHeader deixando os campos Mes e Ano nao editavel    ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/								     
	fChangeMYear()
	
	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Cria as Variaveis de Memoria e Carrega os Dados Conforme o arณ
	ณ quivo														   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
	For nX := 1 To Len(aHeaderRG8) 
		Private &( "M->"+aHeaderRG8[ nX , 02 ] ) := aColsRG8[ 01 , nX ]
	Next nX	

	aSvRG8Cols := aClone( aColsRG8 )

	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Monta o Dialogo Principal                                    ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg TITLE OemToAnsi( STR0001 ) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL

	@ aObjSize[1,1],aObjSize[1,2] 				GROUP oGroup TO aObjSize[1,3],(aObjSize[1,4]/100*10 - 2 )  LABEL OemToAnsi(STR0014) OF oDlg PIXEL	// Codigo do Periodo:
	oGroup:oFont:= oFont
	@ aObjSize[1,1],(aObjSize[1,4]/100*10)		GROUP oGroup TO aObjSize[1,3], (aObjSize[1,4]/100*30 - 2 ) LABEL OemToAnsi(STR0015) OF oDlg PIXEL	// Numero de Pagamento:
	oGroup:oFont:= oFont
	@ aObjSize[1,1],(aObjSize[1,4]/100*30)		GROUP oGroup TO aObjSize[1,3], (aObjSize[1,4]/100*60 - 2 ) LABEL OemToAnsi(STR0013) OF oDlg PIXEL  	// Processo
	oGroup:oFont:= oFont                                                 
	@ aObjSize[1,1],(aObjSize[1,4]/100*60)		GROUP oGroup TO aObjSize[1,3], (aObjSize[1,4]/100*80 - 2 ) LABEL OemToAnsi(STR0016) OF oDlg PIXEL  	// Roteiro
	oGroup:oFont:= oFont  
	@ aObjSize[1,1],(aObjSize[1,4]/100*80)		GROUP oGroup TO aObjSize[1,3], (aObjSize[1,4])         	 LABEL OemToAnsi(STR0017) OF oDlg PIXEL		// Periodo
	oGroup:oFont:= oFont 

	@ aObjSize[1,1] + 10    , ( aObjSize[1,2] + 5 )       		SAY oPeriodo  Var cPeriodoOri  				SIZE 050,10 OF oDlg PIXEL 
	@ aObjSize[1,1] + 10    , ((aObjSize[1,4]/100*10) + 5)	SAY oNumPag   Var cNumPagOri   				SIZE 050,10 OF oDlg PIXEL 
	@ aObjSize[1,1] + 10    , ((aObjSize[1,4]/100*30) + 5)	SAY oProcesso Var cProcessoOri + cDescProc 	SIZE 100,10 OF oDlg PIXEL  
	@ aObjSize[1,1] + 10    , ((aObjSize[1,4]/100*60) + 5)	SAY oRoteiro  Var cRoteiroOri  				SIZE 050,10 OF oDlg PIXEL 
	@ aObjSize[1,1] + 10    , ((aObjSize[1,4]/100*80) + 5)	SAY DTOC(dDtIni) + " - "  + DTOC(dDtFim) 	SIZE 060,10 OF oDlg PIXEL 
 
	oGetRG8:= MsNewGetDados():New(aObjSize[2,1],;	     // nTop
									 aObjSize[2,2]	,;  // nLelft
									 aObjSize[2,3]	,;	// nBottom
		                             aObjSize[2,4]	,;	// nRright
									 nOpcNewGd      ,;  // controle do que podera ser realizado na GetDado - nstyle
									 "GPA510LinOk"	,;	// funcao para validar a edicao da linha - ulinhaOK
									 "GPA510TudoOk"	,;	// funcao para validar todas os registros da GetDados - uTudoOK
	  								 NIL			,;	// cIniCPOS
									 NIL			,;	// aAlter
									 0				,; 	// nfreeze
									 99999			,;  // nMax
									 NIL		    ,;	// cFieldOK
									 NIL			,;	// usuperdel
									 bRG8DelOk      ,;	// udelOK
									 @oDlg			,; 	// objeto de dialogo - oWnd
									 @aHeaderRG8    ,;	// Vetor com Colunas - AparHeader
									 @aColsRG8	     )	// Vetor com Header - AparCols
	                     
		nPosRec:=GdfieldPos("RG8_REC_WT",oGetRG8:aHeader)
		nPosMod:=GdfieldPos("RG8_MODCOR",oGetRG8:aHeader)

		oGetRG8:bChange:={ |lChange| cModuloFlt := oGetRG8:aCols[oGetRG8:nAt,nPosMod]} 
		oGetRG8:Refresh()
		
		bSet15	:= {|| nOpcAlt:= 1 , IF(oGetRG8:TudoOk(),oDlg:End(),nOpcAlt:=0)}
		bSet24	:= {|| oDlg:End()}
		
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg , bSet15 , bSet24 )

	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณQuando Confirmada a Opcao e Nao for Visualizacao Grava        ณ
	ณ                                            				   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
	If nOpcx # 5 
		If nOpcAlt == 1 .and. nOpcX != 2 

			/*
			ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			ณ Gravando/Incluido ou Excluindo Informacoes RG8               ณ
			ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
			GPA510Grava( 	cFilRG8	  ,;
							aSvRG8Cols,;		//9-Clone de ARCGCols 
							aRG8Recnos,;		//10-Vetor com Recnos de 
							nPosRec	  ,;
							nOpcX		;
						)
		EndIf
 	ElseIf nOpcAlt == 1
		Gp510Deleta() 
	EndIf
	
End Sequence 

RestArea( aAreaRG8 )

dbSelectArea("RCH") 
GO nSvRec
                                                                                                 
If nOpcx == 3    //--Quando Inclusao
   MBrChgLoop(.F.)
EndIf

Return Nil 

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณGp510Deleta ณ Autor ณ Natie                 ณ Data ณ 25/06/08 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Deleta a correspondencia de periodos                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ                                                              ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function Gp510Deleta() 

Local nPosRec	:= GdfieldPos("RG8_REC_WT",oGetRG8:aHeader)
Local nPosRegs	:= GdfieldPos("RG8_QTREGS",oGetRG8:aHeader) 
Local nX		:= 0 

Begin Transaction 
	For nX:=1 To Len(oGetRG8:aCols)	 
		RG8->( dbGoto(oGetRG8:Acols[nX][nPosRec]) ) 
		/*
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณ Nao permite a delecao de periodo (origem) q ja foi efetuado  ณ
		ณ o fechamento                                                 ณ			
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
		If oGetRG8:Acols[nX][nPosRegs] = 0 
			RecLock("RG8", .F.,.T.) 
			dbDelete()  
			RG8->(MsUnlock()) 	
		Endif 	
	Next nX 
End Transaction  

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGpRG8DelOkบAutor  ณNatie               บ Data ณ  26/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se pode deletar o registro                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function  GpRG8DelOk()
Local lDelOk	:= .T. 
Local nPosReg	:= GdfieldPos("RG8_QTREGS",oGetRG8:aHeader) 

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Nao permite a manutencao de periodo (origem) q ja foi        ณ
ณ efetuado o fechamento                                        ณ			
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
Begin Sequence 
	If !Empty( oGetRG8:aCols[oGetRG8:nAt,nPosReg]) 
		MsgAlert( OemToAnsi( STR0023 ) + CRLF+ ; 
     	          OemToAnsi( STR0022 )         ,; //"Nใo ้ permitido fazer a manuten็ใo deste campo. "##" Periodo ja foi encerrado " 
		          OemToAnsi( STR0021 ) ) 				
		lDelOK:= .F.
	Endif 
End Sequence

Return(lDelOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPEA510   บAutor  ณMicrosiga           บ Data ณ  10/23/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Static Function  fChangeMYear()
          
Aeval(aHeaderRg8,{|x| x[14]:= If( alltrim(x[2]) $ ("RG8_MESCOR/RG8_ANOCOR") ,"V"  , x[14]   )   }  ) 

Return(.T.) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPEA510   บAutor  ณMicrosiga           บ Data ณ  10/23/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GPA510Grava(cFilRG8,aSvRG8Cols,aRG8Recnos,nPosRec, nOpcX ) 

Local nX		:= 0
Local nY		:= 0 
Local nMaxArray	:= Len(oGetRG8:aHeader)
Local lGravouOk	:= .F. 
Local lTravou 	:= .F. 

If nOpcX == 4 .and. fCompArray(oGetRG8:aCols, aSvRG8Cols) 
	Return (lGravouOk) 
Endif

Begin Transaction
	For nX:=1 TO Len(oGetRG8:aCols)	
		If oGetRG8:Acols[nX][nPosRec] > 0
			dbGoto(oGetRG8:Acols[nX][nPosRec])
			RecLock("RG8", .F.,.T.)
			If oGetRG8:Acols[nX][Len(oGetRG8:Acols[nX])]			//-- Ver se esta deletado  
				dbDelete() 
				Loop  
			EndIf  
			lTravou:=.T. 
		Else 
			If !(oGetRG8:Acols[nX][Len(oGetRG8:Acols[nX])]) 
				RecLock("RG8",.T.)
				RG8->RG8_FILIAL	:= cFilRG8
				RG8->RG8_MODORI	:= cModulo
				RG8->RG8_PRCORI	:= cProcessoOri
				RG8->RG8_PERORI	:= cPeriodoOri
				RG8->RG8_NPGORI	:= cNumPagOri
				RG8->RG8_ROTORI	:= cRoteiroOri 
				RG8->RG8_MESORI	:= cMes 
				RG8->RG8_ANOORI	:= cAno 
				lTravou:=.T. 
			Else 
				Loop 
			EndIf 
		EndIf 
		If lTravou
			//--Verifica se esta deletado 
			For nY := 1 To nMaxArray 
				cCampo    		:= Trim(oGetRG8:aHeader[nY][2]) 
				RG8->(&cCampo) 	:= oGetRG8:Acols[nX,nY] 
			Next nY 
		EndIf
		lGravouOk := .T. 
		RG8->(MsUnlock())
	Next nX
End Transaction  

Return Nil 
                   
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPA510LINOK      บAutor  ณMicrosiga           บ Data ณ  26/10/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua consistencia das linhas da get Dados                        บฑฑ
ฑฑบ          ณ                                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function GPA510LinOk( oBrowse ) 
Local lLinOk	:= .T. 
Local aCposKey	:= {} 

Begin Sequence 
	
	/*/
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Se nao Estiver Deletado              						   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
	If !( GdDeleted() )
		/*/
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณ Verifica Itens Duplicados na GetDados						   ณ
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
		aCposKey := {"RG8_MODCOR", "RG8_PERCOR","RG8_PROCOR", "RG8_ROTCOR"} 
		If !( lLinOk := GdCheckKey( aCposKey , 4 ) )
			Break
		EndIf
		
		/*/
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณ Verifica Se o Campos Estao Devidamente Preenchidos		   ณ
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
		If !( lLinOk := GdNoEmpty( aCposKey ) )
	    	Break 
		EndIf 

		/*/
		ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		ณ Verificar   Per + Numpag + processo + Roteiro (x Modulo)     ณ
		ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู/*/
		If !( lLinOk := GdVldPeriodo(oBrowse ) )
	    	Break 
		EndIf 
	
	EndIf 
			
End Sequence 

Return (lLinOk) 
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGp500TudoOk      บAutor  ณMicrosiga           บ Data ณ  09/21/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Efetua consistencia dos dados                                     บฑฑ
ฑฑบ          ณ                                                                   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                                บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function GPA510TudoOk( oBrowse )

Local lTudoOk	:= .T. 
Local nLoop		:=0
Local nLoops 	:= Len( oGetRG8:aCols )

Begin Sequence 

	For nLoop := 1 To nLoops
		oGetRG8:nAt := nLoop
		If !( lTudoOk := GPA510LinOk( oBrowse ) )
			Break 
		EndIf
	Next nLoop

End Sequence

Return( lTudoOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfVldModPerบAutor  ณMicrosiga           บ Data ณ  03/06/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณna alteracao do Modulo, limpa as variaveis do periodo para  บฑฑ
ฑฑบ          ณinsercao de um valido conforme o modulo selecionado         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ RG8_MODCOR                                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function  fVldModPer() 
Local lRetOK	:= .T.
Local aArea 	:= GetArea()
Local aRG8Cols	:= {}
Local nAT		:= 0
Local nPosMod	:= 0
Local nPosPer	:= 0
Local nPosPag	:= 0
Local nPosPro	:= 0
Local nPosRot	:= 0 
Local cCampo 	:= &(ReadVar())                                       

If (lRetOk:=  GpRG8DelOk() )
	aRG8Cols:= oGetRG8:aCols
	nAT		:= oGetRG8:nAT 

	nPosMod	:= GdFieldPos("RG8_MODCOR", oGetRG8:aHeader)
	nPosPer	:= GdFieldPos("RG8_PERCOR", oGetRG8:aHeader)
	nPosPag	:= GdFieldPos("RG8_NPGCOR", oGetRG8:aHeader)
	nPosPro	:= GdFieldPos("RG8_PROCOR", oGetRG8:aHeader)
	nPosRot	:= GdFieldPos("RG8_ROTCOR", oGetRG8:aHeader)
	If  cCampo <> aRG8Cols[nAT,nPosMod] 	
		aRG8Cols[nAt, nPosper] := Space( TamSx3( "RG8_PERCOR" )[1] )
		aRG8Cols[nAt, nPosPag] := Space( TamSx3( "RG8_NPGCOR" )[1] )
		aRG8Cols[nAt, nPosPro] := Space( TamSx3( "RG8_PROCOR" )[1] )
		aRG8Cols[nAt, nPosRot] := Space( TamSx3( "RG8_ROTCOR" )[1] )
	EndIf 
	cModuloFlt := M->RG8_MODCOR
EndIf 
	
RestArea(aArea)
Return(lRetOK) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPEA510   บAutor  ณMicrosiga           บ Data ณ  10/25/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega variavel com  nomes dos modulos Protheus            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ X3_BOX                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function RtModNameBox()

Local aModName	:= RetModName()
Local cOpcBox   := ""
Local nX		:= 0 

aSort(aModname,,,{|x,y|x[2] < Y[2] }) 
For Nx:= 1 to len(aModName)

	cOpcBox 	+= Right(aModName[nX,2],3) + "=" + aModName[nX,2] +If(nX<=len(aModname), ";","") 
	
Next Nx
	
Return( cOpcBox )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPEA510   บAutor  ณMicrosiga           บ Data ณ  10/26/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณNao permite a digitacao dos campos                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณX3_WHEN                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function  fVldVisual()
Local lRetOk := .T. 

lRetOk	:=GpRG8DelOk()

Return( lRetOk ) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfVldperiodo บAutor  ณMicrosiga           บ Data ณ  10/26/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica o periodo                                            บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณX3_VALID                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function  fVldPeriodo() 
Local aArea		:= GetArea()
Local cCampo	:= ReadVar()
Local cNumPag	:= ""  
Local cQuery	:= ""
Local lOk	  	:= .T. 
Local nCnt		:= 0 
Local nPosPer	:= GdFieldPos("RG8_PERCOR", oGetRG8:aHeader)
Local nAT 		:= AT(">",cCampo) 
cCampo		:= substr(cCampo,nAT+1,10)

If (cCampo == "RG8_PERCOR" )
	cPeriodo := &(ReadVar())
Else 
	cPeriodo := oGetRG8:aCols[oGetRG8:nAT,nPosPer]
	cNumPag	 := &(ReadVar()) 
EndIf

If(lOk:=  GpRG8DelOk() ) 
	
	cQuery := " SELECT COUNT(*) TOTAL " 
	cQuery += "   FROM "+	RetSqlName("RCH")  
	cQuery += "  WHERE RCH_FILIAL = '" + xFilial("RCH")+ "' AND " 
	cQuery += "        RCH_PER    = '" + cPeriodo      + "' AND " 
	If (cCampo == "RG8_NPGCOR" )
		cQuery	+= 	" RCH_NUMPAG  = '" + cNumPag + "' AND "
	EndIf
	cQuery += "       RCH_MODULO  = '" + cModuloFlt + "' AND " 
	cQuery += " D_E_L_E_T_ <> '*' "
		
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'QRCH', .F., .T.) 
	dbSelectArea("QRCH") 
	nCnt := QRCH->TOTAL 
	dbCloseArea() 
		                               
	If nCnt <= 0
		MsgAlert( OemToAnsi(STR0020) , OemToAnsi( STR0010 ) ) // "Periodo Invalido ou nao cadastrado "#"Atencao"
	    lOk := .F.
	EndIf
	
EndIf 

RestArea(aArea)
Return(lOk) 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGdVldPeriodoบAutor  ณMicrosiga           บ Data ณ  10/26/07   บฑฑ
ฑฑฬออออออออออุออออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica o ModuloxprocessoxRoteiroxPeriodo                    บฑฑ
ฑฑบ          ณ                                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณX3_VALID                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/ 
Function  GdVldPeriodo(oBrowse) 
Local aArea		:= GetArea()
Local cProcCor	:= ""
Local cRotCor 	:= Space( GetSx3Cache( "RG8_ROTCOR"	, "X3_TAMANHO" ) )
Local cPerCor	:= ""
Local cNumPagCor:= ""  
Local cMesRG8	:= ""
Local cAnoRG8	:= ""
Local cQuery	:= ""
Local cAliasRCH	:= "RCH"

Local nCnt		:= 0 
Local nPosMod	:= GdFieldPos("RG8_MODCOR", oGetRG8:aHeader)
Local nPosPer	:= GdFieldPos("RG8_PERCOR", oGetRG8:aHeader)
Local nPosPag	:= GdFieldPos("RG8_NPGCOR", oGetRG8:aHeader)
Local nPosPro	:= GdFieldPos("RG8_PROCOR", oGetRG8:aHeader)
Local nPosRot	:= GdFieldPos("RG8_ROTCOR", oGetRG8:aHeader)
Local nPosMes	:= GdFieldPos("RG8_MESCOR", oGetRG8:aHeader)
Local nPosAno	:= GdFieldPos("RG8_ANOCOR", oGetRG8:aHeader)

Local lOk	  	:= .T. 

If (nPosPer + nPosPag+nPosPro+nPosRot) > 0 
	cModuloFlt	:= oGetRG8:aCols[oBrowse:nAt,nPosMod ] 
	cProcCor	:= oGetRG8:aCols[oBrowse:nAt,nPosPro ]  
	//Folha Mod. 2 obriga a cadastrar o roteiro no cadastro periodos RCH
	If MV_MODFOL == "2"	
		cRotCor := oGetRG8:aCols[oBrowse:nAt,nPosRot ]  
	EndIf
	cPerCor		:= oGetRG8:aCols[oBrowse:nAt,nPosPer ]  
	cNumPagCor	:= oGetRG8:aCols[oBrowse:nAt,nPosPag ]  

	cAliasRCH	:= "QRCH"
	/* 
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Contar o Numero de Registros                                             ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
	cQuery := " SELECT RCH.RCH_ANO, RCH.RCH_MES, COUNT(*) TOTAL " 
	cQuery += " FROM "+	RetSqlName("RCH")  + " RCH "
	cQuery += " WHERE RCH.RCH_FILIAL = '" + xFilial("RCH")+ "' AND " 
	cQuery += "       RCH.RCH_MODULO = '" + cModuloFlt    + "' AND " 
	cQuery += "       RCH.RCH_PROCES = '" + cProcCor      + "' AND " 
	If MV_MODFOL == "2"	
		cQuery += "   RCH.RCH_ROTEIR = '" + cRotCor       + "' AND "
	EndIf
	cQuery += "       RCH.RCH_PER    = '" + cPerCor       + "' AND " 
	cQuery += "       RCH.RCH_NUMPAG = '" + cNumPagCor    + "' AND "
	cQuery += "       D_E_L_E_T_ <> '*' "
	cQuery += " GROUP BY RCH.RCH_ANO, RCH.RCH_MES " 
	
	cQryReg := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery) , cAliasRCH, .F., .T.) 
	dbSelectArea(cAliasRCH) 
	nCnt	:= (cAliasRCH)->TOTAL 
	cMesRG8	:= (cAliasRCH)->RCH_MES 
	cAnoRG8	:= (cAliasRCH)->RCH_ANO 
	(cAliasRCH)->(	dbCloseArea()) 		
			                               
	If nCnt <= 0 
		MsgAlert( OemToAnsi(STR0021), OemToAnsi( STR0010 ) ) // ""Processo, roteiro de cแlculo,  e periodo e invalido ou nao esta cadastrado neste Modulo"#"Atencao" 
		lOk := .F.
	Endif
	
	oGetRG8:aCols[oBrowse:nAt, nPosMes] := cMesRG8
	oGetRG8:aCols[oBrowse:nAt, nPosAno] := cAnoRG8
	oGetRG8:oBrowse:Refresh() 
EndIf 
	
RestArea(aArea)
Return(lOk) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  ณMicrosiga           บ Data ณ  10/23/07   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณIsola opcoes de menu para que as opcoes da rotina possam    บฑฑ
ฑฑบ          ณser lidas pelas bibliotecas Framework da Versao 9.12 .      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function MenuDef()
Local aRotina  

/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Define Array contendo as Rotinas a executar do programa      ณ
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
ณ    6 - Copiar                                                ณ
ณ    7 - Legenda                                               ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/

aRotina := {	{ STR0004 , "PesqBrw"	 , 0 , 1 } ,; 	//"Pesquisar"
				{ STR0005 , "GPA510Manu" , 0 , 2 } ,; 	//"Visualizar"
				{ STR0006 , "GPA510Manu" , 0 , 3 } ,; 	//"Incluir"
				{ STR0007 , "GPA510Manu" , 0 , 4 } ,; 	//"Alterar"
				{ STR0008 , "GPA510Manu" , 0 , 5 }  ; 	//"Excluir"
			}
Return (aRotina)