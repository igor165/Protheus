#INCLUDE "PONM410.CH"
#INCLUDE "PROTHEUS.CH"  
#INCLUDE "PONCALEN.CH"

Static lPnm410CposBlock              
Static lPort1510 	:= Port1510() 	//Verifica se Portaria 1510/2009 esta em vigor.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PONM410  ³ Autor ³ Mauricio MR                      ³ Data ³ 20/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera arquivo AFDT - SREP                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³             ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ FNC             ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia C.  ³21/05/14³TPQAN3           ³Incluido o fonte da 11 para a 12 e efetua-³±± 
±±³            ³        ³                 ³da a limpeza.                             ³±±
±±³Christiane V³31/07/14³TQBVGL           ³Incluir no log funcionários sem PIS.      ³±± 
±±³Luis Artuso ³23/09/14³TQLHBU 		  ³Ajuste para permitir considerar como perio³±±
±±³			   ³        ³				  ³do inicial a data informada no pergunte   ³±±  
±±³			   ³        ³				  ³MV_PAR13      							 ³±±
±±|Thiago Y.M.N|10/02/15|TQTSOA			  |Ajuste para gerar arquivo de AFDT primeiro³±±
±±|			   |        |				  |no servidor, melhorando a perfomance, e de³±±
±±|			   |        |				  |pois copiando para a pasta local.         ³±±
±±|Renan Borges|15/05/15|           TSIDQK|Ajuste para imprimir motivo somente para  ³±±
±±|			   |        |				  |os tipos corretos definidos pela portaria ³±±
±±|			   |        |				  |1510.                                     ³±±      
±±|Luis Artuso |15/06/15|           TSPKFB|Ajuste para considerar os parametros De / ³±±
±±|			   |        |				  |ate de matricula.                         ³±±    
±±|Allyson M   |06/07/15|		    TSDP39|Ajuste na posicao da reinicializacao de   ³±±
±±|			   |        |				  |aMarcOri pois acumuluva matriculas sem    ³±±
±±|			   |        |				  |necessidade.     						 ³±±
±±|Renan Borges|07/12/15|           TTTSI7|Ajuste para ao realizar a geração do AFDT ³±±
±±|			   |        |				  |seja gerado corretamente as informações do³±±
±±|			   |        |				  |cabeçalho referente as datas de inicio e  ³±±   
±±|			   |        |				  |fim dos registros.                        ³±±   
±±|Oswaldo L.  |03/04/17  |DRHPONTP-164                           |Projeto cTree                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß */
Function PONM410() 
  
Local aArea			:= GetArea()
Local aSays			:= {}
Local aButtons		:= {}
Local cSvFilAnt		:= cFilAnt
Local lBarG1ShowTm 	:= .F.
Local lBarG2ShowTm 	:= .F.
Local nOpcA			:= 0

Private cCadastro := OemtoAnsi(STR0001)		//"Gera‡„o do arquivo AFDT"

Private dIniCale		:= Ctod("//")
Private dFimCale		:= Ctod("//")

Private lAbortPrint := .F.

Private lBlind := IsBlind()

DEFAULT lPnm410CposBlock	:= ExistBlock( "PNM410CPOS"	)

If lPort1510
	cCadastro += fPortTit() //Complementa titulo da tela com dizeres referente a portaria.
EndIf

Pergunte("PNM410",.F.)


/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ So Executa se os Modos de Acesso dos Arquivos Relacionados es³
³ tiverm OK e se For Encontrado o Periodo de Apontamento.      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF ValidArqPon() 
	
	PonDestroyStatic()
	
	If !lBlind
		AADD(aSays,OemToAnsi( STR0002 ) )// //"Este programa gera arquivo AFDT"
		
		AADD(aButtons, { 5,.T.,{|| Pergunte("PNM410",.T. ) } } )
		AADD(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(),FechaBatch(),nOpcA := 0 ) }} )
		AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )
		FormBatch( cCadastro, aSays, aButtons )
		
		IF ( nOpcA == 1 )
			
			// Verifica se deve Mostrar Calculo de Tempo nas BarGauge
			lBarG1ShowTm := ( SuperGetMv("MV_PNSWTG1",NIL,"N") == "S" )
			lBarG2ShowTm := ( SuperGetMv("MV_PNSWTG2",NIL,"S") == "S" )
			
			// Executa o Processo de Leitura/Apontamento
			Proc2BarGauge(  { || PNM410Proc() } , STR0001 , NIL , NIL , .T. , lBarG1ShowTm , lBarG2ShowTm ) // Geração do arquivo AFDT
			
		EndIF
	Else
		PNM410Proc() // Geração do arquivo AFDT
	EndIf
	
EndIF

cFilAnt := cSvFilAnt
RestArea( aArea )

Return( NIL )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ PONM410Processa ³ Autor ³ Mauricio MR    ³ Data ³ 21/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Processa a geracao do arquivo magnetico AFDT               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso  	 ³ SIGAPON				             						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static FUNCTION PNM410Proc() 
Local aAreaSRA	 	:= SRA->( GetArea() )
Local aMarcOri		:= {}

//-- Variaveis para a geracao do arquivo magnetico
    
Local lCriou	:= .F.  
                                                  
//-- Variaveis para obter as informacoes das empresas
Local aInfo   		:= 	{}  

//-- Variaveis para passagem entre funcoes
Local cTpIdEmp     	:=	"" 
Local cTipoInsc		:= 	""
Local cCPFCNPJ		:= 	""
Local cCEI			    :=	"" 
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
Local cAcessaSRA	:= &("{ || " + ChkRH("PONM410","SRA","2") + "}") 

//-- Variaveis de filias das tabelas
Local cFilSP8		:= ""
Local cFilSPG		:= ""
Local cFilRFE		:= ""
Local cFilRFH		:= ""

//-- Bloco do cadastro de funcionarios SRA
Local bSraScope

//-- Barra de progressao
Local aRecsBarG		:= {}  
Local aRecsSR6		:= {}
Local cTimeIni		:= Time()
Local cMsgBarG1		:= ""
Local lIncProcG1	:= .T.
Local lSR6Comp		:= Len(Alltrim(xFilial( "SR6" ))) < FwGetTamFilial
Local nLastRec		:= 0
Local nIncPercG1	:= 0
Local nIncPercG2	:= 0
Local nCount1Time	:= 0
Local nRecsSR6		:= 0

//-- Contador
Local nVezes		:= 0

//-- Lacos
Local nX			:= 0

//-- Retorno de Ponto de entrada
Local uRetBlock 

//-- Controle de periodos
Local lTemMov       := .F.
Local naPeriodos	:= 0  
Local cIniData		:= ""
Local cFimData		:= ""

//-- Montagem do calendario   
Local lSPJExclu		:= Len(AllTrim(xFilial("SPJ"))) = FwGetTamFilial
Local cTurno		:= "!!"
Local cSeq			:= "!!"

Local aSp8Fields	:= SP8->( dbStruct() )
Local nSp8Fields	:= Len( aSp8Fields	)
Local aSpGFields	:= SPG->( dbStruct() )
Local nSpGFields	:= Len( aSpGFields	)
Local aRFEFields	:= RFE->( dbStruct() )
Local nRFEFields	:= Len( aRFEFields	)
Local aRFHFields	:= RFH->( dbStruct() )
Local nRFHFields	:= Len( aRFHFields	)
   	
Local lQueryOpened	:= .F.
Local lProssegue	:= .T.

Local aStruSRA		:= {}
Local aCposSRA		:= {} 

Local cSitQuery		:= ""
Local cCatQuery 	:= "" 
   	
Local cAliasSRAQry	:= ""
Local cAliasSRARec	:= ""  
   	
  	  	   	
Local aTempSRA		:= SRA->( dbStruct() )
Local nContField	:= Len( aTempSRA	)

Local cSRAWhere		:= ""

//-- Controle de Log
Private aLogDet		:= {}
Private aLogMarc	:= Array(5,1)
Private aLogTitle	:= {}

//-- Controle de periodo 
Private dPerIni   := Ctod("//")	//-- Data Inicial o Periodo de Cada Filial
Private dPerFim   := Ctod("//")	//-- Data Final o Periodo de Cada Filial

Private dMarcIni   := Ctod("//")	//-- Data Inicial a Considerar para Recuperar as Marcacoes
Private dMarcFim   := Ctod("//")	//-- Data Final a Considerar para Recuperar as Marcacoes
Private dIniPonMes := Ctod("//")	//-- Data Inicial do Periodo em Aberto 
Private dFimPonMes := Ctod("//")	//-- Data Final do Periodo em Aberto 

Private lImpAcum		:= .F.

Private aPeriodos  := {}

//Montagem do calendario
Private aMarcacoes 	:= {}
Private aTabPadrao 	:= {}
Private aTabCalend 	:= {}
Private aTurnos 	:= {}
Private oTmpAFDT
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carregando as Perguntas                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Pergunte("PNM410",.F.)



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
	
	//-- O nome do arquivo deve ser AFDT
	If !"AFDT" $ UPPER(cFile)
		Aviso( STR0006,STR0012, { "Ok" },,STR0004 ) //Atencao###"Nome do arquivo inválido."###"Erro ao abrir o arquivo"
		lAbortPrint := .T.
		Break
	EndIf                                 
	
	
	
	If !(lCriou:=PN410Cria())
		Aviso( STR0006,STR0005, { "Ok" },,STR0007 ) //"Erro ao abrir o arquivo"## Verifique se este processo já está sendo executado em outra estação."##"Nao foi possivel abrir o arquivo temporario AFDT.
		lAbortPrint := .T.
		Break
	Endif
	
	dbSelectArea("SP8") //-- Marcacoes
	dbSetOrder(RetOrder( "SP8", "P8_FILIAL+P8_MAT+DTOS(P8_DATAAPO)+DTOS(P8_DATA)+STR(P8_HORA,5,2)"))                     

	dbSelectArea("SPG") //-- Marcacoes Acumuladas
	dbSetOrder(RetOrder( "SPG", "PG_FILIAL+PG_MAT+DTOS(PG_DATAAPO)+DTOS(PG_DATA)+STR(PG_HORA,5,2)"))                     	
	
	dbSelectArea("RFE") //-- Marcacoes originais dos Funcion rios
	DbSetOrder( RetOrder( "RFE", "RFE_EMPORG+RFE_FILORG+RFE_MATORG+DTOS(RFE_DATAAP)+DTOS(RFE_DATA)+STR(RFE_HORA,5,2)" ))

	dbSelectArea("RFH") //-- Marcacoes originais dos Funcion rios Acumuladas
	DbSetOrder( RetOrder( "RFH", "RFH_EMPORG+RFH_FILORG+RFH_MATORG+DTOS(RFH_DATAAP)+DTOS(RFH_DATA)+STR(RFH_HORA,5,2)" )) 
	
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
	IF ( lPnm410CposBlock )
		IF ( ValType( uRetBlock := ExecBlock("PNM410CPOS",.F.,.F.,aCposSRA) ) == "A" )
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
			aAdd( aLogDet , STR0013 )//"A geracao do AFDT Foi Cancelada Pelo Usuario"
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
	
	lQueryOpened		:= .T.
			
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Abandona o Processamento									   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	IF ( lAbortPrint )
		aAdd( aLogDet , STR0013 )//"A geracao do AFDT Foi Cancelada Pelo Usuario"	
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
	
	If !lBlind
		// Inicializa Mensagem para a IncProcG2() ( Funcionarios )
		IncProcG2( STR0014  , .F. )	// 'Processando...'
		
		// Atualiza a Mensagem para a IncProcG2() ( Funcionarios )
		BarGauge2Set( nLastRec )
	EndIf
	
	While SRA->( !Eof() .and. ( ( cFilTnoAtu := ( RA_FILIAL + RA_TNOTRAB ) ) >= cFilTnoDe ) .and. ;
		                        ( cFilTnoAtu <= cFilTnoAte ) )
		lProssegue	:= .T.								

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
		³ Consiste a Situacao										  ³
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
			aAdd( aLogDet , STR0013 )//"A geracao do AFDT Foi Cancelada Pelo Usuario"
			Break
		EndIF  
		
		//-- Pis em branco
		If Empty(SRA->RA_PIS)                                                        
			cLog := STR0010 + STR0011 + " " + STR0017 + " " + SRA->RA_FILIAL + " - " + STR0024 + SRA->RA_MAT   //"Nao Enviado(s) - "### "PIS INVALIDO"###"Filial:" ##"Matricula: "#####
			aAdd( aLogDet , cLog )
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
				
				// Reinicializa a Filial/Turno Anterior
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
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Carrega as Tabelas de Horario Padrao						  ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				IF ( lSPJExclu .or. Empty( aTabPadrao ) )
					aTabPadrao := {}
					( @aTabPadrao , IF( lSPJExclu , cLastFil , NIL ) )
				EndIF
		    							
				//--Geracao do registro de quebra de CNPJ/CPF ou CEI
				//-- Cabecalho 
				TIPO01(aInfo, cTpIdEmp, @cTipoInsc, @cCPFCNPJ, @cCEI )

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
							
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Carrega as Filiais dos Arquivos	                           ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				cFilSP8	:= fFilFunc("SP8")
				cFilSPG	:= fFilFunc("SPG")
				cFilRFE	:= fFilFunc("RFE")
				cFilRFH	:= fFilFunc("RFH")				
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
			IncPrcG2Time( STR0030 , nLastRec , cTimeIni , .T. , 2 , nIncPercG2 ) // "Processados:"
		EndIf
		
		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Consiste Admissao e Demissao                                ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		IF SRA->(;
					( RA_ADMISSA > dPerFim );
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
			aAdd( aLogDet , STR0013 )//"A geracao do AFDT Foi Cancelada Pelo Usuario"
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
		
			lProssegue	:= .T.
	
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
			³Verifica se o Calendario sera utilizado no caso de legado ou ³
			³se os novos campos estao alimentados com as informacoes neces³
 			³sarias.													  ³
			ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		    lTemMov:= .F.
			
			/*
				IF lImpAcum
			 	    lAbortPrint	:= GetMarc(@lTemMov, "SPG", cTipoInsc, cCPFCNPJ, cCEI, cPIS, aSpGFields, nSpGFields , cFilSPG, cIniData, cFimData, @dDataIni, @dDataFim  )   			   
					dbSelectArea("SRA")
			        IF lAbortPrint
			           Break
			        Endif 
				Else              
			 	    lAbortPrint	:= GetMarc(@lTemMov, "SP8",  cTipoInsc, cCPFCNPJ, cCEI, cPIS, aSp8Fields, nSp8Fields, cFilSP8, cIniData, cFimData, @dDataIni, @dDataFim 	)                   
					dbSelectArea("SRA")
			        IF lAbortPrint
			           Break
			        Endif 				
				Endif  
			*/
			           
			//-- Se não tem  movimento, provavelmente trata-se de legado sem os novos campos preenchidos
			//-- nesse caso procuramos as informacoes por meio do calendario do funcionario    
			IF !lTemMov	

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
			
			    /*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Carrega Arrays com as Marca‡”es do Periodo (aMarcacoes), com³
				³o Calendario de Marca‡”es do Periodo (aTabCalend) e com    as³	
				³Trocas de Turno do Funcionario (aTurnos)					  ³	
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				( aMarcacoes := {} , aTabCalend := {} , aTurnos := {}, aMarcOri := {} )   
			    /*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Importante: 												  ³
				³ O periodo fornecido abaixo para recuperar as marcacoes   cor³
				³ respondente ao periodo de apontamentoo Calendario de 	 Marca³	
				³ ‡”es do Periodo ( aTabCalend ) e com  as Trocas de Turno  do³	
				³ Funcionario ( aTurnos ) integral afim de criar o  calendario³	
				³ com as ordens correspondentes as gravadas nas marcacoes	  ³	
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				IF !GetMarcacoes(	@aMarcacoes					,;	//01-Marcacoes dos Funcionarios
									@aTabCalend					,;	//02-Calendario de Marcacoes
									@aTabPadrao					,;	//03-Tabela Padrao
									@aTurnos					,;	//04-Turnos de Trabalho
									aPeriodos[ nX , 1 ]			,;	//05-Periodo Inicial
									aPeriodos[ nX , 2 ] 		,;	//06-Periodo Final
									SRA->RA_FILIAL				,;	//07-Filial
									SRA->RA_MAT					,;	//08-Matricula
									cTurno						,;	//09-Turno
									cSeq						,;	//10-Sequencia de Turno
									SRA->RA_CC					,;	//11-Centro de Custo
									IF(lImpAcum,"SPG","SP8")	,;	//12-Alias para Carga das Marcacoes
									NIL							,;	//13-Se carrega Recno em aMarcacoes
									.T.							,;	//14-Se considera Apenas Ordenadas
								    .T.    						,;	//15-Se Verifica as Folgas Automaticas
								  	.F.    			 			,;	//16-Se Grava Evento de Folga Automatica Periodo Anterior
								 	/*lGetMarcAuto*/			,;	//17 -> Se Carrega as Marcacoes Automaticas
									/*aRecsMarcAut*/	    	,;	//18 -> Registros de Marcacoes Automaticas que deverao ser Desprezadas
									/*bCondMarcAut*/			,;	//19 -> Bloco para avaliar as Marcacoes Automaticas que deverao ser Desprezadas
									/*lChkPerAponta*/			,;	//20 -> Se Considera o Periodo de Apontamento das Marcacoes
									/*lSncMaMe*/				,;	//21 -> Se Efetua o Sincronismo dos Horarios na Criacao do Calendario
									.T.       			 		;  //22 -> Se carrega as marcacoes desconsideradas (Uso com lPort1510)
								  )
										 
					//aAdd( aLogDet , STR0039 )//"Erro na montagem do Calendario:"    
					//-- Empresa: XX#Filial: XX#Matricula: 999999#Periodo : XX/XX/XXXX - XX/XX/XXXX#
					aAdd( aLogMarc[1], STR0028 + cEmpAnt + Space(1) + STR0017 + SRA->RA_FILIAL + Space(1) + STR0024 + SRA->RA_MAT + Space(1) + ;
					STR0034 + DtoC(aPeriodos[nx, 1 ]) + " - " +	DtoC(aPeriodos[ nX , 2 ]) )
					lProssegue	:= .F.					
				EndIF					 
		        
				If ( lProssegue )
				
					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³ Monta a Query das Marcacoes mensais						   ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					If !GetMarcTab(aMarcacoes, cTipoInsc, cCPFCNPJ, cCEI, cPIS, aSp8Fields, nSp8Fields, cFilSP8,	aPeriodos[ nX , 3 ], aPeriodos[ nX , 4 ], @dDataIni, @dDataFim, @aMarcOri )
						lProssegue	:= .F.
					EndIf
					
				EndIf
				
				If ( lProssegue )

					dbSelectArea("SRA")
					
					IF lAbortPrint
					   Break
					Endif
				
				EndIf
	        EndIf

			aSort( aMarcOri,,,{ |x,y| x[1]+x[2]+x[3] > y[1]+y[2]+y[3] } )
	        
			If ( lProssegue )
				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Monta a Query das Marcacoes Originais						   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				 If lImpAcum
					If !GetMarcOrig("RFH", cTipoInsc, cCPFCNPJ, cCEI, cPIS, aRFHFields, nRFHFields , cFilRFH, cIniData, cFimData, aMarcOri  )
						lProssegue	:= .F.					
					EndIf
				Else
					If !GetMarcOrig("RFE", cTipoInsc, cCPFCNPJ, cCEI, cPIS, aRFEFields, nRFEFields , cFilRFE, cIniData, cFimData, aMarcOri  )
						lProssegue	:= .F.						
					EndIf
				EndIf
				
				If ( lProssegue )

					dbSelectArea("SRA")
					
					IF lAbortPrint
					   Break
					Endif
				
				EndIf
				
			EndIf
			
			// Complementa as inforamcoes do Cabecalho
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
If lQueryOpened		
	SRA->( dbCloseArea() )
	ChkFile( "SRA" )
EndIf

If Len(aLogMarc[1])>1
	aAdd( aLogDet , "")
	aAdd( aLogDet , STR0039 )//"Erro na montagem do Calendario:"
	For nX := 1 to Len(aLogMarc[1])
		aAdd(aLogDet , aLogMarc[1][nX])
	Next nX
EndIf

If Len(aLogMarc[2])>1
	aAdd( aLogDet , "")
	For nX := 1 to Len(aLogMarc[2])
		aAdd(aLogDet , aLogMarc[2][nX])
	Next nX
EndIf

If Len(aLogMarc[3])>1
	aAdd( aLogDet , "")
	For nX := 1 to Len(aLogMarc[3])
		aAdd(aLogDet , aLogMarc[3][nX])
	Next nX
EndIf

If Len(aLogMarc[4])>1
	aAdd( aLogDet , "")
	For nX := 1 to Len(aLogMarc[4])
		aAdd(aLogDet , aLogMarc[4][nX])
	Next nX
EndIf

If Len(aLogMarc[5])>1
	aAdd( aLogDet , "")
	aAdd( aLogMarc , STR0035) //"Erro de Inconsistencia. Marcacao original ausente do arquivo-fonte Tratado: "
	For nX := 1 to Len(aLogMarc[5])
		aAdd(aLogDet , aLogMarc[5][nX])
	Next nX
EndIf

If ! lAbortPrint .And. Empty( aLogDet )
	cCPFCNPJ := ""
	If !FGeraArq(@cCPFCNPJ)            
		aAdd( aLogDet , STR0027 )						//"Erro ao gerar o arquivo"
		aAdd( aLogDet , STR0028 + cCPFCNPJ + STR0029 )	//"-- Empresa: "###" Sem Marcacoes"			
	EndIf
EndIf	

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Gera o Log de Inconsistencias                                ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF !Empty( aLogDet )
	aAdd( aLogDet , "" )
	aAdd( aLogDet , STR0021 )
	aAdd( aLogDet , STR0042 )
	fMakeLog( { aLogDet } , aLogTitle , "PNM410" )
EndIF

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Restaura o Conteudo Original da Filial de Entrada			   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
cFilAnt:= cSvFilAnt

RestArea( aAreaSRA )

//-- Apaga o indice do AFDT
If lCriou
	//P410ApIndice(cArqnome)
	dbSelectArea("AFDT")
	dbCloseArea()
	If oTmpAFDT <> Nil
	    oTmpAFDT:Delete()
	    Freeobj(oTmpAFDT)
    EndIf
Endif

Return( NIL )
 
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncai    ³P410ApIndiceºAutor  ³Mauricio MR       º Data ³  20/10/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Apaga o indice do arquivo AFDT quando sair da rotina       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ PONM410                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function P410ApIndice(cArqNome)
Local nVezes := 0                          
Local cArquivo := FileNoExt(cArqNome)+"1"+OrdBagExt()

dbSelectArea("AFDT")
dbCloseArea()

While File(cArquivo)
	nVezes ++
   	If nVezes >= 10
		Aviso( STR0004,STR0009+'"'+cArquivo +'"', { "Ok" },,STR0008 ) //"Atencao"###"Nao foi possivel excluir o arquivo "###"Erro ao Excluir arquivo"
		Return
	EndIf
	FErase(FileNoExt(cArqNome)+"1"+OrdBagExt())           
EndDo

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Pn410Cria ³ Autor ³ Mauricio MR		    ³ Data ³ 20/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Verifica se existe o arquivo e cria se necessario			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³            												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PONM410  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function Pn410Cria()

Local aStru  :={}
Local cInd
Local nVezes := 0
Local aLstIndices := {}
   
aStru 	:= {;
			 {	"FDT_TINSC"		, "C" 	, 001 , 0 },;
			 {	"FDT_INSC"		, "C" 	, 014 , 0 },;
			 {	"FDT_CEI"		, "C" 	, 012 , 0 },;
			 {	"FDT_TIPO" 		, "C" 	, 001 , 0 },;
			 {	"FDT_PIS"		, "C" 	, 012 , 0 },;
			 {	"FDT_DATA"		, "D"	, 008 , 0 },;
			 {	"FDT_HORA"		, "C" 	, 004 , 0 },;
			 {	"FDT_RELO"		, "C" 	, 002 , 0 },;				 
		 	 {	"FDT_ID"		, "C" 	, 009 , 0 },;
			 {	"FDT_TEXTO"		, "C" 	, 255 , 0 },;
			 {	"FDT_EMFIMA"	, "C"	, 10  , 0 } }

AAdd (aLstIndices, {"FDT_TINSC","FDT_INSC","FDT_CEI","FDT_TIPO","FDT_PIS","FDT_DATA","FDT_HORA","FDT_RELO","FDT_ID"}  ) 
oTmpAFDT:= RhCriaTrab("AFDT", aStru, aLstIndices)

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³GetMarcTab³ Autor ³Mauricio MR		    ³ Data ³21/10/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtem as marcacoes para o periodo informado a partir do Ca- ³±±
±±³          ³lendario.                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³GetMarc()													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³PONM410	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/              
Static Function GetMarcTab(aMarcacoes, cTipoInsc, cCPFCNPJ, cCEI, cPIS, aSp_Fields, nSp_Fields, cFil, dIniData, dFimData, dDataIni, dDataFim, aMarcOri  )
Local nX		:= 0  
Local cMat		:= SRA->RA_MAT  
Local dDataApo   
Local nHora		
Local cCC  
Local cTpMcRep   		//Pode ter o conteudo "D" vindo das manutencoes de marcacoes (os tipos "E" e "S" sao gerados nesse programa)
Local cTipoMarc	:= ""   //Pode ter o conteudo "E" ou "S" gerados nesse programa
Local cTpMarca   		//Pode ter o conteudo do cTpMcRep ou do cTipoMarc
Local cTipoReg   		//Original("O"),Incluido ("I") ou Preassinalado ("P") 
Local cIdOrg   
Local cRelogio
Local cEmpOrg
Local cFilOrg
Local cMatOrg
Local lCancela	:= .F.  
Local nMarcacoes	:= Len(aMarcacoes)
Local cSeqJrn	:= "!!"
Local nSeq		:= 0     
Local cOrdem	:= "!!"  
Local nPos		:= 0
Local nDias		:= 0 
Local nTotDias	:= 0
Local nTab		:= 0
Local dData		:= Ctod("")
     
dDataAnt		:= Ctod("") 
cSeqJrn			:= "!!"
nSeq			:= 0

nTotDias := ( dFimData - dIniData )

For nDias := 0 To nTotDias
                    
    dData	:= dIniData + nDias
    
	//-- o Array aTabcalend ‚ setado para a 1a Entrada do dia em quest„o.
	IF ( nTab := aScan(aTabCalend, {|x| x[1] == dData .and. x[4] == '1E' }) ) == 0.00
		Loop
	EndIF

	//-- o Array aMarcacoes ‚ setado para a 1a Marca‡„o do dia em quest„o.
	IF Empty(nX := aScan(aMarcacoes, { |x| x[3] == aTabCalend[nTab, 2] })) 
		Loop
	EndIF

    cTipoMarc	:= "S" //Para posterior alteracao
	nSeq		:= 0
	
	dDataAnt	:= dData
		    
	While ( nX <= nMarcacoes ) .and. ( aTabCalend[nTab, 2] == aMarcacoes[nX, AMARC_ORDEM 		] ) 
		dData		:= aMarcacoes[nX, AMARC_DATA 		]	//-- Data da Marcacao
		nHora		:= aMarcacoes[nX, AMARC_HORA 		] 	//-- Hora da Marcacao
		cCC			:= aMarcacoes[nX, AMARC_CC 			]	//-- Centro de Custos
		cTipoReg	:= aMarcacoes[nX, AMARC_TIPOREG 	]	//-- Tipo de Registro da Marcacao 
		cREP		:= aMarcacoes[nX, AMARC_NUMREP	 	]	//-- Numero do REP
		cMotivRg	:= aMarcacoes[nX, AMARC_MOTIVRG	 	]	//-- Motivo de Registro de Incusao ou Desconsideracao  
		cIdOrg		:= aMarcacoes[nX, AMARC_IDORG	 	]	//-- Identificacao da Origem da marcacao
		dDataApo	:= aMarcacoes[nX, AMARC_DATAAPO 	]	//-- Data de Apontamento   
		cOrdem		:= aMarcacoes[nX, AMARC_ORDEM 		]	//-- Ordem da Marcacao
		cTpMcRep	:= aMarcacoes[nX, AMARC_TPMCREP		]	//-- Tipo de Marcacao
		cRelogio	:= aMarcacoes[nX, AMARC_RELOGIO		]	//-- Relogio Origem da Marcacao
		cEmpOrg		:= aMarcacoes[nX, AMARC_EMPORG		]	//-- Empresa de Origem
		cFilOrg		:= aMarcacoes[nX, AMARC_FILORG		]	//-- Filial de Origem
		cMatOrg		:= aMarcacoes[nX, AMARC_MATORG		]	//-- Matricula de Origem
		
		If !Empty(cEmpOrg)
			If Empty(aMarcOri) .or. ( ( aScan(aMarcOri, {|x| x[1] + x[2] + x[3] ==  cEmpOrg + cFilOrg + cMatOrg }) ) == 0 )
				aAdd( aMarcOri , {cEmpOrg , cFilOrg , cMatOrg} ) //Guarda origem das marcacoes
			EndIf
		EndIf
	
    	//-- Verifica ocorrencia de nao conformidade:
		IF cTpMcRep <> "D" 
			
			//-- Tipo de Marcacao
		    cTipoMarc := IF(cTipoMarc == "E", "S", "E")
		    
		    IF cTipoMarc == "E"  
			    //----- Gera numero sequencial de jornada
			    nSeq++
		   	 	cSeqJrn		:= Alltrim(StrZero(nSeq, 2) )	
		   	Endif	
		   	cTpMarca	:= cTipoMarc
		   	cSeqMarca	:= cSeqJrn 
	    Else
	    	cTpMarca	:= cTpMcRep                                 
	    	cSeqMarca	:= ""
	    Endif

	    //-- Consiste informacoes para o registro tipo 02
		IF !fVerReg02(cFil, cMat, dDataApo, dData, cTpMarca, cTipoReg, @cMotivRg)
			lCancela	:= .T.
			Exit
		Endif
		
		//-- DETALHE	
	   	TIPO02(cTipoInsc, cCPFCNPJ, cCEI, dData, nHora, cPIS, cREP, cTpMarca, cSeqMarca, cTipoReg, cMotivRg, cIdOrg , cRelogio)
	
		//-- Variaveis utilizadas para determinar a menor e a maior data de marcacao para cada CNPJ/CPF/CEI lido	          
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
		
	    nX++
	    
	    If nX > nMarcacoes
	    	Exit
	    Endif
	    
	End While    
                                                  
	//-- Se a jornada terminou com uma marcacao de entrada  (faltou a saida)
	IF	(cTpMarca == "E" ) 
		aAdd( aLogMarc[2] , STR0023 + cFil + Space(1) + STR0024 + cMat + Space(1) + STR0025 + Dtoc(dDataAnt) )//"Marcacoes impares: Filial: "##xxxxxxx##"Matricula: "##Data Ap.: ##xx/xx/xx
		lCancela	:= .T.
		Exit
	Endif
	
	If lCancela
		Exit
	Endif
	
Next nDias

Return !(lCancela)	

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³fVerReg02 ³ Autor ³Mauricio MR		    ³ Data ³10/11/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Consiste informacoes para geracao do registro Tipo 02		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³fVerReg02()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³PONM410	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/         
Static Function fVerReg02(cFil, cMat, dDataApo, dData, cTpMarca, cTipoReg, cMotivRg)
Local lRet:= .T.

//Verifica se existe motivo informado para marcacoes desprezadas ou incluidas
IF ( (cTpMarca == "D") .or. (cTipoReg=='I') ) .and. Empty(cMotivRg)
	aAdd( aLogMarc[3] , STR0041 + cFil + Space(1) + STR0024 + cMat + Space(1) + STR0025 + Dtoc(dDataApo) + Space(1) + STR0034 + Dtoc(dData)  )// "Marcacao sem motivo de manutencao.Filial: "##xxx##"Matricula: "##Data Ap.: ##xx/xx/xx##"Data Marc.: "xx/xx/xx
    lRet:= .F.
ElseIf ( (cTpMarca <> "D") .AND. (cTipoReg <> 'I') ) .and. !Empty(cMotivRg)
	cMotivRg := ""
Endif

Return (lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³GetMarc   ³ Autor ³Mauricio MR		    ³ Data ³21/10/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtem as marcacoes para o periodo informado				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³GetMarc()													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³PONM410	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/              
/*
Static Function GetMarc(lTemMov, cAliasSP_, cTipoInsc, cCPFCNPJ, cCEI, cPIS, aSp_Fields, nSp_Fields, cFil, cIniData, cFimData, dDataIni, dDataFim  )
Local aArea		:= GetArea()
Local nX		:= 0  
Local cPrefix	:= ( PrefixoCpo( cAliasSP_ )) 
Local cMat		:= SRA->RA_MAT  
Local dDataApo   
Local nHora		
Local cCC

Local cTpMcRep   		//Pode ter o conteudo "D" vindo das manutencoes de marcacoes (os tipos "E" e "S" sao gerados nesse programa)
Local cTipoMarc	:= ""   //Pode ter o conteudo "E" ou "S" gerados nesse programa
Local cTpMarca   		//Pode ter o conteudo do cTpMcRep ou do cTipoMarc

Local cTipoReg   		//Original("O"),Incluido ("I") ou Preassinalado ("P") 
Local cIdOrg 
Local cRelogio

Local lCancela	:= .F. 

Local dDataAnt	:= Ctod("") 
Local cSeqJrn	:= "!!"  
Local cSeqMarca := ""	//Pode ter o conteudo Vazio (marcacao desprezada) ou a sequencia da jornada (1,2,3,4,5, qdo entrada ou saida não desprezadas)
Local nSeq		:= 0

Local lQueryOpened		:= .F.

Local cSP_Campos:= ""
Local cSP_Query := ""
Local cSP_Where	:= ""			                  
Local cSP_Ordem := ""

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carregando os Campos do SP? na Query						   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/    
/*
cSP_campos:= "%"
For nX := 1 To nSp_Fields
	cSP_Campos += aSp_Fields[ nX , 01 ] + ", "
Next nX
cSP_Campos := SubStr( cSP_Campos , 1 , Len( cSP_Campos ) - 2 ) + "%"
*/
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Montando a Condicao										   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
/*
cSP_Where := "%"
cSP_Where += cAliasSP_ + "."
cSP_Where += cPrefix+"_FILIAL='"+cFil+"'"
cSP_Where += " AND "				
cSP_Where += cAliasSP_ + "."
cSP_Where += cPrefix+"_MAT='" + cMat +"'"
cSP_Where += " AND "				
cSP_Where += " ( "
cSP_Where += cAliasSP_ + "."
cSP_Where += cPrefix+"_DATAAPO>='"+cIniData+"'"
cSP_Where += " AND "
cSP_Where += cAliasSP_ + "."
cSP_Where += cPrefix+"_DATAAPO<='"+cFimData+"'"
cSP_Where += " ) "
cSP_Where += "%"

cSP_Ordem := "%" 		+ 	cAliasSP_ + "." 	+ cPrefix	+ "_FILIAL, "	+;
							cAliasSP_ + "." 	+ cPrefix	+ "_MAT, "		+;
							cAliasSP_ + "." 	+ cPrefix 	+ "_DATAAPO, "	+;
							cAliasSP_ + "." 	+ cPrefix 	+ "_DATA, "		+;
							cAliasSP_ + "." 	+ cPrefix 	+ "_HORA, "		+;								
							cAliasSP_ + "." 	+ cPrefix 	+ "_IDORG %"	

cAliasSP_Qry	:= GetNextAlias()

IF cAliasSP_ == "SP8"
	BeginSql alias cAliasSP_Qry 
		COLUMN P8_DATA 		AS DATE
		COLUMN P8_DATAAPO 	AS DATE
		SELECT	%exp:cSP_Campos%
		FROM %table:SP8% SP8
		WHERE 
			  %exp:cSP_Where% AND
		      SP8.%notDel%   
		ORDER BY %exp:cSP_Ordem%
	EndSql   	
Else 
	BeginSql alias cAliasSP_Qry  
		COLUMN PG_DATA 		AS DATE
		COLUMN PG_DATAAPO 	AS DATE
		SELECT	%exp:cSP_Campos%
		FROM %table:SPG% SPG
		WHERE 
			  %exp:cSP_Where% AND
		      SPG.%notDel%   
		ORDER BY %exp:cSP_Ordem%
	EndSql   	
Endif

lQueryOpened := .T.

IF ! lQueryOpened
	(cAliasSP_)->( dbSeek( cFil + SRA->RA_MAT + cIniData  , .T. ) ) 
Endif
      
cTipoMarc	:= ""
dDataAnt	:= Ctod("") 
cSeqJrn		:= "!!"
nSeq		:= 0

While (cAliasSP_Qry)->( !Eof() .and. ( ( cFil + cMat ) == ( &(cPrefix+"_FILIAL")+&(cPrefix+"_MAT") ) )  .and.;
			   ( ( Dtos( &(cPrefix+"_DATAAPO") ) >= cIniData ) .and.  ( Dtos( &( cPrefix+"_DATAAPO") ) <= cFimData) )  )
    
    lTemMov:= .T.

	dData		:= (cAliasSP_Qry)->(&(cPrefix+"_DATA"		)) 	//-- Data da Marcacao
	nHora		:= (cAliasSP_Qry)->(&(cPrefix+"_HORA"		)) 	//-- Hora da Marcacao
	cCC			:= (cAliasSP_Qry)->(&(cPrefix+"_CC"		))	//-- Centro de Custos
	cTpMcRep	:= (cAliasSP_Qry)->(&(cPrefix+"_TPMCREP"	))	//-- Tipo da Marcacao do REP 
	cTipoReg	:= (cAliasSP_Qry)->(&(cPrefix+"_TIPOREG"	))	//-- Tipo de Registro da Marcacao 
	cREP		:= (cAliasSP_Qry)->(&(cPrefix+"_NUMREP"	))	//-- Numero do REP
	cMotivRg	:= (cAliasSP_Qry)->(&(cPrefix+"_MOTIVRG"	))	//-- Motivo de Registro de Incusao ou Desconsideracao  
	cIdOrg		:= (cAliasSP_Qry)->(&(cPrefix+"_IDORG"		))	//-- Linha/Registro do REP
    cRelogio	:= (cAliasSP_Qry)->(&(cPrefix+"_RELOGIO"	))	//-- Relogio Origem da Marcacao

    IF dDataAnt <> ( dDataApo:= (cAliasSP_Qry)->(&(cPrefix+"_DATAAPO"	)) )
		dDataAnt	:= (cAliasSP_Qry)->(&(cPrefix+"_DATAAPO"	)) 	//-- Data do Apontamento
	    cTipoMarc	:= "S" //Para posterior alteracao
	    nSeq		:= 0
	Endif

	//-- Verifica ocorrencia de nao conformidade:
	IF Empty(dDataApo)
		aAdd( aLogDet , STR0033 + cFil + Space(1) + STR0024 + cMat + Space(1) + STR0025 + Dtoc(dDataApo) + Space(1) + STR0034 + Dtoc(dData)  )//"Erro na Data de Apontamento. Filial: "##xxx##"Matricula: "##Data Ap.: ##xx/xx/xx##"Data Marc.: "xx/xx/xx
		lCancela	:= .T.
		Exit
	Endif  
		
	//-- Verifica ocorrencia de nao conformidade:
	IF cTpMcRep <> "D" 
		
			//-- Tipo de Marcacao
		    cTipoMarc := IF(cTipoMarc == "E", "S", "E")
		    
		    IF cTipoMarc == "E"  
			    //----- Gera numero sequencial de jornada
			    nSeq++
		   	 	cSeqJrn		:= Alltrim(Str(nSeq))	
		   	Endif	
		   	cTpMarca	:= cTipoMarc
		   	cSeqMarca	:= cSeqJrn 
    Else
    	cTpMarca	:= cTpMcRep                                 
    	cSeqMarca	:= ""
    Endif

    //-- Consiste informacoes para o registro tipo 02
	IF !fVerReg02(cFil, cMat, dDataApo, dData, cTpMarca, cTipoReg, cMotivRg)
		lCancela	:= .T.
		Exit
	Endif      
    
	//-- DETALHE	
   	TIPO02(cTipoInsc, cCPFCNPJ, cCEI, dData, nHora, cPIS, cREP, cTpMarca, cSeqMarca, cTipoReg, cMotivRg, cIdOrg, cRelogio)


	//-- Variaveis utilizadas para determinar a menor e a maior data de marcacao para cada CNPJ/CPF/CEI lido	          
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
	
	(cAliasSP_Qry)->( dbSkip() )   
	                                                          
    //-- Se a data de apontamento mudou ou chegou no final do arquivo
	IF ( ( dDataAnt <> (  (cAliasSP_Qry)->( &(cPrefix+"_DATAAPO"	) )  ) )  .or. (cAliasSP_Qry)->(Eof())  )
		                                                                                        
		//-- Se a jornada terminou com uma marcacao de entrada  (faltou a saida)
		IF	(cTipoMarc == "E" ) 
			aAdd( aLogDet , STR0023 + cFil + Space(1) + STR0024 + cMat + Space(1) + STR0025 + Dtoc(dDataAnt) )//"Marcacoes impares: Filial: "##xxxxxxx##"Matricula: "##Data Ap.: ##xx/xx/xx
			lCancela	:= .T.
			Exit
		Endif
	   	Loop
	Endif  

End While

IF lQueryOpened
	( cAliasSP_Qry )->( dbCloseArea() )
Endif

RestArea(aArea)

Return (lCancela)	

*/
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³GetMarcOrig  ³ Autor ³Mauricio MR	        ³ Data ³23/10/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Obtem as marcacoes para o periodo informado				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³GetMarcOrig()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso		 ³PONM410	 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/              
Static Function GetMarcOrig(cAliasSP_, cTipoInsc, cCPFCNPJ, cCEI, cPIS, aSp_Fields, nSp_Fields, cFil, cIniData, cFimData, aMarcOri )
Local aArea			:= GetArea()
Local aEmpOri		:= {}
Local nX			:= 0
Local nY			:= 0
Local nLenOri		:= Len(aMarcOri)
Local nEmp			:= 0
Local nOrdem		:= RetOrder( cAliasSP_, cAliasSP_+"_EMPORG+"+cAliasSP_+"_FILORG+"+cAliasSP_+"_MATORG+DTOS("+cAliasSP_+"_DATAAP)+DTOS("+cAliasSP_+"_DATA)+STR("+cAliasSP_+"_HORA,5,2)" )
Local cPrefix		:= ( PrefixoCpo( cAliasSP_ )) 
Local cMat			:= SRA->RA_MAT
Local cSP_Campos	:= ""
Local cSP_Query 	:= ""
Local cSP_Where		:= ""
Local cSP_Ordem 	:= ""
Local cAliasCpo		:= cAliasSP_
Local dDataApo
Local nHora
Local cTipoReg
Local cIdOrg
Local lCancela		:= .F.
Local lEmpAberta	:= .F.

Local dDataAnt		:= Ctod("") 

Local lQueryOpened	:= .F.

For nY := 1 to nLenOri
	If Empty(aEmpOri) .or. ( ( aScan(aEmpOri, {|x| x ==  aMarcOri[nY,01] }) ) == 0 )
		aAdd( aEmpOri , aMarcOri[nY,01] ) //Guarda origem das marcacoes
	EndIf
Next nY

For nEmp := 1 to Len(aEmpOri)

	If (cEmpAnt # aEmpOri[nEmp])
		IF !( fAbrEmpresa(cAliasSP_,nOrdem,aEmpOri[nEmp]) )
			Loop
		EndIF
		lEmpAberta :=  .T.
		cAliasSP_  := "PON"+cAliasSP_
	EndIf

	lQueryOpened  := .T.

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carregando os Campos do RF? na Query						   ³
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
	cSP_Where += " ( "
			
	For nY := 1 to nLenOri
					
		If aMarcOri[nY,01] # aEmpOri[nEmp]
			Loop
		EndIf
		If nY > 1 .and. !(cSP_Where == "% ( ")
			cSP_Where += " OR "
		EndIf
		
		cSP_Where += " ( "
		cSP_Where += cAliasCpo + "."
		cSP_Where += cPrefix+"_EMPORG='" + aMarcOri[nY,01] +"'"
		cSP_Where += " AND "				
		cSP_Where += cAliasCpo + "."
		cSP_Where += cPrefix+"_FILORG='" + aMarcOri[nY,02] +"'"	
		cSP_Where += " AND "				
		cSP_Where += cAliasCpo + "."
		cSP_Where += cPrefix+"_MATORG='" + aMarcOri[nY,03] +"'"
		cSP_Where += " ) "
	
	Next nY
	
	cSP_Where += " ) "
	cSP_Where += " AND "				
	cSP_Where += cAliasCpo + "."
	cSP_Where += cPrefix+"_NATU='0'"	
	cSP_Where += " AND "
	cSP_Where += " ( "
	cSP_Where += cAliasCpo + "."
	cSP_Where += cPrefix+"_DATAAP>='"+cIniData+"'"
	cSP_Where += " AND "
	cSP_Where += cAliasCpo + "."
	cSP_Where += cPrefix+"_DATAAP<='"+cFimData+"'"
	cSP_Where += " ) "
	cSP_Where += "%"

	cSP_Ordem := "%" 		+ 	cAliasCpo + "." 	+ cPrefix	+ "_FILIAL, "	+;
								cAliasCpo + "." 	+ cPrefix	+ "_EMPORG, "	+;   
								cAliasCpo + "." 	+ cPrefix	+ "_FILORG, "	+;								
								cAliasCpo + "." 	+ cPrefix	+ "_MATORG, "	+;
								cAliasCpo + "." 	+ cPrefix 	+ "_DATAAP, "	+;								
								cAliasCpo + "." 	+ cPrefix 	+ "_DATA, "		+;
								cAliasCpo + "." 	+ cPrefix 	+ "_HORA, "		+;								
								cAliasCpo + "." 	+ cPrefix 	+ "_IDORG %"	
	
	cAliasSP_Qry	:= GetNextAlias()

	If lImpAcum
		BeginSql alias cAliasSP_Qry 
			COLUMN RFH_DATAAP	AS DATE
			COLUMN RFH_DATA	 	AS DATE
			SELECT	%exp:cSP_Campos%
			FROM %table:RFH% RFH
			WHERE 
				  %exp:cSP_Where% AND
			      RFH.%notDel%   
			ORDER BY %exp:cSP_Ordem%
		EndSql
	Else
		BeginSql alias cAliasSP_Qry 
			COLUMN RFE_DATAAP	AS DATE
			COLUMN RFE_DATA	 	AS DATE
			SELECT	%exp:cSP_Campos%
			FROM %table:RFE% RFE
			WHERE 
				  %exp:cSP_Where% AND
			      RFE.%notDel%   
			ORDER BY %exp:cSP_Ordem%
		EndSql
	EndIf

	IF !lQueryOpened    
		cAliasSP_Qry := cAliasSP_
		(cAliasSP_Qry)->( dbSeek( aMarcOri[01,01] + aMarcOri[01,02] + aMarcOri[01,03] + cIniData  , .T. ) )
	Endif
	      
	dDataAnt	:= Ctod("") 
	
	While (cAliasSP_Qry)->( !Eof() .and. ;	  
							  (  ;
							  	( &(cPrefix+"_EMPORG") == aEmpOri[nEmp] ) .and. ;
							  	( Dtos(&(cPrefix+"_DATAAP")) <= cFimData ) .and. (  Dtos( &(cPrefix+"_DATAAP") ) >= cIniData ) ;
							  );
							)
		
		If !lQueryOpened
			If ( aScan(aMarcOri, {|x| x[1] + x[2] + x[3] ==  (cAliasSP_Qry)->(&(cPrefix+"_EMPORG")+ &(cPrefix+"_FILORG") + &(cPrefix+"_MATORG")) }) ) == 0
		    	(cAliasSP_Qry)->( dbSkip() )   
				Loop			
			EndIf 
		EndIf
							
	  	//-- somente considera marcacoes de funcionarios  
	    IF (cAliasSP_Qry)->(&(cPrefix+"_NATU"))  <> '0'
	    	(cAliasSP_Qry)->( dbSkip() )   
			Loop
	    Endif	
	
		dData		:= (cAliasSP_Qry)->(&(cPrefix+"_DATA"  )) 	//-- Data da Marcacao
		nHora		:= (cAliasSP_Qry)->(&(cPrefix+"_HORA"  )) 	//-- Hora da Marcacao
		cTipoReg	:= 'O'										//-- Tipo de Registro da Marcacao 
		cREP		:= (cAliasSP_Qry)->(&(cPrefix+"_NUMREP")) 	//-- Numero do REP
		cMotivRg	:= SPACE(100)								//-- Motivo de Registro de Incusao ou Desconsideracao         
		cIdOrg		:= (cAliasSP_Qry)->(&(cPrefix+"_IDORG" ))	//-- Linha/Registro do REP
		cTipoMarc	:= SPACE(01)
		cSeqJrn		:= SPACE(2)
		cRelogio	:= (cAliasSP_Qry)->(&(cPrefix+"_RELOGI"))	//-- Relogio
		dDataApo	:= (cAliasSP_Qry)->(&(cPrefix+"_DATAAP"))
	    
		//-- Verifica ocorrencia de nao conformidade:
		IF Empty(dDataApo)
			aAdd( aLogMarc[4] , STR0033 + cFil + Space(1) + STR0024 + cMat + Space(1) + STR0025 + Dtoc(dDataApo) + Space(1) + STR0034 + Dtoc(dData)  )//"Erro na Data de Apontamento. Filial: "##xxx##"Matricula: "##Data Ap.: ##xx/xx/xx##"Data Marc.: "xx/xx/xx
			lCancela	:= .T.
			Exit
		Endif  
			
		//-- Consiste informacoes para o registro tipo 02
		IF !fVerReg02(cFil, cMat, dDataApo, dData, cTipoMarc, cTipoReg, @cMotivRg)
			lCancela	:= .T.
			Exit
		Endif         
	
		//-- DETALHE	
		IF !TIPO02(cTipoInsc, cCPFCNPJ, cCEI, dData, nHora, cPIS, cREP, cTipoMarc, cSeqJrn, cTipoReg, cMotivRg, cIdOrg, cRelogio, .T.)
			//aAdd( aLogMarc , STR0035) //"Erro de Inconsistencia. Marcacao original ausente do arquivo-fonte Tratado: " 	
			//-- Empresa: XX#Filial: XX#Matricula: 999999#Data Marc: XX/XX/XXXX#Hora Marc: xx.xx#Num.REP: 9999999999999999#NSR/Linha: 99999999
	  		aAdd( aLogMarc[5], 	STR0028 + cEmpAnt + Space(1) + STR0017 + Space(1) + cFil + Space(1) + STR0024 + cMat + Space(1) 	+;
							STR0034 + Dtoc(dData) + Space(1) + STR0036 	+ Alltrim(STR(nHora,2)) 	+ Space(1) + STR0037 	+;
						    cREP + Space(1) + STR0038 + cIdOrg )
				
	
			lCancela	:= .T.
			Exit
		Endif  
		(cAliasSP_Qry)->( dbSkip() )   
	
	End While
	
	IF lQueryOpened
		( cAliasSP_Qry )->( dbCloseArea() )
	Endif
	
	IF ( lEmpAberta )
		fFecEmpresa(cAliasSP_)
		lEmpAberta := .F.
	EndIF	

Next nEmp

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
±±³ Uso		 ³ PONM410  												  ³±±
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
	cCEI			:= space(12-len(alltrim(aInfo[09])))+alltrim(aInfo[09])		//	026	037	012		CEI
Else 
	cTipoInsc		:= Left(cTpIdEmp+Space(01),01) 								//	011	011	001		1 - CPF / 2 - CNPJ
	cCPFCNPJ		:= space(14-len(alltrim(aInfo[08])))+alltrim(aInfo[08])		//	012	025	014		CPF ou CNPJ
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

GravaAFDT(cIdReg, { cTipoInsc , cCPFCNPJ , cCEI , cRazaoouNome, cDataIni, cDataFim } )      

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³TIPO02	³ Autor ³ Mauricio MR		    ³ Data ³ 20/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta registro Tipo "2"									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³            												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ PONM410  												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/

Static Function TIPO02(cTipoInsc, cCPFCNPJ, cCEI, dData, nHora, cPis, cREP, cTpMcREP, cSeqJrn, cTipoReg, cMotivRg, cIdOrg, cRelogio, lCheck)

Local cIdReg    	:= ""
Local cDataMarc		:= ""
Local cHoraMarc		:= ""  
Local lRet			:= .T. 

DEFAULT lCheck	:= .F.

cIdReg		:= "2"										 							//  010 010 001    	Tipo do registro 
cDataMarc	:= Transforma(dData)													//	011	018	008		Data da Marcacao
cHoraMarc  	:= StrZero(Int(nHora),2) + StrZero(( nHora-Int(nHora)) *100,2)	   		//	019	022	004		Hora da Marcacao
cPIS		:= Left( Replicate("0", 12 - Len( AllTrim( cPis ))) + cPis,	12	)					//	023	034	012		PIS	
cREP		:= IF( Empty( Val( cREP ) ), PAD(Alltrim(cREP)	,17,"0"	),cREP)			//	035	051	017		REP	
cTpMcREP	:= Left( cTpMcREP 	+ Space(01),	01	)								//  052	052	001		Tipo de Marcacao 'E' para Entrada 'S' para Saida ou 'D' para desconsiderada
cSeqJrn		:= Left( cSeqJrn 	+ Space(02),	02	)								//  053	054	002		Numero Sequencial da E/S da Jornada
cTipoReg	:= Left( cTipoReg 	+ Space(01),	01	)								//  055	055	001		Tipo de registro 'O' original, 'I' incluido digitacao ou 'P' pre-assinalado
cMotivRg	:= Left( cMotivRg 	+ Space(100),	100	)								//  056	155	100		Motivo qdo tipo de Marcacao for 'D' ou Tipo de registro for 'I'
cRelogio	:= Left( cRelogio 	+ Space(2)	,	02	)								//  				Relogio da Origem

lRet:= GravaAFDT(cIdReg, { cTipoInsc, cCPFCNPJ, cCEI, dData, cDataMarc, cHoraMarc, cPIS, cREP, cTpMcREP, cSeqJrn, cTipoReg, cMotivRg, cIdOrg, cRelogio }, lCheck)      

Return( lRet )
              
 /*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GravaAFDT³ Autor ³ Mauricio MR	        ³ Data ³ 21/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava os dados no arquivo temporario                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ GravaAFDT(aLinha)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³  						                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PONM410()                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function GravaAFDT(	cTipo		,;
							aCampos  	,;//		"1" - { cTipoInsc, cCPFCNPJ, cCEI, cRazaoouNome, cDataIni, cDataFim }
						    lCheck       ;// 		"2" - { cTipoInsc, cCPFCNPJ, cCEI, dData, cDataMarc, cHoraMarc, cPIS, cREP, cTpMcREP, cSeqJrn, cTipoReg, cMotivRg, cIdOrg }
						 ) 
Local cSeek		:=	""
Local lFound  
Local lRet		:= .T.
Local aOldAlias := GetArea()                
Local cAFDTTableName
Local cSql 
Local cAliasQry := GetNextAlias() 
DEFAULT lCheck	:= .F.    //Nao verifica regra de checagem conforme o tipo de registro

// cTipo: 	 
//        		'01'-Cabecalho Informacoes da Empresa
//				'02'-Detalhe Marcacoes do Ponto
//              '09'-Trailer

dbSelectArea("AFDT")             

If cTipo $ "1"		// FDT_TINSC+FDT_INSC+FDT_CEI+FDT_TIPO			
	//{ cTipoInsc, cCPFCNPJ, cCEI, cRazaoouNome, cDataIni, cDataFim }
	cSeek := aCampos[1] + aCampos[2] + aCampos[3] + '1' 
						//      01           02         03           '02'      07          04          06        13
Elseif cTipo $ "2"		// "FDT_TINSC + FDT_INSC + FDT_CEI + FDT_TIPO + FDT_PIS + Dtos(FDT_DATA) + FDT_HORA + FDT_RELO + FDT_ID"
   						//{  cTipoInsc	,; 01
   						//	 cCPFCNPJ	,; 02
   						//	 cCEI		,; 03
						//	 dData    	,; 04
   						//	 cDataMarc	,; 05
   						//	 cHoraMarc	,; 06
   						//	 cPIS		,; 07
   						//	 cREP		,; 08
   						//	 cTpMcREP	,; 09
   						//	 cSeqJrn	,; 10
   						//	 cTipoReg	,; 11
   						//	 cMotivRg	,; 12
   						//	 cIdOrg 	   13
   						// }
/*   	cInd:= "FDT_TINSC + FDT_INSC + FDT_CEI + FDT_TIPO + FDT_PIS + Dtos(FDT_DATA) + FDT_HORA + FDT_RELO + FDT_ID"					*/
    If lCheck
    	cSeek 	:= aCampos[1] + aCampos[2] + aCampos[3] + '2' + aCampos[7] + Dtos(aCampos[4]) + aCampos[6]  +  aCampos[14] + IIF(aCampos[13] <> NIL, aCampos[13] , "")  
	EndIf
EndIf 
 
If !lCheck .and. cTipo $ '2'
	lFound = .F.
Else
//	lFound	:= AFDT->(MsSeek(cSeek))
	
	cAFDTTableName := oTmpAFDT:GetRealName()
	
	If cTipo $ "1"
		cSQL := " SELECT * FROM " + cAFDTTableName
		cSql += " WHERE  "
		cSql += " D_E_L_E_T_ = ' ' and "
		cSql += " FDT_TINSC = '" + aCampos[1]+ "' and "
		cSql += " FDT_INSC  = '" + aCampos[2]+ "' and "
		cSql += " FDT_CEI   = '" + aCampos[3]+ "' and "
		cSql += " FDT_TIPO  = '1'                     "
	EndIf
	
	If cTipo $ "2" .And. lCheck			
    
		cSQL := " SELECT * FROM " + cAFDTTableName
		cSql += " WHERE  "
		cSql += " D_E_L_E_T_ = ' ' and "
		cSql += " FDT_TINSC = '" + aCampos[1]+ "' and "
		cSql += " FDT_INSC  = '" + aCampos[2]+ "' and "
		cSql += " FDT_CEI   = '" + aCampos[3]+ "' and "
		cSql += " FDT_TIPO  = '2'                 and "
		cSql += " FDT_PIS   = '" + aCampos[7] + "' and "
		cSql += " FDT_DATA  = '" + dtos(aCampos[4]) + "' and "
		cSql += " FDT_HORA  = '" + aCampos[6]+ "' and "
		cSql += " FDT_RELO  = '" + aCampos[14]+ "' and "
					
		IF aCampos[13] <> NIL
			cSql += " FDT_ID    = '" + aCampos[13] + "'  "
		Else
			cSql += " FDT_ID    = ''  "
		EndIf 
	
	EndIf
						
	//COM EMBEDED  NAO FUNCIONA A CONSULTA NA TABELA TEMPORARIA ...POR ISTO USAMOS DBUSEAREA 				
	DbUseArea( .T.,"TOPCONN",TCGenQry(,,ChangeQuery(cSQL)),cAliasQry,.F.,.T. )	
	
	lFound := .F.	
	If (cAliasQry)->(!Eof())
		lFound := .T.	
		AFDT->( DbGoTo(   (cAliasQry)->(R_E_C_N_O_)     )  )
	Else
		dbSelectArea("AFDT")
	EndIf
				
	(cAliasQry)->(DbCloseArea())
		
EndIf

If lfound
	cSeek:=cSeek
endif

//-- Se a marcacao no RFE inexiste nas tabelas de marcacoes ocorreu alguma inconsistencia, aborta o processo.		
IF cTipo $ "2" .and. lCheck .and. (!lFound)
   lRet	:= .F.
Elseif !lCheck
	AFDT->( RecLock("AFDT", !lFound ) )
	
		AFDT->FDT_TINSC		:= aCampos[1] // cTipoInsc
		AFDT->FDT_INSC 		:= aCampos[2] // cCPFCNPJ
		AFDT->FDT_CEI  		:= aCampos[3] // cCEI
		AFDT->FDT_TIPO  	:= cTipo
		
		If cTipo $ "1" //Cabecalho  
			AFDT->FDT_TEXTO 	:= 	cTipo 		+;
									aCampos[1] 	+; // cTipoInsc
									aCampos[2] 	+; // cCPFCNPJ
									aCampos[3] 	+; // cCEI
									Padr(aCampos[4],150) 	+; // cRazaoouNome	
									aCampos[5] 	+; // cDataIni
									aCampos[6] 	   // cDataFim
	
		
		ElseIf cTipo $ "2" //Trailer
		
			AFDT->FDT_PIS  		:=  aCampos[7] 
			AFDT->FDT_DATA 		:=  aCampos[4] 
			AFDT->FDT_HORA 		:=  aCampos[6] 
			AFDT->FDT_ID 		:=  aCampos[13] 			
			AFDT->FDT_RELO 		:=  aCampos[14] 
			AFDT->FDT_TEXTO 	:= 	cTipo 		+;
									aCampos[5] 	+; // cDataMarc
									aCampos[6] 	+; // cHoraMarc
									aCampos[7] 	+; // cPIS
									aCampos[8] 	+; // cREP	
									aCampos[9] 	+; // cTpMcREP
									aCampos[10]	+; // cSeqJrn
									aCampos[11]	+; // cTipoReg
									ALLTRIM(aCampos[12])    // cMotivRg
			AFDT->FDT_EMFIMA  	:= 	cEmpAnt+SRA->RA_FILIAL+SRA->RA_MAT    
			
		Endif
	
	AFDT->( MsUnlock() )
Endif
		                                         
RestArea(aOldAlias)	

Return( lRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FGeraArq     ³ Autor ³ Mauricio MR      ³ Data ³ 21/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao que gera arquivo                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FGeraArq()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PONM410                                                   ³±±
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
Local cLocFile		:= Alltrim(cFile)
Local cArqtmp		:= GetNextAlias() 
Local cAliasQry := GetNextAlias()    
Local cAFDTTableName := oTmpAFDT:GetRealName()
Local cSql 	
// Gera arquivo
cFile	:= Upper(GetPvProfString( GetEnvServer() , "StartPath" , "" , GetAdv97() ) ) //( __RelDir + "AFDT" )
cFile	:=	Alltrim(cFile + cArqtmp)

nHandle := 	MSFCREATE(cFile)

If FERROR() # 0 .Or. nHandle < 0
	Aviso( STR0004,STR0026, { "Ok" },,STR0006 ) //Atencao###"Erro ao criar o arquivo"
	FClose(nHandle)
	Return (.F.)
EndIf

// Arquivo com todos os tipos
AFDT->(dbGoTop())

cData	:= Transforma( MsDate() )
cHora	:= STRZERO( Val( Substr( cHora, 1, 3) ),2) + STRZERO( Val( Substr( cHora, 4, 2 ) ),2 )

While AFDT->(!Eof())
    
    nSequencial ++                        
    cSequencial := STRZERO(nSequencial,9) 
   	     
	// Gravar o Header do arquivo
	If AFDT->FDT_TIPO == "1"  
	    nRecno	:= AFDT->(Recno())
	    
	    cSQL := " SELECT * FROM " + cAFDTTableName
		cSql += " WHERE  "
		cSql += " D_E_L_E_T_ = ' ' and "
		cSql += " FDT_TINSC = '" + AFDT->FDT_TINSC + "' and "
		cSql += " FDT_INSC  = '" + AFDT->FDT_INSC + "' and "
		cSql += " FDT_CEI   = '" + AFDT->FDT_CEI + "' and "
		cSql += " FDT_TIPO  = '2'                  "
							
		//COM EMBEDED  NAO FUNCIONA A CONSULTA NA TABELA TEMPORARIA ...POR ISTO USAMOS DBUSEAREA 				
		DbUseArea( .T.,"TOPCONN",TCGenQry(,,ChangeQuery(cSQL)),cAliasQry,.F.,.T. )	
			
		If (cAliasQry)->(Eof())
		
			dbSelectArea("AFDT")
			cIncricao	:= AFDT->FDT_INSC  
		    lRet:= .F.
		    (cAliasQry)->(DbCloseArea())
		    Exit
		Else
		
			dbSelectArea("AFDT")
			(cAliasQry)->(DbCloseArea())
		EndIf
		
		cGrava		:= Substr(cSequencial  + AFDT->FDT_TEXTO,1,203) 
		cGrava		+= cData + cHora 
		cGrava		:= Substr(cGrava,1,215)+ CHR(13)+CHR(10)
		FWrite(nHandle,cGrava)
		
		
		
	ElseIF AFDT->FDT_TIPO == "2"  
	
		cGrava		:= cSequencial  + AFDT->FDT_TEXTO 
		cGrava		:= Substr(cGrava,1,155)+ CHR(13)+CHR(10)
		FWrite(nHandle,cGrava)
	EndIf	
	
	AFDT->(dbSkip())
EndDo 

//Arquivo vazio
If (nSequencial == 0)
	Return (.F.)
EndIf

nSequencial ++                        
cSequencial := STRZERO(nSequencial,9)                 
cGrava		:= cSequencial + "9"+CHR(13)+CHR(10)
FWrite(nHandle,cGrava)

FClose(nHandle)

If !( __CopyFile( cFile , cLocFile ) )
	Aviso( STR0004,STR0026, { "Ok" },,STR0006 ) //Atencao###"Erro ao criar o arquivo"
	fErase( cFile )
	Return (.F.)
EndIf

fErase( cFile )

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
±±³Fun‡…o	 ³ FGETAFDT ³ Autor ³ Mauricio MR			³ Data ³ 20/10/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Permite que o usuario decida onde sera criado o arquivo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PNM410 													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function FGETAFDT()
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
		cFile := cGetFile("Arquivo AFDT | AFDT.*", OemToAnsi(STR0031))  //"Selecione Diretorio"
	EndIf
		 				 
	If Empty(cFile)
		Return .F.
	EndIf

	If "."$cFile
		cFile := Substr(cFile,1,rat(".", cfile)-1)
	EndIf


	If ! "AFDT" $ UPPER(cFile)
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
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fAbrEmpresa	  ³ Autor ³Leandro Drumond        ³ Data ³28/12/2009³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Abre o Arquivo da Outra Empresa                        			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ cAlias - Alias do Arquivo a Ser Aberto							³
³          ³ nOrdem - Ordem do Indice              							³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fAbrEmpresa(cAlias,nOrdem,cEmpPara)

Local cModo
Local lRet
Local cSvEmpAnt := cEmpAnt

cEmpAnt := cEmpPara

IF ( lRet := MyEmpOpenFile("PON"+cAlias,cAlias,nOrdem,.t.,cEmpPara,@cModo) )
	dbSelectArea( "PON"+cAlias )
EndIF

cEmpAnt := cSvEmpAnt
 
Return( lRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³MyEmpOpenFile ³ Autor ³Leandro Drumond        ³ Data ³11/01/2010³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Abre Arquivo de Outra Empresa                         			³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³x1 - Alias com o Qual o Arquivo Sera Aberto                  	³
³          ³x2 - Alias do Arquivo Para Pesquisa e Comparacao                ³
³          ³x3 - Ordem do Arquivo a Ser Aberto                              ³
³          ³x4 - .T. Abre e .F. Fecha                                       ³
³          ³x5 - Empresa                                                    ³
³          ³x6 - Modo de Acesso (Passar por Referencia)                     ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function MyEmpOpenFile(x1,x2,x3,x4,x5,x6)
Local cSavE := cEmpAnt, cSavF := cFilAnt, xRet
xRet	:= EmpOpenFile(@x1,@x2,@x3,@x4,@x5,@x6)
cEmpAnt := cSavE
cFilAnt := cSavF

Return( xRet )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³fFecEmpresa	  ³ Autor ³Leandro Drumond        ³ Data ³28/12/2009³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Fecha o Arquivo da Outra Empresa                        		³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³ cAlias - Alias do Arquivo a Ser Fechado						³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function fFecEmpresa( cAlias )

IF Select("PON"+cAlias) > 0
	("PON"+cAlias)->(dbCloseArea())
EndIF

Return( .T. )

Function fMagProxVer() 
Local cMsg := ''

cMsg := "Funcionalidade estará disponível na próxima atualização."
MsgInfo( OemToAnsi( cMsg ) , OemToAnsi( STR0004 ) )	//  'Aten‡„o!'

Return .T.
