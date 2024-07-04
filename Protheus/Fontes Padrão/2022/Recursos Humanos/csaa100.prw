#include "Protheus.ch"
#include "CSAA100.CH"
#include "fwadaptereai.ch"

/*/                                                  									
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡…o    ³ CSAA100    ³Autor  ³ Cristina Ogura        ³ Data ³ 25/07/2001  º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºDescri‡…o ³ Cadastramento dos Departamentos de uma empresa                  º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºParametros³ Nenhum                                                          º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±º         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                  º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±ºProgramador ³ Data     ³ BOPS ³  Motivo da Alteracao                        º±±
±±ÌÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¹±±
±±³Cecilia Car.³07/07/2014³TPZVTW³Incluido o fonte da 11 para a 12 e efetuada  ³±±
±±³            ³          ³      ³a limpeza.                                   ³±±
±±³Marcos Perei³03/09/2015³PCREQ-³Produtizacao projeto Gestão Pública na 12.   ³±±
±±³            ³          ³5342  ³                                             ³±±
±±³Renan Borges³05/02/2016³TUGHE3³Criação do ponto de entrada CSAA100VLD para  ³±±
±±³     	   ³          ³      ³que seja possivel realizar validações customi³±±
±±³     	   ³          ³      ³zadas nos dados do cadastro.                 ³±±
±±³Eduardo K.M.³21/06/2016³TVFKXG³Criação das funções CrgKeyini e VldDepSup    ³±±
±±³     	   ³          ³  	 ³para que tratar alteração e exclusão de 	   ³±±
±±³     	   ³          ³      ³departamentos que possuam solicitações  	   ³±±
±±³     	   ³          ³      ³em aberto e carga dp campo QB_KEYINI    	   ³±±
±±³Raquel H.   ³29/06/2016³TVFOB3³Ajuste p/ consulta padrao da matricula       ³±±
±±³     	   ³          ³      ³responsavel 							       ³±±
±±³P. Pompeu..³21/09/2016³TVTZYD³Criacao da funcao CCDescSQB....................±±
±±³Flavio C.  ³10/11/2016³TWMG32³Correção função VldDepSup para tratar alias   ³±±
±±³Joao Balbino³20/12/2016³MPRIMESP-264³Ajuste na validação do departamento na ³±±
±±³     	   ³          ³      ³estrutra de aprovação por dp				   ³±±
±±³Joao Balbino³14/06/2017³MPRIMESP10300³Ajuste na validação do reponsável do  ³±±
±±³     	   ³          ³      ³departamento quando SQB for exclusiva.       ³±±
±±³M. Silveira ³20/06/2017³DRHPON|Ajuste na funcao fEstrutDepto() p/ nao gerar ³±±
±±³ 		   ³		  ³TP-843|o codigo QB_KEYINI em duplicidade.           ³±±
±±³Leonardo M. ³27/09/2017³MPRIMESP³ Ajuste para permitir alterar resp. do     ³±±
±±³     	   ³          ³-10149  ³ departamento quando o mesmo não tem       ³±±
±±³     	   ³          ³        ³ solicitações pendentes.			       ³±±		
±±³Wesley Alves³20/08/2020³DRHGCH-20762³Envio de dados para gravar na RJP      ³±±
±±³Pereira.    ³          ³            ³quando houver alteração de registros.  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±                
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±± 
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/*
Usar essa documentação quando inclui o fonte em alguma pasta de inovação, por exemplo
12.1.6, a cada merge com o fonte da sustentação atualizar as informações abaixo para 
que no merge final fique facil a atualização do fonte
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍ³±±
±±³Data Fonte Sustentação³ ChangeSet ³±±
±±³ÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ³±±  
±±³    07/07/2015        ³  313629   ³±±
±±³    03/08/2015        ³  319747   ³±± 
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÑÍÍÍÍÍ±±
*/

Function CSAA100(nOpcAuto , aRotinaNew, aRotAuto, nOpc )
	Local cFiltra			//Variavel para filtro
	Local aIndFil	:= {}	//Variavel Para Filtro
	Local nPos
	Local nX

	Private aSQBVirtual := {}
	Private aSQBVisual  := {}
	Private aSQBHeader  := {}
	Private aSQBFields  := {}
	Private aSQBAltera  := {}
	Private aSQBNotAlt  := {}

	Private lGestPubl	:= if(ExistFunc("fUsaGFP"),fUsaGFP(),.f.) //Verifica se utiliza o modulo de Gestao de Folha Publica - SIGAGFP
	               
	Private bFiltraBrw := {|| Nil}		//Variavel para Filtro
	Private cCadastro  := ""
	Private aRotina    := MenuDef() // ajuste para versao 9.12 - chamada da funcao MenuDef() que contem aRotina
	
	Private lExecAuto  	:= ( aRotAuto <> Nil  .And. nOpc <> Nil )
	Private cBkpFilAnt    := cFilAnt
	Private lOrgCfg		:= SuperGetMv("MV_ORGCFG",,"0") == "0"	
	
	If lGestPubl
		cCadastro  := OemToAnsi(STR0038)	//"Lotações"	
	Else
		cCadastro  := OemToAnsi(STR0001)	//"Departamento"	
	Endif
	If SQB->(ColumnPos('QB_KEYINI')) > 0 	
		CrgKeyini()// Faz carga incial do campo QB_KEYINI
	EndIf	
	
   	If ( nPos := Ascan(aRotina,{|x| Upper(x[2])=="CSA100ATU"}) ) > 0
    	aDel(aRotina , nPos)
		aSize(aRotina,Len(aRotina)-1)
   EndIf
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SQB")
	dbSetOrder(1)
	dbGotop()

If lExecAuto
	nPos := aScan(aRotAuto, {|x| x[1] == "QB_FILIAL" })
	If nPos > 0
		M->QB_FILIAL := CriaVar( "QB_FILIAL" )
		M->QB_FILIAL := aRotAuto[ nPos ][2]
		aAdd( aSQBFields , "QB_FILIAL" )
	EndIf

	aSQBHeader := SQB->( GdMontaHeader( NIL , @aSQBVirtual , @aSQBVisual , NIL , {"SQB_FILIAL"}, , .T. ) )

	For nX := 1 To Len( aSQBHeader )
		//If ( nOpc == 3 .OR. nOpc == 4 )
			nPos := aScan(aRotAuto, {|x| x[1] == aSQBHeader[ nX ][ 02 ] })
			If nPos > 0
				&( "M->"+aSQBHeader[ nX , 02 ] ) := CriaVar( aSQBHeader[ nX , 02 ] )
				&( "M->"+aSQBHeader[ nX , 02 ] ) := aRotAuto[ nPos ][2]
				aAdd( aSQBFields , aSQBHeader[ nX , 02 ] )
			EndIf
		//ElseIf ( nOpc == 5 )
		//EndIf
	Next nX

	SQB->(DBSEEK(M->QB_FILIAL + M->QB_DEPTO))

	MBrowseAuto(nOpc,aRotAuto,"SQB", .F.)
Else	
	cFiltra 	:= CHKRH(FunName(),"SQB","1")	
	bFiltraBrw	:= {|| FilBrowse("SQB",@aIndFil,@cFiltra) }

	Eval(bFiltraBrw)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SQB")
	dbGoTop()
	
	MBrowse(6, 1,22,75,"SQB")
	         
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	EndFilBrw("SQB",aIndFil)
	
EndIf
	cFilAnt := cBkpFilAnt
	
	dbSelectArea("SQB")
	dbSetOrder(1)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Csa100Rot ³ Autor ³ Cristina Ogura       ³ Data ³ 25.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Opcao de exclusao dos departamentos                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 : Alias                                              ³±±
±±³          ³ ExpN1 : Registro                                           ³±±
±±³          ³ ExpN2 : Opcao                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ CSAa100       ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CSA100Rot(cAlias, nReg, nOpc)
	Local lConfirma
	//Local aAC:= { STR0007,STR0008 } 	//"Abandona"###"Confirma"
	Local lAchou :=.F.
	Local aPosEnch:={}
	Local aAreaSQB := {}
	Local aAdvSize		:= {}
	Local aInfoAdvSize	:= {}
	Local aObjCoords 	:= {}
	Local aObjSize		:= {}	
	Local nLenSX8  		:= GetSX8Len()
	Private oEnSQB 
	
If lExecAuto
	aAreaSQB := getArea()
	lConfirma := .T.
Else 
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }					 
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords ) 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a entrada de dados do arquivo                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aTELA[0][0],aGETS[0]
	
	dbSelectArea(cAlias)
	dbSetOrder(1)
	
	RegToMemory(cAlias, (nOpc == 3))

	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL
                 
	oEnSQB	:= MsmGet():New(	cAlias		,;
								nReg		,;
								nOpc		,;
								NIL			,;
								NIL			,;
								NIL			,;
								NIL,; //aRdmFields	,;
								aObjSize[1],;
								NIL,; //aRdmAltera	,;
								NIL			,;
								NIL			,;
								NIL			,;
								oDlg		,;
								NIL			,;
								.F.			,;
								NIL			,;
								.F.			 ;
							)
	
	//Grava a area corrente para o possivel desposicionamento
	//que ocorre atraves da consulta padrao SQB, no campo Dep. Superior
	aAreaSQB := getArea()
	
	If SQB->(ColumnPos('QB_KEYINI')) > 0 	
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(oEnSQB:aGets, oEnSQB:aTela) .AND. Csa100VldPE() .AND. !ExistKeySqb() .AND. ValFilMat() .And. VldDepSup() .And. RespDepto(), (oDlg:End(), lConfirma := .T.), NIL)}, {|| lConfirma := .F., oDlg:End()}) 
	Else
		ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| If(Obrigatorio(oEnSQB:aGets, oEnSQB:aTela) .AND. Csa100VldPE() .AND. !ExistKeySqb() .AND. ValFilMat(), (oDlg:End(), lConfirma := .T.), NIL)}, {|| lConfirma := .F., oDlg:End()}) 
	Endif

EndIf

	If lConfirma == .T.   
	    //Restaura a area corrente eliminando o problema de desposicionamento
	    //por consulta padrao
		restArea(aAreaSqb) 
		
		If nOpc == 5
			Cs100Dele(cAlias, nReg, nOpc)
		Else 
			Cs100Grava(nOpc)
		Endif
		If SuperGetMV( "MV_MDTGPE" , .F. , "N" ) == "S" .And. nOpc == 3 .And. FindFunction("MDTW030")
			MDTW030( "SQB" , M->QB_DEPTO ) //Executa o W.F. de Aviso do SESMT
		EndIf
	Else
		//Acionou o botao cancelar apos ter solicitado uma inclusao
		If __lSX8
			While ( GetSX8Len() > nLenSX8 )
				RollBackSX8()
			EndDo
		EndIf	  
	EndIf
	
Return                    
                           

/*Static Function BtnOkClick
	Local lTudoOk := EnchoTudOk( oEndRd0 )
Return 
*/


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs100Grava³ Autor ³ Cristina Ogura        ³ Data ³ 25.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava todos os registros referentes ao departamento         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Cs100Grava                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs100Grava(nOpcX)
	Local nCount
	Local nX
	Local nPos
    Local aDeptos
	Local aDadosAuto 	:= {}		// Array com os dados a serem enviados pela MsExecAuto() para gravacao automatica
    Local cNewDepto 	:= ""
    Local cIniOld		:= ""
    Local cDepSupAnt	:= SQB->QB_DEPSUP
	Local cKey			:= ""
	Local cAliasTmp		:= GetNextAlias()
	Local lKeyIni 		:= SQB->(ColumnPos('QB_KEYINI'))>0 
    Local lIntegDef  	:= FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI") .And. FWHasEAI("CSAA100",.T.,,.T.)
	Local lTsaDep	 	:= If( SQB->(ColumnPos('QB_RHEXP'))>0, SuperGetMv("MV_TSADEP", NIL ,.F. ),.F. )
	Local lTSREP	 	:= SuperGetMv( "MV_TSREP" , NIL , .F. )
	Local lProcessa		:= .F.
	Local lVdfQbCC		:= (GetMv( "MV_VDFQBCC",, "1" ) == "1")
	Local nLen			:= 0

	Local lProcNG		:= .F. // verifica se processa a integração NG

	Private lMsHelpAuto := .f.	// Determina se as mensagens de help devem ser direcionadas para o arq. de log
	Private lMsErroAuto := .f.	// Determina se houve alguma inconsistencia na execucao da rotina em relacao aos

	IF EMPTY(M->QB_CC) .AND. lGestPubl .AND. lVdfQbCC
		lProcessa := MsgYesNo("O centro de custo não foi informado. Deseja vincular ao centro de custo " + alltrim(M->QB_DEPTO) + " automaticamente? ") 
	Else	
		lProcessa := .T.
	EndIf
	
	IF SuperGetMv("MV_RHNG",.F. ,.F.)
		If nOpcx == 4 .AND. (M->QB_DEPTO <> SQB->QB_DEPTO .or. M->QB_DESCRIC <> SQB->QB_DESCRIC)
			lProcNG := .T.
		ELSEIF nOpcx <> 4
			lProcNG := .T.
		ENDIF
	ENDIF
	
	If lProcessa	
		ConfirmSX8()
		If nOpcx == 3 .OR. nOpcx == 4
			RecLock("SQB", Iif(nOpcx == 3, .T., .F.))
			
			For nCount := 1 To SQB->(FCount()) 
				//Grava o campo filial 'manualmente' para quando a tabela estiver
				//exclusiva, a filial seja gravada corretamente
				If ( FieldName(nCount) == "QB_FILIAL" ) 
					SQB->QB_FILIAL := xFilial("SQB")
				Else
					If lExecAuto
						nPos := aScan(aSQBFields, {|x| x ==  FieldName(nCount) })
						If nPos > 0					
							SQB->(FieldPut(nCount, &( "M->"+aSQBFields[ nPos ] )))
						EndIf
					Else
						SQB->(FieldPut(nCount, GetMemVar( FieldName(nCount) )))
					EndIf
				EndIf
			Next nCount
			
			MsUnlock() 
		EndIf
		If SQB->(ColumnPos('QB_KEYINI')) > 0 .And. (nOpcx == 3 .Or. (nOpcx == 4 .And. cDepSupAnt <> SQB->QB_DEPSUP) .Or. Empty(SQB->QB_KEYINI))
			cIniOld := Alltrim(SQB->QB_KEYINI)
			
			If !Empty(SQB->QB_DEPSUP)
				cKey := FGetKeyIni(SQB->QB_FILIAL+SQB->QB_DEPSUP)
				nChave := 1		 	
				BeginSql alias cAliasTmp
					SELECT MAX(QB_KEYINI) AS KEYINI FROM %table:SQB% SQB WHERE
					SQB.%NotDel%
					AND SQB.QB_FILIAL = %exp:SQB->QB_FILIAL%
					AND SUBSTRING(SQB.QB_KEYINI,1,%exp:LEN(ALLTRIM(CKEY))%) = %exp:alltrim(cKey)% 
				EndSql
				If !(cAliasTmp)->(Eof())
					If Len(alltrim((cAliasTmp)->KEYINI)) == Len(alltrim(cKey))
						nChave := 1
					Else
						nChave := val(substr(alltrim((cAliasTmp)->KEYINI),Len(alltrim(cKey))+1,3))+1
					EndIf
				EndIf
				(cAliasTmp)->(dbCloseArea())
				
				cKey := Alltrim(cKey) + StrZero(nChave, 3)
				
				RecLock("SQB", .F.)
					SQB->QB_KEYINI :=  cKey
				MsUnlock()
				
				fTrocaKey(cIniOld, SQB->QB_DEPTO,SQB->QB_FILIAL)
			Else
				nChave := 1
				BeginSql alias cAliasTmp
					SELECT MAX(QB_KEYINI) AS KEYINI FROM %table:SQB% SQB WHERE
					SQB.QB_DEPSUP = %Exp:Space(GetSx3Cache("QB_DEPSUP", "X3_TAMANHO"))% AND
					SQB.%NotDel%
					AND SQB.QB_KEYINI <> '' 
				EndSql
				
				nLen := IIF(len(alltrim((cAliasTmp)->KEYINI)) >= 3, len(alltrim((cAliasTmp)->KEYINI)), 3)
				If !(cAliasTmp)->(Eof())
					nChave := val(substr(alltrim((cAliasTmp)->KEYINI), 1, nLen)) + 1
				EndIf
				(cAliasTmp)->(dbCloseArea())
				
				nLen := IIF(len(cValToChar(nChave)) >= 3, len(cValToChar(nChave)), 3)
				RecLock("SQB", .F.)
					SQB->QB_KEYINI :=   StrZero(nChave,nLen)
				MsUnlock()
				
				fTrocaKey(cIniOld, SQB->QB_DEPTO,SQB->QB_FILIAL) 
			EndIf
			CrgKeyini(.T., cIniOld)
		EndIf
		//-- Inicializa a integracao via WebServices TSA
		If lTSREP .AND. lTsaDep
			oObjREP := PTSREPOBJ():New()
			
			//Executa o WebServices TSA - Centro de Custo
			If oObjREP:WSAllocation( 3 )
				
				//Grava o Log do controle de exportacao WebServices TSA
				oObjRep:WSUpdRHExp( "SQB" )
				
			Endif
		EndIF
		
		If lIntegDef
			// chamada da função integdef
			FwIntegDef('CSAA100')
		EndIf
		
		UpdRD4Desc(cEmpAnt, SQB->QB_FILIAL, SQB->QB_DEPTO, SQB->QB_DESCRIC, "1")
		ConfirmSX8()
		
		if lProcNG
			fPrepDadosApi(nOpcx)
		Endif
		
		If lGestPubl .And.; 						// Gestao de Folha Publica
			lVdfQbCC    	// Indica se o Cadastro de Centro de Custo CTT será 1x1 com o Departamento SQB (1-Sim;2-Não).
			
			If (nOpcx == 3 .or. nOpcX == 4) .and. empty(SQB->QB_CC)
					CTT->(DBSETORDER(1))
					IF !CTT->(dbSeek(xFilial("CTT") + SQB->QB_DEPTO))  
						aDadosAuto:= {	{'CTT_CUSTO' , SQB->QB_DEPTO     , Nil},;	// Especifica qual o Código do Centro de Custo.
										{'CTT_CLASSE', "2"			     , Nil},;	// Especifica a classe do Centro de Custo, 
										{'CTT_NORMAL', "2"			     , Nil},;	// 1-Receita ; 2-Despesa                                       
										{'CTT_DESC01', SQB->QB_DESCRIC   , Nil},;	// Indica a Nomenclatura do Centro de Custo
										{'CTT_DTEXIS', CTOD("01/01/1980"), Nil}}	// Especifica qual a Data de Início de Existência para CC
									
						MSExecAuto({|x, y| CTBA030(x, y)},aDadosAuto, 3)
						If lMsErroAuto	
							MostraErro()
						EndIf					
					Endif
					RecLock("SQB", .F.)
						SQB->QB_CC := SQB->QB_DEPTO
					MSUNLOCK()
			Endif
			
		Endif
		
		// ---------------------------------------------------------------------------------
		// Alterado por Cleverson Ernesto Silva - em 31/05/2015
		// -
		// Adicionado chamada da funcao At202AtSup para atualizar o cadastro
		// TECA202 - Area de Supervisao automaticamente nas Alteracoes do
		// cadastro de departamento
		// ---------------------------------------------------------------------------------
		If FindFunction("At202AtSup") .AND. ( nOpcx == 3 .OR. nOpcx == 4 )
			At202AtSup (SQB->QB_DEPTO, SQB->QB_FILRESP , SQB->QB_MATRESP )
		EndIf
	Else	
		RollBackSX8()
	ENDIF
	
Return

/*/{Protheus.doc} FGetKeyIni
//Busca KeyIni de um departamento
@author flavio.scorrea
@since 14/08/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function FGetKeyIni(cChave)
Local aArea	:= GetArea()
Local cKey 	:= ""
dbSelectArea("SQB")
SQB->(dbSetOrder(1))
If SQB->(dbSeek(cChave))
	cKey := SQB->QB_KEYINI
EndIf
RestArea(aArea)
Return cKey

/*/{Protheus.doc} fTrocaKey
//Troca chave de departamentos filhos
@author flavio.scorrea
@since 14/08/2018
@version undefined
@example
(examples)
@see (links_or_references)
/*/
Static Function fTrocaKey(cIniOld, cDepto,cFilDepto) 
Local aArea		:= GetArea()
Local cAliasTmp	:= GetNextAlias()			
Local cKeyOld	:= ""
Local aDeptos	:={}
Local nCont		:= 0

If Empty(cIniOld)
	return
EndIf

BeginSql alias cAliasTmp
	SELECT * FROM  %table:SQB% SQB WHERE
	SQB.%NotDel%
	AND SQB.QB_FILIAL = %exp:cFilDepto%
	AND SUBSTRING(SQB.QB_KEYINI,1,%exp:Len(cIniOld)% ) = %exp:cIniOld% 
	AND SQB.QB_DEPTO <> %exp:cDepto% 
EndSql

While !(cAliasTmp)->(Eof())
	
	dbSelectArea("SQB")
	SQB->(dbSetOrder(1))
	If SQB->(dbSeek((cAliasTmp)->QB_FILIAL+(cAliasTmp)->QB_DEPTO))
		RecLock("SQB", .F.)
			SQB->QB_KEYINI :=  ""//aDeptos [nCont,5]
		MsUnlock()
	EndIf
		
	(cAliasTmp)->(dbSkip())
EndDo
(cAliasTmp)->(dbCloseArea())

RestArea(aArea)
Return

//
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Cs100Dele ³ Autor ³ Cristina Ogura        ³ Data ³ 25.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Deleta todos os registros referentes ao departamento        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Cs100Dele                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Cs100Dele(cAlias, nReg, nOpc)
	
	Local cIndCond	:= ""
	Local cArqNtx	:= ""
	Local c2IndCond	:= ""
	Local c2ArqNtx	:= ""
	Local n2Index	:= 0
	Local cDepto	:= SQB->QB_DEPTO
	Local aSQBarea	:= SQB->(GetArea())
	Local lRet		:= .T.
	Local lSQ3		:= .F.
	Local lTsaDep	:= If( SQB->(ColumnPos('QB_RHEXP'))>0, SuperGetMv("MV_TSADEP", NIL ,.F. ),.F. )
	Local lTSREP	:= SuperGetMv( "MV_TSREP" , NIL , .F. )
	Local oObjREP
    
    Local lIntegDef  :=  FindFunction("GETROTINTEG") .And. FindFunction("FWHASEAI") .And. FWHasEAI("CSAA100",.T.,,.T.)
	
		//-- Verifica se o departamento esta em alguma visao 
	IF 	( lRet:= fDelDeptoVisao( xFilial('SQB'), cDepto ) )

	   	//-- Verifica delecao através do SX9
	   	lRet:=  csaa100ChkDel( cAlias , nReg , nOpc, cDepto )
	   	
	   	// CHAMA O PE APÓS A VALIDAÇÃO DA SX9.
	   	If lRet
	   		lRet := CsaPosVldX9()
	   	Endif

   		// CASO O lRet NÃO SEJA .T. NÃO HA NECESSIDADE DE EXECUTAR O BLOCO ABAIXO.
   		If lRet
	   		//-- se permitiu a delecao através do SX9, tenta as relacoes especiais do SQB
			//# Verifica se existe algum Depto Superior com este codigo de avaliacao
			c2IndCond	:= "SQB->QB_FILIAL+SQB->QB_DEPSUP"		
			c2ArqNtx  	:= CriaTrab(NIL,.F.)
			IndRegua("SQB", c2ArqNtx, c2IndCond,,, STR0010)		// "Selecionando Registros..."	
			n2Index		:= RetIndex("SQB")
			
			dbSetOrder(n2Index + 1)               
			If dbSeek(xFilial("SQB") + cDepto)
				Help("", 1, "CS100NPODE")		// Nao posso excluir este departamento pois existem cargso ligados a ele"
				lRet := .F.
			EndIf
			
			//# Restaura indices e apaga arquivo temporario
			dbSelectArea("SQB")
			Set Filter To
			RetIndex("SQB")
			dbSetOrder(1)
			FErase (c2ArqNtx + OrdBagExt())
			
			RestArea(aSQBarea)
		EndIf
		
		If lRet
			// Verifica se existe algum calendario/curso com este codigo de avaliacao
			dbSelectArea("SQ3")
			dbSetOrder(1)
			
			cIndCond	:= "SQ3->Q3_FILIAL+SQ3->Q3_DEPTO"		
			cArqNtx  	:= CriaTrab(NIL,.F.)
			IndRegua("SQ3", cArqNtx, cIndCond,,, STR0010)		// "Selecionando Registros..."	
			nIndex		:= RetIndex("SQ3")
			
			dbSetOrder(nIndex + 1)               
			If dbSeek(xFilial("SQ3") + SQB->QB_DEPTO)
				Help("", 1, "CS100NPODE")		// Nao posso excluir este departamento pois existem cargso ligados a ele"
				lRet := .F.
			EndIf
			
			lSQ3 := .T.
		EndIf
		
		If lRet
			Begin Transaction
				dbSelectArea("SQB")
				dbSetOrder(1)
				If dbSeek(xFilial("SQB") + SQB->QB_DEPTO)
					RecLock("SQB", .F., .T.)
					dbDelete()
					WriteSx2("SQB")
				EndIf	         
			End Transaction
		EndIf

		If lTSREP .AND. lTsaDep
			oObjREP := PTSREPOBJ():New()

			//Executa o WebServices TSA - Centro de Custo
			oObjREP:WSAllocation( 5 )
		EndIF
        
        If lIntegDef
			// chamada da função integdef
			FwIntegDef('CSAA100')
		EndIf

		if SuperGetMv("MV_RHNG",.F. ,.F.)
			fPrepDadosApi(nOpc)
		Endif

		If lSQ3
			//# Restaura indices e apaga arquivo temporario
			dbSelectArea("SQ3")
			Set Filter To
			RetIndex("SQ3")
			dbSetOrder(1)
			FErase (cArqNtx + OrdBagExt())
		EndIf  
		
		dbSelectArea("SQB")
		dbSetOrder(1)
  		Else
    	Help("", 1, "CS100DEP")		// Nao posso excluir este departamento pois ele consta em outra tabela"
    Endif
    
Return Nil

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³csaa100ChkDel   ³Autor³Mauricio MR		  ³ Data ³12/09/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Verificar se o Depto Pode ser Deletado  					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Firmais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³CSAA100                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³NIL															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Firmais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function csaa100ChkDel( cAlias , nReg , nOpc, cDepto )

Local aArea		:= GetArea()
Local aAreas	:= {}
Local cFilSQB	:= xFilial( "SQB" )
Local lDelOk	:= .T.

//RCL
aAdd( aAreas , Array( 03 ) )
nAreas := Len( aAreas )
aAreas[nAreas,01] := RCL->( GetArea() )
aAreas[nAreas,02] := Array( 2 )
				aAreas[nAreas,02,01] := "RCL_FILIAL"
				aAreas[nAreas,02,02] := "RCL_DEPTO"
aAreas[nAreas,03] := RetOrdem( "RCL" , "RCL_FILIAL+RCL_DEPTO+RCL_POSTO" , .T. )


( cAlias )->( MsGoto( nReg ) )

lDelOk := ChkDelRegs(	cAlias			,;	//01 -> Alias do Arquivo Principal
						nReg			,;	//02 -> Registro do Arquivo Principal
						nOpc			,;	//03 -> Opcao para a AxDeleta
						cFilSQB		,;	//04 -> Filial do Arquivo principal para Delecao
						cDepto			,;	//05 -> Chave do Arquivo Principal para Delecao
						aAreas			,;	//06 -> Array contendo informacoes dos arquivos a serem pesquisados
						NIL 			,;	//07 -> Mensagem para MsgYesNo
						NIL				,;	//08 -> Titulo do Log de Delecao
						NIL				,;	//09 -> Mensagem para o corpo do Log
						.F.				,;	//10 -> Se executa AxDeleta
						.T.				,;	//11 -> Se deve Mostrar o Log
						NIL				,;	//12 -> Array com o Log de Exclusao
						NIL				,;	//13 -> Array com o Titulo do Log
						NIL				,;	//14 -> Bloco para Posicionamento no Arquivo
						NIL				,;	//15 -> Bloco para a Condicao While
						NIL				,;	//16 -> Bloco para Skip/Loop no While
						NIL				,;	//17 -> Verifica os Relacionamentos no SX9
						NIL				,;	//18 -> Alias que nao deverao ser Verificados no SX9
						NIL				,;	//19 -> Se faz uma checagem soft
						lExecAuto       ;  //20 -> Se esta executando rotina automatica
					)


RestArea( aArea )

Return( lDelOk )


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fDelDeptoVisao  ³Autor³Mauricio MR		  ³ Data ³12/09/2011³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Verificar se o Depto Pode ser Deletado  					³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Firmais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³CSAA100                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³NIL															³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Firmais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fDelDeptoVisao( cFil, cDepto )

Local aSaveArea	:= GetArea() 

Local cTipVis	:= "%RDK.RDK_HIERAR = '1' %" 
Local cQryRDK	:= ''
Local cBranco	:= ''

Local lNaoTemDepto := .T.
Local cOrdem	:= "RDK_FILIAL+RDK_HIERAR+RDK_TIPO+RDK_CODIGO"
Local nOrdem	:= 0	

nOrdem			:= RetOrdem(cOrdem)	
cOrdem	:= "%"+ cOrdem + "%"
cFilVisao  := xFilial( "RDK" , cFil )   

cOrdem	:= "%RDK_FILIAL+RDK_HIERAR+RDK_TIPO+RDK_CODIGO%"
				
cQryRDK := GetNextAlias()
    
BeginSql alias cQryRDK
	
	SELECT 	COUNT(*) AS QTDEDEPTO 
	FROM %table:RDK% RDK
	INNER JOIN %table:RD4% RD4
	ON	RD4_EMPIDE = %exp:cEmpAnt%
		AND	RD4_CODIDE = %exp:cDepto%
		AND	( RD4_FILIDE = %exp:cFil% OR  RD4_FILIDE = %exp:cBranco% ) 
		AND	RD4_CODIDE = %exp:cDepto%
	WHERE                         
		RDK_FILIAL = %exp:cFilVisao%
		AND %exp:cTipVis%
		AND RDK.%NotDel%
		AND RD4.%NotDel% 

EndSql

lNaoTemDepto:=Empty( (cQryRDK)->(QTDEDEPTO) )
(cQryRDK)->(DbCloseArea())

RestArea(aSaveArea)

Return( lNaoTemDepto )

/*                                	
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Luiz Gustavo     ³ Data ³28/12/2006³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Isola opcoes de menu para que as opcoes da rotina possam    ³
³          ³ser lidas pelas bibliotecas Framework da Versao 9.12 .      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³CSAA100                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   
Static Function MenuDef()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Array contendo as Rotinas a executar do programa      ³
	//³ ----------- Elementos contidos por dimensao ------------     ³
	//³ 1. Nome a aparecer no cabecalho                              ³
	//³ 2. Nome da Rotina associada                                  ³
	//³ 3. Usado pela rotina                                         ³
	//³ 4. Tipo de Transa‡„o a ser efetuada                          ³
	//³    1 - Pesquisa e Posiciona em um Banco de Dados             ³
	//³    2 - Simplesmente Mostra os Campos                         ³
	//³    3 - Inclui registros no Bancos de Dados                   ³
	//³    4 - Altera o registro corrente                            ³
	//³    5 - Remove o registro corrente do Banco de Dados          ³
	//³    6 - Alteracao sem inclusao de registro                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aRotina :=    { 	{ STR0002, "PesqBrw"	, 0, 1, NIL, .F.},;	//"Pesquisar"
							{ STR0003, "AxVisual"	, 0, 2},; 				//"Visualizar"
							{ STR0004, "Csa100Rot"	, 0, 3},; 				//"Incluir"
							{ STR0005, "Csa100Rot"	, 0, 4},; 				//"Alterar"
							{ STR0006, "Csa100Rot"	, 0, 5},;				//"Excluir"
    						{ STR0015, "Csa100Atu"	, 0, 4} }				//"Atualizar Visoes"
    						
    						
    Local aRet 	:= {}
    Local nX	:= 0
    
	//Ponto de Entrada para inclusão de itens no menu
	If ExistBlock("CSA100MEN")
		aRet 	 := Execblock("CSA100MEN",.F.,.F.)
		If ValType( aRet )== "A"
			For nX := 1 to Len(aRet)
				aAdd(aRotina, aRet[nX])
			Next nX
		EndIf	
	EndIf

Return aRotina     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CSAA100   ºAutor  ³Microsiga           º Data ³  10/16/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Verifica se a chave ja existe antes de incluir para evitar  º±±
±±º          ³o erro de chave duplicada                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ExistKeySqb()
	Local lRet := .F.
	
	If(ExistCpo("SQB" , M->QB_DEPTO,1,"",.F.)) .AND. Inclui
			MsgAlert(OemToAnsi(STR0014))
		lRet:=.T.
	EndIf
	
	//Não permite definir o próprio departamento como departamento superior
	If !lRet .and. (M->QB_DEPSUP == M->QB_DEPTO)
		If lGestPubl
			MsgAlert(OemToAnsi(STR0039)) //"A Lotação não pode ser o superior dele mesmo."
		Else
			MsgAlert(OemToAnsi(STR0036)) //"O departamento não pode ser o superior dele mesmo."
		Endif
		lRet := .T.
	EndIf
	        
Return lRet

Static Function RespDepto()
Local lRet := .T.

If !Empty(M->QB_DEPSUP) .and. (Empty(M->QB_FILRESP) .Or. Empty(M->QB_MATRESP))
	If lGestPubl
		MsgAlert(OemToAnsi(STR0040)) //"É obrigaório o preenchimnento de Filial e Matricula do responsável quando utiliza estrutura de lotações.
	Else
		MsgAlert(OemToAnsi(STR0037)) //"É obrigaório o preenchimnento de Filial e Matricula do responsável quando utiliza estrutura de departamentos.	
	Endif
	lRet := .F.
EndIf
	        
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Csa100Atu ºAutor  ³ Adilson Silva      º Data ³ 10/01/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Atualizar as Descricoes dos Departamentos na Tabela das    º±±
±±º          ³ Visoes - RD4.                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP11                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Csa100Atu()

Local aOldAtu := GETAREA()
Local bAction := { || CursorWait(), fProcVisoes( oDlg, aList ), CursorArrow()}
Local oOk     := LoadBitmap( GetResources(), "LBOK" )	//"CHECKED"
Local oNo     := LoadBitmap( GetResources(), "LBNO" )	//"UNCHECKED"
Local lChk1   := .F.

Local aList := {}

Local oList, oGroup
Local oDlg, oConfirma
Local oExit, oChk1

dbSelectArea( "RDK" )
dbSetOrder( 1 )
dbGoTop()
Do While !Eof()
   If RDK->RDK_HIERAR == "1" .And. RDK->RDK_STATUS <> "2"
      Aadd(aList,{.F.,					;	// 01 - Flag
                  RDK->RDK_CODIGO,		;	// 02 - Codigo da Visao
                  RDK->RDK_DESC,		;	// 03 - Descricao da Visao
                  RDK->RDK_DTINCL,		;	// 04 - Data da Inclusao
                  RDK->(Recno())}		)	// 05 - Recno
   EndIf
   dbSkip()
EndDo
dbGoTop()
If Len( aList ) == 0
   Aviso(STR0016,STR0017,{STR0018})	//"ATENCAO"###"Não existem visões a serem atualizadas!"###"Sair"
   RESTAREA( aOldAtu )
   Return
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Interface                                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lGestPubl
	DEFINE MSDIALOG oDlg TITLE STR0041 FROM 069,236 To 492,936 PIXEL	// "Atualizar Lotações na Tabela das Visões"
Else
	DEFINE MSDIALOG oDlg TITLE STR0019 FROM 069,236 To 492,936 PIXEL	// "Atualizar Departamentos na Tabela das Visões"
Endif

@ 010,010 GROUP oGroup TO 200,340 LABEL OemToAnsi( STR0020 ) OF oDlg PIXEL	// "Atualizar Visões"
oConfirma := SButton():New(180 , 260 , 1 , { || Eval( bAction )} , oDlg , .T. )
oConfirma:cCaption := STR0021		// "Confirmar"
oExit := SButton():New(180 , 300 , 1 , { || oDlg:End() } , oDlg , .T. )
oExit:cCaption := STR0022			// "Cancelar"
@ 180,013 CheckBox oChk1 VAR lChk1 PROMPT STR0023 SIZE 70,7 PIXEL OF oDlg ON CLICK( aEval( aList, {|x| x[1] := lChk1 } ),oList:Refresh() )	// "Marca/Desmarca Todos"
@ 020,013 ListBox oList Fields HEADER " ", STR0024, STR0025, STR0026, STR0027 SIZE 324,150 OF oDlg PIXEL ON dblClick(aList[oList:nAt,1] := !aList[oList:nAt,1])	// "Código"###"Descrição"###"Data Inclusão"###"Registro"

oList:SetArray( aList )
oList:bLine := {|| {If(aList[oList:nAt,1],oOk,oNo), ;
                        aList[oList:nAt,2], ;
                        aList[oList:nAt,3], ;
                        aList[oList:nAt,4], ;
                        aList[oList:nAt,5]}}

ACTIVATE MSDIALOG oDlg CENTERED

RESTAREA( aOldAtu )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fProcVisoesºAutor  ³ Adilson Silva     º Data ³ 10/01/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Executa o Processamento das Atualizacoes das Descricoes dosº±±
±±º          ³ Departamentos na Tabela das Visoes - RD4.                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MP11                                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function fProcVisoes( oDlg, aList )

Local cChave   := ""
Local cFilRdk  := xFilial("RDK")
Local cFilSqb  := xFilial("SQB")
Local nTamDesc := If(Len(RD4->RD4_DESC) < Len(SQB->QB_DESCRIC),Len(RD4->RD4_DESC),Len(SQB->QB_DESCRIC))
Local nX       := 0

If Aviso(STR0016,STR0028,{STR0029,STR0030}) == 1   //"ATENCAO"###"Confirma Processamento?"###"Não"###"Sim"
   Return
EndIf

// Ordem de Pesquisa do SQB
SQB->(dbSetOrder( RetOrdem("SQB", "QB_FILIAL+QB_DEPTO") ))

Begin Sequence

For nX := 1 To Len( aList )
    // Testa as Visoes Selecionadas
    If !aList[nX,1]
       Loop
    EndIf
    
    cChave := cFilRdk + aList[nX,2]

    // Bloqueia o Cabecalho - RDK
    If !( lLocks := WhileNoLock( "RDK" , {aList[nX,5]} , NIL , 1 , 1 , .T. , 1 , 5 ) )
       Break
    EndIf
    
    Begin Transaction

    // Processa as Atualizacoes das Descricoes dos Departamentos
    dbSelectArea( "RD4" )
    dbSeek( cChave )
    Do While !Eof() .And. RD4->(RD4_FILIAL + RD4_CODIGO) == cChave
       If SQB->(dbSeek( cFilSqb + RD4->RD4_CODIDE ))
          If PadR(RD4->RD4_DESC,nTamDesc) <> PadR(SQB->QB_DESCRIC,nTamDesc)
                RecLock("RD4",.F.)
                 RD4->RD4_DESC := SQB->QB_DESCRIC
                MsUnlock()
          EndIf
       EndIf
       dbSkip()
    EndDo

    End Transaction

    // Libera o Lock do Cabecalho - RDK
	FreeLocks( "RDK" , aList[nX,5] , .T. )
Next nX

End Sequence

// Fecha o Dialogo
oDlg:End()

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ValFilMat	 ³ Autor ³ Gustavo M.	        ³ Data ³01.02.13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida preenchimento de campos responsaveis.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/   
Static Function ValFilMat()

Local lRet	  := .T.   
Local nFilResp:= 0 
Local nMatResp:= 0
Local nCount  := 0   

For nCount := 1 To SQB->(FCount()) 
	If ( FieldName(nCount) == "QB_FILRESP" ) 
		nFilResp:= nCount
	ElseIf ( FieldName(nCount) == "QB_MATRESP" ) 
		nMatResp:= nCount 
	Endif
Next nCount

If !Empty(GetMemVar( FieldName(nFilResp))) .Or. !Empty(GetMemVar( FieldName(nMatResp)))
	If Empty(GetMemVar( FieldName(nFilResp))) 
	    lRet:= .F.  
	Elseif Empty(GetMemVar( FieldName(nMatResp)))
		lRet:= .F.
	Endif 
	
	If !lRet              
		MsgAlert(OemToAnsi(STR0031))
	Endif
Endif
               
Return lRet

Static Function IntegDef(cXml, nTypeTrans, cTypeMessage, cVersion)
   Local aRet := {}

   aRet := CSAI100(cXml, nTypeTrans, cTypeMessage, cVersion)
Return aRet
/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³Csa100SetFil    ³Autor³Leandro Drumond	   ³ Data ³23/06/2015³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³FUNCAO PARA SETAR UMA VARIAVEL SE PASSOU NO F3				 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³Campo envado do parametro da linha da getdados         	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³CSAA100 e sxb			                                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Function Csa100SetFil()

Local cFiltro := ""
//nao eh necessario trocar a filial do cFilAnt para montar o filtro.
//Ou uso filial do campo QB_FILRESP ou o xFilial atual.
If FunName() == "CSAA100" 
	If !Empty(M->QB_FILRSP2)
		cFiltro := "SRA->RA_FILIAL == '" + M->QB_FILRSP2 + "'  .AND. SRA->RA_SITFOLH <> 'D' "
	EndIf
EndIf

If Empty(cFiltro)
	cFiltro := "SRA->RA_FILIAL == '" + xFilial("SRA") + "'  .AND. SRA->RA_SITFOLH <> 'D' "
EndIf

cFiltro := "@#" + cFiltro + "@#"

Return(cFiltro)



Function Csa100Fil2()

Local cFiltro := ""
If FunName() == "CSAA100" 
	If !Empty(M->QB_FILRESP)
		cFiltro := "SRA->RA_FILIAL == '" + M->QB_FILRESP + "'  .AND. SRA->RA_SITFOLH <> 'D' "
	EndIf
EndIf

If Empty(cFiltro)
	cFiltro := "SRA->RA_FILIAL == '" + xFilial("SRA") + "'  .AND. SRA->RA_SITFOLH <> 'D' "
EndIf

cFiltro := "@#" + cFiltro + "@#"

Return(cFiltro)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o ³Csa100VldMat	³ Autor ³ Leandro Drumond       ³ Data ³ 23.06.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida matricula digitada no campo QB_MATRESP               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Csa100VldMat()
Local aArea		:= GetArea()
Local lRet 		:= .F.
Local cQuery 	:= ""
Local cAliasSRA := GetNextAlias()

If Empty(M->QB_FILRESP)
	M->QB_FILRESP := xFilial("SRA") //jah que considero a filial corrente para validacao, jah preencho o campo
EndIf
   
cQuery := " SELECT SRA.RA_MAT, SRA.RA_SITFOLH "
cQuery += " FROM " + RetFullName("SRA",EmpSQBResp()) + " SRA "
cQuery += " WHERE SRA.D_E_L_E_T_ = ' ' "
cQuery += " AND SRA.RA_FILIAL  = '" + xFilial("SRA",M->QB_FILRESP) + "' "
cQuery += " AND SRA.RA_MAT  = '" + M->QB_MATRESP + "' "
cQuery += " ORDER BY SRA.RA_MAT "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRA,.T.,.T.)

If (cAliasSRA)->(!Eof())
	If (cAliasSRA)->(RA_SITFOLH) <> 'D'
		lRet := .T.
	Else
		lRet := .F.
		Aviso(STR0016,STR0034,{"OK"})//"Atenção"#"Funcionário demitido não permitido como responsável"
	EndIf
Else
	Help("",1,"REGNOIS")
EndIf

(cAliasSRA)->(dbCloseArea())

RestArea(aArea)

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o ³Csa100VldPE	³ Autor ³ Renan Borges       ³ Data ³ 05.01.16    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ponto de entrada CSAAVLD100 para ser possível validar os    ³±±
±±³          ³os dados do cadastro de departamentos como desejar.         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Csa100VldPE()
Local lCsaVld	:= ExistBlock( "CSAA100VLD" )
Local lRet		:= .T.		

If lCsaVld	
	If(Valtype(lVldRet := ExecBlock( "CSAA100VLD", .F.,.F.)) == "L")
		lRet	:= lVldRet
	EndIf
EndIf

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o ³CrgKeyini	³ Autor ³ João Balbino       ³ Data ³ 17.05.16    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Função que faz a carga incial para gravação do campor       ³±±
±±³          ³QB_KEYINI que será utilizado na busca das solicitações.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function CrgKeyini(lForca, cIniOld)

	Local aAreaSQB 	:= SQB->(GetArea())
	Local nCont 	:= 0
	Local cChave 	:= ""
	Local aDeptos 	:= {}
	Local lKeyIni 	:= SQB->(ColumnPos("QB_KEYINI")) > 0
	Local aDepX		:= {}
	Local aLog		:= {}
	Local nX		:= 0
	Local cMsgYesNo	:= ""
	Local cTitLog	:= ""
	
	Default lForca	:= .F.
	Default cIniOld	:= ""
	
	If IsInCallStack("Cs100Grava") .And. Empty(cIniOld)
		Return
	EndIf
	
	aDeptos := fEstrutDepto(cFilAnt,,,lForca)

	If Len(aDeptos) > 0	
		DbSelectArea("SQB")
		DbSetOrder(1)
		
		If (lKeyIni .And. Empty(SQB->QB_KEYINI) .And. Len(aDeptos)>0) .Or. lForca
			For nCont := 1 To Len(aDeptos)
				If SQB->(DbSeek(xFilial("SQB", aDeptos[nCont,8]) + aDeptos[nCont,1]))
					Reclock("SQB", .F.)
						SQB->QB_KEYINI := aDeptos[nCont,5]
					MsUnlock()
				EndIf
			Next nCont
		EndIf
	EndIf

	If lKeyIni .And. Empty(cIniOld) .And. lOrgCfg 
		cSQBAlias := "QSQB"		
		BeginSql alias cSQBAlias
			SELECT SQB.*
			FROM %table:SQB% SQB
			WHERE SQB.QB_FILRESP <> ' ' AND
			SQB.QB_MATRESP <> ' ' AND
			SQB.QB_KEYINI = ' ' AND
			SQB.%notDel%
			ORDER BY SQB.QB_KEYINI
		EndSql

		While (cSQBAlias)->( !Eof() )
			aAdd(aDepX, {(cSQBAlias)->QB_FILIAL, (cSQBAlias)->QB_DEPTO, (cSQBAlias)->QB_DESCRIC } )
			(cSQBAlias)->( dbSkip() )
		EndDo
		(cSQBAlias)->( dbCloseArea() )

		If Len(aDepX) > 0
			cMsgYesNo	:= OemToAnsi(;
										STR0047 + ;	// "Foram identificados Departamentos com Filial/Matrícula Responsável "
										STR0048 + ;	// "cuja estrutura de hierarquia ,impossibilitando"
										STR0049	+ ; // "a geração devida do campo Chave de Busca (QB_KEYINI)."
										CRLF	+ ;
										CRLF	+ ;
										STR0050	+ ; // "OBSERVAÇÃO: Verificar se os níveis estão cadastrados corretamente - "
										STR0051	+ ; // "o último nível não deve possuir Dep. superior cadastrado!"
										CRLF	+ ;
										CRLF	+ ;
										STR0052	  ;	// "Deseja visualizar o relatório de Departamentos inconsistentes agora?"
									)
			cTitLog		:= OemToAnsi( STR0016 )	// Atencao!"
			lGerEr :=  MsgYesNo( OemToAnsi( cMsgYesNo ) ,  OemToAnsi( cTitLog ) ) 
			If lGerEr
				aAdd(aLog,OemToAnsi(STR0053)) // "O(s) Departamento(s) abaixo devem ter sua estrutura de hierarquia revisada: "
				For nX := 1 to Len(aDepX)
					aAdd(aLog,OemToAnsi(STR0046)  + ": " + aDepX[nX][1] + " / " + OemToAnsi(STR0024) + ": " + aDepX[nX][2] + " - " + aDepX[nX][3])
				Next nX		
				aAdd(aLog,"	"		)
				bMkLog := { || fMakeLog( { aLog } ,{ OemToAnsi(STR0054) } ,NIL , .T. , FunName() , NIL , "M" , "L" , NIL , .F. ) }//"Log de Departamentos Inconsistentes"
				MsAguarde( bMkLog , OemToAnsi( STR0054 ) )//"Log de Departamentos Inconsistentes"
			EndIf
		EndIf
	EndIf	
	Restarea(aAreaSQB)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o ³VldDepSup	³ Autor ³ João Balbino       ³ Data ³ 17.05.16    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida alteração no campo departamento superior.            ³±±
±±³          ³                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function VldDepSup()
	Local cAliasRH3 := GetNextAlias()
	Local cKey 		:= ""
	Local cFil 		:= ""
	Local cResp 	:= ""
	Local lTemReg 	:= .F.
	Local lRet		:= .T. 
	Local cRetOrdem := "RH3_FILIAL+RH3_DEPTO"
	Local nOrdem	:= RetOrdem(cRetOrdem)
	Local lHist		:= .F.
	Local aDeptos 	:= fEstrutDepto(cFilAnt)
	Local lKeyIni 	:= SQB->(ColumnPos("QB_KEYINI")) > 0 
	Local lOk		:= .T.
	Local nPos 		:= 0
	
	cDepSup := FGetKeyIni(xFilial("SQB",SQB->QB_FILIAL)+M->QB_DEPSUP)
	
	If !Empty(M->QB_KEYINI) .And. Alltrim(M->QB_KEYINI) == substr(cDepSup,1,Len(alltrim(M->QB_KEYINI)))
		MsgAlert(STR0042)//"Estrutura não permitida, para mover o departamento para um nível inferior é preciso primeiro mover os departamentos 'Filhos'"
		return .F.
	EndIf
	If lKeyIni .And. !Empty(M->QB_KEYINI)
		// Query para verificar se existem solicitações em aberto		
		cKey  := AllTrim(M->QB_KEYINI)
		cFil  := AllTrim(SQB->QB_FILRESP) 
		cResp := AllTrim(SQB->QB_MATRESP) 
		BeginSQL ALIAS cAliasRH3
			SELECT COUNT(*) QTD
			FROM %table:RH3% RH3
			WHERE RH3.RH3_KEYINI = %exp:ckey%
 					AND RH3.RH3_STATUS IN ('1','4','5')
 					AND RH3.RH3_TIPO <> 'H'
 					AND RH3.RH3_FILAPR = %exp:cFil%
 					AND RH3.RH3_MATAPR = %exp:cResp%
 					AND RH3.%NotDel%
 		EndSQL
 			 			 		
 		lTemReg := Iif((cAliasRH3)->QTD > 0, .T.,.F.)
 		(cAliasRH3)->( dbCloseArea() )
 		
 		cAliasRH3 := GetNextAlias()
 		//Query para verificar se existe histórico
 		BeginSQL ALIAS cAliasRH3
			SELECT COUNT(*) QTD
			FROM %table:RH3% RH3
			WHERE RH3.RH3_KEYINI = %exp:ckey%
			AND RH3.RH3_TIPO <> 'H'
			AND RH3.%NotDel%
 		EndSQL
 		
 		lHist := Iif((cAliasRH3)->QTD > 0, .T.,.F.)
 		(cAliasRH3)->( dbCloseArea() )
 		
	 	
		If lTemReg //Não será possivel alterar o cadastro enquanto houver solicitações pendentes.
			MsgAlert(OemToAnsi(STR0032))
			lRet := .F.
		Elseif lHist // Não será possivel exclusão se houver histórico.
			lOk := MsgYesNo(OemToAnsi(STR0033),OemToAnsi(STR0016)) //# Deseja prosseguir? # ATENÇÃO
		EndIf
				
		If !lOk
			lRet := .F.
		EndIf
		
	EndIf

Return lRet

/*/{Protheus.doc} CCDescSQB
	Retorna a descricao do Centro de Custo(CTT) utilizando a filial do Departamento(SQB)
@author PHILIPE.POMPEU
@since 21/09/2016
@version P12.1.13
@param cFilQb, caractere, por padrao SQB->QB_FILIAL, porem pode-se passar M->QB_FILIAL se desejado.
@return cReturn, descricao do centro de Custo
/*/
Function CCDescSQB(cFilQb)
Local aArea := GetArea()
Local cMyAlias:= GetNextAlias()
Local cResult := ""
Default cFilQb := If(Empty(AllTrim(xFilial("CTT",SQB->QB_FILIAL))),'% %','% CTT_FILIAL like ' + "'" + AllTrim(xFilial("CTT",SQB->QB_FILIAL)) + "'" + ' AND %')

BeginSql alias cMyAlias
	SELECT CTT_DESC01
	FROM %table:CTT% CTT
	WHERE %exp:cFilQb% 
	CTT_CUSTO = %exp:SQB->QB_CC% AND %notDel%
EndSql

If((cMyAlias)->(!Eof()))
	cResult := (cMyAlias)->CTT_DESC01
EndIf
(cMyAlias)->(dbCloseArea())

RestArea(aArea)
Return cResult

/*/{Protheus.doc} ValComa
	Função para validação do campo Comarca (QB_COMARC)
@author Equipe RH
@since 24/07/2018
@version P12.1.23
@return lRet, lógico, indica se valor inserido é válido.
/*/
Function ValComa()

Local lGestPubl := IIF(ExistFunc("fUsaGFP"),fUsaGFP(),.F.)
Local lRet		:= .F.

If lGestPubl
	lRet := Existcpo("REC",M->QB_COMARC)                                                                                       
Else
	lRet := Vazio() .or. Existcpo("REC",M->QB_COMARC)                                                                                       
Endif

Return lRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o ³CsaPosVldX9	³ Autor ³ Silvio C. Stecca  ³ Data ³ 09.01.19     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Ponto de entrada CSAPOSX9 para ser possível validar os      ³±±
±±³          ³os dados do cadastro de departamentos como desejar após a   ³±±
±±³          ³validação dos dados da tabela SX9 através da função         ³±±
±±³          ³csaa100ChkDel().                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³CSAA100                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function CsaPosVldX9()

	Local lCsaPosX9	:= ExistBlock("CSAPOSX9")
	Local lRet		:= .T.		
	
	If lCsaPosX9	
		If Valtype(lVldRet := ExecBlock("CSAPOSX9", .F., .F.)) == "L"
			lRet := lVldRet
		EndIf
	EndIf

Return lRet

/*/{Protheus.doc} VldEmpCsa
//TODO Valida a empresa escolhida.
@author martins.marcio
@since 04/06/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function VldEmpCsa()

Local lRet := .T.

IF !( lRet := SM0->( dbSeek( EmpSQBResp() ) ) )
	Help("",1,"REGNOIS")
Else
	M->QB_FILRESP := SPACE(LEN(SQB->QB_FILRESP)) 
	M->QB_MATRESP := SPACE(LEN(SQB->QB_MATRESP))
EndIf

Return lRet
 
/*/{Protheus.doc} EmpSQBResp
//TODO Retorna a empresa do responsável.
@author martins.marcio
@since 28/05/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function EmpSQBResp()

Local cEmpResp := cEmpAnt

If SQB->(ColumnPos("QB_EMPRESP")) > 0
	If !Empty(M->QB_EMPRESP)
		cEmpResp := M->QB_EMPRESP
	Else
		M->QB_EMPRESP := cEmpResp
	EndIf
EndIf

Return cEmpResp

/*/{Protheus.doc} ConECsa100
//TODO Consulta específica.
@author martins.marcio
@since 03/06/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function ConECsa100()

Local oDlg, oLbx
Local aCpos  := {}
Local aRet   := {}
Local lRet   := .F.
Local cFilt := SPACE(40)
Private aCombo := {" ","01-"+OemToAnsi(STR0044),"02-"+OemToAnsi(STR0045)} // Matricula, Nome
Private cCombo := " "

DEFINE MSDIALOG oDlg TITLE OemToAnsi(STR0043) FROM 0,0 TO 350,500 PIXEL

@ 010,010 MSCOMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 060,010 OF oDlg PIXEL
@ 010,080 MSGET cFilt SIZE 125, 010 OF oDlg PIXEL Picture "@!"
@ 030,010 LISTBOX oLbx FIELDS HEADER OemToAnsi(STR0046)/*Filial*/ , OemToAnsi(STR0044)/*Matrícula*/ , OemToAnsi(STR0045) /*Nome*/ SIZE 230,120 OF oDlg PIXEL

aCpos := fGetSRA(cFilt)

oLbx:SetArray( aCpos )
oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3]}}
oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3]}}}

DEFINE SBUTTON FROM 010,213 TYPE 17 ACTION (aCpos := fGetSRA(cFilt),oLbx:SetArray( aCpos ),oLbx:bLine := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3]}})  ENABLE OF oDlg
DEFINE SBUTTON FROM 160,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2],oLbx:aArray[oLbx:nAt,3]})  ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg CENTER

If Len(aRet) > 0 .And. lRet
	If Empty(aRet[2])
		lRet := .F.
	Else
		M->QB_MATRESP := aRet[2]
	EndIf
EndIf

Return lRet

/*/{Protheus.doc} fGetSRA
//TODO Executa query da SRA
@author martins.marcio
@since 04/06/2019
@version 1.0
@return ${return}, ${return_description}
@param cFilt, characters, descricao
@type function
/*/
Static Function fGetSRA(cFilt)

Local aDados  := {}
Local cQuery := ""
Local cAliasSRA := GetNextAlias()
Default cFilt := SPACE(40)

cQuery := " SELECT SRA.RA_FILIAL,SRA.RA_MAT, SRA.RA_NOME "
cQuery +=   " FROM " + RetFullName("SRA",EmpSQBResp()) + " SRA "
cQuery +=  " WHERE SRA.D_E_L_E_T_ = ' ' "
cQuery +=    " AND SRA.RA_FILIAL  = '" + xFilial("SRA",M->QB_FILRESP) + "' "
cQuery +=    " AND SRA.RA_SITFOLH <> 'D' "
If !Empty(cFilt) .And. !Empty(cCombo)
	If  Left(cCombo,2) == "01"
		cQuery += " AND SRA.RA_MAT LIKE '%" + AllTrim(cFilt) + "%' "
	ElseIf Left(cCombo,2) == "02"
		cQuery += " AND SRA.RA_NOME LIKE '%" + AllTrim(cFilt) + "%' "
	EndIf
EndIf
cQuery += " ORDER BY SRA.RA_FILIAL, SRA.RA_MAT "

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSRA,.T.,.T.)

While (cAliasSRA)->(!Eof())
	aAdd(aDados,{(cAliasSRA)->(RA_FILIAL),(cAliasSRA)->(RA_MAT), (cAliasSRA)->(RA_NOME)})
	(cAliasSRA)->(dbSkip())
EndDo
(cAliasSRA)->(dbCloseArea())

If Len(aDados) < 1
	aAdd(aDados,{" "," "," "})
EndIf

Return aDados

//-------------------------------------------------------------------
/*/{Protheus.doc} function VldMatResp
Validação da matricula do responsavel
@author  Gisele Nuncherino
@since   24/07/2020
/*/
//-------------------------------------------------------------------
function VldMatResp()

Local lRet := .T.

if Vazio() .Or. (iif(FindFunction('Csa100VldMat'), Csa100VldMat(), .T.))
	lRet := .T.
else
	lRet := .F.
Endif

return lRet

/*/{Protheus.doc} fPrepDadosApi
Processo para preparar os dados de inclusão/alteração/deleção para 
integração via API REST.

@since	20/08/2020
@autor	Wesley Alves Pereira
@version P12.1.XX

/*/
Static Function fPrepDadosApi(nOpcao)
	
Local aArea		:= GetArea()

Local cOperacao := ""

If nOpcao == 5
	cOperacao := "E"
	fSendDadosApi(cOperacao)
ElseIf nOpcao == 4
	cOperacao := "A"
	fSendDadosApi(cOperacao)
ElseIf nOpcao == 3
	cOperacao := "I"
	fSendDadosApi(cOperacao)
EndIf

RestArea(aArea)

Return (.T.)

/*/{Protheus.doc} fSendDadosApi
Processo para enviar os dados de inclusão/alteração/deleção para 
integração via API REST.

@since	20/08/2020
@autor	Wesley Alves Pereira
@version P12.1.XX

/*/
Static Function fSendDadosApi(cOperacao)
	
Local dDtBase   := DDATABASE
Local cHoraAt   := time()
Local cTmpEmp   := cEmpAnt
Local cProces   := "SQB"
Local cUserId   := SubStr(cUsuario,7,15)
Local cTmpCod   := ""
Local cTmpFil   := xFilial("SQB")
Local cChave    := ""

Default cOperacao := ''

If ( ( cOperacao == 'I') .OR. ( cOperacao == 'A') .OR. ( cOperacao == 'E'))

	cChave := cTmpEmp + "|" + cTmpFil + "|" + SQB->QB_DEPTO

	If FindFunction("fSetDeptoRJP")
		fSetDeptoRJP(cTmpFil, cProces, cChave, cOperacao,  dDtBase, cHoraAt,cUserId)			
	Endif
EndIf

Return (.T.)
