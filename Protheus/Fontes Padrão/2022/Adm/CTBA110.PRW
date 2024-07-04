#INCLUDE "CTBA110.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "JPEG.CH"     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA110   บ Autor ณ Anderson Goncalves บ Data ณ  24/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Rotina para geracao e controle de diarios                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function CTBA110() 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de Variaveis                                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local cSegofi  		:= AllTrim(GetMv( "MV_SEGOFI" , .F. , "0" ))
Local lRet			:= .T.
Private cDelFunc 	:= ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
Private cCadastro 	:= STR0001 //"Controle de diario"
Private aRotina 	:= MenuDef()
Private cString     := "CVL"
Private lEquador	:= cPaisLoc $ "EQU" 

If lRet .And. !AliasInDic("CVL")
	Help("  ",1,"CTB110CVL",,STR0015 ,1,0) //"Tabela CVL nใo consta no dicionario, por favor verificar."
	lRet := .F.
Else
	dbSelectArea(cString) 
EndIf

If lRet .And. cSegofi == '0'
	Help("  ",1,"CTB110SEG",,STR0016 ,1,0) //"Parametro MV_SEGOFI desabilitado, por favor verificar."
	lRet := .F.
EndIf

If lRet .And. lEquador 
	If lRet .And. cSegofi == '8' .And. !(CVL->(FieldPos("CVL_TIPSEQ")) > 0)
		Help("  ",1,"CTB110TIPSEQ",,STR0017 ,1,0) //"Campo CVL_TIPSEQ nใo consta no dicionario, por favor verificar." 
		lRet := .F.
	EndIf
Else
	If lRet .And. cSegofi == '8'
		Help("  ",1,"ONLYEQUADOR",, STR0018 ,1,0) //"Disponivel apenas no equador." 
		lRet := .F.
	Endif
Endif

If lRet
	dbSelectArea(cString) 
	mBrowse( 6,1,22,75,cString)
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA110Dlgบ Autor ณ Anderson Goncalves บ Data ณ  24/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Montagem da tela com Enchoice e getDados                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function CTBA110Dlg(xParam1,xParam2,xParam3) 

Local cAliasE := xParam1           // Tabela cadastrada no Dicionario de Tabelas (SX2) que sera editada
// Vetor com nome dos campos que serao exibidos. Os campos de usuario sempre serao              
// exibidos se nao existir no parametro um elemento com a expressao "NOUSER"                    
Local aCpoEnch  	:= { "CVL_COD", "CVL_DESCR"}
Local aAlterEnch	:= {""}		// Vetor com nome dos campos que poderao ser editados                                           
Local nOpc    		:= xParam3 	// Numero da linha do aRotina que definira o tipo de edicao (Inclusao, Alteracao, Exclucao, Visualizacao)
Local nReg    		:= xParam2	// Numero do Registro a ser Editado/Visualizado (Em caso de Alteracao/Visualizacao)
// Vetor com coordenadas para criacao da enchoice no formato {<top>, <left>, <bottom>, <right>} 
Local aPos		  	:= {019,002,048,550}                      
Local nModelo		:= 3     	// Se for diferente de 1 desabilita execucao de gatilhos estrangeiros                           
Local lF3 		  	:= .F.		// Indica se a enchoice esta sendo criada em uma consulta F3 para utilizar variaveis de memoria 
Local lMemoria 		:= .T.		// Indica se a enchoice utilizara variaveis de memoria ou os campos da tabela na edicao         
Local lColumn		:= .F.		// Indica se a apresentacao dos campos sera em forma de coluna                                  
Local caTela 		:= "" 		// Nome da variavel tipo "private" que a enchoice utilizara no lugar da propriedade aTela       
Local lNoFolder		:= .F.		// Indica se a enchoice nao ira utilizar as Pastas de Cadastro (SXA)                            
Local lProperty		:= .T.		// Indica se a enchoice nao utilizara as variaveis aTela e aGets, somente suas propriedades com os mesmos nomes
                                                                                                                                             
Local nX			:= 0                                                                                                              
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis da MsNewGetDados()      ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
// Vetor responsavel pela montagem da aHeader
Local aCpoGDa       := {"CVM_DTINI","CVM_RAD","CVM_SEQINI","CVM_INCRE","CVM_SEQULT","CVM_DTSEQ","CVM_DESCR"}                                                                                                 
// Vetor com os campos que poderao ser alterados                                                                                
Local aAlter     	:= {""}
Local nSuperior    	:= 052           	// Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= 002           	// Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= 270          	// Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= 622           	// Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem
// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia  
Local nOpc1        	:= GD_INSERT+GD_DELETE+GD_UPDATE                                                                            
Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols                  
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)      
Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.            
                                        // Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do            
                                        // segundo campo>+..."                                                               
Local nFreeze      	:= 000              // Campos estaticos na GetDados.                                                               
Local nMax         	:= 999              // Numero maximo de linhas permitidas. Valor padrao 99                           
Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo                                           
Local cSuperDel 		:= ""              	// Funcao executada quando pressionada as teclas <Ctrl>+<Delete>                    
Local cDelOk			:= "AllwaysTrue"   	// Funcao executada para validar a exclusao de uma linha do aCols                   
// Objeto no qual a MsNewGetDados sera criada                                      
Local oWnd				:= Nil                                                                                                  
Local aHead				:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader                    
Local aCol				:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols
Local aObjects			:= {}
Local aPosObj			:= {}
Local aSize				:= {}        

Local cSegofi			:= Alltrim(GetMv( "MV_SEGOFI" , .F. , "0" ))
Local lModCorr			:= GetNewPar("MV_CTBLBSQ","N") == "S"
Local lGrvCorr			:= ExistBlock("CTB110LBC")    

// Variaveis Private da Funcao
Private oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        
// Privates das NewGetDados
Private oGetDados

Do Case
	Case xParam3 == 2
		VISUAL := .T.     

	Case xParam3 == 3
		INCLUI := .T. 
		aAlter := {"CVM_DTINI","CVM_RAD","CVM_SEQINI","CVM_DESCR","CVM_INCRE"} 
		aAlterEnch	:= {"CVL_COD","CVL_DESCR"}

		If cSegofi == "8"
			aAdd( aAlterEnch, "CVL_TIPSEQ" )
		EndIf

	Case xParam3 == 4
		ALTERA := .T.                                                
		aAlter := {"CVM_DTINI","CVM_RAD","CVM_SEQINI","CVM_DESCR","CVM_INCRE"}
		aAlterEnch	:= {"CVL_DESCR"} 	   

		If cSegofi == "8"
			aAdd( aAlterEnch, "CVL_TIPSEQ" )
		EndIf

	Case xParam3 == 5
		DELETA := .T.
EndCase    

If cSegofi == "8"
	aAdd( aCpoEnch  , "CVL_TIPSEQ" )
EndIf

If ((ALTERA .Or. DELETA) .And. CVL->CVL_COD $ "01/02/03/04") .And. !lModCorr
   Help( " ", 1, "RESCODDIA" )
	Return                                                           
EndIf

oWnd := oDlg 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Faz o calculo automatico de dimensoes de objetos     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aSize := MsAdvSize()
AAdd( aObjects, { 100, 30, .T., .T. } )
AAdd( aObjects, { 100, 70, .T., .T. } )
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aPosObj 	:= MsObjSize( aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL

RegToMemory(cAliasE,If(nOpc == 3,.T.,.F.), .F.)


oEnchoice := MsMGet():New(cAliasE,nReg,nOpc,/*aCRA*/,/*cLetra*/,/*cTexto*/,aCpoEnch,aPosObj[1],aAlterEnch,nModelo,;
/*nColMens*/,/*cMensagem*/,/*cTudoOk*/,oDlg,lF3,lMemoria,lColumn, caTela, lNoFolder, lProperty) 		


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega o aHeader										 			ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DbSelectArea("SX3")                                                                                                             
SX3->(DbSetOrder(2)) // Campo                                                                                                   
For nX := 1 to Len(aCpoGDa)                                                                                                     
	If SX3->(DbSeek(aCpoGDa[nX]))                                                                                                 
			aAdd(aHead, { AllTrim(X3Titulo()),;
                        SX3->X3_CAMPO,;
                        SX3->X3_PICTURE,;
                        SX3->X3_TAMANHO,;
                        SX3->X3_DECIMAL,;
                        SX3->X3_VALID,;
                        SX3->X3_USADO,;
                        SX3->X3_TIPO,;
                        SX3->X3_F3,;
                        SX3->X3_CONTEXT,;
                        X3Cbox(),;
                        SX3->X3_RELACAO,;
                        If(Empty(SX3->X3_WHEN),'.T.',SX3->X3_WHEN),;
                        SX3->X3_VISUAL,;
                        SX3->X3_VLDUSER,;
                        SX3->X3_PICTVAR,;
                        SX3->X3_OBRIGAT})


	Endif                                                                                                                         
Next nX                                                                                                                         
                                                             
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se for inclusใo inicializa as variaveis                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If nOpc == 3                                                                                        
	aAux := {}                          
	For nX := 1 to Len(aCpoGDa)         
		If DbSeek(aCpoGDa[nX])             
			Aadd(aAux,CriaVar(SX3->X3_CAMPO))
		Endif                              
	Next nX                                                              
Else
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Carrega a GetDados com os registros correspondentes da tabela CVM   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	aAux := {}
	dbSelectArea("CVM")
	CVM->(dbSetOrder(1))
	CVM->(dbSeek(xFilial("CVM")+CVL->CVL_COD))
	While CVM->(!EOF()) .and. xFilial("CVM") == CVM->CVM_FILIAL  .AND. CVM->CVM_COD == CVL->CVL_COD
		Aadd(aCol,{	CVM->CVM_DTINI,;
					CVM->CVM_RAD,;
					CVM->CVM_SEQINI,;
					CVM->CVM_INCRE,;
					CVM->CVM_SEQULT,;
					CVM->CVM_DTSEQ,;
					CVM->CVM_DESCR,;
					.f.})
		CVM->(dbSkip())
	Enddo
EndIf                            

oGetDados:= MsNewGetDados():New(aPosObj[2][1],aPosObj[2][2],aPosObj[2][3],aPosObj[2][4],nOpc1,cLinOk,cTudoOk,cIniCpos,;                               
                             aAlter,nFreeze,nMax,"CTBA110Vld()",cSuperDel,cDelOk,oWnd,aHead,aCol) 

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(CTBA110Lok(),(nOpc=1,CTBA110Tok(nReg),oDlg:End(),nOpc := 0),)},{||oDlg:End()})
         
If lGrvCorr .And. !DELETA .And. nOpc == 0
	ExecBlock("CTB110LBC",.F.,.F.)
EndIf

Return(.T.) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออหออออออออออออออออออออหออออออหอออออออออออออปฑฑ
ฑฑบPrograma  ณMenuDef   บAutor  บAnderson Goncalves  บ Data บ  24/04/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออสออออออออออออออออออออสออออออสอออออออออออออนฑฑ
ฑฑบDescri…o ณ Utilizacao do menu Funcional                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณArray com opcoes da rotina.                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
                                                                    
Static Function MenuDef()

Local aRotMenuDef := {} 

AADD( aRotMenuDef, { STR0003	, "AxPesqui"  						, 0 , 1 } ) //"Pesquisar"
AADD( aRotMenuDef, { STR0004	, "CTBA110Dlg('CVL',Recno(),2)" 	, 0 , 2 } ) //"Visualizar"
AADD( aRotMenuDef, { STR0005	, "CTBA110Dlg('CVL',Recno(),3)" 	, 0 , 3 } ) //"Incluir"
AADD( aRotMenuDef, { STR0006	, "CTBA110Dlg('CVL',Recno(),4)" 	, 0 , 4 } ) //"Alterar"
AADD( aRotMenuDef, { STR0007	, "CTBA110Dlg('CVL',Recno(),5)" 	, 0 , 5 } ) //"Excluir"

Return(aRotMenuDef)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA110Lokบ Autor ณ SI4004 - Anderson Goncalves บ Data ณ  20/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Funcao de validar as Linhas da GetDados                             บฑฑ
ฑฑบ          ณ                              									   บฑฑ      
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบRetorno   ณ aRotina := aRotMenuDef											   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB			                                                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                    

Static Function CTBA110Lok()                     

Local nX := 0
Local nY := 0

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica os campos obrigatorios da Enchoice                             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If ALTERA .or. INCLUI
	
	If Empty(M->CVL_COD)
		Help(" ",1,"OBRIGAT",,"Diario",4)
		Return(.f.)
	EndIf
	If Empty(M->CVL_DESCR)
		Help(" ",1,"OBRIGAT",,"Descricao", 4)
		Return(.f.)
	EndIf
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica os campos obrigatorios da GetDados                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
	For nY := 1 To Len(oGetDados:aHeader)
		If AllTrim(oGetDados:aHeader[nY,2]) $ "CVM_DTINI/CVM_RAD/CVM_SEQINI/CVM_DESCR" 
			For nX := 1 To Len(oGetDados:aCols)                                 
					If Empty(oGetDados:aCols[nX,nY]) .and. !(oGetDados:aCols[nX,08])
						Help(" ",1,"OBRIGAT",,RetTitle(oGetDados:aHeader[nY,2]),4)
						Return(.f.)
					EndIf                                                                    
			Next nX 
		EndIf
	Next nY 
EndIf 

Return(.T.)                                          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA110Tokบ Autor ณ SI4004 - Anderson Goncalves บ Data ณ  20/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gravacao das informacoes dentro do sistema, tabelas CVL e CVM       บฑฑ
ฑฑบ          ณ                            										   		  บฑฑ      
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB			                                                     บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                    

Static Function CTBA110Tok(nReg,nOpc)                                       

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis da Rotina 													   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
Local lGrava 	:= Nil 
Local nY     	:= 0
Local nX     	:= 0
Local lDeleteOK	:= .T.
Local cSegofi  		:= AllTrim(GetMv( "MV_SEGOFI" , .F. , "0" ))

dbSelectArea("CVL")
CVL->(dbSetOrder(1)) 

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณDefinecao se ้ falso ou verdadeiro para o RECLOCK                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
If ALTERA .or. DELETA
	lGrava := .f.
	CVL->(dbGoTo(nReg))
ElseIf INCLUI 
	lGrava := .t.
EndIf 

Begin Transaction
    
	If ALTERA .or. INCLUI                                                                        
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAltera็ใo, inclusใo ou dele็ใo na tabela CVL                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
		RecLock("CVL",lGrava)
		If ALTERA .or. INCLUI 
			CVL->CVL_FILIAL		:= xFilial("CVL")
			CVL->CVL_COD 		:= M->CVL_COD
			CVL->CVL_DESCR 		:= M->CVL_DESCR
			If  cSegofi == "8" 
				CVL->CVL_TIPSEQ		:= M->CVL_TIPSEQ
			EndIf
		ElseIf DELETA
			CVL->(dbDelete())
		EndIf
		msUnlock()     
    
    	dbSelectArea("CVM")
		CVM->(dbSetOrder(1))
	
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณAltera็ใo, inclusใo ou dele็ใo na tabela CVM                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
		For nX := 1 To Len(oGetDados:aCols)
			If !oGetDados:aCols[nX,08]				
					lGrava := !(CVM->(dbSeek(xFilial("CVM")+M->CVL_COD+dtos(oGetDados:aCols[nX,01])+oGetDados:aCols[nX,02])))
					RecLock("CVM",lGrava)  					
					For nY := 1 To Len( oGetDados:aHeader ) 
						CVM->( FieldPut(FieldPos(oGetDados:aHeader[nY,2]), oGetDados:aCols[nX, nY] ) )
					Next nY
					CVM->CVM_FILIAL 	:= xFilial("CVM")
					CVM->CVM_COD 		:= CVL->CVL_COD
					msUnlock()
			Else
				If (CVM->(dbSeek(xFilial("CVM")+M->CVL_COD+dtos(oGetDados:aCols[nX,01])+oGetDados:aCols[nX,02])))
					RecLock("CVM",.F.)
					CVM->(dbDelete()) 
					msUnlock()
				EndIf
			EndIf
		Next nX
	ElseIf DELETA 
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณDeleta o cabe็alho                                                      ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
		lDeleteOK := DelCritica( CVL->CVL_COD )

		IF lDeleteOk
			dbSelectArea("CVL")
			RecLock("CVL",.f.)
			CVL->(dbDelete())
			msUnlock()

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณDeleta os itens                                                         ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 	
			CVM->(dbSeek(xFilial("CVM")+CVL->CVL_COD))	
			While CVM->(!EOF()) .and. CVM->(CVM_FILIAL+CVM_COD) == xFilial("CVM")+CVL->CVL_COD
				RecLock("CVM",.f.)
				CVM->(dbDelete())
				msUnlock()
				CVM->(dbSkip())
			Enddo
		EndIf
	Endif

End Transaction                           
	
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัอออออออออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBA110Vldบ Autor ณ SI4004 - Anderson Goncalves บ Data ณ  20/02/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯอออออออออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Validacao da getDados para a nao duplicacao de campos               บฑฑ
ฑฑบ          |                                                                     บฑฑ      
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGACTB			                                                   บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                                                  

Function CTBA110Vld()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVariaveis da rotina													   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
Local lLog := .f. 
Local dData := oGetDados:aCols[n,1]

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se tem registros duplicados dentro da GetDados                 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู 
If AllTrim(READVAR()) == "M->CVM_RAD"

	nPos := Ascan(oGetDados:aCols,{|x| Dtos(x[1])+x[2] = dtos(dData)+M->CVM_RAD}) 
	
	If nPos > 0 .And. nPos != oGetDados:nAt 
		Help (" ", 1, STR0008,,STR0009, 3, 0)  //"Chave Duplicada"###"Registro ja existente dentro da GetDados"
		Return(.f.)
	EndIf
	
EndIf

Return(.t.) 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDelCriticaบAutor  ณRenato F. Campos    บ Data ณ  06/28/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function DelCritica( cCod )
Local lOk := .T.
Local lCtb110Excl := ExistBlock( "CTB110EXCL" )

DEFAULT cCod := ""

IF lOk .And. lCtb110Excl
	lOk := ExecBlock("CTB110EXCL" , .F. , .F. , {cCod} )
Endif

IF lOk .And. ! Empty( cCod )
	DbSelectArea( "CT2" )
	DbSetOrder(14)

  	IF MsSeek( xFilial( "CT2" ) + cCod )
		lOk := .F.
		MsgAlert( "C๓digo do diario jแ utilizado" ) 
 	EndIf
ENDIF

RETURN lOk
