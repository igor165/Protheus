
#INCLUDE "PlsR245.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"

Static objCENFUNLGP := CENFUNLGP():New()
Static lAutoSt	:= .F.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ PLSR245 ³ Autor ³ Rafael M. Qudrotti     ³ Data ³ 03.02.04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Impressao do extrato de utilizacao do titulo...       	   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ PLSR245                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Advanced Protheus                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Alteracoes desde sua construcao inicial                                ³±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Alteracoes ³ Data     ³Motivo                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define nome da funcao                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Function PLSR245(	cmv_par01, cmv_par02, cmv_par03, cmv_par04, cmv_par05, cmv_par06,;
					cmv_par07, cmv_par08, cmv_par09, cmv_par10, cmv_par11, cmv_par12,;
					cmv_par13, cmv_par14, cmv_par15, cmv_par16, cmv_par17, cmv_par18,;
					cmv_par19 )
					
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis padroes para todos os relatorios...                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE nQtdLin     := 60
PRIVATE cTamanho    := "G"
PRIVATE cTitulo     := STR0001 //"Emissao dos boletos de cobranca"
PRIVATE cDesc1      := STR0002 //"Emissao dos boletos de cobranca de acordo com os parametros selecionados."
PRIVATE cDesc2      := ""
PRIVATE cDesc3      := ""
PRIVATE cAlias      := "SE1"
PRIVATE cPerg       := "PLR245"
PRIVATE cRel        := "PLSR245"
PRIVATE nli         := 80
PRIVATE m_pag       := 1
PRIVATE lCompres    := .F.
PRIVATE lDicion     := .F.
PRIVATE lFiltro     := .T.
PRIVATE lCrystal    := .F.
PRIVATE aOrderns    := {}
PRIVATE aReturn     := { "", 1,"", 1, 1, 1, "",1 }
PRIVATE lAbortPrint := .F.

if !lAutoSt .AND. !objCENFUNLGP:getPermPessoais()
	objCENFUNLGP:msgNoPermissions()
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Testa ambiente do relatorio somente top...                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !PLSRelTop()
	Return .F.
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Chama SetPrint (padrao)                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cmv_par01 # Nil
	cPerg := ""
	mv_par01 := cmv_par01
	mv_par02 := cmv_par02
	mv_par03 := cmv_par03
	mv_par04 := cmv_par04
	mv_par05 := cmv_par05
	mv_par06 := cmv_par06
	mv_par07 := cmv_par07
	mv_par08 := cmv_par08
	mv_par09 := cmv_par09
	mv_par10 := cmv_par10
	mv_par11 := cmv_par11
	mv_par12 := cmv_par12
	mv_par13 := cmv_par13
	mv_par14 := cmv_par14
	mv_par15 := cmv_par15
	mv_par16 := cmv_par16
	mv_par17 := cmv_par17
	mv_par18 := cmv_par18
	mv_par19 := cmv_par19
	
Else
	Pergunte(cPerg,.F.)
Endif

if !lAutoSt
	cRel := SetPrint(	cAlias		,cRel		,cPerg		,@cTitulo	,;
					cDesc1		,cDesc2		,cDesc3		,lDicion	,;
					aOrderns	,lCompres	,cTamanho	,{}			,;
					lFiltro		,lCrystal)
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi cancelada a operacao (padrao)                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoSt .AND. nLastKey  == 27
	Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         				³
//³ mv_par01 // Cliente de                                       				³
//³ mv_par02 // Loja ate                                        				³
//³ mv_par03 // Cliente ate                                      				³
//³ mv_par04 // Loja                                            				³
//³ mv_par05 // Operadora de                                     				³
//³ mv_par06 // Operadora ate                                    				³
//³ mv_par07 // Empresa de                                       				³
//³ mv_par08 // Empresa ate                                      				³
//³ mv_par09 // Contrato de                                      				³
//³ mv_par10 // Contrato ate                                     				³
//³ mv_par11 // Sub-Contrato de                                  				³
//³ mv_par12 // Sub-Contrato ate                                                ³
//³ mv_par13 // Matricula De                                       				³
//³ mv_par14 // Matricula Ate                                                   ³
//³ mv_par15 // Mes de                                          				³
//³ mv_par16 // Ano de                                           				³
//³ mv_par17 // Mes Ate                                         				³
//³ mv_par18 // Ano Ate                                          				³
//³ mv_par19 // Detalha Cobranca - Por Usuario/Por Tipo Cobranca                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Configura impressora (padrao)                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoSt
	SetDefault(aReturn,cAlias)
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Emite relat¢rio                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoSt
	MsAguarde({|| R245Imp() }, cTitulo, "", .T.)
else
	R245Imp()
endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da rotina                                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R245Imp  ³ Autor ³ Rafael M. Quadrotti   ³ Data ³ 14.06.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime detalhe do relatorio...                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/
Static Function R245Imp()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define variaveis...                                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cSQL			:= ""							// Select deste relatorio
LOCAL cSE1Name 		:= SE1->(RetSQLName("SE1"))	// Retorna o nome do alias no TOP
Local cPrefixo 		:= ""							// Prefixo do titulo
Local cTitulo 		:= ""							// Titulo
Local cParcela 		:= ""							// Parcela do titulo
Local cTipo 		:= ""							// E1_TIPO
Local aDadosEmp		:= {}							// Array com os dados da empresa.
Local aDadosTit		:= {}							// Array com os dados do titulo			
Local aDadosBanco   := {}							// Array com os dados do banco
Local aDatSacado	:= {}							// Array com os dados do Sacado.
Local aBmp			:= { "" }						// Vetor para Bmp.
Local cOperadora    := BX4->(PLSINTPAD())			// Retorna a operadora do usuario.
Local aBfq			:= {}
Local aDependentes	:= {}							// Array com os dependentes do sacado.
Local aOpenMonth	:= {}							// Array com os meses em aberto.
Local aObservacoes  := {}							// Array com as observacoes do extrato.
Local aMsgBoleto    := {}							// Array com as mensagens do boleto.
Local cCart		    := ""							// Carteira do titulo
Local cSA6Key		:= ""							// Chave de pesquisa do SA6 Cadastro de bancos,
Local aCobranca		:= {}
Local aCodBar		:= {}							// Variavel com os dados do codigo de barras.
Local cUsuAnt       := ""
Local lNome			:= .T.
SE1->(DbSetOrder(1))


oPrint:= TMSPrinter():New( STR0003 ) //"Boleto Laser"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se as configuracoes de impressora foram definidas para ³
//³que o objeto possa ser trabalhado.                              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoSt .and. !(oPrint:IsPrinterActive())
     Aviso(STR0041,STR0042,{"OK"})   //"Impressora"###"As configurações da impressora não foram encontradas. Por favor, verifique as configurações para utilizar este relatório. "
     oPrint:Setup()
     Return (.F.)
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT * FROM "+cSE1Name+" WHERE E1_FILIAL = '" + xFilial("SE1") + "' AND "
cSQL += 	"E1_CLIENTE + E1_LOJA >= '"+mv_par01+mv_par02+"' AND "
cSQL += 	"E1_CLIENTE + E1_LOJA <= '"+mv_par03+mv_par04+"' AND "
cSQL += 	"E1_CODINT >= '"+mv_par05+"' AND E1_CODINT <= '"+mv_par06+"' AND "
cSQL += 	"E1_CODEMP >= '"+mv_par07+"' AND E1_CODEMP <= '"+mv_par08+"' AND "
cSQL += 	"E1_CONEMP >= '"+mv_par09+"' AND E1_CONEMP <= '"+mv_par10+"' AND "
cSQL += 	"E1_SUBCON >= '"+mv_par11+"' AND E1_SUBCON <= '"+mv_par12+"' AND "
cSQL += 	"E1_MATRIC >= '"+mv_par13+"' AND E1_MATRIC <= '"+mv_par14+"' AND "
cSQL += 	"E1_ANOBASE + E1_MESBASE >= '"+mv_par16+mv_par15+"' AND "
cSQL += 	"E1_ANOBASE + E1_MESBASE <= '"+mv_par18+mv_par17+"' AND E1_SALDO > 0 AND "
cSQL += 	"E1_PARCELA <> '" + StrZero(0, Len(SE1->E1_PARCELA)) + "' AND " 
cSQL += 	"E1_SITUACA <> '0' AND "

If ! Empty(aReturn[7])
	cSQL += PLSParSQL(aReturn[7]) + " AND "
Endif
cSQL += cSE1Name+".D_E_L_E_T_ = '' "
cSQL += "ORDER BY " + SE1->(IndexKey())

PLSQuery(cSQL,"R245Imp")

If !lAutoSt .AND. R245Imp->(Eof())
	R245Imp->(DbCloseArea())
	Help("",1,"RECNO")
	Return
Endif

if !lAutoSt
	oPrint:SetPortrait() // ou SetLandscape()
	oPrint:StartPage()   // Inicia uma nova página

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exibe mensagem...                                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsProcTxt(PLSTR0001)//#include "PLSMGER.CH"
endif

BA0->(DbSeek(xFilial("BA0") + cOperadora))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicio da impressao dos detalhes...                                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SE1->(DbSetOrder(1))
BM1->(DbSetOrder(4))
BA1->(DbSetOrder(2))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Busca Bmp da empresa.³// Logo
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lAutoSt .AND. File("lgrl" + SM0->M0_CODIGO + SM0->M0_CODFIL + ".Bmp")
	aBMP := { "lgrl" + SM0->M0_CODIGO + SM0->M0_CODFIL + ".Bmp" }
ElseIf !lAutoSt .AND. File("lgrl" + SM0->M0_CODIGO + ".Bmp")
	aBMP := { "lgrl" + SM0->M0_CODIGO + ".Bmp" }
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicia laco para a impressao  dos boletos.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

While ! R245Imp->(Eof())
	aCobranca	:= {}
	cPrefixo 	:= R245Imp->E1_PREFIXO
	cTitulo 	:= R245Imp->E1_NUM
	cParcela 	:= R245Imp->E1_PARCELA
	cTipo 		:= R245Imp->E1_TIPO
	
	BM1->(DbSeek(xFilial("BM1") + cPrefixo + cTitulo + cParcela + cTipo))
	BA3->(DbSeek(xFilial("BA3") + BM1->BM1_CODINT + BM1->BM1_CODEMP + BM1->BM1_MATRIC))
	
	aDependentes := {}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Em caso de pessoa juridica, nao emite os dependentes.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BA3->BA3_TIPOUS == '1' //Pessoa Fisica
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca de dependentes para impressao dos dados.³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		DbSelectArea("BA1")
		If DbSeek(xFilial("BA1") + BM1->BM1_CODINT + BM1->BM1_CODEMP + BM1->BM1_MATRIC)
			
			While 	(!EOF() .And.;
					xFilial("BA1")  == BA1->BA1_FILIAL .And.;
					BA1->BA1_CODINT == BM1->BM1_CODINT .And.;
					BA1->BA1_CODEMP == BM1->BM1_CODEMP .And.;
					BA1->BA1_MATRIC == BM1->BM1_MATRIC)
					
					
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Identifica os usuarios que fazem parte do titulo posicionado. ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If 	(SubStr(DtoS(BA1->BA1_DATINC),1,6) <= R245Imp->E1_ANOBASE+R245Imp->E1_MESBASE) .and. ;
						(Empty(BA1->BA1_MOTBLO))
					
						Aadd(aDependentes, {BA1->BA1_TIPREG,BA1->BA1_NOMUSR})
					EndIf	
						
				DbSkip()
			End
		EndIf
	EndIf
	DbSelectArea("R245Imp")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna os meses em aberto do sacado.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aOpenMonth:=PLR245MES(R245Imp->E1_CLIENTE,R245Imp->E1_LOJA,R245Imp->E1_MESBASE,R245Imp->E1_ANOBASE)
	
	lImpBM1 := .F.
	
	While 	!BM1->(Eof()) 					.And.;
			BM1->BM1_PREFIX = cPrefixo 		.And.;
			BM1->BM1_NUMTIT = cTitulo 		.And.;
			BM1->BM1_PARCEL = cParcela 		.And.;
			BM1->BM1_TIPTIT = cTipo           
			
            If BM1->BM1_CODTIP $ "127,116,104,117,120,121,122,123,124,125"			
               lImpBM1 := .F.
            Else
               lImpBM1 := .T.   
            Endif   
		
			If BM1->BM1_CODINT+BM1->BM1_CODEMP+BM1->BM1_MATRIC+BM1->BM1_TIPREG == cUsuAnt
				lNome := .F.
			Else
			    cUsuAnt := BM1->BM1_CODINT+BM1->BM1_CODEMP+BM1->BM1_MATRIC+BM1->BM1_TIPREG
			    lNome:= .T.
			EndIf
			
			If lImpBM1
 			  Aadd(aCobranca,{	Iif(lNome,BM1->BM1_NOMUSR,""),;
		  						"",;
		  						"",;
		  						"",;
		  						BM1->BM1_CODTIP,;
		  						BM1->BM1_DESTIP,;
		  						Iif(BM1->BM1_CODTIP $ "104;116;120;121;123;124","",BM1->BM1_VALOR),;
		  						""})
		     Endif
		    
		    
		    If BM1->BM1_CODTIP $ "104;116;120;121;123;124"		
			
				DbSelectArea("BD6")
				DbSetOrder(5)
				If MsSeek(xFilial("BD6")+BM1->BM1_CODINT+BM1->BM1_CODEMP+BM1->BM1_MATRIC+BM1->BM1_TIPREG)
					While 	!EOF() 					 				.AND.;
							 BM1->BM1_CODINT == BD6->BD6_OPEUSR 	.AND.;
							 BM1->BM1_CODEMP == BD6->BD6_CODEMP		.AND.;
							 BM1->BM1_MATRIC == BD6->BD6_MATRIC		.AND.;
							 BM1->BM1_TIPREG == BD6->BD6_TIPREG
					
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Efetua laco no BD6 para selecionar os dados do extrato.³
						//³Armazena IDUSR para posterior ordenacao por este campo.³
						//³                                                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		   				If 	BD6->BD6_VLRTPF > 0 					.AND.;
		   			 		BD6->BD6_ANOPAG = IF(R245Imp->E1_MESBASE=="01",StrZero(Val(R245Imp->E1_ANOBASE)-1,4),R245Imp->E1_ANOBASE) .AND.;
		   			 		BD6->BD6_MESPAG = IF(R245Imp->E1_MESBASE=="01","12",StrZero((Val(R245Imp->E1_MESBASE)-1),2))
		    		    
		    				Aadd(aCobranca,{	"",;
		    									BD6->BD6_NOMRDA,;
		    									BD6->BD6_DATPRO,;
		    									BD6->BD6_NUMERO,;
		    									BD6->BD6_CODPRO,;
		    									BD6->BD6_DESPRO,;
		    									BD6->BD6_VLRTPF,;
		    									BD6->BD6_IDUSR})
		    				
		    			EndIf
		    	
		    		BD6->(DbSkip())
		   			End
		    	EndIf
	    	EndIf
		BM1->(DbSkip())
	End
	
	aBfq := RetornaBfq(R245Imp->E1_CODINT, "199")
	If R245Imp->E1_IRRF > 0
		Aadd(aCobranca,{	"",;
		    				"",;
		    				ctod(""),;
		    				"",;
		    				"",;
		    				"",;
		    				0,;
		    				""})

		Aadd(aCobranca,{	"",;
		    				"",;
		    				ctod(""),;
		    				"",;
		    				aBfq[1],;
		    				AllTrim(aBfq[3])+" (-) ",;
		    				R245Imp->E1_IRRF,;
		    				""})

	Endif
	
	aDadosEmp	:= {	BA0->BA0_NOMINT                                                           	,; //Nome da Empresa
						BA0->BA0_END                                                              	,; //Endereço
						AllTrim(BA0->BA0_BAIRRO)+", "+AllTrim(BA0->BA0_CIDADE)+", "+BA0->BA0_EST 	,; //Complemento
						STR0045+Subs(BA0->BA0_CEP,1,5)+"-"+Subs(BA0->BA0_CEP,6,3)             		,; //CEP //"CEP: "
						STR0046+BA0->BA0_TELEF1                                           		,; //Telefones //"PABX/FAX: "
						STR0047+Subs(BA0->BA0_CGC,1,2)+"."+Subs(BA0->BA0_CGC,3,3)+"."+; //"CNPJ.: "
						Subs(BA0->BA0_CGC,6,3)+"/"+Subs(BA0->BA0_CGC,9,4)+"-"+;
						Subs(BA0->BA0_CGC,13,2)                                                    	,; //CGC
						STR0043 + BA0->BA0_SUSEP }  //I.E //"ANS : "
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega mensagens para boleto.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aObservacoes := PLR245TEXT(2					,R245Imp->E1_CODINT	,R245Imp->E1_CODEMP,R245Imp->E1_CONEMP	,;
	R245Imp->E1_SUBCON	,R245Imp->E1_MATRIC ,R245Imp->E1_ANOBASE+R245Imp->E1_MESBASE)
	
	
	aMsgBoleto   := PLR245TEXT(1					,R245Imp->E1_CODINT	,R245Imp->E1_CODEMP,R245Imp->E1_CONEMP	,;
	R245Imp->E1_SUBCON	,R245Imp->E1_MATRIC ,R245Imp->E1_ANOBASE+R245Imp->E1_MESBASE)
	
	
	SA1->(DbSeek(xFilial("SA1") + R245Imp->E1_CLIENTE + R245Imp->E1_LOJA))
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso nao exita o banco e agencia no SE1 busca informacoes do SEA.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ((Empty(R245Imp->E1_PORTADO) .OR. Empty(R245Imp->E1_AGEDEP)) .AND. !Empty(R245Imp->E1_NUMBOR) )
		SEA->(DbSeek(xFilial("SEA")+R245Imp->E1_NUMBOR+ cPrefixo + cTitulo + cParcela + cTipo      ))
	    cSA6Key:=SEA->EA_PORTADO+SEA->EA_AGEDEP+SEA->EA_NUMCON
	ElseIf !Empty(R245Imp->E1_PORTADO) .AND. !Empty(R245Imp->E1_AGEDEP)
		cSA6Key:=R245Imp->E1_PORTADO+R245Imp->E1_AGEDEP+R245Imp->E1_CONTA
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados para codigo de barras³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SA6")
	DbSetOrder(1)
	DbSeek(xFilial()+cSA6Key,.T.)
	
	DbSelectArea("R245Imp")
	aDadosBanco  := {	SA6->A6_COD                                          	,;  //Numero do Banco
						SA6->A6_NREDUZ                                       	,;  //Nome do Banco
						SA6->A6_AGENCIA					                       	,;  //Agencia
						Subs(SA6->A6_NUMCON,1,AT("-",SA6->A6_NUMCON)-1)		,; 	//Conta Corrente
						Subs(SA6->A6_NUMCON,AT("-",SA6->A6_NUMCON)+1)  		}   //Dígito da conta corrente
						
	
	If Subs(aDadosBanco[1],1,3) == '001' //Banco do Brasil
		cCart := '18'
	ElseIf Subs(aDadosBanco[1],1,3) == '104' //CEF
		cCart := '82' 
	EndIf	
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados do Titulo³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDadosTit   :=  {	AllTrim(E1_NUM)+AllTrim(E1_PARCELA),; 	//Numero do título
						E1_EMISSAO,;             				//Data da emissão do título
						dDataBase,;             				//Data da emissão do boleto
						E1_VENCTO,;             				//Data do vencimento
						E1_SALDO - E1_IRRF,;					//Valor do título
						E1_NUMBCO }								//Nosso numero (Ver fórmula para calculo)
						
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Retorna o codigo de barras para impressao.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCodBar := Plr245Bar(E1_SALDO - E1_IRRF,SubStr(SM0->M0_CGC,1,8),cPrefixo,cTitulo,E1_NUMBCO)
	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Dados Sacado   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDatSacado   := {	AllTrim(SA1->A1_NOME)								,;      //Razão Social
						AllTrim(SA1->A1_COD )                            	,;      //Código
						AllTrim(SA1->A1_END )+"-"+SA1->A1_BAIRRO         	,;      //Endereço
						AllTrim(SA1->A1_MUN )                            	,;      //Cidade
						SA1->A1_EST                                      	,;      //Estado
						SA1->A1_CEP                                      }   	    //CEP
						
	R245Graf(	aCobranca	,R245Imp->E1_SDDECRE		,R245Imp->E1_SDACRES	,oPrint			,;
				aBMP		,aDadosEmp					,aDadosTit				,aDadosBanco	,;
				aDatSacado	,aMsgBoleto					,aCodBar				,aOpenMonth		,;
				aDependentes,aObservacoes				,cCart 					,cPrefixo		,;
				cTitulo		,R245Imp->E1_CODEMP			,R245Imp->E1_MATRIC)
				
	R245Imp->(DbSkip())
End

//Ú--------------------------------------------------------------------¿
//| Fecha arquivo...                                                   |
//À--------------------------------------------------------------------Ù
R245Imp->(DbCloseArea())
//Ú--------------------------------------------------------------------------¿
//| Libera impressao                                                         |
//À--------------------------------------------------------------------------Ù
if !lAutoSt
	oPrint:EndPage()     // Finaliza a página
	oPrint:Preview()     // Visualiza antes de imprimir
endif

//Ú--------------------------------------------------------------------------¿
//| Fim do Relat¢rio                                                         |
//À--------------------------------------------------------------------------Ù
Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ R245Graf ³ Autor ³ Rafael M. Quadrotti   ³ Data ³ 08.10.03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Imprime Boleto modo grafico                                ³±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Alteracoes ³ Data     ³Motivo                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
/*/

Static Function R245Graf(	aCobranca		,nAbatim		,nAcrescim		,oPrint		,;
							aBMP			,aDadosEmp		,aDadosTit		,aDadosBanco,;
							aDatSacado		,aMsgBoleto		,aCodBar		,aOpenMonth	,;
							aDependentes	,aObservacoes	,cCart			,cPrefixo	,;
							cTitulo			,cGrupoEmp 		,cMatric)
							
Local oFont8	// --¿
Local oFont10	// 	 |
Local oFont11n	// 	 |
Local oFont13n	// 	 |
Local oFont15n	// 	 Ã- Fontes para impressao do relatorio grafico.
Local oFont16	// 	 |
Local oFont16n	// 	 |
Local oFont21	// --Ù
Local oBrush
Local aBitmap 	:= aClone(aBmp)		// Array com os bmps para impressao
Local nColuna   := 0				// Contador para coluna.
// 19 linha de extrato
Local aLinhas	:= { 805, 850, 900, 950, 1000, 1050, 1100, 1150, 1200, 1250 ,1300 ,1350 ,1400 ,1450 ,1500 ,1550 ,1600 }
Local nContLn	:= 0	// Controle de linhas para impressao de dependentes.
Local nI		:= 0	// Contador do laco para impressao de dependentes.
Local nMsg      := 0    // Contador para as mensagens
Local nCob		:= 0	// Contador para for do extrato.

//Parâmetros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont8  := TFont():New("Arial",9,8 ,.T.,.F.,5,.T.,5,.T.,.F.)
oFont10 := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11n:= TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont13n:= TFont():New("Arial",9,13,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15n:= TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont16 := TFont():New("Arial",9,16,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n:= TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont21 := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)

oBrush := TBrush():New("",4)

oPrint:StartPage()   // Inicia uma nova página

oPrint:Say  (050	,500	,aDadosEmp[1]	,oFont11n)
oPrint:Say  (090	,500	,aDadosEmp[2] 	,oFont8 )
oPrint:Say  (125	,500	,aDadosEmp[3] 	,oFont8 )
oPrint:Say  (160	,500	,aDadosEmp[4] 	,oFont8 )
oPrint:Say  (195	,500	,aDadosEmp[5] 	,oFont8 )
oPrint:Say  (230	,500	,aDadosEmp[6] 	,oFont8 )


//ÚÄÄÄÄÄÄÄÄÄÄ¿
//³Bmp da ANS³
//ÀÄÄÄÄÄÄÄÄÄÄÙ
If File(SuperGetMv("MV_PLSLANS", .F., "ANS.BMP"))
	oPrint:SayBitmap (050 ,1825,SuperGetMv("MV_PLSLANS", .F., "ANS.BMP"),470 ,150)
Else
	oPrint:Say  (250,500,aDadosEmp[7] ,oFont10)
Endif

oPrint:Say  (250,1780,STR0044 + R245Imp->E1_MESBASE+" / "+R245Imp->E1_ANOBASE ,oFont10) //"Mês de competência: "

// Linhas do extrato.
oPrint:SayBitmap (50 ,100,aBitMap[1],200 ,200 )
oPrint:Box  (300,100,2680,2300)
oPrint:Line (400,0100,400,2300)
oPrint:Line (700,0100,700,2300)
oPrint:Line (300,0400,400,0400)
oPrint:Line (300,0800,400,0800)
oPrint:Line (300,1150,700,1150)
oPrint:Line (300,1500,400,1500)
oPrint:Line (300,1900,700,1900)

oPrint:Line (2405,100,2405,2300)// Limite para observacao

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime detalhes do extratos com dados para cobranca.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nTotLin := 1600 //Ultima linha do extrato padrao. A partir desta linha sera adicionada + 50 pixeis e a
				//ficha de compensacao sera gerada em uma nova pagina.
For nCob := 1 To Len(aCobranca)
	If nCob <= Len(aLinhas)
		
		oPrint:Say (aLinhas[nCob],0110 ,SubStr(Alltrim(aCobranca[nCob][1]),1,21),oFont8 )	
		oPrint:Say (aLinhas[nCob],0510 ,Alltrim(aCobranca[nCob][2]),oFont8 )	
		oPrint:Say (aLinhas[nCob],1060 ,Iif(Empty(aCobranca[nCob][3]),"",DtoC(aCobranca[nCob][3])),oFont8 )
		oPrint:Say (aLinhas[nCob],1260 ,Alltrim(aCobranca[nCob][4]),oFont8 )
		oPrint:Say (aLinhas[nCob],1560 ,SubStr(Alltrim(aCobranca[nCob][5])+"-"+aCobranca[nCob][6],1,30),oFont8 )
		oPrint:Say (aLinhas[nCob],2110 ,Iif(Empty(aCobranca[nCob][7]),"",Trans(aCobranca[nCob][7], "@E 99,999.99")),oFont8 )
	Else
		oPrint:EndPage()			// Finaliza a pagina
		oPrint:StartPage()			// Inicializo nova pagina
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime novo cabecalho de pagina³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		R245HEADER(@oPrint,aDadosEmp,oFont8,oFont11n,oFont10,aBMP)
	EndIf
Next

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Emissao dos dados do sacado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:Say  (400,105 ,STR0004             					,oFont8 ) //"Dados do Sacado"
oPrint:Say  (470,115 ,Subs(aDatSacado[1],1,40)+" ("+aDatSacado[2]+")" ,oFont10)
oPrint:Say  (505,115 ,Subs(aDatSacado[3],1,48),oFont10)
oPrint:Say  (540,115 ,Subs(aDatSacado[4],1,48),oFont10)
oPrint:Say  (540,500 ,Subs(aDatSacado[5],1,38)+"  "+aDatSacado[6]	,oFont10)

//Informacoes dos Usuários/dependentes
oPrint:Say  (400,1155 ,STR0005+Iif(BA3->BA3_TIPOUS == '1',(" ("+R245Imp->E1_CODINT+"."+R245Imp->E1_CODEMP+"."+R245Imp->E1_MATRIC+")"),"") ,oFont8 ) //"Usuários"

nContLn := 455
For nI := 1 To Len(aDependentes)
	If nI == 1
		oPrint:Say  (nContLn,1165 ,aDependentes[nI,1]+" - "+Alltrim(aDependentes[nI,2])+STR0006		      ,oFont8) //" (Titular)"
	Else
		oPrint:Say  (nContLn,1165 ,aDependentes[nI,1]+" - "+aDependentes[nI,2]			      ,oFont8)
	EndIf
	nContLn+=25
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Emite somente os 5 primeiros dependentes devido ao espaco no boleto.³
	//³Foi utilizado for e estrutura de array para facilitar a customizacao³
	//³para impressao de mais dependentes.								   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If  nI > 9
		Exit
	EndIf
Next nI

//Meses em aberto
oPrint:Say  (400,1905 ,STR0007                  ,oFont8 ) //"Meses em aberto"
nContLn := 455
nColuna := 1905
For nI := 1 To Len(aOpenMonth)
	oPrint:Say  (nContLn,nColuna ,aOPenMonth[nI] ,oFont8)
	nContLn+=25
	
	//Alterna as colunas
	If nColuna == 1905
		nColuna := 1955
	ElseIf nColuna == 1955
		nColuna := 1905
	EndIf
	
	If nI > 18
		Exit
	EndIf
Next nI

oPrint:Say  (300,105,STR0008                   ,oFont8 ) //"Vencimento"
oPrint:Say  (345,205,DTOC(aDadosTit[4])             ,oFont10)

oPrint:Say  (300,405,STR0009                     ,oFont8 ) //"Valor R$"
oPrint:Say  (345,505,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

oPrint:Say  (300,805,STR0010             ,oFont8 ) //"Data de Emissão"
oPrint:Say  (345,905,DTOC(aDadosTit[3])             ,oFont10)

oPrint:Say  (300,1155,"Número da fatura"            ,oFont8 ) //Numero da fatura
oPrint:Say  (345,1255,cPrefixo+cTitulo                  ,oFont10)

oPrint:Say  (300,1505,"Contrato"      ,oFont8 ) //"Contrato"
oPrint:Say  (345,1555,cGrupoEmp+"-"+cMatric,oFont10)

oPrint:Say  (300,1905,"Número do documento"                ,oFont8 ) //Numero do documento
oPrint:Say  (345,1950,aDadosTit[6]                  ,oFont10)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao das colunas do extrato de utilizacao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:FillRect({705,100,750,2300},oBrush)
oPrint:Say  (710,((2300-21)/2),STR0048      ,oFont8 ) //21 = Len de "Extrato de utilizacao"  Calculo para centralizar //"Extrato de utilização"
oPrint:Line (750,0100,750,2300) // Linha horizontal do cabecalho do extrato. // Extrato de utilizacao
oPrint:Say  (760,0110,STR0049      ,oFont8 ) //"Usuário"
oPrint:Line (750,0500,2405,0500) // Linha divisória de colunas

oPrint:Say  (760,510,STR0054      ,oFont8 ) //"Prestador"
oPrint:Line (750,1050,2405,1050) // Linha divisória de colunas

oPrint:Say  (760,1060,STR0052      ,oFont8 ) //"Data"
oPrint:Line (750,1250,2405,1250) // Linha divisória de colunas

oPrint:Say  (760,1260,STR0053      ,oFont8 ) //"Lote"
oPrint:Line (750,1550,2405,1550) // Linha divisória de colunas

oPrint:Say  (760,1560,STR0050      ,oFont8 ) //"Lançamento/Procedimento"
oPrint:Line (750,2100,2405,2100) // Linha divisória de colunas

oPrint:Say  (760,2110,STR0051      ,oFont8 ) //"Valor Total"

oPrint:Line (800,0100,800,2300) // Linha horizontal do cabecalho do extrato. 



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao da observacao.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nMsg:=2430
oPrint:Say  (2405,105,STR0014                ,oFont8 ) //"Observação"
For nI := 1 To len(aObservacoes)
	oPrint:Say  (nMsg,105,aObservacoes[nI]        ,oFont8 )
	nMsg+=30
	If nI > 10
		Exit
	EndIf
Next nI

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Recibo do Sacado.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:Box  (2780,100,2980,2300)
oPrint:Line (2880,100,2880,2300)
oPrint:Say  (2780,100,STR0036,oFont8) //"Sacado"
oPrint:Say  (2825,205,aDatSacado[1]+" ("+aDatSacado[2]+")" ,oFont10)

oPrint:Say  (2880,105,STR0008                   ,oFont8 ) //"Vencimento"
oPrint:Say  (2925,205,DTOC(aDadosTit[4])             ,oFont10)

oPrint:Say  (2880,405,STR0009                     ,oFont8 ) //"Valor R$"
oPrint:Say  (2925,505,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

oPrint:Say  (2880,805,STR0010             ,oFont8 ) //"Data de Emissão"
oPrint:Say  (2925,905,DTOC(aDadosTit[3])             ,oFont10)

oPrint:Say  (2880,1155,"Número da fatura"            ,oFont8 ) //Numero da fatura
oPrint:Say  (2925,1255,cPrefixo+cTitulo                  ,oFont10)

oPrint:Say  (2880,1505,"Contrato"      ,oFont8 ) //"Contrato"
oPrint:Say  (2925,1555,cGrupoEmp+"-"+cMatric,oFont10)

oPrint:Say  (2880,1905,"Número do documento"         ,oFont8 ) //Numero do documento
oPrint:Say  (2925,1950,aDadosTit[6]                  ,oFont10)
                               

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao das linhas divisorias de cada campo do recibo.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint:Line (2880,0400,2980,0400)
oPrint:Line (2880,0800,2980,0800)
oPrint:Line (2880,1150,2980,1150)
oPrint:Line (2880,1500,2980,1500)
oPrint:Line (2880,1900,2980,1900)

;oPrint:Say  (3000,100,aCodBar[1]                  ,oFont10)
oPrint:Say  (2984,100,aCodBar[1]                  ,oFont10)
//MSBAR("INT25",26,1.5,aCodBar[2],oPrint,.F.,Nil,Nil,0.025,1.2,Nil,Nil,"A",.F.) 
MSBAR("INT25",26,1.3,aCodBar[2],oPrint,.F.,Nil,Nil,0.025,1.2,Nil,Nil,"A",.F.) 
oPrint:EndPage() // Finaliza a pagina

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PLR245MES ºAutor  ³Rafael M. Quadrotti º Data ³  02/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna os meses em aberto do sacado.                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLR245MES(cCliente,cLoja,cMesBase,cAnoBase)
Local aMeses 	:= {} 							//Retorno da funcao.
Local cSQL      := ""							//Query
Local cSE1Name 	:= SE1->(RetSQLName("SE1"))	//retorna o alias no TOP.

SE1->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta query...                                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cSQL := "SELECT * FROM "+cSE1Name+" WHERE E1_FILIAL = '" + xFilial("SE1") + "' AND "
cSQL += "			E1_CLIENTE + E1_LOJA = '"+cCliente+cLoja+"' AND "
cSQL += "			E1_SALDO > 0 AND "
cSQL += "			E1_PARCELA <> '" + StrZero(0, Len(SE1->E1_PARCELA)) + "' AND "
cSQL += cSE1Name+".D_E_L_E_T_ = '' "
cSQL += "ORDER BY " + SE1->(IndexKey())

PLSQuery(cSQL,STR0040) //"Meses"

If Meses->(Eof())
	Meses->(DbCloseArea())
	Aadd(aMeses,"")
Else
	While 	!Eof() .And.;
		Meses->E1_CLIENTE == cCliente .And.;
		Meses->E1_LOJA ==	cLoja
		If (cMesBase<>E1_MESBASE .And. cAnoBase<>E1_ANOBASE)
			Aadd(aMeses,E1_MESBASE+"/"+E1_ANOBASE)
		EndIf	
		DbSkip()
	End
	Meses->(DbCloseArea())
EndIf
Return (aMeses)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PLR245TEXTºAutor  ³Rafael M. Quadrotti º Data ³  02/04/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna as mensagens para impressao.                        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³ Esta funcao executa uma selecao em tres tabelas para       º±±
±±º          ³ encontrar a msg relacionada ao sacado.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PLR245TEXT(	nTipo	,cCodInt	,cCodEmp	,cConEmp,;
							cSubCon	,cMatric	,cBase	)//cBase = Ano+mes
Local cQuery  	 := ""
Local cNTable1   := "" // Nome da tabela no SQL
Local cNTable2   := "" // Nome da tabela no SQL
Local cNTable3   := "" // Nome da tabela no SQL
Local aMsg		 := {} // Array de mensagens

DbSelectArea("BH1")
DbSetOrder(2)
cNTable1 := RetSqlName("BH1")
cNTable2 := RetSqlName("BA3")
cNTable3 := RetSqlName("BH2")

cQuery := "SELECT BH1.* ,BH2.* ,BA3.BA3_CODPLA,BA3.BA3_FILIAL,BA3.BA3_CODINT,BA3.BA3_CODEMP,BA3.BA3_MATRIC,BA3.BA3_CONEMP,BA3.BA3_VERCON,BA3.BA3_SUBCON,BA3.BA3_VERSUB "
cQuery += "FROM " +cNTable1+ " BH1 , " +cNTable2 +" BA3 , " +cNTable3 +" BH2 "

//BH1
cQuery += "WHERE BH1.BH1_FILIAL='"	+	xFilial("BH1")		+	"'    AND "
cQuery += "		 BH1.BH1_CODINT='"	+	cCodInt				+	"'    AND "
cQuery += "		 BH1.BH1_TIPO='"	+	Transform(nTipo,"9")+	"'    AND "
If !Empty(cCodEmp)
	cQuery += "(('"+cCodEmp +"' BETWEEN BH1.BH1_EMPDE   AND BH1.BH1_EMPATE) OR (BH1.BH1_EMPATE='' AND BH1.BH1_EMPDE='') ) AND "
EndIf
If !Empty(cConEmp)
	cQuery += "(('"+cConEmp +"' BETWEEN BH1.BH1_CONDE   AND BH1.BH1_CONATE)  OR (BH1.BH1_CONATE='' AND BH1.BH1_CONDE='') ) AND "
EndIf
If !Empty(cSubCon)
	cQuery += "(('"+cSuBCon +"' BETWEEN BH1.BH1_SUBDE   AND BH1.BH1_SUBATE)  OR (BH1.BH1_SUBATE='' AND BH1.BH1_SUBDE='') ) AND "
EndIf
If !Empty(cMatric)
	cQuery += "(('"+cMatric +"' BETWEEN BH1.BH1_MATDE   AND BH1.BH1_MATATE)  OR (BH1.BH1_MATATE='' AND BH1.BH1_MATDE='') ) AND "
EndIf
If !Empty(cBase)
	cQuery += "(('"+cBase   +"' BETWEEN BH1.BH1_BASEIN AND BH1.BH1_BASEFI) OR (BH1.BH1_BASEIN='' AND BH1.BH1_BASEFI='') ) AND "
EndIf
//BA3 PARA ENCONTRAR O PLANO
cQuery += "		 BA3.BA3_FILIAL='"	+	xFilial("BA3")	+	"'    AND "
cQuery += "		 BA3.BA3_CODINT='"	+	cCodInt  		+	"'    AND "
cQuery += "		 BA3.BA3_CODEMP='"	+	cCodEmp  		+	"'    AND "
cQuery += "		 BA3.BA3_MATRIC='"	+	cMatric  		+	"'    AND "
cQuery += "		((BA3.BA3_CODPLA BETWEEN BH1.BH1_PLAINI AND BH1.BH1_PLAFIM) OR (BH1.BH1_PLAINI='' AND BH1.BH1_PLAFIM='') ) AND "

//BH2 MENSAGENS PARA IMPRESSAO
cQuery += "		 BH2.BH2_FILIAL = '"	+	xFilial("BH2")	+	"'    AND "
cQuery += "		 BH2.BH2_CODIGO = BH1.BH1_CODIGO  AND "


cQuery += "		BH1.D_E_L_E_T_<>'*' AND BA3.D_E_L_E_T_<>'*' AND BH2.D_E_L_E_T_<>'*' "
cQuery += "ORDER BY " + BH1->(IndexKey())

PLSQuery(cQuery,"MSG")

If MSG->(Eof())
	MSG->(DbCloseArea())
	Aadd(aMSG,"")
Else
	While 	!Eof()
		If Iif(BH1->(FieldPos("BH1_CONDIC")) > 0 , (Empty(MSG->BH1_CONDIC) .or. (&(MSG->BH1_CONDIC))), .T.)
			Aadd(aMSG,MSG->BH2_MSG01)
		Endif
		DbSkip()
	End      
	If Len(aMSG) == 0
		Aadd(aMSG,"")
	Endif				
	MSG->(DbCloseArea())
EndIf

Return aMsg








/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³R245HeaderºAutor  ³Rafael M. Quadrotti º Data ³  03/11/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Emite um novo cabecalho devido a quebra de pagina.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 PLS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R245HEADER(oPrint,aDadosEmp,oFont8,oFont11n,oFont10,aBitMap)

oPrint:Say  (050	,500	,aDadosEmp[1]	,oFont11n)
oPrint:Say  (090	,500	,aDadosEmp[2] 	,oFont8 )
oPrint:Say  (125	,500	,aDadosEmp[3] 	,oFont8 )
oPrint:Say  (160	,500	,aDadosEmp[4] 	,oFont8 )
oPrint:Say  (195	,500	,aDadosEmp[5] 	,oFont8 )
oPrint:Say  (230	,500	,aDadosEmp[6] 	,oFont8 )
	

//ÚÄÄÄÄÄÄÄÄÄÄ¿
//³Bmp da ANS³
//ÀÄÄÄÄÄÄÄÄÄÄÙ
If File(SuperGetMv("MV_PLSLANS", .F., "ANS.BMP"))
	oPrint:SayBitmap (050 ,1825,SuperGetMv("MV_PLSLANS", .F., "ANS.BMP"),470 ,150)
Else
	oPrint:Say  (225,500,aDadosEmp[7] ,oFont10)
Endif

oPrint:Say  (250,1780,STR0044 + R245Imp->E1_MESBASE+" / "+R245Imp->E1_ANOBASE ,oFont10) //"Mês de competência: "

// Linhas do extrato.
oPrint:SayBitmap (50 ,100,aBitMap[1],250 ,200 )
oPrint:Box  (300,100,1852,2300)
oPrint:Line (400,0100,400,2300)
oPrint:Line (700,0100,700,2300)
oPrint:Line (300,0400,400,0400)
oPrint:Line (300,0800,400,0800)
oPrint:Line (300,1150,700,1150)
oPrint:Line (300,1500,400,1500)
oPrint:Line (300,1900,700,1900)

oPrint:Line  (1902,100,1902,2300)// Tracejado para destaque do boleto.

oPrint:Line (1625,100,1625,2300)// Limite para observacao

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PLSR245   ºAutor  ³Rafael M. Quadrotti º Data ³  03/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna codigo de barras.                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Plr245Bar(cValor,cCGC,cPrefixo,cTitulo,cNNumero)
Local aRet := {}  	// Posição 1 - Representacao numerica
					// Posicao 2 - codigo numerico para codigo de barras.
Local cRepNum	:= "866"+R245Calc("866")+StrTran(Strzero(cValor,10),",","")+cCGC+Alltrim(cPrefixo)+Alltrim(cTitulo)+Strzero(Val(Alltrim(cNNumero)),10) // Fixo de acordo com padrao do layout
Local cCodBar	:= ""
Local cPart1	:= SubStr(cRepNum, 1,11)
Local cPart2	:= SubStr(cRepNum,12,11)         
Local cPart3	:= SubStr(cRepNum,23,11)
Local cPart4	:= SubStr(cRepNum,34,11)
Local cDvP1		:= R245Calc(SubStr(cRepNum, 1,11))
Local cDvP2		:= R245Calc(SubStr(cRepNum,12,11))
Local cDvP3		:= R245Calc(SubStr(cRepNum,23,11))
Local cDvP4		:= R245Calc(SubStr(cRepNum,34,11))

cCodBar := cPart1+cDvP1 + cPart2+cDvP2 + cPart3+cDvP3 + cPart4+cDvP4
cRepNum := cPart1+"-"+cDvP1+" "+cPart2+"-"+cDvP2+" "+cPart3+"-"+cDvP3+" "+cPart4+"-"+cDvP4
Aadd(aRet,cRepNum)
Aadd(aRet,cCodBar)

Return aRet	       

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³245CALC   ºAutor  ³Rafael M. Quadrotti º Data ³  03/12/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna o digito verificador do codigo de barras.          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP8                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R245CALC(cValor)
Local nDv 		:= 0
Local nDigito 	:= 0
Local nPeso		:= 1// Inicia com 1 para na primeira execucao ser 2.
Local nValOper	:= 0
Local nAux		:= 0,nx

For nX := 1 To Len(cValor)
	nDigito := Val(SubStr(cValor,nX,1))
    If nPeso == 2
    	nPeso := 1
    ElseIf nPeso == 1
    	nPeso := 2
    EndIf
    
    nAux := (nDigito*nPeso)
    
    If nAux > 9
    	nAux := nAux-9
    EndIf
    
    nValOper+= nAux
   		
Next nX

nDv:= 10-MoD(nValOper,10)


Return Transform(nDv,"9")

function PLSR245StC(lValor)
lAutoSt := lValor
return
