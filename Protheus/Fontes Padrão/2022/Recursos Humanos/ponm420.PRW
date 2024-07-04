#INCLUDE "PONM420.CH"
#INCLUDE "PROTHEUS.CH"  
#INCLUDE "PONCALEN.CH"

Static lPnm420CposBlock              

Static lPort1510 	:= Port1510() 	//Verifica se Portaria 1510/2009 esta em vigor.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PONM420  ³ Autor ³ Mauricio MR                      ³ Data ³ 28/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera arquivo ACJEF - SREP                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC             ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia C.  ³21/05/14³TPQAN3           ³Incluido o fonte da 11 para a 12 e efetua-³±± 
±±³            ³        ³                 ³da a limpeza.                             ³±±
±±³Emerson Camp³29/07/14³TPQAN3           ³Removido o retorno da função fGeraTipos   ³±±
±±³            ³        ³                 ³pois esta função retorna Nil desde que foi³±±
±±³            ³        ³                 ³criada, e não tem nenhuma condição de     ³±±
±±³            ³        ³                 ³negação. E alterado cLog para aLogDet.    ³±±
±±³			   ³		³				  ³- Horários Contratuais - da portaria 1510.³±±
±±³Oswaldo L.  ³03/04/17³DRHPONTP-164     ³Projeto cTree                             ³±±
±±³	      	   ³	    ³		          ³- Horários Contratuais - da portaria 1510.³±±
±±³Willian U.  ³07/06/17³DRHPONTP-821     ³Réplica DRHPONTP-795: Ajuse na validacao  ³±±
±±³	       	   ³	    ³		          ³dos ADM/DEM p/ que seja conforme a data do³±±
±±³	           ³	    ³		          ³periodo informado.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PONM420() 
  
Local aArea			:= GetArea()
Local aSays			:= {}
Local aButtons		:= {}
Local cSvFilAnt		:= cFilAnt
Local lBarG1ShowTm 	:= .F.
Local lBarG2ShowTm 	:= .F.
Local nOpcA			:= 0

Private cCadastro := OemtoAnsi(STR0001)		//"Geracao do arquivo ACJEF"

Private dIniCale		:= Ctod("//")
Private dFimCale		:= Ctod("//")

Private lAbortPrint := .F.   

Private lBlind := IsBlind()

DEFAULT lPnm420CposBlock	:= ExistBlock( "PNM420CPOS"	)

If lPort1510
	cCadastro += fPortTit() //Complementa titulo da tela com dizeres referente a portaria.
EndIf

Pergunte("PNM420",.F.)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ So Executa se os Modos de Acesso dos Arquivos Relacionados es³
³ tiverm OK e se For Encontrado o Periodo de Apontamento.      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF ValidArqPon() 
	
	If !lBlind
		AADD(aSays,OemToAnsi( STR0002 ) )// //"Este programa gera o Arquivo de Controle de Jornada para Efeitos Fiscais - ACJEF" 
		
		AADD(aButtons, { 5,.T.,{|| Pergunte("PNM420",.T. ) } } )
		AADD(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(),FechaBatch(),nOpcA := 0 ) }} )
		AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
		FormBatch( cCadastro, aSays, aButtons )
		
		PonDestroyStatic()
		
		IF ( nOpcA == 1 )
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Verifica se deve Mostrar Calculo de Tempo nas BarGauge			 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			lBarG1ShowTm := ( SuperGetMv("MV_PNSWTG1",NIL,"N") == "S" )
			lBarG2ShowTm := ( SuperGetMv("MV_PNSWTG2",NIL,"S") == "S" )
			/*                               
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Executa o Processo de Leitura/Apontamento       					 ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			Proc2BarGauge(  { || PNM420Proc() } , STR0001 , NIL , NIL , .T. , lBarG1ShowTm , lBarG2ShowTm ) // "Geracao do arquivo ACJEF"
		EndIF
	Else
		PNM420Proc()
	EndIf
EndIF

cFilAnt := cSvFilAnt
RestArea( aArea )

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PONM420Processa ³ Autor ³ Mauricio MR    ³ Data ³ 21/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa a geracao do arquivo magnetico ACJEF              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso  	 ³ SIGAPON				             						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static FUNCTION PNM420Proc() 
Local aAreaSRA	 	:= SRA->( GetArea() )

//-- Variaveis para a geracao do arquivo magnetico
Local cArqNome 
Local cArqCH    
Local lCriou	:= .F.

//-- Variaveis para obter as informacoes das empresas
Local aInfo   		:= 	{}  

//-- Variaveis para passagem entre funcoes
Local cTpIdEmp     	:=	"" 
Local cTipoInsc		:= 	""
Local cCPFCNPJ		:= 	""
Local cCEI			   := "" 
Local cPIS			:=  ""			
Local dDataIni
Local dDataFim 

//-- Variaveis de controles de quebras
Local cSvFilAnt		:= cFilAnt
Local cLastFil   	:= "__cLastFil__"
Local cFilTnoOld	:= "__cFilTnoOld__"
Local cFilTnoAtu	:= "__cFilTnoAtu__"
Local cOldFilTnoSeq	:= "__cOldFilTnoSeq__"
Local cAtuFilTnoSeq	:= "__cAtuFilTnoSeq__" 

//-- Variaveis de Perguntas SX1
Local cFilTnoDe		:= ""
Local cFilTnoAte	:= ""
Local cFilialDe  	:= ""
Local cFilialAte 	:= ""
Local cCCDe      	:= ""
Local cCCAte     	:= ""  
Local cTurnoDe   	:= ""
Local cTurnoAte  	:= ""
Local cMatDe     	:= ""
Local cMatAte    	:= ""         
Local cRegraDe   	:= ""
Local cRegraAte  	:= ""
Local cSituacoes 	:= ""
Local cCategoria 	:= ""

//-- Variaveis de controle de acesso as informacoes do cadastro de funcionario
Local cAcessaSRA	:= &("{ || " + ChkRH("PONM420","SRA","2") + "}") 

//-- Variaveis de filias das tabelas   
Local cFilSP4		:= ""
Local cFilSP9 		:= ""
Local cFilSPA		:= ""    
Local cFilSR6		:= "" 
Local cFilRFF		:= "" 
Local cFilRFG		:= "" 
Local cFilSPC		:= ""
Local cFilSPH		:= ""

//-- Bloco do cadastro de funcionarios SRA
Local bSraScope
                  
//-- Barra de progressao
Local aRecsBarG		:= {}  
Local aRecsSR6		:= {}
Local cTimeIni		:= Time()
Local cMsgBarG1		:= ""
Local lIncProcG1	:= .T.
Local lSR6Comp		:= Len( AllTrim( xFilial( "SR6" ) )) < FwGetTamFilial
Local nLastRec		:= 0
Local nIncPercG1	:= 0
Local nIncPercG2	:= 0
Local nCount1Time	:= 0
Local nRecsSR6		:= 0
      
//-- Carga de Eventos
Local cHe			:= ''
Local cFaltas		:= ''
Local cHDiurnas		:= ''
Local cHNoturnas	:= '' 
Local cAtrasos		:= ''
Local cSaidaA       := ''
Local cSaidaE       := ''
Local aSP4			:= {}
	
//-- Contador
Local nVezes		:= 0

//-- Lacos
Local nX			:= 0

//-- Retorno de Ponto de entrada
Local uRetBlock 

//-- Controle de periodos
Local lImpAcum		:= .F.
Local lTemMov       := .F.
Local naPeriodos	:= 0  
Local cIniData		:= ""
Local cFimData		:= ""

//-- Montagem do calendario
Local cTurno		:= "!!"
Local cSeq			:= "!!" 

Local lSPJExclu		:= Len(Alltrim( xFilial("SPJ") )) = FwGetTamFilial
Local lSP4Exclu		:= Len(Alltrim( xFilial("SP4") )) = FwGetTamFilial   
Local lSP9Exclu		:= Len(AllTrim( xFilial("SP9") )) = FwGetTamFilial   

Local aRFFFields	:= RFF->( dbStruct() )
Local nRFFFields	:= Len( aRFFFields	)
Local aRFGFields	:= RFG->( dbStruct() )
Local nRFGFields	:= Len( aRFGFields	)
Local aSpCFields	:= SPC->( dbStruct() )
Local nSpCFields	:= Len( aSpCFields	)
Local aSpHFields	:= SPH->( dbStruct() )
Local nSpHFields	:= Len( aSpHFields	)
Local lQueryOpened	:= .F.

Local aStruSRA		:= {}
Local aCposSRA		:= {} 

Local cSitQuery		:= ""
Local cCatQuery 	:= "" 
   	
Local cAliasSRAQry	:= ""
Local cAliasSRARec	:= ""  
  	  	   	
Local aTempSRA		:= SRA->( dbStruct() )
Local nContField	:= Len( aTempSRA	)

Local cSRAWhere		:= ""

Local cCHAliasQry := GetNextAlias()
Local cCHTableName 
Local cSql

//-- Controle de Log
Private aLogDet		:= {}
Private aLogTitle	:= {}

//-- Controle de periodo 
Private dPerIni   := Ctod("//")	//-- Data Inicial o Periodo de Cada Filial
Private dPerFim   := Ctod("//")	//-- Data Final o Periodo de Cada Filial

Private dMarcIni   := Ctod("//")	//-- Data Inicial a Considerar para Recuperar as Marcacoes
Private dMarcFim   := Ctod("//")	//-- Data Final a Considerar para Recuperar as Marcacoes
Private dIniPonMes := Ctod("//")	//-- Data Inicial do Periodo em Aberto 
Private dFimPonMes := Ctod("//")	//-- Data Final do Periodo em Aberto 

Private aPeriodos  := {}

//Montagem do calendario
Private aMarcacoes 	:= {}
Private aTabPadrao 	:= {}
Private aTabCalend 	:= {}
Private aTurnos 	:= {}   

Private cTamTurno	:= Space( TamSX3('R6_TURNO')[1] )   

Private nCH			:= 0  

Private nQuantc		:= TamSx3("PC_QUANTC")[1]

Private cACJEFAlias := "ACJEF"
Private cACJCHAlias := "ACJCH"
Private oTmpACJEF
Private oTmpACJCH

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carregando as Perguntas                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Pergunte("PNM420",.F.)


cFilialDe  	:= mv_par01
cFilialAte 	:= mv_par02
cCCDe      	:= mv_par03
cCCAte     	:= mv_par04
cTurnoDe   	:= mv_par05
cTurnoAte  	:= mv_par06
cMatDe     	:= mv_par07
cMatAte    	:= mv_par08  
cRegraDe   	:= mv_par09
cRegraAte  	:= mv_par10
cSituacoes 	:= mv_par11
cCategoria 	:= mv_par12
dIniCale	:= mv_par13
dFimCale 	:= mv_par14
cFile	   	:= mv_par15  

Begin Sequence
	
	IF Empty( dIniCale ) .or. Empty( dFimCale )
		Help(" ",1,"PONFORAPER" , , OemToAnsi( STR0022 ) , 5 , 0  )	//'Periodo de Apontamento Invalido.'
		lAbortPrint := .T.
		Break
	EndIF
	
	//-- O nome do arquivo deve ser ACJEF
	If !"ACJEF" $ UPPER(cFile)
		Aviso( STR0006,STR0012, { "Ok" },,STR0004 ) //###"Erro ao abrir o arquivo"###"Nome do arquivo inválido."###Atencao
		lAbortPrint := .T.
		Break
	EndIf                                 
	
	//cria ACJCH e ACJEF
	If !(lCriou:=PN420Cria())
		Aviso( STR0006,STR0005, { "Ok" },,STR0007 ) //"Erro ao abrir o arquivo"## Verifique se este processo já está sendo executado em outra estação."##"Nao foi possivel abrir o arquivo temporario ACJEF."
		lAbortPrint := .T.
		Break
	Endif
	
	dbSelectArea("RFF") //-- Pre-ACJEF
	dbSetOrder(RetOrder( "RFF", "RFF_FILIAL+RFF_MAT+DTOS(RFF_DATA)+RFF_PD+RFF_CC"))            
	
	dbSelectArea("RFG") //-- Acumulado Pre-ACJEF
	dbSetOrder(RetOrder( "RFG", "RFG_FILIAL+RFG_MAT+DTOS(RFG_DATA)+RFG_PD+RFG_CC"))            
	
	
	dbSelectArea("SPC") //-- Apontamentos
	dbSetOrder(RetOrder( "SPC", "PC_FILIAL+PC_MAT+DTOS(PC_DATA)+PC_PD+PC_TPMARCA+PC_CC"))                     
	
	dbSelectArea("SPH") //-- Apontamentos Acumulados
	dbSetOrder(RetOrder( "SPH", "PH_FILIAL+PH_MAT+DTOS(PH_DATA)+PH_PD+PH_TPMARCA+PH_CC"))                     
	
	dbSelectArea("SRA") //-- Funcion rios
	DbSetOrder( RetOrder( "SRA", "RA_FILIAL+RA_TNOTRAB+RA_SEQTURN+RA_REGRA+RA_MAT" ))
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Inicializa Filial/Turno De/Ate							   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cFilTnoDe	:= ( cFilialDe + cTurnoDe )
	cFilTnoAte	:= ( cFilialAte + cTurnoAte )
	
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Cria o Bloco dos Funcionarios que atendam ao Scopo	   	   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	bSraScope := { || (;
							( RA_TNOTRAB	>= cTurnoDe		.and. RA_TNOTRAB	<= cTurnoAte	) .and. ;
							( RA_FILIAL 	>= cFilialDe	.and. RA_FILIAL 	<= cFilialAte	) .and. ;
							( RA_REGRA 		>= cRegraDe		.and. RA_REGRA 		<= cRegraAte	) .and. ;
							( RA_MAT 		>= cMatDe		.and. RA_MAT 		<= cMatAte		) .and. ;
							( RA_CC 		>= cCCDe		.and. RA_CC 		<= cCCAte		);
					   );
				 }
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Seta apenas os Campos do SRA que serao Utilizados           ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdd( aCposSRA , "RA_FILIAL"	)
	aAdd( aCposSRA , "RA_MAT" 		)	
	aAdd( aCposSRA , "RA_NOME"		)
	aAdd( aCposSRA , "RA_CC"		)
	aAdd( aCposSRA , "RA_PIS"		)		
	aAdd( aCposSRA , "RA_TNOTRAB"	)
	aAdd( aCposSRA , "RA_SEQTURN"	)
	aAdd( aCposSRA , "RA_REGRA"  	)
	aAdd( aCposSRA , "RA_ADMISSA"  	)
	aAdd( aCposSRA , "RA_DEMISSA"  	)
	aAdd( aCposSRA , "RA_CATFUNC"  	)
	aAdd( aCposSRA , "RA_SITFOLH"  	)
	aAdd( aCposSRA , "RA_HRSEMAN" 	)
	aAdd( aCposSRA , "RA_HRSMES" 	)
	aAdd( aCposSRA , "RA_ACUMBH" 	)
	/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Verifica e Seta os campos a mais incluidos no Mex             ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/				
	fAdCpoSra(aCposSra)			
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Ponto de Entrada para Campos do Usuario                      ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF ( lPnm420CposBlock )
		IF ( ValType( uRetBlock := ExecBlock("PNM420CPOS",.F.,.F.,aCposSRA) ) == "A" )
			IF Len( uRetBlock ) >= Len( aCposSRA )
				aCposSRA	:= aClone( uRetBlock )
				uRetBlock	:= NIL
			EndIF
		EndIF
	EndIF


	For nX := 1 To nContField
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Abandona o Processamento									   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF ( lAbortPrint )
			aAdd( aLogDet , STR0013 )//"A geracao do ACJEF Foi Cancelada Pelo Usuario"
			Break
		EndIF
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Carrega os Campos do SRA para a Montagem da Query			   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF aScan( aCposSRA , { |x| Upper(AllTrim(x)) == Upper( AllTrim( aTempSRA[ nX , 1 ] ) ) } ) > 0
			aAdd( aStruSRA , aClone( aTempSRA[ nX ] ) )
		EndIF
	Next nX
	aCposSRA	:= aTempSRA := NIL
	nContField	:= Len( aStruSRA )
	
	cAliasSRAQry := 'SRA'
	
	//-- Modifica variaveis para a Query 
	cSitQuery := ""
	For nX:=1 to Len(cSituacoes)
		cSitQuery += "'" + Subs(cSituacoes,nX,1) + "'" + ", "
	Next nX                                                         
	cSitQuery := SubStr( cSitQuery , 1 , Len( cSitQuery ) - 2 ) 
	cSitQuery := "%" + cSitQuery + "%"
	
	cCatQuery := ""
	For nX:=1 to Len(cCategoria)
		cCatQuery += "'" + Subs(cCategoria,nX,1) + "'" + ", "
	Next nX        
	cCatQuery := SubStr( cCatQuery , 1 , Len( cCatQuery ) - 2 ) 
	cCatQuery := "%" + cCatQuery + "%"
	
	cCampos:= "%"
	For nX := 1 To nContField
		cCampos += aStruSRA[ nX , 1 ] + ", "
	Next nX
	cCampos := SubStr( cCampos , 1 , Len( cCampos ) - 2 ) + "%"
	
	cSRAWhere := "%"
	cSRAWhere += "SRA.RA_FILIAL>='"+cFilialDe+"' AND "
	cSRAWhere += "SRA.RA_FILIAL<='"+cFilialAte+"' AND "
	cSRAWhere += "SRA.RA_TNOTRAB>='"+cTurnoDe+"' AND "	
	cSRAWhere += "SRA.RA_TNOTRAB<='"+cTurnoAte+"' AND "
	cSRAWhere += "SRA.RA_MAT>='"+cMatDe+"' AND "	
	cSRAWhere += "SRA.RA_MAT<='"+cMatAte+"' AND "
	cSRAWhere += "SRA.RA_REGRA>='"+cRegraDe+"' AND "	
	cSRAWhere += "SRA.RA_REGRA<='"+cRegraAte+"' AND "
	cSRAWhere += "SRA.RA_CC>='"+cCCDe+"' AND "	
	cSRAWhere += "SRA.RA_CC<='"+cCCAte+"'%"
	
	cOrdem := "%SRA.RA_FILIAL, SRA.RA_TNOTRAB, SRA.RA_SEQTURN, SRA.RA_REGRA, SRA.RA_MAT%"	
	
	SRA->( dbCloseArea() ) //Fecha o SRA para uso da Query
	
	BeginSql alias cAliasSRAQry 
		COLUMN RA_ADMISSA AS DATE
		COLUMN RA_DEMISSA AS DATE
		
		SELECT	%exp:cCampos%
		FROM %table:SRA% SRA
		WHERE 
			  %exp:cSRAWhere% AND
			  SRA.RA_SITFOLH	IN	(%exp:Upper(cSitQuery)%) 	AND
			  SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%)	AND
	 	      SRA.%notDel%   
		ORDER BY %exp:cOrdem%
	EndSql   
	
	lQueryOpened := .T.
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Abandona o Processamento									   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF ( lAbortPrint )
		aAdd( aLogDet , STR0013 )//"A geracao do ACJEF Foi Cancelada Pelo Usuario"
		Break
	EndIF
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Verifica o Total de Registros a Serem Processados            ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	cAliasSRARec:= GetNextAlias()
	BeginSql alias cAliasSRARec
		SELECT COUNT(*) NLASTREC 
		FROM %table:SRA% SRA
		WHERE 
			  %exp:cSRAWhere% AND
			  SRA.RA_SITFOLH	IN	(%exp:Upper(cSitQuery)%) 	AND
			  SRA.RA_CATFUNC	IN	(%exp:Upper(cCatQuery)%)	AND
	 	      SRA.%notDel%   
	EndSql   
	
	nLastRec := (cAliasSRARec)->NLASTREC
	(cAliasSRARec)->( dbCloseArea() )
	
	IF !lQueryOpened
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Verifica o Total de Registros a Serem Processados            ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		aRecsBarG := {}
		CREATE SCOPE aRecsBarG FOR SRA->( Eval( bSraScope ) )
		SRA->( dbSeek( cFilialDe , .T. ) )
		nLastRec := SRA->( ScopeCount( aRecsBarG ) )

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Procura primeiro funcion rio.                               ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		SRA->( dbSeek( cFilTnoDe , .T. ) )
    Endif
    
	If !lBlind
		// Inicializa Mensagem para a IncProcG2() ( Funcionarios )
		IncProcG2( STR0014  , .F. )	// 'Processando...'
		
		// Atualiza a Mensagem para a IncProcG2() ( Funcionarios )
		BarGauge2Set( nLastRec )
	EndIf
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Processa a triagem de funcionarios                           ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	While SRA->( !Eof() .and. ( ( cFilTnoAtu := ( RA_FILIAL + RA_TNOTRAB ) ) >= cFilTnoDe ) .and. ;
		                        ( cFilTnoAtu <= cFilTnoAte ) )

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Consiste controle de acessos e filiais validas               ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF SRA->( !(RA_FILIAL $ fValidFil()) .or. !Eval(cAcessaSRA) )
			SRA->(dbSkip()) 
			Loop
		EndIF
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Consiste filtro do intervalo De / Ate                        ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF SRA->( !Eval( bSraScope ) )
			SRA->( dbSkip() )
			Loop
 		EndIF
    
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Consiste a Categoria										  ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF !( SRA->RA_SITFOLH $ cSituacoes )
			SRA->( dbSkip() )
			Loop
		EndIF

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Consiste a Categoria										  ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF !( SRA->RA_CATFUNC $ cCategoria )
			SRA->( dbSkip() )
			Loop
		EndIF  

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Aborta o processamento                                       ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF ( lAbortPrint )
			aAdd( aLogDet , STR0013 )//"A geracao do ACJEF Foi Cancelada Pelo Usuario"
			Break
		EndIF  
		
		//-- Pis em branco
		If Empty(SRA->RA_PIS)
			aAdd( aLogDet , STR0010+STR0011+" "+ STR0017+SRA->RA_FILIAL+" - "+	STR0023 + SRA->RA_MAT )       //"Nao Enviado(s) - "### "PIS INVALIDO"###"Filial:" ##"Matricula: "#####
   			SRA->( dbSkip() )
			Loop
		EndIf

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Atualiza a Mensagem para a IncProcG1() ( Turnos )			   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		cAtuFilTnoSeq := ( cFilTnoAtu + SRA->RA_SEQTURN )
		IF !( cOldFilTnoSeq == cAtuFilTnoSeq )
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Atualiza o Filial/Turno/Sequencias Anteriores				   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			cOldFilTnoSeq := cAtuFilTnoSeq
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Atualiza a Mensagem para a BarGauge do Turno 				   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			//"Filial:"###"Turno:"###"Sequencia:"
			cMsgBarG1 := SRA->( STR0017 + " " + RA_FILIAL + " - " + STR0018 + " " + RA_TNOTRAB + " - " + Left(AllTrim( fDesc( "SR6" , RA_TNOTRAB , "R6_DESC" , NIL , RA_TNOTRAB , 01 ) ),50) + " " + STR0019 + " " + RA_SEQTURN )
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Verifica se Houve Troca de Filial para Verificacai dos Turnos³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			IF !( cLastFil == SRA->RA_FILIAL ) //A Atribuicao a cLastFil sera feita abaixo
				If !lBlind
					// Obtem o % de Incremento da 2a. BarGauge
					nIncPercG1 := SuperGetMv( "MV_PONINC1" , NIL , 5 , SRA->RA_FILIAL )
					
					// Obtem o % de Incremento da 2a. BarGauge
					nIncPercG2 := SuperGetMv( "MV_PONINCP" , NIL , 5 , SRA->RA_FILIAL )
					
					// Realimenta a Barra de Gauge para os Turnos de Trabalho
					IF ( !lSR6Comp .or. ( nRecsSR6 == 0 ) )
						CREATE SCOPE aRecsSR6 FOR ( R6_FILIAL == cLastFil .or. Empty( R6_FILIAL ) )
						nRecsSR6 := SR6->( ScopeCount( aRecsSR6 ) )
					EndIF
					
					// Define o Contador para o Processo 1
					--nCount1Time
					
					// Define o Numero de Elementos da BarGauge
					BarGauge1Set( nRecsSR6 )
					
					// Inicializa Mensagem na 1a BarGauge
					IncProcG1( cMsgBarG1 , .F. )
				EndIf
				
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Reinicializa a Filial/Turno Anterior                         ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				cFilTnoOld := "__cFilTnoOld__"   
				
				//-- Carrega o aInfo com os dados do SIGAMAT.EMP
				If !fInfo(@aInfo,SRA->RA_FILIAL)
					Exit
				EndIf
				
				If aInfo[15] == 1			// CEI
					cTpIdEmp := "3"
				ElseIF aInfo[15] == 3		// CPF
					cTpIdEmp := "2"
				Else
					cTpIdEmp := "1"			// CNPJ
				EndIf
				
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Atualiza a Filial Anterior								   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				cLastFil	:= SRA->RA_FILIAL	
	            cFilAnt		:= cLastFil	
			    
		    	/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Carrega as Filiais dos Arquivos	                           ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				  
				cFilSP4 := fFilFunc("SP4")
				cFilRFF	:= fFilFunc("RFF")
				cFilRFG	:= fFilFunc("RFF")
				cFilSPC	:= fFilFunc("SPC")
				cFilSPH	:= fFilFunc("SPH")
				cFilSP9 := fFilFunc("SP9")
				cFilSPA := fFilFunc("SPA") 
				cFilSR6 := fFilFunc("SR6")
			    
			    
			     /*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Carrega as Tabelas de Horario Padrao						  ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				IF ( lSPJExclu .or. Empty( aTabPadrao ) )
					aTabPadrao := {}                 
					fTabTurno( @aTabPadrao , IF( lSPJExclu , cLastFil , NIL ) )
				EndIF
			    
		    	/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Carrega TODOS os Eventos da Filial						  ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				IF ( Empty( cFaltas ) .or. ( lSP9Exclu ) )
					cHE			:= ''
					cFaltas		:= ''
					cHDiurnas	:= ''
					cHNoturnas	:= ''
					cAtrasos	:= ''
					cSaidaA     := ''
					cSaidaE     := ''
					lAbortPrint:=GetSP9(cFilSP9, @cHe, @cFaltas, @cHDiurnas, @cHNoturnas, @cAtrasos, @cSaidaA, @cSaidaE )
					IF lAbortPrint
				        Break
					Endif
					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³ Preenche o Array  com as Horas Extras		  				  ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					aSP4	:= {}
					lAbortPrint:=GetSP4(cFilSP4, cHe, aSP4 )
					IF lAbortPrint
				        Break
					Endif
				EndIF
						
				//--Geracao do registro de quebra de CNPJ/CPF ou CEI
				
				//-- Cabecalho 
				TIPO01(aInfo, cTpIdEmp, @cTipoInsc, @cCPFCNPJ, @cCEI )

                
				//-- Obtem o ultimo Horario Contratual para a empresa	
				nCH		:= 0
				
				cCHTableName := oTmpACJCH:GetRealName()
				
				cSQL := " SELECT * FROM " + cCHTableName
				cSql += " 		WHERE  "
				cSql += " 		JCH_TINSC  = '" + cTipoInsc  + "' and "
				cSql += " 		JCH_INSC   = '" + cCPFCNPJ   + "' and "
				cSql += " 		JCH_CEI    = '" + cCEI    + "' and "
				cSql += " 		D_E_L_E_T_ = ' ' "
				
				//COM EMBEDED  NAO FUNCIONA A CONSULTA NA TABELA TEMPORARIA ...POR ISTO USAMOS DBUSEAREA 				
				DbUseArea( .T.,"TOPCONN",TCGenQry(,,ChangeQuery(cSQL)),cCHAliasQry,.F.,.T. )	
				
				If (cCHAliasQry)->(!Eof())
					
					ACJCH->( DbGoTo(   (cCHAliasQry)->(R_E_C_N_O_)     )  )
					nCH	:= Val( (cCHAliasQry)->(JCH_CH) )
				Else
					dbSelectArea("ACJCH")
				EndIf
				
				(cCHAliasQry)->(DbCloseArea())
				
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Carrega periodo de Apontamento Aberto						  ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				IF !CheckPonMes( @dPerIni , @dPerFim , .F. , .T. , .F. , cLastFil )
					Exit
				EndIF
				
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Obtem datas do Periodo em Aberto							  ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				GetPonMesDat( @dIniPonMes , @dFimPonMes , cLastFil )
				
			EndIF
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Verifica se Deve Incrementar a Gauge ou Apenas Atualizar a Men³
			³sagem														   ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			IF ( lIncProcG1 := !( cFilTnoOld == cFilTnoAtu ) )
				cFilTnoOld := cFilTnoAtu
			EndIF
			
			If !lBlind
				// Incrementa a Barra de Gauge referente ao Turno
				IncPrcG1Time( cMsgBarG1 , nRecsSR6 , cTimeIni , .F. , nCount1Time , nIncPercG1 , lIncProcG1 )
			EndIf
		EndIF
		
		If !lBlind
			// Movimenta a R‚gua de Processamento do Processamento Principal
			IncPrcG2Time( STR0028 , nLastRec , cTimeIni , .T. , 2 , nIncPercG2 ) // "Procesados:"
		EndIf
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Consiste Admissao e Demissao                                ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF SRA->(;
					( RA_ADMISSA > dFimCale );
					.or.;
					(;
						!Empty( RA_DEMISSA );
						.and.;
						( RA_DEMISSA < dIniCale );
					);
				)
			SRA->( dbSkip() )
			Loop
		EndIF
	  
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Aborta o processamento                                       ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF ( lAbortPrint )
			aAdd( aLogDet , STR0013 )//"A geracao do ACJEF Foi Cancelada Pelo Usuario"
			Break
		EndIF
        
        cPIS	:= SRA->RA_PIS

	   	aPeriodos := Monta_per( dIniCale , dFimCale , cLastFil , SRA->RA_MAT , dPerIni , dPerFim )

	   	/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³Corre Todos os Periodos 									  ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		naPeriodos := Len( aPeriodos )
		For nX := 1 To naPeriodos
			
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Reinicializa as Datas Inicial e Final a cada Periodo Lido.	  ³
			³Os Valores de dPerIni e dPerFim foram preservados nas   varia³
			³veis: dCaleIni e dCaleFim.									  ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	        //aPeriodos[ nX , 1 ]
	        //aPeriodos[ nX , 2 ] 
			
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Obtem as Datas para Recuperacao das Marcacoes				  ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	        //aPeriodos[ nX , 3 ]
	        //aPeriodos[ nX , 4 ]
			
			cIniData	:= Dtos( aPeriodos[ nX , 3 ] )
			cFimData	:= Dtos( aPeriodos[ nX , 4 ] )
			
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Verifica se Impressao eh de Acumulado						  ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			lImpAcum := ( aPeriodos[ nX , 2 ]  < dIniPonMes )
			
			
			
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³ Retorna Turno/Sequencia das Marca‡”es Acumuladas			  ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			IF ( lImpAcum )
				IF SPF->( dbSeek( SRA->( RA_FILIAL + RA_MAT ) + Dtos( aPeriodos[ nX , 1 ]) ) ) .and. !Empty(SPF->PF_SEQUEPA)
					cTurno	:= SPF->PF_TURNOPA
					cSeq	:= SPF->PF_SEQUEPA
				Else
		    		/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³ Tenta Achar a Sequencia Inicial utilizando RetSeq()³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/                 
					IF !RetSeq(cSeq,@cTurno,aPeriodos[ nX , 1 ],aPeriodos[ nX , 2 ] ,dDataBase,aTabPadrao,@cSeq) .or. Empty( cSeq )
		    			/*
						ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³Tenta Achar a Sequencia Inicial utilizando fQualSeq()		  ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
						cSeq := fQualSeq( NIL , aTabPadrao , aPeriodos[ nX , 1 ] , @cTurno )
					EndIF
				EndIF
			Else
	   			/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³Considera a Sequencia e Turno do Cadastro            		  ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				cTurno	:= SRA->RA_TNOTRAB
				cSeq	:= SRA->RA_SEQTURN  
			EndIF
			
			
			// Carrega Arrays com o Calendario de Marcações do Periodo(aTabCalend) e com as Trocas de Turno do Funcionario (aTurnos)
			aTabCalend 	:= {} 
			aTurnos		:= {}
			aMarcacoes	:= {}
			
			If !GetMarcacoes( @aMarcacoes, @aTabCalend, aTabPadrao, @aTurnos, aPeriodos[nX, 1], aPeriodos[nX, 2], SRA->RA_FILIAL, SRA->RA_MAT, cTurno, cSeq, SRA->RA_CC,,,,,,,,, .F., .F., .F., .T.)
				aAdd( aLogDet , STR0042 + SRA->RA_FILIAL + " " + STR0023 + SRA->RA_MAT + Space(1) + STR0030 + Dtoc(aPeriodos[nX,3]) + " - " + Dtoc(aPeriodos[nX,4]) )//"Nao foi possivel criar o calendario para funcionario. Filial: " ##"Matricula: "##"Periodo: "##/##/## - ##/##/##
				Loop
			EndIf
			
			aApo	:= {}
			
			// Carrega array de apontamentos com as horas trabalhadas previstas.
			lAbortPrint := fGeraHor(cFilSPA, cFilSR6, aTabCalend, aPeriodos[nX,3], aPeriodos[nX,4], @aApo, aMarcacoes) 
			IF lAbortPrint
		        Break
			Endif
			
			/*
			ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			³Verifica se o Calendario sera utilizado no caso de legado ou ³
			³se os novos campos estao alimentados com as informacoes neces³
			³sarias.													  ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			
			IF lImpAcum
				
				lAbortPrint	:= GetApo("RFG", @aApo, cHe, cFaltas, cHDiurnas, cHNoturnas, cAtrasos, cSaidaA, cSaidaE, aSP4, cTipoInsc, cCPFCNPJ, cCEI, cPIS, aRFGFields, nRFGFields, cFilRFG, cIniData, cFimData)
				dbSelectArea("SRA")
				IF lAbortPrint
		           Break
				Endif				 
			Else              
				
				lAbortPrint	:= GetApo("RFF", @aApo, cHe, cFaltas, cHDiurnas, cHNoturnas, cAtrasos, cSaidaA, cSaidaE, aSP4, cTipoInsc, cCPFCNPJ, cCEI, cPIS, aRFFFields, nRFFFields, cFilRFF, cIniData, cFimData)
				
				dbSelectArea("SRA")
				IF lAbortPrint
		           Break
				Endif
			Endif  
		    
		    //Função retorna Nil desde que foi criada, e não tem nenhuma condição de negação.
		    //Apenas alimenta DtIni e DtFim para ser utilizada na TIP001 logo abaixo, 
		    //porém as data não são obrigatórias.    
			fGeraTipos(aApo, cTipoInsc, cCPFCNPJ, cCEI, cPIS, @dDataIni, @dDataFim)
			dbSelectArea("SRA")
	        IF lAbortPrint
	           Break
	        Endif 
			
			// Complementa as informacoes do Cabecalho
			TIPO01(aInfo, cTpIdEmp, cTipoInsc, cCPFCNPJ, cCEI, dDataIni, dDataFim )
			
		NEXT nX	
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Pr¢ximo Funcion rio										   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		SRA->( dbSkip() )
		
	End While
	
End Sequence

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Fecha a Query do SRA e Restaura o Padrao                    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF lQueryOpened		
	SRA->( dbCloseArea() )
	ChkFile( "SRA" )
Endif


If ! lAbortPrint          
	cCPFCNPJ := ""
	IF !FGeraArq(@cCPFCNPJ)            
		aAdd( aLogDet , STR0025 )						//"Erro ao gerar o arquivo"
		aAdd( aLogDet , STR0026 + cCPFCNPJ + STR0027 )	//"-- Empresa: "###" Sem Apontamentos"			
	Endif
Endif	

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Gera o Log de Inconsistencias                                ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !Empty( aLogDet )
	fMakeLog( { aLogDet } , aLogTitle , "PNM420" )
EndIF

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Restaura o Conteudo Original da Filial de Entrada			   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cFilAnt:= cSvFilAnt

RestArea( aAreaSRA )

//-- Apaga o indice do ACJEF
If lCriou
	//P420ApIndice(cArqnome, cArqCH)
	dbSelectArea(cACJEFAlias)
	dbCloseArea()
	If oTmpACJEF <> Nil
	    oTmpACJEF:Delete()
	    Freeobj(oTmpACJEF)
    EndIf
    
    dbSelectArea(cACJCHAlias)
	dbCloseArea()
	If oTmpACJCH <> Nil
	    oTmpACJCH:Delete()
	    Freeobj(oTmpACJCH)
    EndIf
    
Endif

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncai    ³P420ApIndiceºAutor  ³Mauricio MR       º Data ³  20/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apaga o indice do arquivo ACJEF quando sair da rotina      º±±
±±º          ³ Apaga o indice do arquivo ACJCH quando sair da rotina      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PONM420                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function P420ApIndice(cArqJEF, cArqCH)
Local nVezes 	:= 0                          
Local cArquivo 

//-- Trata Arquivo de Controle de Jornada para Efeito Fiscais
cArquivo:= FileNoExt(cArqJEF)+"1"+OrdBagExt()

dbSelectArea("ACJEF")
dbCloseArea()
While File(cArquivo)
	nVezes ++
   	If nVezes >= 10
		Aviso( STR0004,STR0009+'"'+cArquivo +'"', { "Ok" },,STR0008 ) //"Atencao"###"Nao foi possivel excluir o arquivo "###"Erro ao Excluir arquivo"
		Return
	EndIf
	FErase(FileNoExt(cArqJEF)+"1"+OrdBagExt())           
EndDo

//-- Trata Arquivo de Horarios Contratuais
cArquivo:= FileNoExt(cArqCH)+"2"+OrdBagExt()
dbSelectArea("ACJCH")
dbCloseArea()
While File(cArquivo)
	nVezes ++
   	If nVezes >= 10
		Aviso( STR0004,STR0009+'"'+cArquivo +'"', { "Ok" },,STR0008 ) //"Atencao"###"Nao foi possivel excluir o arquivo "###"Erro ao Excluir arquivo"
		Return
	EndIf
	FErase(FileNoExt(cArqCH)+"2"+OrdBagExt())           
EndDo


//-- Trata Arquivo de Horarios Contratuais
cArquivo:= FileNoExt(cArqCH)+"1"+OrdBagExt()
While File(cArquivo)
	nVezes ++
   	If nVezes >= 10
		Aviso( STR0004,STR0009+'"'+cArquivo +'"', { "Ok" },,STR0008 ) //"Atencao"###"Nao foi possivel excluir o arquivo "###"Erro ao Excluir arquivo"
		Return
	EndIf
	FErase(FileNoExt(cArqCH)+"1"+OrdBagExt())           
EndDo

Return



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Pn420Cria ³ Autor ³ Mauricio MR		    ³ Data ³ 20/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se existe o arquivo e cria se necessario			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³            												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PONM420  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Pn420Cria( )

Local aStru 	:={}
Local cInd     
Local cInd1
Local nVezes	:= 0
Local aLstIndices := {}
   
aStru 	:= {;
			 {	"JEF_TINSC"		, "C" 	, 001 , 0 },;
			 {	"JEF_INSC"		, "C" 	, 014 , 0 },;
			 {	"JEF_CEI"		, "C" 	, 012 , 0 },;
			 {	"JEF_TIPO" 		, "C" 	, 001 , 0 },;
			 {	"JEF_PIS"		, "C" 	, 012 , 0 },;
 			 {	"JEF_DATA"		, "D"	, 008 , 0 },;
			 {	"JEF_HORA"		, "C" 	, 004 , 0 },;
			 {	"JEF_EJ"		, "C" 	, 005 , 0 },;				 
 			 {	"JEF_SI"		, "C" 	, 005 , 0 },;				 
 			 {	"JEF_EI"		, "C" 	, 005 , 0 },;				  				 
 			 {	"JEF_SJ"		, "C" 	, 005 , 0 },;				 
			 {	"JEF_CH"		, "C" 	, 004 , 0 },;				 
			 {	"JEF_TEXTO"		, "C" 	, 255 , 0 },;
			 {	"JEF_EMFIMA"	, "C"	, 10  , 0 } }

AAdd (aLstIndices, {"JEF_TINSC","JEF_INSC","JEF_CEI","JEF_TIPO","JEF_PIS","JEF_DATA","JEF_EJ"}  ) 
oTmpACJEF:= RhCriaTrab(cACJEFAlias, aStru, aLstIndices)

(cACJEFAlias)->(dbSetOrder(1))
(cACJEFAlias)->(dbGotop())

aStru 	:= {;
				 {	"JCH_TINSC"		, "C" 	, 001 , 0 },;
				 {	"JCH_INSC"		, "C" 	, 014 , 0 },;
				 {	"JCH_CEI"		, "C" 	, 012 , 0 },;
				 {	"JCH_CH"		, "C" 	, 004 , 0 },;
				 {	"JCH_EJ"		, "C" 	, 004 , 0 },;				 
 				 {	"JCH_SI"		, "C" 	, 004 , 0 },;				 
 				 {	"JCH_EI"		, "C" 	, 004 , 0 },;				  				 
 				 {	"JCH_SJ"		, "C" 	, 004 , 0 },;   
 				 {	"JCH_S1"		, "C" 	, 004 , 0 },;				 
 				 {	"JCH_E1"		, "C" 	, 004 , 0 },;				 
 				 {	"JCH_S2"		, "C" 	, 004 , 0 },;				  				 
 				 {	"JCH_E2"		, "C" 	, 004 , 0 },;   
				 {	"JCH_TEXTO"		, "C" 	, 255 , 0 }; 				 				 
			 }

aLstIndices := {}
AAdd (aLstIndices, {"JCH_TINSC","JCH_INSC","JCH_CEI","JCH_EJ","JCH_SJ","JCH_SI","JCH_EI","JCH_S1","JCH_E1","JCH_S2","JCH_E2"}  ) 
AAdd (aLstIndices, {"JCH_TINSC","JCH_INSC","JCH_CEI","JCH_CH"}  ) 

oTmpACJCH:= RhCriaTrab(cACJCHAlias, aStru, aLstIndices)

(cACJCHAlias)->(dbSetOrder(1))
(cACJCHAlias)->(dbGotop())

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³GetApo    ³ Autor ³Mauricio MR		    ³ Data ³29/10/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtem os apontamentos para o periodo informado			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³GetMarc()													  ³±±                                      L
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³PONM420	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/              
Static Function GetApo(cAliasSP_, aApo, cHe, cFaltas, cHDiurnas, cHNoturnas, cAtrasos, cSaidaA, cSaidaE ,aSP4, cTipoInsc, cCPFCNPJ, cCEI, cPIS, aSp_Fields, nSp_Fields, cFil, cIniData, cFimData, dDataIni, dDataFim  )

Local aArea			:= GetArea()
Local nX			:= 0  
Local cPrefix		:= ( PrefixoCpo( cAliasSP_ )) 
Local cMat			:= SRA->RA_MAT  
Local dDataApo   
Local lCancela		:= .F. 
Local cEvento		:= ""
Local nQuant		:= 0    
Local nPercent  	:= 0    
Local cSinal		:= "1"
Local cTurno		:= cTamTurno
Local cTipodia		:= ""
Local cTipoHeAnt	:= ""  
Local nDestino		:= 1
Local nI			:= 0
Local nY			:= 0
Local nPosTno		:= 0 
Local nPos			:= 0
Local nPosDel		:= 0
Local nPosApo		:= 0  
Local aTnoxDia		:= {}
Local aDiaxMod		:= {}
Local aDiasSemApo	:= {}  
Local lTemnoDia		:= .F.	 
Local cModalidade	:= ""		
Local dDataAnt		:= Ctod("") 
Local lQueryOpened	:= .F.
Local cAliasSP_Qry	:= ""
Local cSP_Campos	:= ""
Local cSP_Query 	:= ""
Local cSP_Where		:= ""			                  
Local cCpoRecno
Local nPosMarc		:= 0

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carregando os Campos do Arquivo na Query					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/    
cSP_campos:= ""
For nX := 1 To nSp_Fields
	cSP_Campos += aSp_Fields[ nX , 01 ] + ", "
Next nX
cSP_Campos := SubStr( cSP_Campos , 1 , Len( cSP_Campos ) - 2 ) 

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Montando a Condicao										   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cSP_Where := ""
cSP_Where += cPrefix+"_FILIAL='"+cFil+"'"
cSP_Where += " AND "				
cSP_Where += cPrefix+"_MAT='" + cMat +"'"
cSP_Where += " AND "				
cSP_Where += " ( "
cSP_Where += cPrefix+"_DATA>='"+cIniData+"'"
cSP_Where += " AND "
cSP_Where += cPrefix+"_DATA<='"+cFimData+"'"
cSP_Where += " ) "
cSP_Where += " AND "
cSP_Where += "D_E_L_E_T_=' ' "

cAliasSP_Qry	:= GetNextAlias()
cTableName	:= InitSqlName( cAliasSP_ )

cCpoRecno	:= ",R_E_C_N_O_"

cSP_Query := "SELECT "
cSP_Query += cSP_Campos
cSP_Query += cCpoRecno + " RECNO "
cSP_Query += " FROM "
cSP_Query += cTableName
cSP_Query += " WHERE "
cSP_Query += cSP_Where
cSP_Query += "ORDER BY " + SqlOrder( (cAliasSP_)->( IndexKey() ) )
cSP_Query := ChangeQuery( cSP_Query )
IF ( lQueryOpened := MsOpenDbf(.T.,"TOPCONN",TcGenQry(NIL,NIL,cSP_Query),cAliasSP_Qry,.F.,.T.) )
	For nX := 1 To nSp_Fields
		IF !( aSp_Fields[ nX , 02 ] == "C" )
			TcSetField(cAliasSP_Qry,aSp_Fields[nX,01],aSp_Fields[nX,02],aSp_Fields[nX,03],aSp_Fields[nX,04])
		EndIF
	Next nX
	cSP_Query := ""
	lQueryOpened		:= .T.
Else
	cAliasQuery	:= cAliasSP_
	( cAliasSP_Qry )->( dbSeek( cFilMat  , .F. ) )
EndIF


IF !lQueryOpened
	(cAliasSP_)->( dbSeek( cFil + SRA->RA_MAT + cIniData  , .T. ) )
	cAliasSP_Qry	:= cAliasSP_
Endif

dDataAnt	:= Ctod("") 

While (cAliasSP_Qry)->( !Eof() .and. ( ( cFil + cMat ) == ( &(cPrefix+"_FILIAL")+&(cPrefix+"_MAT") ) )  .and.;
			   ( ( Dtos( &(cPrefix+"_DATA") ) >= cIniData ) .and.  ( Dtos( &( cPrefix+"_DATA") ) <= cFimData) )  )
    
	
	IF dDataAnt <> ( dDataApo:= ((cAliasSP_Qry)->(&(cPrefix+"_DATA"	))))
		nPosApo		:= Ascan(aApo,{|x| x[1] == dDataApo} )
		If nPosApo == 0
			(cAliasSP_Qry)->( dbSkip() )
			Loop
		EndIf
		IF dDataAnt <> Ctod("")
			IF !fChkApo( aApo[nPosApo ] )
				//aAdd( aLogDet , STR0031 + cFil + " " + STR0032 + cCodAuto )//"Evento sem classificacao: Filial: "##"Evento: "##
				lCancela	:= .T.
			Endif
		Endif   
		dDataAnt	:= (cAliasSP_Qry)->(&(cPrefix+"_DATA"	)) 	//-- Data do Apontamento  
		
		aTnoxDia	:= {}
		aDiaxMod	:= {}
		aDiasSemApo	:= {}			
	Endif                
	
    //-- Obtem o Codigo do Evento de Apontamento
	//cEvento 	:= 	(cAliasSP_Qry)->( If( Empty( &(cPrefix+"_PDI") ) ,&(cPrefix+"_PD"),&(cPrefix+"_PDI") ) )
	cEvento 	:= 	(cAliasSP_Qry)->( &(cPrefix+"_PD") )
    //-- Obtem as horas do Evento
	//nQuant 		:=  (cAliasSP_Qry)->( If( Empty( &(cPrefix+"_QUANTI") ) ,&(cPrefix+"_QUANTC"),&(cPrefix+"_QUANTI") ) )
	
	nQuant 		:=  (cAliasSP_Qry)->( &(cPrefix+"_QUANTC") )
	
	 //-- Obtem o Percentual do adicional de horas extras
	nPercent 	:=  (cAliasSP_Qry)->( &(cPrefix+"_PERCEN") ) 
	
	//-- Obtem o Turno do Apontamento 
	//cTurno		:=  (cAliasSP_Qry)->( &(cPrefix+"_TURNO") ) 		
	cTurno		:= aApo[nPosApo, 19] 
	//-- Obtem o Tipo do Dia do Apontamento 
	cTipoDia	:= aApo[nPosApo, 20] 	
	
	//-- Destino das Horas Apontadas (Compensação ou pagamento)
	nDestino 	:=  (cAliasSP_Qry)->( &(cPrefix+"_TIPO") )  
	
	//-- Sinal da quantidade do evento. "1" - Soma, "2" - Subtrai
	cSinal	 	:=  (cAliasSP_Qry)->( &(cPrefix+"_SINAL") )  	
	
	//-- Nao Lista dias em que o empregado nao possua horario a ser cumprido
	IF Empty(aApo[nPosApo, 21] )
	   	(cAliasSP_Qry)->( dbSkip() )   
	 
		IF ( dDataAnt <> ( (cAliasSP_Qry)->(&(cPrefix+"_DATA"	)) ) ) .or. (cAliasSP_Qry)->(Eof())
			IF !fChkApo( aApo[nPosApo ] )
				//aAdd( aLogDet , STR0031 + cFil + " " + STR0032 + cCodAuto )//"Evento sem classificacao: Filial: "##"Evento: "##
				lCancela	:= .T.
			Endif
		Endif
        Loop
	Endif
	
	
	IF ( cEvento$cHDiurnas )
		aApo[nPosApo, 2] 	:= SomaHoras(aApo[nPosApo,2], nQuant)
	ElseIF ( cEvento$cHNoturnas )
			aApo[nPosApo, 3] 	:= SomaHoras(aApo[nPosApo,3], nQuant)	   
    ElseIF 	( cEvento $ cFaltas )
   	    	fCalcDest(@aApo[nPosApo,29], 	@aApo[nPosApo,33], nQuant, nDestino, /*aApo[nPosApo,28]*/, /*aApo[nPosApo,23]*/, 			)	
    ElseIF  ( cEvento $ cAtrasos )
	    	fCalcDest(@aApo[nPosApo,30], 	@aApo[nPosApo,34], nQuant, nDestino, /*aApo[nPosApo,26]*/, /*aApo[nPosApo,23]*/,			)
    ElseIF 	( cEvento $ cSaidaA )
	    	fCalcDest(@aApo[nPosApo,31], 	@aApo[nPosApo,35], nQuant, nDestino, /*aApo[nPosApo,27]*/, /*aApo[nPosApo,23]*/,			)
    ElseIF  ( cEvento $ cSaidaE  )  
			fCalcDest(@aApo[nPosApo,32], 	@aApo[nPosApo,36], nQuant, nDestino, /*aApo[nPosApo,27]*/, /*aApo[nPosApo,23]*/,			)            
    ElseIf ( cEvento$cHe )
	
		    //-- Inicializa a variavel de pesquisa do evento para obtencao da modalidade e do percentual
			nPosTno	:= 0
			//-- Procura pelo Evento na Tabela do Dia 
			IF !Empty(aTnoxDia)
				lTemnoDia	:= .F.
                //Procura pela Modalidade e Percentual
       	     	IF Empty( nPosTno:= Ascan(aTnoxDia,	{|x| 		( x[1] == cTurno) 	.and. 	;
    	        		                    	      			( x[2] == cEvento) /*.and.*/  	;
																/*( x[3] == cTipoDia)*/ 		;
											};
									   );
							)		   
					 nPosTno:= Ascan(aTnoxDia,	{|x|( x[1] == cTamTurno )	.and. 	;
    		       	                    	        ( x[2] == cEvento) 				/*.and.*/  	;
													/*( x[3] == cTipoDia)*/ 					;
												};
								   	)
				Endif
			
				IF nPosTno	> 0
				    //-- Procura pela Localizacao da Modalidade e Percentual
				    //-- na data de apontamento
			   		nPos:= Ascan(aDiaxMod,	{|x| 	( x[1] == aTnoxDia[nPosTno,4])	.and. 	;
													( x[2] == aTnoxDia[nPosTno,5])			;
											};
							   )  

					IF nDestino == 2 //Banco de Horas / Horas compensadas 
					
	    				//-- converte as horas extras noturnas em horas-relogio se nao usou hora reduzida para calculo das horas extras do dia
			    		If aDiaxMod[nPos, 1] == "N"  .and. !aApo[nPosApo,22] 
    						aApo[nPosApo, 18 ]:= __TimeSum( aApo[nPosApo, 18 ], __Min2Hrs(__Hrs2Min( nQuant )  * aApo[nPosApo,23]	))     
						   	aApo[nPosApo, 18 ]:= __TimeSum( __TimeSum( aApo[nPosApo, 18 ] , 0 ) , 0 )   						    						
    						
							
						Else
							aApo[nPosApo, 18 ]:= __TimeSum( aApo[nPosApo, 18 ], nQuant )  
						  	aApo[nPosApo, 18 ]:= __TimeSum( __TimeSum( aApo[nPosApo, 18 ] , 0 ) , 0 )   
								
						Endif
						
					Else
					
						If nPos == 1   		//Modalidade Extra 1  
							aApo[nPosApo, 4 ]:= SomaHoras( aApo[nPosApo, 4 ], nQuant )	
							
							aApo[nPosApo, 5 ]:= aDiaxMod[nPos, 2]
							aApo[nPosApo, 6 ]:= aDiaxMod[nPos, 1]
	
						ElseIf nPos == 2 	//Modalidade Extra 2
							aApo[nPosApo, 7 ]:= SomaHoras( aApo[nPosApo, 7 ], nQuant )	
							aApo[nPosApo, 8 ]:= aDiaxMod[nPos, 2]
							aApo[nPosApo, 9 ]:= aDiaxMod[nPos, 1]
	
						ElseIf nPos == 3	//Modalidade Extra 3
							aApo[nPosApo, 10]:= SomaHoras( aApo[nPosApo, 10 ], nQuant )	
							aApo[nPosApo, 11]:= aDiaxMod[nPos, 2]
							aApo[nPosApo, 12]:= aDiaxMod[nPos, 1]
	
						ElseIf nPos == 4	//Modalidade Extra 4
							aApo[nPosApo, 13]:= SomaHoras( aApo[nPosApo, 13 ], nQuant )	
							aApo[nPosApo, 14]:= aDiaxMod[nPos, 2]
							aApo[nPosApo, 15]:= aDiaxMod[nPos, 1]						
						Endif
					Endif
					lTemnoDia	:= .T.
				Endif			   
         	      
			Endif
         	   
			//-- Na primeira vez ou se nao encontrou no historico anterior
			IF Empty(aTnoxDia) .or. !lTemnoDia
				
    			nPosTno:= Ascan(aSP4,	{|x| 	( x[1] == cTurno) 	.and. 	;
    	    	                           	    ( x[2] == cEvento) /*.and.*/  	;
												/*( x[3] == cTipoDia)*/ 		;
										};
							   )
						
				//-- Se nao encontrar na tabela de HE do Turno, procura pela tabela de HE generica
				IF Empty(nPosTno)
				
					nPosTno:= Ascan(aSP4,	{|x| 	( x[1] == cTamTurno)  	.and. 	;
					                           	    ( x[2] == cEvento) 					/*.and.*/  	;
													/*( x[3] == cTipoDia)*/						;
											};
									)
				Endif				
				
				IF Empty(nPosTno)
				//-- Se existir percentual de valorização obtem as demais informacoes a partir
				//-- do lancamento pois se trata de uma hora extra que não se encontra na tabela
				//-- de horas extras, provavelmente eh originaria de um abono ou evento informado 
					IF !Empty(nPercent) 
						IF !( cTipoDia $ "A*B*C*D*E*F*G*H" )
							cModalidade := If( Val(cTipoDia ) >= 5 , "N" , "D" )
						Else
							cModalidade	:= If( cTipoDia $ "B*D*F*H" , "N" , "D" )
						EndIF	
					Else  
					    dbSelectArea("SP9")
					    dbSeek ((xFilial("SP9"))+cEvento) 
					        If Empty(SP9->P9_IDPON) 
					   			aAdd( aLogDet , STR0040 + fPoeTraco(cFil) + Space(1) + STR0018 + fPoeTraco(cTurno) + Space(1) + STR0043 + cTipoDia + Space(1) + STR0038 + cEvento  )//"Evento de Hora Extra Nao Encontrado para a Filial: "##"Turno: "##"Tipo: "##"Codigo: "
					   			lCancela	:= .T.
					   			Exit    
					   	   	Else
					   	   		IF !( cTipoDia $ "A*B*C*D*E*F*G*H" )
						   	 		cModalidade := If( Val(cTipoDia ) >= 5 , "N" , "D" )
					 	 		Else
						  			cModalidade	:= If( cTipoDia $ "B*D*F*H" , "N" , "D" )
					   	  		EndIF	
					   	  		nPercent:= SuperGetMV("MV_PERCVAL",Nil,50)
					   	    Endif
					Endif
				Else
					aadd(aTnoxDia, 	{	aSP4[nPosTno, 1] 	,; //Turno se existir
										aSP4[nPosTno, 2] 	,; //Evento
										aSP4[nPosTno, 3] 	,; //Tipo de Dia
										aSP4[nPosTno, 4] 	,; //Modalidade
										aSP4[nPosTno, 5] 	 ; //Percentual
									};
						)  
				Endif
					
					
				nPos:= 0
				//-- Se Ja registrou alguma modalidade procura a posicao da modalida informada e do percentual
				IF !Empty(aDiaxMod)                   
					//-- Se o evento foi encontrado na tabela de horas extras, transfere as informacoes
					IF !Empty(nPosTno) 
					   cModalidade 	:= aTnoxDia[Len(aTnoxDia),4]
					   nPercent		:= aTnoxDia[Len(aTnoxDia),5]
					Endif 
					
					nPos:= Ascan(aDiaxMod,	{|x| 	( x[1] == cModalidade)	.and. 	;
													( x[2] == nPercent)				;
											};
							   )  
				Endif
					
				//-- Se Nao localizou a modalidade/percentual informados cria novo elemento
				IF Empty(nPos) 
					IF !Empty(nPosTno) 
					   cModalidade 	:= aTnoxDia[Len(aTnoxDia),4]
					   nPercent		:= aTnoxDia[Len(aTnoxDia),5]
					Endif 
					
					aadd(aDiaxMod,	{cModalidade, nPercent} )	
					
					nPos := Len(aDiaxMod)
					If ( nPos > 1 .And. cTipoHeAnt <> aDiaxMod[nPos, 1] ) .Or. ( nPos > 4 .And. cTipoHeAnt == aDiaxMod[nPos, 1] )
						aAdd(aApo,aClone(aApo[nPosApo]))						
						nPosApo := Len(aApo)
						aSize(aApo,nPosApo)
						
						For nI:=1 To Len(aDiaxMod)-1
							aDel(aDiaxMod,1)
							aSize(aDiaxMod,Len(aDiaxMod)-1) 
						Next
						
						nPos := 1
						
						aApo[nPosApo,4] := 0
						aApo[nPosApo,5] := 0
						aApo[nPosApo,6] := " "
						aApo[nPosApo,7] := 0
						aApo[nPosApo,8] := 0
						aApo[nPosApo,9] := " "
						aApo[nPosApo,10] := 0
						aApo[nPosApo,11] := 0
						aApo[nPosApo,12] := " "
						aApo[nPosApo,13] := 0
						aApo[nPosApo,14] := 0
						aApo[nPosApo,15] := " "
					Endif
				Endif
				
				IF nDestino == 2 //Banco de Horas / Horas compensadas 
					//-- converte as horas extras noturnas em horas-relogio se nao usou hora reduzida para calculo das horas extras do dia
		    		If aDiaxMod[nPos, 1] == "N"  .and. ! aApo[nPosApo,22] 
   						aApo[nPosApo, 18 ]:= __TimeSum( aApo[nPosApo, 18 ], __Min2Hrs(__Hrs2Min( nQuant )  * aApo[nPosApo,23]	)) 
						aApo[nPosApo, 18 ]:= __TimeSum( __TimeSum( aApo[nPosApo, 18 ] , 0 ) , 0 )   						
						
					Else
						aApo[nPosApo, 18 ]:= __TimeSum( aApo[nPosApo, 18 ], nQuant )  
						aApo[nPosApo, 18 ]:= __TimeSum( __TimeSum( aApo[nPosApo, 18 ] , 0 ) , 0 )   
							
					Endif
				
				Else
					//-- converte as horas extras noturnas em horas-relogio se nao usou hora reduzida para calculo das horas extras do dia
		    		If aDiaxMod[nPos, 1] == "N"  .and. aApo[nPosApo,22] 
						nQuant	:= fRedz2HrsRel(nQuant,aApo[nPosApo,23])
					Endif                     

				   	If nPos == 1   		//Modalidade Extra 1
						aApo[nPosApo, 4 ]:= SomaHoras( aApo[nPosApo, 4 ], nQuant )
						aApo[nPosApo, 5 ]:= aDiaxMod[nPos, 2]
						aApo[nPosApo, 6 ]:= aDiaxMod[nPos, 1]
						cTipoHeAnt 		 := aDiaxMod[nPos, 1]
					ElseIf nPos == 2 	//Modalidade Extra 2
						aApo[nPosApo, 7 ]:= SomaHoras( aApo[nPosApo, 7 ], nQuant )	
						aApo[nPosApo, 8 ]:= aDiaxMod[nPos, 2]
						aApo[nPosApo, 9 ]:= aDiaxMod[nPos, 1]
						cTipoHeAnt 		 := aDiaxMod[nPos, 1]
					ElseIf nPos == 3	//Modalidade Extra 3
						aApo[nPosApo, 10]:= SomaHoras( aApo[nPosApo, 10 ], nQuant )	
						aApo[nPosApo, 11]:= aDiaxMod[nPos, 2]
						aApo[nPosApo, 12]:= aDiaxMod[nPos, 1]
						cTipoHeAnt 		 := aDiaxMod[nPos, 1]
					ElseIf nPos == 4	//Modalidade Extra 4
						aApo[nPosApo, 13]:= SomaHoras( aApo[nPosApo, 13 ], nQuant )	
						aApo[nPosApo, 14]:= aDiaxMod[nPos, 2]
						aApo[nPosApo, 15]:= aDiaxMod[nPos, 1]
						cTipoHeAnt 		 := aDiaxMod[nPos, 1]						
					Endif
                Endif
	   		Endif	
	Endif      

	(cAliasSP_Qry)->( dbSkip() )   
 
	IF ( dDataAnt <> ( (cAliasSP_Qry)->(&(cPrefix+"_DATA"	)) ) ) .or. (cAliasSP_Qry)->(Eof())
		IF !fChkApo( aApo[nPosApo ] )
			//aAdd( aLogDet , STR0031 + cFil + " " + STR0032 + cCodAuto )//"Evento sem classificacao: Filial: "##"Evento: "##
			lCancela	:= .T.
		Endif
	Endif
	
EndDo

//-- Corre todos os apontamentos e ajustas as horas noturnas
For nX:= 1 To Len(aApo)
    /*
    //-- Usou hora reduzida para calculo das horas extras do dia
    //IF !aApo[nX,22]
    		//-- converte as horas extras noturnas relogio em horas reduzidas
    		If aApo[nX, 6 ] == "N"  	//06 - Modalidade   1
    			aApo[nX, 04 ]:= fHrsRel2Redz(	aApo[nX, 04 ],aApo[nX,23])
    		Endif 
   			If aApo[nX, 9 ] == "N"  	//09 - Modalidade   2
    			aApo[nX, 07 ]:= fHrsRel2Redz(	aApo[nX, 07 ],aApo[nX,23])
    		Endif
			If aApo[nX, 12 ] == "N"		//12 - Modalidade   3  
    			aApo[nX, 10 ]:= fHrsRel2Redz(	aApo[nX, 10 ],aApo[nX,23])		
    		Endif    		
			If aApo[nX, 15 ] == "N"		//15 - Modalidade   4  
				aApo[nX, 13 ]:= fHrsRel2Redz(	aApo[nX, 13 ],aApo[nX,23])
    		Endif    		
	Endif
	*/ 
	//-- O acrescimo noturno nao eh calculado separadamente das horas noturnas trabalhadas 
	IF (!aApo[nX, 24]) //.and. (!aApo[nX, 25]) //24 - Acrescimo Noturno no Adicional
		//-- Horas noturnas trabalhadas sao convertidas em horas-relogio
		aApo[nX, 3]:= fRedz2HrsRel(	aApo[nX, 03 ],aApo[nX,23])
	Endif
	
	//-- Soma as Faltas/Atrasos/Saida Antecipada e Saida no Expediente no campo de Faltas/Atrasos para Folha
	IF 	!Empty(aApo[nX, 29])	//29 - Folha: Horas de Faltas	  
		aApo[nX, 16] 	:=__TimeSum( aApo[nX, 16] , aApo[nX, 29] )
	Endif 
	
	IF 	!Empty(aApo[nX, 30])	//30 - Folha: Horas de Atrasos	  
		aApo[nX, 16] 	:=__TimeSum( aApo[nX, 16] , aApo[nX, 30] )
	Endif
	
	IF 	!Empty(aApo[nX, 31])	//31 - Folha: Horas de Saida Antecipada											   
		aApo[nX, 16] 	:=__TimeSum( aApo[nX, 16] , aApo[nX, 31] )
	Endif
	
	IF 	!Empty(aApo[nX, 32])	//32 - Folha: Horas de Saida no Expediente  
		aApo[nX, 16] 	:=__TimeSum( aApo[nX, 16] , aApo[nX, 32] )
	Endif			
	
	IF 	!Empty(aApo[nX, 16])	//16 - Horas Faltas/Atrasos  
		aApo[nX, 16] 	:=__TimeSum( __TimeSum( aApo[nX, 16] , 0 ) , 0 )
	Endif
	
	//-- Soma as Faltas/Atrasos/Saida Antecipada e Saida no Expediente no campo de horas a compensar para Banco	
	IF 	!Empty(aApo[nX, 33])	//33 - Banco: Horas de Faltas 
		aApo[nX, 18] 	:=__TimeSub( aApo[nX, 18] , aApo[nX, 33] )
	Endif 
	
	IF 	!Empty(aApo[nX, 34])	//34 - Banco: Horas de Atrasos 
		aApo[nX, 18] 	:=__TimeSub( aApo[nX, 18] , aApo[nX, 34] )
	Endif
	
	IF 	!Empty(aApo[nX, 35])	//35 - Banco: Horas de Saida Antecipada	 
		aApo[nX, 18] 	:=__TimeSub( aApo[nX, 18] , aApo[nX, 35] )
	Endif
	
	IF 	!Empty(aApo[nX, 36])	//36 - Banco: Horas de Saida no Expediente	
		aApo[nX, 18] 	:=__TimeSub( aApo[nX, 18] , aApo[nX, 36] )
	Endif			
	
	IF 	!Empty(aApo[nX, 18])	//18 - Saldo a compensar  
		aApo[nX, 18] 	:=__TimeSub( __TimeSub( aApo[nX, 18] , 0 ) , 0 )
	Endif
	
	//-- Verificar se existem horas a compensar e gera o sinal das mesmas
	IF 	!Empty(aApo[nX, 18])
		IF aApo[nX, 18] > 0
			aApo[nx, 17]:= 1
		Else                
			aApo[nx, 17]:= 2
		Endif	
		aApo[nX, 18]	:= Abs(aApo[nX, 18])
		aApo[nX, 18] 	:=__TimeSum( __TimeSum( aApo[nX, 18] , 0 ) , 0 )
	Endif
	
	If nX < Len(aApo)
		// Reorganiza o array aApo para juntar todas as modalidades ("D" e "N") em uma unica posição no array, respeitando o limite de 4 HE para cada posição no array
		dDataApo 	:= aApo[nX,1]
		cModalidade := aApo[nX,6]
		For nI:=6 To 15 Step 3
			If Empty( aApo[nX,nI] )
				If (nPosDel := aScan(aApo, {|x| x[1] == dDataApo .And. x[6] == cModalidade},nX+1)) > 0					
					aApo[nX,nI-2]	:=	aApo[nPosDel,4]
					aApo[nX,nI-1]	:=	aApo[nPosDel,5]
					aApo[nX,nI]		:=	aApo[nPosDel,6]
					
					For nY:=4 To 13 Step 3
						aApo[nPosDel,nY]	:= aApo[nPosDel,nY+3]
						aApo[nPosDel,nY+1]	:= aApo[nPosDel,nY+4]
						aApo[nPosDel,nY+2]	:= aApo[nPosDel,nY+5]
					Next
					
					aApo[nPosDel,13]	:= 0
					aApo[nPosDel,14]	:= 0
					aApo[nPosDel,15]	:= " "
				EndIf
			EndIf
		Next
	EndIf
	
	// Verifica se Tem marcações, mas não tem apontamento (funcionário cumpriu a jornada definida e não gerou horas normais)
	If Empty(aApo[nX, 02]) .And. Empty(aApo[nX, 03]) .And. (nPosMarc := (AScan(aMarcacoes, {|x| x[AMARC_DATAAPO] == aApo[nX, 01] })) ) > 0
		CalcHorasN(aApo[nX, 01], nPosMarc, @aApo[nX])
	EndIf
	
Next

IF lQueryOpened
	( cAliasSP_Qry )->( dbCloseArea() )
Endif	

RestArea(aArea)

Return (lCancela)	



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fHrsRel2Redz ³ Autor ³ Mauricio MR        ³ Data ³ 08/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Convert horas relogio em horas reduzidas				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
/*Static function fHrsRel2Redz(nHoras,nMinHnot)    
IF !Empty(nHoras)
	//--Calcula as horas noturnas
	nHoras:= __Min2Hrs(__Hrs2Min(nHoras)  * nMinHnot	)  
	//-- Trata arredondamento das horas (caso particular do protheus)
	nHoras:= __TimeSum( __TimeSum( nHoras, 0 ) , 0 )  
Endif	
Return(nHoras) */



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fRedz2HrsRel ³ Autor ³ Mauricio MR        ³ Data ³ 04/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Convert horas reduzidas em horas relogio				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static function fRedz2HrsRel(nHoras,nMinHnot)    
IF !Empty(nHoras)
	//--Calcula as horas noturnas
	nHoras:= __Min2Hrs(__Hrs2Min(nHoras)  / nMinHnot	)  
	//-- Trata arredondamento das horas (caso particular do protheus)
	nHoras:= __TimeSum( __TimeSum( nHoras, 0 ) , 0 )  
Endif	
Return(nHoras)        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fCalcDest    ³ Autor ³ Mauricio MR        ³ Data ³ 04/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Apura os totais conforme destino das horas dos eventos	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fCalcDest(nHoras, nBanco, nQuant, nDestino, lReduz, nReduz, cSinal)
Local nQuantNew

DEFAULT cSinal 	:= '1'
DEFAULT lReduz	:= .T.
                     
nQuantNew	:=   nQuant  


//-- converte as horas extras noturnas em horas-relogio se nao usou hora reduzida para calculo das horas extras do dia
If !lReduz
	nQuantNew:= __Min2Hrs(__Hrs2Min( nQuant )  * nReduz	)	
Endif
	
IF nDestino == 2 //Banco de Horas / Horas compensadas 
    IF cSinal == "1"
		nBanco:= __TimeSum( nBanco,nQuantNew) 
	Else 
		nBanco:= __TimeSub( nBanco,nQuantNew) 
	Endif	
	nBanco:= __TimeSum( __TimeSum( nBanco, 0 ) , 0 )  
Else                
    IF cSinal == "1"
		nHoras:= __TimeSum( nHoras, nQuantNew)     
	Else                                           
		nHoras:= __TimeSub( nHoras, nQuantNew)     
	Endif
		
  	nHoras:= __TimeSum( __TimeSum( nHoras, 0 ) , 0 )  
Endif	

Return(Nil)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fPoeTraco ³ Autor ³ Mauricio MR           ³ Data ³ 04/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para por traco no lugar de branco				      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fPoeTraco(cCampo) 
Return( IF( Empty(cCampo), Replicate("-",len(cCampo)),cCampo))    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fchkApo   ³ Autor ³ Mauricio MR           ³ Data ³ 31/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Funcao para checagem dos apontamentos do Dia			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Static Function fchkApo(aApo)
Local lRet	:= .T.

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fGeraHor  ³ Autor ³ Mauricio MR           ³ Data ³ 31/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Gera os horarios contratuais previstos para o empregado     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fGeraHor(cFilRegra, cFilTurno, aTabCalend, dPerIni, dPerfim, aApo, aMarcacoes)

Local nX       		:= 0
Local dData    		:= 0
Local cTipodia 		:= ''        
Local lTrbFeriado	:=.F.  
Local aRegra		:= {}
Local cRegra		:= ''  
Local aTurno		:= {}
Local cTurno		:= cTamTurno
Local cIntSREP		:= '' 
Local cOrdem		:= '!!'  
Local lAfastado		:= .F. 
Local lForaPer		:= .F.     
Local nLenCalend	:= 	Len(aTabCalend) 
Local aHorSREP		:= ""
Local lCancela		:= .F.
Local lTemMarc		:= .F. 

Default aMarcacoes := {}

For nX := 1 To nLenCalend
    
	dData := aTabCalend[nX,CALEND_POS_DATA	]      
	
    //Somente verifica afastamento para Ordem ainda nao lida
    If cOrdem != aTabCalend[nX, CALEND_POS_ORDEM]                                                
		cOrdem := aTabCalend[nX, CALEND_POS_ORDEM]  
		//-- Desconsidera as datas fora do periodo solicitado
		lForaPer	:= (dData < dPerIni .OR. dData > dPerFim)  .OR. SRA->( RA_SITFOLH $ 'DúT' .and. dData > RA_DEMISSA ) 
		//-- Desconsidera as datas de afastamento             
		lAfastado:=  fAfasta(SRA->RA_FILIAL,SRA->RA_MAT,dData)      
		
		aAdd(aApo, {;
					dData	,;	//01 - Data de Apontamento
					0		,; 	//02 - Horas Diurnas
					0		,; 	//03 - Horas Noturnas 
					0		,; 	//04 - Horas Extras 1
					0		,; 	//05 - Percentual   1
					" "		,; 	//06 - Modalidade   1
					0		,; 	//07 - Horas Extras 2
					0		,; 	//08 - Percentual   2
					" "		,; 	//09 - Modalidade   2
					0		,; 	//10 - Horas Extras 3
					0		,; 	//11 - Percentual   3
					" "		,; 	//12 - Modalidade   3
					0		,; 	//13 - Horas Extras 4
					0		,; 	//14 - Percentual   4
					" "		,; 	//15 - Modalidade   4																					
					0		,; 	//16 - Horas Faltas/Atrasos
					0		,; 	//17 - Sinal de Horas
					0 		,; 	//18 - Saldo a compensar
					""		,; 	//19 - Turno de Trabalho
					""      ,; 	//20 - Tipo do dia  
					{}      ,;	//21 - aHorarios para Efeito do SREP   
					.F.     ,;	//22 - Extra com Hora Reduzida 
					0      ,;	//23 - Valor da hora reduzida
					.F.		,;	//24 - Acrescimo Noturno no Adicional
					.F.     ,; 	//25 - Acrescimo Noturno em Evento Especifico 
					.F.     ,;	//26 - Atraso com Hora Reduzida
					.F.     ,;	//27 - Saida Antecipada com Hora Reduzida
					.F.     ,; 	//28 - Faltas com Hora Reduzida	 
					0		,;	//29 - Folha: Horas de Faltas						
					0		,;	//30 - Folha: Horas de Atrasos											 
					0		,;	//31 - Folha: Horas de Saida Antecipada											 
					0		,;	//32 - Folha: Horas de Saida no Expediente											 
					0		,;	//33 - Banco: Horas de Faltas						
					0		,;	//34 - Banco: Horas de Atrasos											 
					0		,;	//35 - Banco: Horas de Saida Antecipada											 
					0		,;	//36 - Banco: Horas de Saida no Expediente
					0		;	//37 - Hora da primeira marcação
				})  
			
		//Entrada Jornada, Saida Intervalo, Entrada Intervalo, Saida Jornada, Saida Intervalo 1, Entrada Intervalo 1, Saida Intervalo 2, Entrada Intervalo 2
		aHorSREP := Array(8)
	Endif    
	
	//-- Verifica se funcionario Trabalha em Feriado
    If cRegra != ( aTabCalend[ nX , CALEND_POS_REGRA ] )
		cRegra		:= (  aTabCalend[ nX , CALEND_POS_REGRA ]  )
		aRegra		:= GetCposRegra(cFilRegra, cRegra)
		lTrbFeriado	:= aRegra[1]
	Endif
    
	//-- Verifica se funcionario Trabalha em Feriado
    If cTurno != ( aTabCalend[ nX , CALEND_POS_TURNO ] )
		cTurno := aTabCalend[nX,CALEND_POS_TURNO]    
		aTurno := GetCposTurno(cFilTurno, cTurno)
	EndIf
	
	aApo[Len(aApo), 22] 	:= aTurno[1] //Aplicacao da Hora  Reduzida na hora extra
    aApo[Len(aApo), 23] 	:= aTurno[2] //Valor da Hora reduzida
    aApo[Len(aApo), 24] 	:= aTurno[3] //Geracao do Acrescimo Noturno no Adicional
	aApo[Len(aApo), 25] 	:= aTurno[4] //Geracao do Acrescimo Noturno em Evento Especifico
	aApo[Len(aApo), 26] 	:= aTurno[5] //Aplicacao da Hora  Reduzida nas horas de Atraso
	aApo[Len(aApo), 27] 	:= aTurno[6] //Aplicacao da Hora  Reduzida nas horas de Saida Antecipada
	aApo[Len(aApo), 28] 	:= aTurno[7] //Aplicacao da Hora  Reduzida nas horas de Faltas	   	   
	
	lTemMarc := !Empty(aMarcacoes) .And. (nPosMarc := (AScan(aMarcacoes, {|x| x[1] == aTabCalend[nX, CALEND_POS_DATA] .And.  x[12] == "1E"})) ) > 0
	
    //Desconsidera a data de APONTAMENTO se funcionario afastado ou se a data estiver fora do periodo solicitado.
    If lForaPer .Or. (lAfastado .And. !lTemMarc)
        Loop
    Endif 
    
    // *** Verifica Tipo Dia ***
    //-- Se Feriado 
         //-- Se Excecao
              //Tipo Dia
         //--Senao Excecao     
	         //-- Se NaoTrabalha  Feriado
	         //   Tipo dia  = "Feriado"
	         //---Senao NaoTrabalha Feriado
	         //   Tipo dia     
	         //-- Fim se Nao Trabalha Feriado
         //-- Fim se Escecao
    //Senao
    //   Tipo Dia
    //-- Fim se Feriado        
    
	cTipoDia	:= IF( aTabCalend[ nX , CALEND_POS_FERIADO ] , IF(  aTabCalend[ nX , CALEND_POS_EXCECAO ]  == "E" , aTabCalend[ nX , CALEND_POS_TIPO_DIA ] , IF(!lTrbFeriado,"F",aTabCalend[ nX , CALEND_POS_TIPO_DIA ] ) ) , aTabCalend[ nX , CALEND_POS_TIPO_DIA] )                  
    aApo[Len(aApo), 19] := cTurno 
	aApo[Len(aApo), 20] := cTipoDia     
    cIntSREP 	:= (  aTabCalend[ nX , CALEND_POS_INTSREP   ] ) 
    
    If Empty(cIntSREP)
		cIntSREP 	:=  "!!"
    Else	
		cIntSREP 	:=SUBSTR(cIntSREP,1,1) + 'S.' + ALLTRIM(STR(Val(SUBSTR(cIntSREP,1,1)) + 1)) + 'E' 
	Endif
	
    //-- Verifica o total de horas trabalhadas da jornada
	While cOrdem == aTabCalend[nX, CALEND_POS_ORDEM] 
		IF !fGerHorSREP(cFilRegra, aTabCalend, nX, cIntSREP, aApo, aHorSREP, cOrdem, nLenCalend, "EJ.SI.EI.SJ", cTurno, aMarcacoes)  
			lCancela := .T.
		EndIf
		nX++ 
		IF nX > nLenCalend
			EXIT
		Endif
	EndDo
	
	nx--
	
    IF lCancela
		EXIT
    Endif
Next nX

Return(lCancela)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fGerHorSREP  ³ Autor ³ Mauricio MR        ³ Data ³ 31/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Identifica as marcacoes do horario contratual 	          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function fGerHorSREP(cFilRegra, aTabCalend, nPosDiaApo, cIntSREP, aApo, aHorSREP, cOrdem, nLenCalend, cTipo, cTurno, aMarcacoes)  
Local nPosSub1	:= 0  
Local nPosProx  := 0
Local lRet		:= .T.
Local nPosMarc	:= 0

Default aMarcacoes := {}

//-- Obtem os Horarios Contratuais para Efeito do SREP
IF ( aTabCalend[ nPosDiaApo , CALEND_POS_TIPO_MARC ] == "1E" ) .and. ("EJ" $ cTipo) //*** Entrada de Jornada ***/
	aHorSREP[1] := aTabCalend[nPosDiaApo,CALEND_POS_HORA]
	If !Empty(aMarcacoes) .And. (nPosMarc := (AScan(aMarcacoes, {|x| x[1] == aTabCalend[nPosDiaApo, CALEND_POS_DATA] .And.  x[12] == "1E"})) ) > 0
		aApo[Len(aApo), 37] := aMarcacoes[nPosMarc, 2]
	EndIf
ElseIF ( SubStr( aTabCalend[ nPosDiaApo , CALEND_POS_TIPO_MARC ] , -1 ) == "E" ) .and. ("EI"$cTipo) // Entrada de Intervalo (Retorno do Intervalo)
	nPosSub1 := ( nPosDiaApo - 1 )
	IF( aTabCalend[ Max( nPosSub1 , 1 ) , CALEND_POS_HRS_INTER ] > 0 .and. ;
		(aTabCalend[ nPosDiaApo , CALEND_POS_TIPO_MARC ]   $ cIntSREP );
	  )	
		aHorSREP[3]:= aTabCalend[nPosDiaApo,CALEND_POS_HORA] 
		IF Empty(cIntSREP)
		    aAdd( aLogDet , STR0041 + fPoeTraco(cFil) + " " + STR0018 + fPoeTraco(cTurno) )//"Intervalo Nao definido para a geracao do ACJEF. Filial: "	##"Turno: "
		   lRet	:= .F.
		Endif                                           
	ElseIF( aTabCalend[ Max( nPosSub1 , 1 ) , CALEND_POS_HRS_INTER ] > 0)            		//*** Entrada para Intervalo Suplementar ***/
		IF aHorSREP[6]== Nil
			aHorSREP[6]:= aTabCalend[nPosDiaApo,CALEND_POS_HORA]  	
		Else                                                            
			aHorSREP[8]:= aTabCalend[nPosDiaApo,CALEND_POS_HORA]  	
		Endif	
	Endif	
ElseIF (  (aTabCalend[ nPosDiaApo , CALEND_POS_HRS_INTER ] > 0 ) .and. ("SI"$cTipo) )   	//*** Saida para o intervalo (Saida Intervalo) ***/
		IF 	( aTabCalend[ nPosDiaApo , CALEND_POS_TIPO_MARC ] $ cIntSREP ) 

			aHorSREP[2]:= aTabCalend[nPosDiaApo,CALEND_POS_HORA] 
			IF  Empty(cIntSREP)
			    aAdd( aLogDet , STR0041 + fPoeTraco(xFilial("SR6") ) + " " + STR0018 + fPoeTraco(cTurno)+SPACE(1)+ ;
			    	aTabCalend[nPosDiaApo,CALEND_POS_SEQ_TURNO]+"/"+DiaSemana( aTabCalend[nPosDiaApo,CALEND_POS_DATA] ) 	 )//"Intervalo Nao definido para a geracao do ACJEF. Filial: "	##"Turno: "
			   	lRet	:= .F.
			Endif
		Else
			IF aHorSREP[5]== Nil            												 //*** Saida para Intervalo Suplementar ***/
				aHorSREP[5]:= aTabCalend[nPosDiaApo,CALEND_POS_HORA]  	
			Else                                                            
				aHorSREP[7]:= aTabCalend[nPosDiaApo,CALEND_POS_HORA]  	
			Endif
		Endif	
ElseIF ("SJ"$cTipo) 																		//*** Saida de Jornada ***/
	nPosProx	:= nPosDiaApo + 1
	IF ( nPosProx  > nLenCalend ) 
			aHorSREP[4]				:= aTabCalend[nPosDiaApo,CALEND_POS_HORA] 
			aApo[Len(aApo), 21] 	:= aClone(aHorSREP)			
	ElseIF ( aTabCalend[nPosProx, CALEND_POS_ORDEM ] <> cOrdem )
     		aHorSREP[4]				:= aTabCalend[nPosDiaApo,CALEND_POS_HORA]  
     		aApo[Len(aApo), 21] 	:= aClone(aHorSREP)
	Endif
		
EndIF
Return (lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³fGeraTipos  ³ Autor ³ Mauricio MR		    ³ Data ³ 31/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera Tipos 01 e 02  					                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Static Function fGeraTipos(aApo, cTipoInsc, cCPFCNPJ, cCEI, cPIS, dDataIni, dDataFim)
Local nApo			:= Len(aApo)
Local nX			:= 0  
Local dData			:= Ctod("")

For nX:=1  to nApo
    //--Se existirem elementos de horarios
	IF !Empty(aApo[nX, 21]) 
		//-- Se nao existir entrada e saida de jornada abandona o dia (Somente consideramos Jornada Prevista)
		IF !( ( aApo[nX ,21, 1] <> Nil ) .and. ( aApo[nX,21,4] <> Nil ) )
			Loop
		Endif                                                       
	Else
		//-- Se não existir horarios
		Loop
	Endif   
	
	IF 	!Empty(aApo[nX, 02]) .OR.;//Hs.Diurnas
		!Empty(aApo[nX, 03]) .OR.;//Hs.Noturnas
		!Empty(aApo[nX, 04]) .OR.;//Hs.Extras 1
		!Empty(aApo[nX, 07]) .OR.;//Hs.Extras 2
		!Empty(aApo[nX, 10]) .OR.;//Hs.Extras 3	
		!Empty(aApo[nX, 13]) .OR.;//Hs.Extras 4
		!Empty(aApo[nX, 16]) .OR.;//Hs.Faltas / Atrasos  
		!Empty(aApo[nX, 18])      //Horas a Compensar
		
		dData	:= aApo[nX, 01] // Data de Apontamento
		
		TIPO03(cTipoInsc, cCPFCNPJ, cCEI,  cPIS, aApo[nX]) 
		
		//-- Variaveis utilizadas para determinar a menor e a maior data de apontamento para cada CNPJ/CPF/CEI lido	          
		IF dDataIni <> NIL
			dDataIni	:= Min( dData, dDataIni )
		Else
			dDataIni	:= dData
		Endif
		
		IF dDataFim <> NIL
			dDataFim	:= Max( dData, dDataFim )	
		Else
			dDataFim    := dData	
		Endif
	Endif	
Next nX     

Return (Nil)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³GetSP4	³ Autor ³ Mauricio MR		    ³ Data ³ 29/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtem a tabela de Horas extras da Filial por Turno 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³            												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PONM420  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function GetSP4(cFil, cHe, aSP4 )
Local aArea			:= GetArea()
Local nX			:= 0  
Local lCancela		:= .F. 
Local cTurno		
Local cCodAuto
Local cCodNAuto 
Local cClas 
Local cID 
Local cTipo 
Local cModalidade 
Local nPercent  	:= 0.00
Local nQuant		:= 0.00
Local dDataAnt		:= Ctod("") 

Local lQueryOpened	:= .F.     

Local lDupAuto		:= .F.
Local lDupNAuto		:= .F.

Local cSP_Campos	:= ""
Local cSP_Query 	:= ""
Local cSP_Where		:= ""			                  
Local cSP_Ordem 	:= ""
Local aSp_Fields	:= SP4->( dbStruct() )
Local nSp_Fields	:= Len( aSp_Fields	)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carregando os Campos  na Query						 	   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/    
cSP_campos:= ""
For nX := 1 To nSp_Fields
	cSP_Campos += aSp_Fields[ nX , 01 ] + ", "
Next nX
cSP_Campos := SubStr( cSP_Campos , 1 , Len( cSP_Campos ) - 2 ) 

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Montando a Condicao										   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cSP_Where := "SP4.P4_FILIAL='"+cFil+"'"

cSP_Ordem := " SP4.P4_FILIAL, SP4.P4_TURNO, SP4.P4_TIPO "	

cAliasSP_Qry	:= GetNextAlias()

cQuery	:= "SELECT "
cQuery	+= cSP_Campos
cQuery 	+= " FROM " + InitSqlName( "SP4" ) + " SP4 "
cQuery 	+= "WHERE "
cQuery	+= cSP_Where
cQuery  += " AND "
cQuery 	+= "D_E_L_E_T_=' ' "
cQuery 	+= "ORDER BY " + cSP_Ordem

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Utiliza ChangeQuery() para Remontar a Query                  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cQuery := ChangeQuery( cQuery )
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Se conseguiu Montar a Query Seta os Campos                   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF ( lQueryOpened := MsOpenDbf(.T.,"TOPCONN",TcGenQry(NIL,NIL,cQuery),cAliasSP_Qry,.T.,.T.) )
	For nX := 1 To nSp_Fields
		IF !( aSp_Fields[ nX , 02 ] == "C" )
			TcSetField(cAliasSP_Qry,aSp_Fields[nX,01],aSp_Fields[nX,02],aSp_Fields[nX,03],aSp_Fields[nX,04])
		EndIF
	Next nX 
EndIF	

IF !lQueryOpened     
	cAliasSP_Qry:= 'SP4'
	SP4->( dbSeek( cFil ) )
Endif
         
aSP4:= {}

While (cAliasSP_Qry)->( !Eof() .and. ( cFiL == P4_FILIAL ) )

    cTurno  	:= (cAliasSP_Qry)->P4_TURNO                          
    cCodAuto	:= (cAliasSP_Qry)->P4_CODAUT 
    cCodNAuto	:= (cAliasSP_Qry)->P4_CODNAUT 
    cTipo		:= (cAliasSP_Qry)->P4_TIPO
    nPercent	:= (cAliasSP_Qry)->P4_PERCENT
    
	IF !Empty(aSP4)
		IF !Empty( Ascan( aSP4, {|x| 	( ( x[1] == cTurno ) 							.and. 	; 
											( 	( lDupAuto := ( x[2] == cCodAuto 	) ) .or. 	;
												( lDupNAuto:= ( x[2] == cCodNAuto 	) )  		;
											) ;
										);
								} ;
						);
				 )
			aAdd( aLogDet , STR0037 + fPoeTraco(cFil) + " " + STR0018 + fPoeTraco(cTurno) + Space(2) + STR0043 + cTipo + Space(2) +;
			IF(lDupNAuto .and. lDupAuto,STR0044,STR0032) + IF( lDupAuto, cCodAuto + IF(lDupNAuto, "/","") ,"" ) +  IF( lDupNAuto, cCodNAuto, "")  )
			//"Codigo de Hora Extra utilizado em mais de um tipo. Filial: "##"Turno: "##"Tipo: "
	        lCancela := .T.
			Exit
		Endif
	Endif
   
	IF !( cTipo $ "A*B*C*D*E*F*G*H" )
		cModalidade := If( Val(cTipo ) >= 5 , "N" , "D" )
	Else
		cModalidade	:= If( cTipo $ "B*D*F*H" , "N" , "D" )
	EndIF	
    
    //-- HE autorizada
    aAdd(aSP4, {	cTurno			,;  //Turno   
    				cCodAuto		,;	//Evento
    			 	cTipo			,;  //Tipo de dia
    			 	cModalidade		,;	//Modalidade
					nPercent		,;	//Percentual
					'A'				;	//Autorizada/Nao autorizada
				};
		)		
	IF  !(cCodAuto$cHe)
		aAdd( aLogDet , STR0031 + fPoeTraco(cFil) + " " + STR0032 + cCodAuto )//"Evento sem classificacao: Filial: "##"Evento: "##
		lCancela	:= .T.
	Endif
  
    //-- HE nao autorizada
    If cCodAuto <> cCodNauto
       aAdd(aSP4, {	cTurno			,;  //Turno   
    				cCodNAuto		,;	//Evento
    			 	cTipo			,;  //Tipo de dia
    			 	cModalidade		,;	//Modalidade
					nPercent		,;	//Percentual
					'N'				;	//Autorizada/Nao autorizada
					};
			)		
		
		IF  !(cCodNAuto$cHe)
			aAdd( aLogDet , STR0031 + fPoeTraco(cFil) + " " + STR0032 + cCodNAuto )//"Evento sem classificacao: Filial: "##"Evento: "##
			lCancela	:= .T.
		Endif
    Endif
		
	(cAliasSP_Qry)->( dbSkip() )   

End While

IF !Empty(aSP4)
	aSort( @aSP4 , NIL , NIL , { |x,y| x[1]+x[2] > y[1]+y[2] } )
Else
	aAdd( aLogDet , STR0039 + fPoeTraco(cFil) )//"Tabela de Hora Extra Nao Encontrada para a Filial: "
	lCancela	:= .T.
Endif

IF lQueryOpened
	(cAliasSP_Qry)->( dbCloseArea() )
Endif

RestArea(aArea)
Return (lCancela)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³GetSP9	³ Autor ³ Mauricio MR		    ³ Data ³ 29/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtem a tabela de Eventos da Filial 				 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³            												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PONM420  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function GetSP9(cFil, cHe, cFaltas, cHDiurnas, cHNoturnas, cAtrasos, cSaidaA, cSaidaE )

Local aArea		:= GetArea()

Local lCancela	:= .F. 

Local cClas 
Local cID      
Local cEvento
Local lQueryOpened	:= .F.

Local nX		:= 0  
Local cSP_Campos:= ""
Local cSP_Where	:= ""			                  
Local cSP_Ordem := ""
Local aSp_Fields	:= SP9->( dbStruct() )
Local nSp_Fields	:= Len( aSp_Fields	)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carregando os Campos do SPC na Query						   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/    
cSP_campos:= "%"
For nX := 1 To nSp_Fields
	cSP_Campos += aSp_Fields[ nX , 01 ] + ", "
Next nX
cSP_Campos := SubStr( cSP_Campos , 1 , Len( cSP_Campos ) - 2 ) + "%"

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Montando a Condicao										   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cSP_Where := "%"
cSP_Where += "SP9.P9_FILIAL='"+cFil+"'"
cSP_Where += "%"

cSP_Ordem := "%SP9.P9_FILIAL, SP9.P9_CODIGO %"	

cAliasSP_Qry	:= GetNextAlias()

BeginSql alias cAliasSP_Qry 
	SELECT	%exp:cSP_Campos%
	FROM %table:SP9% SP9
	WHERE 
		  %exp:cSP_Where% AND
	      SP9.%notDel%   
	ORDER BY %exp:cSP_Ordem%
EndSql   	

lQueryOpened	:= .T.

IF !lQueryOpened   
	cAliasSP_Qry:= 'SP9'
	SP9->( dbSeek( cFil ) )
Endif
         
aSP9:= {}

While (cAliasSP_Qry)->( !Eof() .and. ( cFiL == P9_FILIAL ) )
    cClas	:= (cAliasSP_Qry)->P9_CLASEV 
    cID		:= (cAliasSP_Qry)->P9_IDPON 
	cEvento	:= (cAliasSP_Qry)->P9_CODIGO     
	//001A	HORAS NORMAIS
	//026A	HORAS NORMAIS NOTURNAS
	//030A	HORAS DE INTERVALO
	//031A	HORAS DE INTERVALO NOTURNAS

    If !EMPTY(cClas)  
	    If cClas == "01"   // Horas Extras
	       cHE+= cEvento + '.'
	    ElseIF cClas == "02" //Faltas
		    cFaltas+= cEvento + '.'
	    ElseIF cClas == '03' //Atrasos
		    cAtrasos+= cEvento + '.'
		ElseIF	cClas == '04'//Saidas Antecipadas
		    cSaidaA+= cEvento + '.'
		ElseIF cClas == '05' //Saidas no Expediente   
		    cSaidaE+= cEvento + '.'
		ElseIF cID $"001A" //Horas Normais Diurnas e de intervalo
		    cHDiurnas+= cEvento + '.'
   		ElseIF cID $"026A" //Horas Normais Noturnas e de intervalo
		    cHNoturnas+= cEvento + '.'
	    Endif
    Else                      
		aAdd( aLogDet , STR0031 + fPoeTraco(cFil) + " " + STR0032 + cEvento )//"Evento sem classificacao: Filial: "##"Evento: "##
        lCancela := .T.
		Exit
    Endif

	(cAliasSP_Qry)->( dbSkip() )   

End While
	
IF Empty(cHE)               
   	aAdd( aLogDet , STR0033 + fPoeTraco(cFil)   )//"Nenhum Evento está configurado como Hora Extra. Filial: "		
    lCancela := .T.
Endif
IF Empty(cFaltas) .and. Empty(cAtrasos) .and. Empty(cSaidaA) .and. Empty(cSaidaE )                
   	aAdd( aLogDet , STR0034 + fPoeTraco(cFil)   )//"Nenhum Evento está configurado como Hora Faltas/Atrasos. Filial: "		
    lCancela := .T.
Endif
IF Empty(cHDiurnas)               
   	aAdd( aLogDet , STR0035 + fPoeTraco(cFil)   )//"Nenhum Evento está configurado como Hora Diurna. Filial: "			 
    lCancela := .T.
Endif
IF Empty(cHNoturnas)               
   	aAdd( aLogDet , STR0036 + fPoeTraco(cFil)   )//"Nenhum Evento está configurado como Hora Noturna. Filial: "		
    lCancela := .T.
Endif  

IF lQueryOpened
	(cAliasSP_Qry)->( dbCloseArea() )
Endif

RestArea(aArea)
Return (lCancela)	                   



		
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³TIPO01	³ Autor ³ Mauricio MR		    ³ Data ³ 20/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta registro Tipo "1"									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³            												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PONM420  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function TIPO01(aInfo, cTpIdEmp, cTipoInsc, cCPFCNPJ, cCEI, dDataIni, dDataFim )

Local cIdReg    	:= ""
Local cRazaoouNome	:= ""
Local cDataIni
Local cDataFim

// "FDT_TINSC + FDT_INSC + FDT_CEI + FDT_TIPO + FDT_PIS + FDT_DATA + FDT_HORA"
cIdReg			:= "1"															//  010 010 001    Tipo do registro 

IF cTpIdEmp 	== '3'                                                                                
	cTipoInsc		:= Space(01)					 							//	011	011	001		1 - CPF / 2 - CNPJ
	cCPFCNPJ		:= space(14)												//	012	025	014		CPF
	cCEI			:= space(12-len(alltrim(aInfo[08])))+alltrim(aInfo[08])	//	026	037	012		CEI
Else 
	cTipoInsc		:= Left(cTpIdEmp+Space(01),01) 							//	011	011	001		1 - CPF / 2 - CNPJ
	cCPFCNPJ		:= space(14-len(alltrim(aInfo[08])))+alltrim(aInfo[08])	//	012	025	014		CPF ou CNPJ
	cCEI			:= space(12)												//	026	037	012		CEI
	
Endif
cRazaoouNome	:= FSubst(Left(aInfo[03]+Space(150),150))						//  038	187	150		Razao Social ou Nome

IF dDataIni <> Nil
	cDataIni	:= Transforma(dDataIni)
Else
	cDataIni	:= ""//Space(8)
Endif

IF dDataFim <> Nil              
	cDataFim	:= Transforma(dDataFim)
Else	
	cDataFim	:= ""//Space(8)
Endif

GravaACJEF(cIdReg, { cTipoInsc , cCPFCNPJ , cCEI , cRazaoouNome, cDataIni, cDataFim } )      

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³TIPO03	³ Autor ³ Mauricio MR		    ³ Data ³ 03/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta registro Tipo "3" - Detalhe							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³            												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PONM420  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function TIPO03(cTipoInsc, cCPFCNPJ, cCEI, cPis, aApo)

Local cIdReg    	:= ""   
Local cHoraEJ		:= ""
Local cMarcEJ		:= ""
Local cHDiurnas		:= aApo[02]
Local cHNoturnas	:= aApo[03]  
Local cExtras1		:= aApo[04]  
Local cPerc1		:= aApo[05]  
Local cMod1			:= aApo[06]  
Local cExtras2		:= aApo[07]  
Local cPerc2		:= aApo[08]  
Local cMod2			:= aApo[09]  
Local cExtras3		:= aApo[10]  
Local cPerc3		:= aApo[11]  
Local cMod3			:= aApo[12]  
Local cExtras4		:= aApo[13]  
Local cPerc4		:= aApo[14]  
Local cMod4			:= aApo[15]  
Local cFaltas		:= aApo[16]  
Local cSinal		:= aApo[17]   
Local cSaldo		:= aApo[18]  

Local nEJ  			:= 0			
Local nSI			:= 0
Local nEI			:= 0
Local nSJ			:= 0

Local nS1  			:= 0			
Local nE1			:= 0                                                                                     
Local nS2			:= 0
Local nE2			:= 0

Local nTamP	  		:= 3

Local lRet			:= .T. 

nEJ			:= IF(Empty(aApo[21, 1]), 0, aApo[21, 1])
nSI			:= IF(Empty(aApo[21, 2]), 0, aApo[21, 2])
nEI			:= IF(Empty(aApo[21, 3]), 0, aApo[21, 3])
nSJ			:= IF(Empty(aApo[21, 4]), 0, aApo[21, 4])

nS1			:= IF(Empty(aApo[21, 5]), 0, aApo[21, 5])
nE1			:= IF(Empty(aApo[21, 6]), 0, aApo[21, 6])
nS2			:= IF(Empty(aApo[21, 7]), 0, aApo[21, 7])
nE2			:= IF(Empty(aApo[21, 8]), 0, aApo[21, 8])

cIdReg		:= "3"										 											//  010 010 001    	Tipo do registro 
cPIS		:= Left( Replicate("0", 12 - Len( AllTrim( cPis ))) + cPis,	12	)						//	011	022	012		PIS	
dDataEJ  	:= aApo[1]																				//	023	030	008		Data Inicio Jornada
cMarcEJ  	:= StrZero(Int(aApo[37]), 2) + StrZero(Int(( aApo[37]-Int(aApo[37])) * 100), 2)			//	031	034	004		Hora Entrada de Jornada
cCH			:= Space(4)																				//	035	038	004		Codigo do Horario (CH)
cHDiurnas  	:= StrZero(Int(cHDiurnas),2) + StrZero(Int( ( cHDiurnas-Int(cHDiurnas) ) *100 ) ,2)		//	039 042	004		Horas Diurnas
cHNoturnas 	:= StrZero(Int(cHNoturnas),2)+ StrZero(Int((cHNoturnas-Int(cHNoturnas)) *100),2)		//	043 046	004		Horas Noturnas

cExtras1 	:= StrZero(Int(cExtras1),2)+StrZero(Int((cExtras1-Int(cExtras1)) *100),2)				//	047 050	004		Horas Extras 1
cPerc1	 	:= StrZero(Int(cPerc1),nTamP)+StrZero(Int((cPerc1-Int(cPerc1)) *10),1)					//	051 054	004		Percentual do adicional de horas extras 1
cMod1	 	:= cMod1																				//	055 055	001		Modalidade da Hora Extra 1

cExtras2 	:= StrZero(Int(cExtras2),2)+StrZero(Int((cExtras2-Int(cExtras2)) *100),2)				//	056 059	004		Horas Extras 2 
cPerc2	 	:= StrZero(Int(cPerc2),nTamP)+StrZero(Int((cPerc2-Int(cPerc2)) *10),1)					//	060 063	004		Percentual do adicional de horas extras 2
cMod2	 	:= cMod2																				//	064 064	001		Modalidade da Hora Extra 2

cExtras3 	:= StrZero(Int(cExtras3),2)+StrZero(Int((cExtras3-Int(cExtras3)) *100),2)				//	065 068	004		Horas Extras 3
cPerc3	 	:= StrZero(Int(cPerc3),nTamP)+StrZero(Int((cPerc3-Int(cPerc3)) *10),1)		   			//	069 072	004		Percentual do adicional de horas extras 3
cMod3	 	:= cMod3																				//	073 073	001		Modalidade da Hora Extra 3

cExtras4 	:= StrZero(Int(cExtras4),2)+StrZero(Int((cExtras4-Int(cExtras4)) *100),2)				//	074 077	004		Horas Extras 4
cPerc4	 	:= StrZero(Int(cPerc4),nTamP)+StrZero(Int((cPerc4-Int(cPerc4)) *10), 1)					//	078 081	004		Percentual do adicional de horas extras 4
cMod4	 	:= cMod4																				//	082 082	001		Modalidade da Hora Extra 4

cFaltas		:= StrZero(Int(cFaltas),2)+StrZero(Int((cFaltas-Int(cFaltas)) *100),2)					//	083 086	004		Horas Faltas/Atrasos

cSinal	    := Alltrim(Str(cSinal))																	//	087 087	004		Sinal de Horas para compensar

cSaldo	    := StrZero(Int(cSaldo),2)+StrZero(Int((cSaldo-Int(cSaldo)) *100),2)        				//	088 091	004		Saldo de Horas para compensar

cHoraEJ  	:= StrZero(Int(nEJ),2) + StrZero(Int(( nEJ-Int(nEJ)) *100),2)				
cHoraSI  	:= StrZero(Int(nSI),2) + StrZero(Int(( nSI-Int(nSI)) *100),2)				
cHoraEI  	:= StrZero(Int(nEI),2) + StrZero(Int(( nEI-Int(nEI)) *100),2)				
cHoraSJ  	:= StrZero(Int(nSJ),2) + StrZero(Int(( nSJ-Int(nSJ)) *100),2)				


cHoraS1  	:= StrZero(Int(nS1),2) + StrZero(Int(( nS1-Int(nS1)) *100),2)				
cHoraE1  	:= StrZero(Int(nE1),2) + StrZero(Int(( nE1-Int(nE1)) *100),2)				
cHoraS2  	:= StrZero(Int(nS2),2) + StrZero(Int(( nS2-Int(nS2)) *100),2)				
cHoraE2  	:= StrZero(Int(nE2),2) + StrZero(Int(( nE2-Int(nE2)) *100),2)	



lRet:= GravaACJEF(cIdReg, {;
							 cTipoInsc	,;//01
							 cCPFCNPJ	,;//02
							 cCEI		,;//03
 							 cPIS		,;//04
 							 dDataEJ	,;//05
 							 cMarcEJ	,;//06
							 cHDiurnas	,;//07
							 cHNoturnas ,;//08
							 cExtras1	,;//09
							 cPerc1		,;//10
							 cMod1		,;//11
 							 cExtras2	,;//12
							 cPerc2		,;//13
							 cMod2		,;//14
							 cExtras3	,;//15
							 cPerc3		,;//16
							 cMod3		,;//17
							 cExtras4	,;//18
							 cPerc4		,;//19
							 cMod4		,;//20						 							 
							 cFaltas	,;//21
							 cSinal		,;//22
							 cSaldo		,;//23
							 cHoraEJ	,;//24
							 cHoraSI	,;//25
							 cHoraEI	,;//26
							 cHoraSJ	,;//27  
							 cHoraS1	,;//28
							 cHoraE1	,;//29
							 cHoraS2	,;//30
							 cHoraE2	;//31  
							 }			;
				  )      



Return( lRet )

              
 /*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GravaACJEF³ Autor ³ Mauricio MR	        ³ Data ³ 21/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os dados no arquivo temporario                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GravaACJEF(aLinha)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  						                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PONM420()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GravaACJEF(	cTipo, aCampos ) 
Local cSeek		:=	""
Local lFound  
Local lRet		:= .T.
Local aOldAlias := GetArea() 
Local cCH		:= ''               

Local cAliasQry := GetNextAlias()
Local cEFTableName := oTmpACJEF:GetRealName()
Local cSql


// cTipo: 	 
//        		'01'-Cabecalho Informacoes da Empresa
//				'02'-Horarios Contratuais
//				'03'-Detalhe 
//              '09'-Trailer

dbSelectArea("ACJEF")             

If cTipo $ "1"		
	//Chave de Pesquisa	: "JEF_TINSC + JEF_INSC + JEF_CEI + JEF_TIPO 
	//Campos passados	: { cTipoInsc, cCPFCNPJ, cCEI, cRazaoouNome, cDataIni, cDataFim }
	//cSeek := aCampos[1] + aCampos[2] + aCampos[3] + '1' 
	cSQL := " SELECT * FROM " + cEFTableName 
	cSql += " 		WHERE  "
	cSql += " 		JEF_TINSC  = '" + aCampos[1]   + "' and "
	cSql += " 		JEF_INSC   = '" + aCampos[2]   + "' and "
	cSql += " 		JEF_CEI    = '" + aCampos[3]   + "' and   JEF_TIPO = '1' and"
	cSql += " 		D_E_L_E_T_ = ' ' "
	 
Elseif cTipo $ "3"	        //     1          2         3                     4          5        6  
	// Chave de Pesquisa	:"JEF_TINSC + JEF_INSC + JEF_CEI + JEF_TIPO + JEF_PIS + Dtos(JEF_DATA) + JEF_EJ 
	/* Campos Passados		:
							 cTipoInsc	,;//01
							 cCPFCNPJ	,;//02
							 cCEI		,;//03
 							 cPIS		,;//04
 							 dDataEJ	,;//05
 							 cHoraEJ	,;//06
							 cHDiurnas	,;//07
							 cHNoturnas ,;//08
							 cExtras1	,;//09
							 cPerc1		,;//10
							 cMod1		,;//11
 							 cExtras2	,;//12
							 cPerc2		,;//13
							 cMod2		,;//14
							 cExtras3	,;//15
							 cPerc3		,;//16
							 cMod3		,;//17
							 cExtras4	,;//18
							 cPerc4		,;//19
							 cMod4		,;//20						 							 
							 cFaltas	,;//21
							 cSinal		,;//22
							 cSaldo		,;//23
							 cHoraEJ	,;//24
							 cHoraSI	,;//25
							 cHoraEI	,;//26
							 cHoraSJ	,;//27
							 cHoraS1	,;//28
							 cHoraE1	,;//29
							 cHoraS2	,;//30
							 cHoraE2	 ;//31
	 */		
	
	//cSeek :=	aCampos[01] + aCampos[02] + aCampos[03] + '2' + aCampos[04] + Dtos(aCampos[05]) + ;
	//			aCampos[06] 
	cSQL := " SELECT * FROM " + cEFTableName 
	cSql += " 		WHERE  "
	cSql += " 		JEF_TINSC  = '" + aCampos[1]   + "' and "
	cSql += " 		JEF_INSC   = '" + aCampos[2]   + "' and "
	cSql += " 		JEF_CEI    = '" + aCampos[3]   + "' and   JEF_TIPO = '2' and"
	
	
	cSql += " 		JEF_PIS    = '" + aCampos[4]         + "' and "
	cSql += " 		JEF_DATA   = '" + dtos(aCampos[5])   + "' and "
	cSql += " 		JEF_EJ     = '" + aCampos[6]         + "' and "
	cSql += " 		D_E_L_E_T_ = ' ' "
	
EndIf
   
//lFound	:= ACJEF->(MsSeek(cSeek))
//COM EMBEDED  NAO FUNCIONA A CONSULTA NA TABELA TEMPORARIA ...POR ISTO USAMOS DBUSEAREA 				
DbUseArea( .T.,"TOPCONN",TCGenQry(,,ChangeQuery(cSQL)),cAliasQry,.F.,.T. )	
	
If (cAliasQry)->(!Eof())
	lFound := .T.
	ACJEF->( DbGoTo(   (cAliasQry)->(R_E_C_N_O_)     )  )
Else            
	dbSelectArea("ACJEF")
	lFound := .F.
EndIf



ACJEF->( RecLock("ACJEF", !lFound) )
	
ACJEF->JEF_TINSC		:= aCampos[1] // cTipoInsc
ACJEF->JEF_INSC 		:= aCampos[2] // cCPFCNPJ
ACJEF->JEF_CEI  		:= aCampos[3] // cCEI
ACJEF->JEF_TIPO  		:= cTipo
		
If cTipo $ "1" //Cabecalho  
	ACJEF->JEF_TEXTO 	:= 	cTipo 		+;
							aCampos[1] 	+; // cTipoInsc
							aCampos[2] 	+; // cCPFCNPJ
							aCampos[3] 	+; // cCEI
							aCampos[4] 	+; // cRazaoouNome	
							aCampos[5] 	+; // cDataIni
							aCampos[6] 	   // cDataFim

		
ElseIf cTipo $ "3" //Detalhe
    	 					
    cCH:= fGravaACJCH( ;
    					aCampos[1]		,; // 01 - cTipoInsc
						aCampos[2] 		,; // 02 - cCPFCNPJ
						aCampos[3] 		,; // 03 - cCEI
						aCampos[24] 	,; // 04 - Entrada Jornada
						aCampos[25] 	,; // 05 - Saida Intervalo
						aCampos[26] 	,; // 06 - Entrada Intervalo
						aCampos[27] 	,; // 07 - Saida Jornada
						aCampos[28] 	,; // 08 - Saida Intervalo
						aCampos[29] 	,; // 09 - Entrada Intervalo
						aCampos[30] 	,; // 10 - Saida Intervalo
						aCampos[31] 	 ; // 11 - Entrada Jornada
    				 )
    
	ACJEF->JEF_PIS  		:=  aCampos[04] 
	ACJEF->JEF_DATA 		:=  aCampos[05] 
	ACJEF->JEF_EJ 			:=  aCampos[24] 
	ACJEF->JEF_SI 			:=  aCampos[25] 
	ACJEF->JEF_EI 			:=  aCampos[26] 
	ACJEF->JEF_SJ 			:=  aCampos[27] 
	ACJEF->JEF_CH 			:=  cCH
	ACJEF->JEF_TEXTO 		:= 	cTipo 						+;
								aCampos[04]					+; // PIS
								Transforma(aCampos[05]) 	+; // Data Inicio da Jornada 
								aCampos[6] 					+; // Hora Inicio da Jornada
								cCH		      				+; // Codigo do Horario previsto para a jornada
								aCampos[07]				 	+; // Horas Diurnas
								aCampos[08]				 	+; // Horas Noturnas
								aCampos[09]					+; // Extras 1
								aCampos[10]					+; // Perc 1
								aCampos[11]					+; // Mod 1
								aCampos[12]					+; // Extras 2
								aCampos[13]					+; // Perc 2
								aCampos[14]					+; // Mod 2
								aCampos[15]					+; // Extras 3
								aCampos[16]					+; // Perc 3
								aCampos[17]					+; // Mod 3
								aCampos[18]					+; // Extras 4
								aCampos[19]					+; // Perc 4
								aCampos[20]					+; // Mod 4																
								aCampos[21]					+; // Faltas/Atrasos							
								aCampos[22]					+; // Sinal para compensar
								aCampos[23]					   // Saldo a compensar																												
								
	ACJEF->JEF_EMFIMA  	:= 	cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT

Endif
	
ACJEF->( MsUnlock() )

(cAliasQry)->(DbCloseArea())		                                         
RestArea(aOldAlias)	

Return( lRet )



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FGravaACJCH  ³ Autor ³ Mauricio MR      ³ Data ³ 18/11/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que grava horario contratuais por Empresa			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FGravaACJCH()                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PONM420                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGravaACJCH( cTipoInsc, cCPFCNPJ, cCEI, cEJ, cSI, cEI, cSJ, cS1, cE1, cS2, cE2 )
Local cSeek     := ""
Local cTexto	:= ""
Local cCHAliasQry := GetNextAlias()
Local cCHTableName := oTmpACJCH:GetRealName()
Local cSql
Local lAchou := .F.
          

cSQL := " SELECT * FROM " + cCHTableName
cSql += " 		WHERE  "
cSql += " 		JCH_TINSC  = '" +  cTipoInsc  + "' and "
cSql += " 		JCH_INSC   = '" +  cCPFCNPJ  + "' and "
cSql += " 		JCH_CEI    = '" +  cCEI  + "' and "
cSql += " 		JCH_EJ     = '" +  cEJ  + "' and "
cSql += " 		JCH_SJ     = '" +  cSJ  + "' and "
cSql += " 		JCH_SI     = '" +  cSI  + "' and "
cSql += " 		JCH_EI     = '" +  cEI  + "' and "
cSql += " 		JCH_S1     = '" +  cS1  + "' and "
cSql += " 		JCH_E1     = '" +  cE1  + "' and "
cSql += " 		JCH_S2     = '" +  cS2  + "' and "
cSql += " 		JCH_E2     = '" +  cE2  + "' and "
cSql += " 		D_E_L_E_T_ = ' ' "
						
//COM EMBEDED  NAO FUNCIONA A CONSULTA NA TABELA TEMPORARIA ...POR ISTO USAMOS DBUSEAREA 				
DbUseArea( .T.,"TOPCONN",TCGenQry(,,ChangeQuery(cSQL)),cCHAliasQry,.F.,.T. )	
		
If (cCHAliasQry)->(!Eof())
	lAchou := .T.
	ACJCH->( DbGoTo(   (cCHAliasQry)->(R_E_C_N_O_)     )  )
Else
	dbSelectArea("ACJCH")
EndIf
				
(cCHAliasQry)->(DbCloseArea())
				
				



IF !lAchou
				
	ACJCH->( RecLock("ACJCH", .T.) )
    nCH++
	cCH:= STRZERO(nCH,4)
/*	cTexto	:= "2" 				+; // Tipo de Registro
				cCH		      	+; // Codigo do Horario previsto para a jornada				    	
				cEJ			 	+; // Entrada Jornada 
				cSI			 	+; // Saida Intervalo
				cEI			 	+; // Entrada Intervalo
				CSJ				+; // Saida Jornada
				cS1		 	    +; // Saida Intervalo Suplementar  1
				cE1		 	    +; // Entrada Intervalo Suplementar 1
				cS2		 	    +; // Saida Intervalo Suplementar   2
				cE2		 	       // Entrada Intervalo Suplementar	2							
*/
	cTexto	:= "2" 				+; // Tipo de Registro
				cCH		      	+; // Codigo do Horario previsto para a jornada				    	
				cEJ			 	+; // Entrada Jornada 
				cSI		 	    +; // Saida Intervalo
				cEI		 	    +; // Entrada Intervalo
				CSJ

		
	ACJCH->JCH_TINSC	:= cTipoInsc
	ACJCH->JCH_INSC 	:= cCPFCNPJ
	ACJCH->JCH_CEI  	:= cCEI
	ACJCH->JCH_CH  		:= cCH
	ACJCH->JCH_EJ  		:= cEJ
	ACJCH->JCH_SI  		:= cSI
	ACJCH->JCH_EI  		:= cEI
	ACJCH->JCH_SJ  		:= cSJ	
	ACJCH->JCH_S1  		:= cS1
	ACJCH->JCH_E1  		:= cE1
	ACJCH->JCH_S2  		:= cS2			
	ACJCH->JCH_E2  		:= cE2		
	ACJCH->JCH_TEXTO	:= cTexto		
	ACJCH->( MsUnlock() )
Else
    cCH	:= 	ACJCH->JCH_CH 
Endif

Return (cCH)  

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FGeraArq     ³ Autor ³ Mauricio MR      ³ Data ³ 21/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que gera arquivo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FGeraArq()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PONM420                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FGeraArq(cIncricao)

Local aGetArea		:= GetArea()  
Local nSequencial   := 0  
Local cSequencial	:= ""
Local cGrava		:= ""  
Local cData			:= ""
Local cHora			:= Time() 
Local nRecno		:= 0    
Local lret			:= .T. 
Local cChave		:= "!!!!"  
Local nVezes		:= 0
Local cAliasQry       := GetNextAlias()
Local cEFTableName    := oTmpACJEF:GetRealName()
Local cCHTableName    := oTmpACJCH:GetRealName()
Local cSql

// Gera arquivo
cFile	:=	Alltrim(cFile)

nHandle := 	MSFCREATE(cFile)
If FERROR() # 0 .Or. nHandle < 0

	While File(cFile)
		nVezes ++      
	   	If nVezes >= 10
			Aviso( STR0004,STR0009+'"'+cFile +'"', { "Ok" },,STR0008 ) //"Atencao"###"Nao foi possivel excluir o arquivo "###"Erro ao Excluir arquivo"
//			Aviso( STR0004,STR0024, { "Ok" },,STR0006 ) //Atencao###"Erro ao criar o arquivo"
			//FClose(nHandle)
			Return Nil
		EndIf
		FErase(cFile)           
	EndDo

EndIf

// Arquivo com todos os tipos
ACJCH->(dbsetorder(2))
ACJCH->(dbGoTop())
ACJEF->(dbGoTop())

cData	:= Transforma( MsDate() )
cHora	:= STRZERO( Val( Substr( cHora, 1, 3) ),2) + STRZERO( Val( Substr( cHora, 4, 2 ) ),2 )

While ACJEF->(!Eof())
    
   
	// Gravar o Header do arquivo
	If ACJEF->JEF_TIPO == "1"  
	    nRecno	:= ACJEF->(Recno())
	    
	    cSQL := " SELECT * FROM " + cEFTableName 
		cSql += " 		WHERE  "
		cSql += " 		JEF_TINSC  = '" + ACJEF->JEF_TINSC   + "' and "
		cSql += " 		JEF_INSC   = '" + ACJEF->JEF_INSC   + "' and "
		cSql += " 		JEF_CEI    = '" + ACJEF->JEF_CEI   + "' and   JEF_TIPO = '3' and"
		cSql += " 		D_E_L_E_T_ = ' ' "
		
	
		//COM EMBEDED  NAO FUNCIONA A CONSULTA NA TABELA TEMPORARIA ...POR ISTO USAMOS DBUSEAREA 				
		DbUseArea( .T.,"TOPCONN",TCGenQry(,,ChangeQuery(cSQL)),cAliasQry,.F.,.T. )	
			
		If (cAliasQry)->(Eof())//IF ! (ACJEF->(Dbseek(JEF_TINSC + JEF_INSC + JEF_CEI + "3")))
			
			dbSelectArea("ACJEF")
			cIncricao	:= ACJEF->JEF_INSC
	        lRet:= .F.
	    
	        (cAliasQry)->(DbCloseArea())
	        Exit
		Else           
			dbSelectArea("ACJEF")
			(cAliasQry)->(DbCloseArea())
		EndIf
	  	
		nSequencial ++                        
	    cSequencial := STRZERO(nSequencial,9) 
   	     
		cGrava		:= Substr(cSequencial  + ACJEF->JEF_TEXTO,1,203) 
		cGrava		+= cData + cHora 
		cGrava		:= Substr(cGrava,1,215)+ CHR(13)+CHR(10)
		
		FWrite(nHandle,cGrava)
	ElseIF ACJEF->JEF_TIPO == "3"  
	    
	    //-- Gera Horarios Contratuais
	    IF ( cChave <> ACJEF->(JEF_TINSC + JEF_INSC + JEF_CEI ) )
	       	cChave	:= ACJEF->(JEF_TINSC + JEF_INSC + JEF_CEI ) 
	    	
	    	
	    	cSQL := " SELECT * FROM " + cCHTableName
			cSql += " 		WHERE  "
			cSql += " 		JCH_TINSC  = '" + ACJEF->JEF_TINSC  + "' and "
			cSql += " 		JCH_INSC   = '" + ACJEF->JEF_INSC   + "' and "
			cSql += " 		JCH_CEI    = '" + ACJEF->JEF_CEI    + "' and "
			cSql += " 		D_E_L_E_T_ = ' ' "
					
			//COM EMBEDED  NAO FUNCIONA A CONSULTA NA TABELA TEMPORARIA ...POR ISTO USAMOS DBUSEAREA 				
			DbUseArea( .T.,"TOPCONN",TCGenQry(,,ChangeQuery(cSQL)),cAliasQry,.F.,.T. )	
			
			If  (cAliasQry)->(!Eof()) .And. ; //ACJCH->(Dbseek(cChave))
			      AllTrim( (cAliasQry)->(JCH_TINSC) ) == AllTrim(ACJEF->JEF_TINSC) .And. ; 
			      AllTrim( (cAliasQry)->(JCH_INSC) )  == AllTrim(ACJEF->JEF_INSC) .And. ; 
			      AllTrim( (cAliasQry)->(JCH_CEI) )  == AllTrim(ACJEF->JEF_CEI) 
					
				While (cAliasQry)->(!Eof()) .And. ; //ACJCH->(Dbseek(cChave))
				      AllTrim( (cAliasQry)->(JCH_TINSC) ) == AllTrim(ACJEF->JEF_TINSC) .And. ; 
				      AllTrim( (cAliasQry)->(JCH_INSC) )  == AllTrim(ACJEF->JEF_INSC) .And. ; 
				      AllTrim( (cAliasQry)->(JCH_CEI) )  == AllTrim(ACJEF->JEF_CEI) 
					
					nSequencial ++                        
    				cSequencial := STRZERO(nSequencial,9) 
   	     
		    		cGrava		:= cSequencial  + (cAliasQry)->(JCH_TEXTO) 
					cGrava		:= Alltrim(cGrava) + CHR(13) + CHR(10)
					FWrite(nHandle,cGrava) 
					
					
					(cAliasQry)->(DBSkip())
				End
				
				(cAliasQry)->(DbCloseArea())
			Else
				(cAliasQry)->(DbCloseArea())
				cIncricao	:= ACJCE->JEF_INSC
		       	lRet:= .F.
	    	   	Exit
			EndIf
			
	    Endif
	
		nSequencial ++                        
	    cSequencial := STRZERO(nSequencial,9) 
   	     
		cGrava		:= cSequencial  + ACJEF->JEF_TEXTO 
		cGrava		:= Substr(cGrava,1,091)+ CHR(13)+CHR(10)
		
		FWrite(nHandle,cGrava)
	EndIf	
	
	ACJEF->(dbSkip())
EndDo 

nSequencial ++                        
cSequencial := STRZERO(nSequencial,9)                 
cGrava:= cSequencial + '9' + CHR(13)+CHR(10)
FWrite(nHandle,cGrava)

FClose(nHandle)
RestArea(aGetArea)
              
Return (lRet) 





/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FSubst        ³ Autor ³ Cristina Ogura   ³ Data ³ 17/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que substitui os caracteres especiais por espacos   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FSubst()                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEM610                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function FSubst(cTexto)

Local aAcentos:={}
Local aAcSubst:={}
Local cImpCar := Space(01)
Local cImpLin :=""
Local cAux 	  :=""
Local cAux1	  :=""   
Local nTamTxt := Len(cTexto)	
Local j
Local nPos
  
// Para alteracao/inclusao de caracteres, utilizar a fonte TERMINAL no IDE com o tamanho
// maximo possivel para visualizacao dos mesmos.
// Utilizar como referencia a tabela ASCII anexa a evidencia de teste (FNC 807/2009).

aAcentos :=	{;
			Chr(199),Chr(231),Chr(196),Chr(197),Chr(224),Chr(229),Chr(225),Chr(228),Chr(170),;
			Chr(201),Chr(234),Chr(233),Chr(237),Chr(244),Chr(246),Chr(242),Chr(243),Chr(186),;
			Chr(250),Chr(097),Chr(098),Chr(099),Chr(100),Chr(101),Chr(102),Chr(103),Chr(104),;
			Chr(105),Chr(106),Chr(107),Chr(108),Chr(109),Chr(110),Chr(111),Chr(112),Chr(113),;
			Chr(114),Chr(115),Chr(116),Chr(117),Chr(118),Chr(120),Chr(122),Chr(119),Chr(121),;
			Chr(065),Chr(066),Chr(067),Chr(068),Chr(069),Chr(070),Chr(071),Chr(072),Chr(073),;
			Chr(074),Chr(075),Chr(076),Chr(077),Chr(078),Chr(079),Chr(080),Chr(081),Chr(082),;
			Chr(083),Chr(084),Chr(085),Chr(086),Chr(088),Chr(090),Chr(087),Chr(089),Chr(048),;
			Chr(049),Chr(050),Chr(051),Chr(052),Chr(053),Chr(054),Chr(055),Chr(056),Chr(057),;
			Chr(038),Chr(195),Chr(212),Chr(211),Chr(205),Chr(193),Chr(192),Chr(218),Chr(220),;
			Chr(213),Chr(245),Chr(227),Chr(252);
			}
			
aAcSubst :=	{;
			"C","c","A","A","a","a","a","a","a",;
			"E","e","e","i","o","o","o","o","o",;
			"u","a","b","c","d","e","f","g","h",;
			"i","j","k","l","m","n","o","p","q",;
			"r","s","t","u","v","x","z","w","y",;
			"A","B","C","D","E","F","G","H","I",;
			"J","K","L","M","N","O","P","Q","R",;
			"S","T","U","V","X","Z","W","Y","0",;
			"1","2","3","4","5","6","7","8","9",;
			"E","A","O","O","I","A","A","U","U",;
			"O","o","a","u";
			}

For j:=1 TO Len(AllTrim(cTexto))
	cImpCar	:=SubStr(cTexto,j,1)
	//-- Nao pode sair com 2 espacos em branco.
	cAux	:=Space(01)  
    nPos 	:= 0
	nPos 	:= Ascan(aAcentos,cImpCar)
	If nPos > 0
		cAux := aAcSubst[nPos]
	Elseif (cAux1 == Space(1) .And. cAux == space(1)) .Or. Len(cAux1) == 0
		cAux :=	""
	EndIf		
    cAux1 	:= 	cAux
	cImpCar	:=	cAux
	cImpLin	:=	cImpLin+cImpCar

Next j

//--Volta o texto no tamanho original
cImpLin := Left(cImpLin+Space(nTamTxt),nTamTxt)

Return cImpLin       

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Transforma³ Autor ³ Cristina Ogura       ³ Data ³ 17/09/98 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Transforma as datas no formato DDMMAAAA                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Transforma(ExpD1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpD1 = Data a ser convertido                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ GPEM610                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Transforma(dData)
Return(StrZero(Day(dData),2) + StrZero(Month(dData),2) + Right(Str(Year(dData)),4))		


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FGETACJEF³ Autor ³ Mauricio MR			³ Data ³ 28/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Permite que o usuario decida onde sera criado o arquivo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PNM420 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function FGETACJEF()
Local mvRet := Alltrim(ReadVar())
Local l1Vez := .T.

oWnd := GetWndDefault()

While .T.
           
	If l1Vez
	 	cFile := mv_par15
	 	l1Vez := .F.
	Else
		cFile := "" 		
	EndIf
		 	
	If Empty(cFile)
		cFile := cGetFile("Arquivo ACJEF | ACJEF.*", OemToAnsi(STR0029))  //"Selecione Diretorio"

	EndIf
		 				 
	If Empty(cFile)
		Return .F.
	EndIf

	If "."$cFile
		cFile := Substr(cFile,1,rat(".", cfile)-1)
	EndIf


	If ! "ACJEF" $ UPPER(cFile)
		Aviso( STR0004,STR0012, { "Ok" },,STR0006 ) //Atencao###"Nome do arquivo inválido."###"Erro ao abrir o arquivo"
		Loop
	EndIf
	&mvRet := cFile
	Exit
EndDo

If oWnd != Nil
	GetdRefresh()
EndIf

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Monta_Per³ Autor ³Equipe Advanced RH     ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Gen‚rico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function Monta_Per( dDataIni , dDataFim , cFil , cMat , dIniAtu , dFimAtu )
                         	
Local aPeriodos := {}
Local cFilSPO	:= xFilial( "SPO" , cFil )
Local dAdmissa	:= SRA->RA_ADMISSA
Local dPerIni   := Ctod("//")
Local dPerFim   := Ctod("//")

SPO->( dbSetOrder( 1 ) )
SPO->( dbSeek( cFilSPO , .F. ) )
While SPO->( !Eof() .and. PO_FILIAL == cFilSPO )
	
    dPerIni := SPO->PO_DATAINI
    dPerFim := SPO->PO_DATAFIM  
	
    //-- Filtra Periodos de Apontamento a Serem considerados em funcao do Periodo Solicitado
    IF dPerFim < dDataIni .OR. dPerIni > dDataFim                                                      
		SPO->( dbSkip() )  
		Loop  
    Endif
	
    //-- Somente Considera Periodos de Apontamentos com Data Final Superior a Data de Admissao
    IF ( dPerFim >= dAdmissa )
		aAdd( aPeriodos , { dPerIni , dPerFim , Max( dPerIni , dDataIni ) , Min( dPerFim , dDataFim ) } )
	Else
		SPO->( dbSkip() )	
		LOOP
	EndIF
	
	SPO->( dbSkip() )
	
EndDo

IF ( aScan( aPeriodos , { |x| x[1] == dIniAtu .and. x[2] == dFimAtu } ) == 0.00 )
	dPerIni := dIniAtu
	dPerFim	:= dFimAtu 
	IF !(dPerFim < dDataIni .OR. dPerIni > dDataFim)
		IF ( dPerFim >= dAdmissa )
			aAdd(aPeriodos, { dPerIni, dPerFim, Max(dPerIni,dDataIni), Min(dPerFim,dDataFim) } )
		EndIF
    Endif
EndIF

Return( aPeriodos )

 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetCposRegra  ³ Autor ³ Mauricio MR        ³ Data ³ 02/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna conteudo da Regra corrente						   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GetCposRegra(cFil, cRegra)                                  ³±± 
±±³          ³ cFil   -> Filial para Consulta da Regra em SPA              ³±±
±±³          ³ cRegra -> Regra a ser Pesquisada                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ponm420                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function GetCposRegra( cFil , cRegra )

Local 	lTrbFeriado := .F. 
Local	aSpaInfo 	:= {;
							"PA_FERIADO"	 ;	//01
						}
aSpaInfo := PosSPA( cRegra , cFil , aSpaInfo , 01 , .F. ) 


/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Verifica Se o Dia em Questao eh um Feriado				  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
lTrbFeriado := ( aSpaInfo[1] == "S" )

Return( {lTrbFeriado })
  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³GetCposTurno  ³ Autor ³ Mauricio MR        ³ Data ³ 06/12/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna conteudo do Turno corrente						   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GetCposTurno(cFil, cTurno)                                  ³±± 
±±³          ³ cFil   -> Filial para Consulta do Turno no SR6	           ³±±
±±³          ³ cTurno -> Turno a ser Pesquisado                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ponm420                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function GetCposTurno( cFil , cTurno )

Local 	lExtrasReduz:= .F.
Local 	lAcrenot	:= .F.
Local 	lIdAcrenot  := .F.	
Local 	lHNotAtr	:= .F.	
Local 	lHNotSai	:= .F.	
Local 	lHNotFal	:= .F.	 
Local   nMinHnot	:= 0
Local	aSR6Info 	:= {;
							"R6_EXTNOT"	 ,;	//01- As horas extras noturnas sao calculadas com reducao de horas (52,25)
							"R6_MINHNOT" ,; //02- Minutos da reducao da hora noturna
							"R6_ACRENOT" ,; //03- Calcula acrescimo noturno no adicional  noturno
							"R6_IDACREN" ,; //04- Calcula o acrescimo noturno em evento especifico para isso
							"R6_HNOTATR" ,; //05- As horas de atraso sao calculadas com reducao de horas (52,25)
							"R6_HNOTSAI" ,; //06- As horas de saida antecipada sao calculadas com reducao de horas (52,25)
							"R6_HNOTFAL" ; 	//07- As horas de faltas sao calculadas com reducao de horas (52,25)
						}   
						
					
aSR6Info := PosSR6( cTurno , cFil , aSR6Info , 01 , .F. ) 


/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Verifica as horas extras noturnas consideram a reducao	  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
lExtrasReduz 	:= ( aSR6Info[1] == "S" )    
nMinHnot		:= ( 60 / aSR6Info[2]  )
lAcrenot		:= ( aSR6Info[3] == "S" )    
lIdAcrenot		:= ( aSR6Info[4] == "S" )    
lHNotAtr		:= ( aSR6Info[5] == "S" )    
lHNotSai		:= ( aSR6Info[6] == "S" )    
lHNotFal		:= ( aSR6Info[7] == "S" )    

Return( {lExtrasReduz, nMinHnot, lAcrenot, lIdAcrenot, lHNotAtr, lHNotSai, lHNotFal})

/*/{Protheus.doc} CalcHorasN
Calcula horas normais e horas noturnas quando não foram geradas no apontamento
@type  Static Function
@author Cícero Alves
@since 14/06/2022
@param dDataApo, Data, Data de apontamento do dia processado
@param nPosMarc, Numérico, Possição da primeira marcação do dia no aMarcacoes
@param aApoDia, Array, Resultados dos apontamento para o dia - Deve Ser passado por referência
/*/
Static Function CalcHorasN(dDataApo, nPosMarc, aApoDia)
	
	Local nCont 		:= 0
	Local nHoras 		:= 0
	Local nHorasTot		:= 0
	Local nHorasNTot	:= 0
	Local nHorasNot		:= 0
	Local nLenMarc		:= Len(aMarcacoes)
	Local nTab			:= AScan(aTabCalend, {|x| x[CALEND_POS_DATA_APO] == dDataApo })
	
	If nTab > 0 .And. aTabCalend[nTab][CALEND_POS_TIPO_ORIG_DIA] == "S" // Apenas para dias trabalhados
		For nCont := nPosMarc To nLenMarc Step 2
			
			If nCont == nLenMarc .Or. aMarcacoes[nCont][AMARC_DATAAPO] != dDataApo .Or. aMarcacoes[nCont + 1 ][AMARC_DATAAPO] != dDataApo
				Exit
			EndIf
			
			If "E" $ aMarcacoes[nCont][AMARC_TIPOMARC]
				fCalHoras(	aMarcacoes[nCont][AMARC_DATA]			,;
							aMarcacoes[nCont][AMARC_HORA]			,;
							aMarcacoes[nCont + 1][AMARC_DATA]		,;
							aMarcacoes[nCont + 1][AMARC_HORA]		,;
							@nHoras    								,;	//05 -> <@>Horas Normais Apontadas
							@nHorasNot      						,;	//06 -> <@>Horas Noturnas Apontadas
							.T.										,;	//07 -> Apontar Horas Noturnas
							aMarcacoes[nCont][AMARC_DATA]			,;	//08 -> Data Inicial Para a Hora Noturna
							NIL										,;	//09 -> <@>Horas de Acrescimo Noturno
							aTabCalend[nTab][CALEND_POS_INI_H_NOT]	,;	//10 -> Inicio do Horario Noturno
							aTabCalend[nTab][CALEND_POS_FIM_H_NOT]	,;	//11 -> Final do Horario Noturno
							60										,;	//12 -> Minutos do Horario Noturno (Não deve reduzir as horas noturnas)
							NIL     								,;	//13 -> Apenas Acrescimo Noturno
							NIL										 ;	//14 -> Periodo da Hora Noturna
						)
				
				nHorasTot := SomaHoras(nHorasTot, nHoras)
				nHorasNTot := SomaHoras(nHorasNTot, nHorasNot)
				nHoras := 0
				nHorasNot := 0
			EndIf
		Next
		
		// Subtrai as HE das horas normais
		for nCont := 6 To 15 Step 3
			If !Empty(aApoDia[nCont])
				If aApoDia[nCont] == "N"
					nHorasNTot := SubHoras(nHorasNTot, aApoDia[nCont - 2])
				Else
					nHorasTot := SubHoras(nHorasTot, aApoDia[nCont - 2])
				EndIf
			EndIf 
		Next
		
		aApoDia[2] := Max(nHorasTot, 0)
		aApoDia[3] := Max(nHorasNTot, 0)
	EndIf
	
Return

