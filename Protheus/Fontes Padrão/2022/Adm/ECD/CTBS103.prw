//#INCLUDE "CTBS0103.ch"
#INCLUDE "PROTHEUS.CH" 
#Include "ApWizard.ch"  
#INCLUDE "ECF.CH"
#INCLUDE "FWLIBVERSION.CH"
//AMARRACAO

Static __cThreadArq := ""
Static __lDefTop	:= IfDefTopCTB()
Static __cGetDB 	:= TcGetDb()

#Define NAO_GRAVAR '#NAOGRAVAR#'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณCTBS103     บAutor  ณFelipe Cunha			ณ  01/01/2015 	  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณWizard de exporta็ใo de dados para o TAF                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function CTBS103(cCodRev,aAutoWizd,lAutoDIPJ,lAutoJobs,lAutomato,nOpcCentra,aAutoY540)
Local oWizard 	:= Nil
Local aPWiz1 	:= {}           
Local aPWiz2 	:= {} 
Local aRetWiz1	:= {}
Local aRetWiz2	:= {}
Local aArea		:= GetArea()
Local aAreaCS0	:= CS0->(GetArea())
Local nOpcRot	:= 0
Local nX		:= 0 
Local lRet		:= .T.
Local lFWCodFil	:= FindFunction( "FWCodFil" )
Local lGestao	:= Iif( lFWCodFil, ( "E" $ FWSM0Layout() .And. "U" $ FWSM0Layout() ), .F. )	// Indica se usa Gestao Corporativa
Local lEcfInfo  := FindFunction("EcfInfoEcon") 

//Variแveis a serem utilizadas no Wizard DIPJ

Local aOpta			:= {"S - Sim", "N - Nใo"}
Local aApurCSLL		:= {"A - Anual", "T - Trimestral", "D - Desobrigada"}
Local aTpExp    	:= {"01 - Bens", "02 - Servi็os", "03 - Direitos", "04 - Opera็๕es Financeiras", "05 - Nใo Especificadas"}
Local aMetodoExp   	:= {"1 - PVE", "2 - PVA", "3 - PVV", "4 - CAP", "5 - PECEx"}
Local aMetodoImp   	:= {"1 - PIC00", "2 - PRL20", "3 - PLR30", "4 - PRL40", "5 - PRL60", "6 - CPL00", "7 - PCI00" }
Local aTpImp    	:= {"01 - Bens", "02 - Servi็os", "03 - Direitos", "04 - Opera็๕es Financeiras", "05 - Nใo Especificadas"}
Local aPesVin   	:= {"1 - Opera็๕es com Pessoa Vinculada" , "2 - Opera็๕es com Pessoa Nใo Vinculada"}

Local aHeader       := {}
Local aFilY540       := {}
Local oOk           := Nil
Local oNo           := Nil
Local oFil          := Nil
Local nPanel        := 0
Local lCentraliz    := .F.

Private aPWizd      := {}
Private aRetWizd    := {}
Private cTicket	    := ''
Private cData	    := ''
Private cHora	    := ''
Private cNrLivro    := ''
Private cTpExp      := ''
Private cMetodoExp	:= ''
Private cMetodoImp	:= ''
Private cTpImp	    := ''
Private cAlterCap   := ''
Private cEscBcCsll  := ''
Private cPessoaVinc := ''
Private lDipj       := .F.
Private nPercSelic  := 0

Private nRecno 	:= 0

Default cCodRev := ''
Default aAutoWizd	:= {}

Default lAutoDIPJ	:= .F.
Default lAutoJobs	:= .F.
Default lAutomato	:= .F.
Default nOpcCentra  := 1 // 1 - "Com Centraliza็ใo", 2 - "Sem Centraliza็ใo"
Default aAutoY540   := {}

//----------------------------------------
//Posiciona na Revisใo selecionada 
//----------------------------------------
If !Empty(cCodRev)
	DbSelectArea("CS0")
	CS0->(dbSetOrder(1))
	CS0->(dbSeek(xFilial("CS0") + cCodRev))
EndIf

cTicket	:= "ECF" + AllTrim(CS0->CS0_CODEMP) + AllTrim(CS0->CS0_CODFIL) + AllTrim(CS0->CS0_CODREV) +  Dtos(Date()) + StrTran(Time(),':','')
cData	:= Date()
cHora	:= Time()

//----------------------------------------
//Wizard1 - Confirma็ใo das informa็๕es da escritura็ใo
//----------------------------------------
aAdd(aPWiz1,{ 1,	"Cod Empresa" ,Space(TamSx3('CS0_CODEMP')[1])	,"@!","","","AllwaysFalse()",0,	.F.}) 
aAdd(aPWiz1,{ 1,	IIF(lGestao,"Empresa/Unidade/Filial","Filial") ,Space(TamSx3('CS0_CODFIL')[1])	,"@!","","","AllwaysFalse()",0,	.F.})
aAdd(aPWiz1,{ 1,	"Revisao" ,Space(TamSx3('CS0_CODREV')[1])	,"@!","","","AllwaysFalse()",0,	.F.})
aAdd(aPWiz1,{ 1,	"Tipo Escrituracao"	,Space(TamSx3('CS0_TPESC')[1])	,"@!","","","AllwaysFalse()",0,	.F.})

aAdd(aRetWiz1,CS0->CS0_CODEMP)
aAdd(aRetWiz1,CS0->CS0_CODFIL)
aAdd(aRetWiz1,CS0->CS0_CODREV)
aAdd(aRetWiz1,CS0->CS0_TPESC)

lCentraliz := ( nOpcCentra == 1 )

If !lAutomato

	aAdd(aPWizd,{1,"N๚mero do Livro - DIPJ"				     	,Space(1)	,"","","",,50,.F.})
	aAdd(aPWizd,{3,"Tipo de Exporta็ใo"			            	,,aTpExp	,100,"",.F.,.T.})
	aAdd(aPWizd,{3,"Qual o M้todo Utilizado nas Exporta็๕es"   	,,aMetodoExp,100,"",.F.,.T.})
	aAdd(aPWizd,{3,"Tipo de Importa็ใo"				        	,,aTpImp	,100,"",.F.,.T.})
	aAdd(aPWizd,{3,"Qual o M้todo Utilizado nas Importa็๕es"   	,,aMetodoImp	,100,"",.F.,.T.})
	aAdd(aPWizd,{3,"Altera็ใo de Capital?"	  			        ,,aOpta		,100,"",.F.,.T.})
	aAdd(aPWizd,{3,"Opc. Escrit. Ativo da Base de Calc. Negativa da CSLL ?" ,,aOpta	,100,"",.F.,.T.})
	aAdd(aPWizd,{3,"Possui Opera็๕es com Pessoa Vinculada"	    ,,aPesVin	,100,"",.F.,.T.})
	aAdd(aPWizd,{1,"M้dia SELIC(%)"							     ,"","@E 99,99" ,"","",,5,.F.})
	aAdd(aPWizd,{3,"Reg. ECF X291"	  			                ,,aOpta		,100,"",.F.,.T.})
	aAdd(aPWizd,{3,"Reg. ECF X292"	  			        		,,aOpta		,100,"",.F.,.T.})
	aAdd(aPWizd,{3,"Reg. ECF X300"	  			       			,,aOpta		,100,"",.F.,.T.})
	//aAdd(aPWizd,{3,"Reg. ECF X305"	  			       			,,aOpta		,100,"",.F.,.T.}) // Comentado aguardando defini็ใo do TAF
	aAdd(aPWizd,{3,"Reg. ECF X310"	  			      		    ,,aOpta		,100,"",.F.,.T.})
	aAdd(aPWizd,{3,"Reg. ECF X320"	  			                ,,aOpta		,100,"",.F.,.T.})
	//aAdd(aPWizd,{3,"Reg. ECF X325"	  			                ,,aOpta		,100,"",.F.,.T.}) //Comentado aguardando defini็ใo do TAF
	aAdd(aPWizd,{3,"Reg. ECF X330"	  			                ,,aOpta		,100,"",.F.,.T.})
	aAdd(aPWizd,{3,"Reg. ECF Y540"	  			                ,,aOpta		,100,"",.F.,Lay7ECF()})
	aAdd(aPWizd,{3,"Reg. ECF Y550"	  			                ,,aOpta		,100,"",.F.,Lay7ECF()})
	aAdd(aPWizd,{3,"Reg. ECF Y560"	  			                ,,aOpta		,100,"",.F.,Lay7ECF()})
	aAdd(aPWizd,{3,"Reg. ECF Y600"	  			                ,,aOpta		,100,"",.F.,.T.})
	aAdd(aPWizd,{3,"Reg. ECF Y570"	  			                ,,aOpta		,100,"",.F.,.T.})
	
	aAdd(aRetWizd,Space(1))
	aAdd(aRetWizd,0)
	aAdd(aRetWizd,0)
	aAdd(aRetWizd,0)
	aAdd(aRetWizd,0)
	aAdd(aRetWizd,2)
	aAdd(aRetWizd,0)
	aAdd(aRetWizd,0)
	aAdd(aRetWizd,"00,00")
	aAdd(aRetWizd,2)
	aAdd(aRetWizd,2)
	aAdd(aRetWizd,2)
	aAdd(aRetWizd,2)
	aAdd(aRetWizd,2)
	aAdd(aRetWizd,2)
	aAdd(aRetWizd,2)
	aAdd(aRetWizd,2)
	aAdd(aRetWizd,2)
	aAdd(aRetWizd,2)
	aAdd(aRetWizd,2)
	aAdd(aRetWizd,2)
	aAdd(aRetWizd,2)
	
	//---------------------------------------------
	//ณ Montagem da Wizard                      
	//---------------------------------------------
	DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
	
	DEFINE WIZARD oWizard TITLE "Escritura็ใo";
	       HEADER "Exporta็ใo de Dados" ;
	       MESSAGE "Parโmetros Iniciais..." 	 ;
	       TEXT "Essa rotina tem o objetivo exportar os dados para o ambiente TAF";
	       NEXT {||.T.} ;
	       FINISH {|| .F. } ;
	       PANEL
	
	nPanel++ 
	ParamBox(aPWiz1,"Parโmetros...",@aRetWiz1,,,,,,oWizard:GetPanel(nPanel))
	
	If lEcfInfo .And. MsgYesNo("Deseja exportar dados para o DIPJ?")

		lDipj := .T.
		//Wizard 1
	   CREATE PANEL oWizard ;
	          HEADER "Exporta็ใo de Dados DIPJ"; 
	          MESSAGE ""; 
	          BACK {|| .T. } ;
	          NEXT {|| oWizard:nPanel:= changePanel( "next", aRetWizd[ECF_REGY540_DIPJ], lCentraliz ), .T. } ;
	          FINISH {|| nOpcRot := 1 , .T. } ;
	          PANEL
		nPanel++
		ParamBox(aPWizd,"Parโmetros...",@aRetWizd,,,,,,oWizard:GetPanel(nPanel))

		// Se o tipo de escritura็ใo for "Com Centraliza็ใo", apresento a wizard de sele็ใo de filiais para o Y540 da DIPJ
		if lCentraliz
			//---------------------------------------------
			//Carrega todas as filiais existentes para a sele็ใo de DIPJ
			//---------------------------------------------
			aHeader	:= ARRAY(5)
			aHeader[1]	:= ""  		
			aHeader[2]	:= IIF(lGestao,"Filial","Empresa/Unidade/Filial")
			aHeader[3]	:= "Razใo Social"
			aHeader[4]	:= "CNPJ"
			aHeader[5]	:= ""
			aFilY540	:= GetEmpEcd( cEmpAnt )

			// Marca a filial centralizadora
			aEval( aFilY540, { |x| IIf( Alltrim( x[3] ) == Alltrim( aRetWiz1[2] ), x[1] := .T., nil ) } )

			//---------------------------------------------
			//Carrega imagens dos botoes
			//---------------------------------------------
			oOk 		:= LoadBitmap( GetResources(), "LBOK")
			oNo			:= LoadBitmap( GetResources(), "LBNO")

			CREATE PANEL oWizard  ;
			HEADER "Quais filiais devem gerar o registro Y540 para a DIPJ?";
			MESSAGE ""	;
			BACK {|| .T.} ;
			Next {|| .T.} ;
			PANEL

			nPanel++
			oFil := TWBrowse():New( 0.5, 0.5 , 300, 100,Nil,aHeader, Nil, oWizard:GetPanel( nPanel ),,,,,,,,,,,,.F.,,.T.,,.F.,,,)
			oFil:bLDblClick := {|| DbClick( oFil, aFilY540, aRetWiz1[2] ) }

			oFil:SetArray( aFilY540 )

			oFil:bHeaderClick := { |oFil , nCol | IIF( ncol == 1, HeadClick( oFil, aFilY540, aRetWiz1[2] ), Nil ) }

			oFil:bLine := {|| {;
							If( aFilY540[oFil:nAt,1] , oOk , oNo ),;
								aFilY540[oFil:nAt,3],;
								aFilY540[oFil:nAt,4],;
								aFilY540[oFil:nAt,5];
							}}
		EndIf	
		
		//Wizard DIPJ
	   CREATE PANEL oWizard ;
	          HEADER "Exporta็ใo de Dados Finalizada"; 
	          MESSAGE ""; 
	          BACK {|| oWizard:nPanel := changePanel( "back", aRetWizd[ECF_REGY540_DIPJ], lCentraliz ), .T. } ;
	          NEXT {|| .T. } ;
	          FINISH {|| nOpcRot := 1 , .T. } ;
			  PANEL
		
		nPanel++
		@ 050,010 SAY "Clique no botใo finalizar para fechar o wizard e iniciar a exporta็ใo dos dados para o TAF (ToTvs Automa็ใo Fiscal)." SIZE 270,020 FONT oBold PIXEL OF oWizard:GetPanel(nPanel)
		
	Else
		//Wizard 1
	   CREATE PANEL oWizard ;
	          HEADER "Exporta็ใo de Dados Finalizada"; 
	          MESSAGE ""; 
	          BACK {|| .T. } ;
	          NEXT {|| .T. } ;
	          FINISH {|| nOpcRot := 1 , .T. } ;
	          PANEL
		ParamBox(aPWiz1,"Parโmetros...",@aRetWiz1,,,,,,oWizard:GetPanel(1))
		
		@ 050,010 SAY "Clique no botใo finalizar para fechar o wizard e iniciar a exporta็ใo dos dados para o TAF (ToTvs Automa็ใo Fiscal)." SIZE 270,020 FONT oBold PIXEL OF oWizard:GetPanel(2)
		
	EndIf
		
	ACTIVATE WIZARD oWizard CENTERED

Else
	
	aRetWizd	:= aAutoWizd
	lDIPJ		:= lAutoDIPJ

	If !Empty( aAutoY540 )
		aFilY540 := aAutoY540
	Endif
	
EndIf

//Fun็ใo que alimenta o array aReg contendo os registros do DIPJ
aReg := DipjReg(aRetWizd)

cNrLivro    := aRetWizd[ECF_NRLIVRO_DIPJ]
cTpExp      := StrZero(aRetWizd[ECF_TPEXPOR_DIPJ],2)
cMetodoExp  := Str(aRetWizd[ECF_METODOEXP_DIPJ])
cTpImp	    := StrZero(aRetWizd[ECF_TPIMPOR_DIPJ],2)
cMetodoImp  := Str(aRetWizd[ECF_METODOIMP_DIPJ])
cAlterCap   := Str(aRetWizd[ECF_ALTERCA_DIPJ])
cEscBcCsll  := Str(aRetWizd[ECF_ESCBCCS_DIPJ])
cPessoaVinc := Str(aRetWizd[ECF_PESVINC_DIPJ])
nPercSelic  := Val( StrTran( aRetWizd[ECF_PERCSELIC_DIPJ],"," ,"." ) )

If nOpcRot == 1 .OR. lDIPJ
	If !lAutomato
		oProcess:= MsNewProcess():New( {|lEnd| EcfExpTAF(aRetWiz1[1],aRetWiz1[2],aRetWiz1[3],oProcess,,,aFilY540, lCentraliz ),EcdGetMsg()} )
		oProcess:Activate()
	Else
		EcfExpTAF(aRetWiz1[1],aRetWiz1[2],aRetWiz1[3],,lAutoJobs,lAutomato, aFilY540, lCentraliz )
	EndIf
EndIf
	          
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcfExpTAF   บAutorณFelipe Cunha	 	บ Data ณ  01/01/2015  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta os dados para o TAF                				  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS022                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcfExpTAF(cEmpEsc,cFilEsp,cRevisao,oProcess,lAutoJobs,lAutomato, aFilY540, lCentraliz )
Local aArea			:= GetArea()
Local aAreaCS0		:= CS0->(GetArea())
Local lRet			:= .T.
Local cAlias		:= 'TAFST1'
Local cFilDipj      := cEmpEsc + cFilEsp
Local lVndaPjExp    := .F.
Local lPjComExp     := .F.
Local aFilDipj		:= GetEmpEcd( cEmpEsc )
Local aFiliais      := {}
Local nX			:= 0
Local cEmpFilSel    := ""
Local cEmpFilAux    := ""

Private cAliasCSZ	:= "CSZ"
Private cAliasCQM	:= "CQM"
Private cFilCSZ   	:= xFilial( "CSZ" )
Private cFilCQM   	:= xFilial( "CQM" )

Default cEmpEsc		:= ''
Default cFilEsp		:= ''
Default cRevisao	:= ''
Default oProcess	:= Nil
Default lAutoJobs	:= .F.
Default lAutomato	:= .F.
Default aFilY540    := { }
Default lCentraliz  := .F.

//-----------------------------------------------------
// Barra de Progresso
//-----------------------------------------------------
If oProcess <> Nil
	oProcess:SetRegua1(14)
Endif

DbSelectArea("CS2")
DbSetOrder(1)
CS2->(DbGoTop())
CS2->(DbSeek( xFilial("CS2") + cRevisao ))
While (CS2 ->(!Eof()))
	If Alltrim(CS2->CS2_CODREV) == Alltrim(CS0->CS0_CODREV)
		aAdd(aFiliais, { CS2->CS2_CNPJ, CS2->CS2_CODEMP, CS2->CS2_CODFIL } )
	EndIf
	CS2->(dbSkip())
EndDo

lRet := EcfLmpSt1(cAlias,lAutomato)

//--------------------------------
//Prote็ใo para ambientes oracle
// Nใo retirar esta instru็ใo
//--------------------------------
TcRefresh(cAlias)	

CS0->(DbSetOrder(2)) //CS0_FILIAL+CS0_CDOEMP+CS0_CODFIL+CS0_CODREV
IF lRet .AND. CS0->(dbSeek( xFilial("CS0") + cEmpEsc + cFilEsp + cRevisao  ))

	//--------------------------------------------------------------
	// Exporta Parametros - Reg. 0000/0010/0020
	//--------------------------------------------------------------		
	lRet := lRet .AND. EcfExpPara(oProcess, cRevisao, cAlias )

	//--------------------------------------------------------------
	// Exporta dados de Identifica็ใo das SCP - Reg. 0035
	//--------------------------------------------------------------		
	lRet := lRet .AND. EcfExpSCP(oProcess, cRevisao, cAlias )
	
	//--------------------------------------------------------------
	// Exporta dados de Signatarios - Reg. 0930
	//--------------------------------------------------------------		
	lRet := lRet .AND. EcfExpSign(oProcess, cRevisao, cAlias )

	//--------------------------------------------------------------
	// Exporta dados de Plano de Contas      - Reg. J050
	// Exporta dados de Plano de Contas Ref. - Reg. J051
	// Exporta dados de Contas Correlatas 	 - Reg. J053		
	//--------------------------------------------------------------	
	lRet := lRet .AND. EcfExpCta(oProcess, cRevisao, cAlias )
	
	//--------------------------------------------------------------
	// Exporta Parametros - Reg. Bloco w
	//--------------------------------------------------------------
	If VAL(CS0->CS0_LEIAUT) >=3 			
		lRet := lRet .AND. EcfExpBlW(oProcess, cRevisao, cAlias)
	Endif 
	
		
	//--------------------------------------------------------------
	// Exporta dados de Centro de Custo - Reg. J100
	//--------------------------------------------------------------	
	lRet := lRet .AND. EcfExpCust(oProcess, cRevisao, cAlias )
	
	//--------------------------------------------------------------
	// Exportando Detalhes dos Saldos Contแbeis  
	// Reg. K030/K155/K156/K355/K356
	//--------------------------------------------------------------	
	lRet := lRet .AND. EcfExpSldC(oProcess, cRevisao, cAlias, 'K' )
	
	//--------------------------------------------------------------
	// Exporta  - Reg. L030/L100/L200/L210/L300
	//--------------------------------------------------------------	
	lRet := lRet .AND. EcfExpSldR(oProcess, cRevisao, cAlias, 'L')
	
	//--------------------------------------------------------------
	// Exporta  - Reg. P030/P100/P150
	//--------------------------------------------------------------	
	lRet := lRet .AND. EcfExpSldR(oProcess, cRevisao, cAlias, 'P')
	
	//--------------------------------------------------------------
	// Exporta  - Reg. U030/U100/U150
	//--------------------------------------------------------------	
	lRet := lRet .AND. EcfExpSldR(oProcess, cRevisao, cAlias, 'U')
	

	//--------------------------------------------------------------
	// Exporta  - Bloco V Reg. V010 / V020 / V030 / V100
	//--------------------------------------------------------------	
	lRet := lRet .AND. EcfExpBl_V(oProcess, cRevisao, cAlias)

	//--------------------------------------------------------------
	// Exporta Reg X350 - Participa็๕es no Exterior – Resultado 
	//                    do Perํodo de Apura็ใo 
	//--------------------------------------------------------------
	//EcfExpDIPJ(oProcess, cRevisao, cAlias, 'X350' )
	
	//--------------------------------------------------------------
	// Exporta Reg X390 - Origem e Aplica็ใo de Recursos 
	//                    Imunes ou Isentas
	//--------------------------------------------------------------	
	EcfExpVis(oProcess, cRevisao, cAlias, , , 'X390' )
	
	//--------------------------------------------------------------
	// Exporta Reg X400 - Com้rcio Eletr๔nico e Tecnologia da Informa็ใo	
	//--------------------------------------------------------------	
	EcfExpVis(oProcess, cRevisao, cAlias, , , 'X400' )
		
	//--------------------------------------------------------------
	// Exporta Reg X460 - Inova็ใo Tecnol๓gica e Desenvolvimento 
	//                    Tecnol๓gico
	//--------------------------------------------------------------	
	EcfExpVis(oProcess, cRevisao, cAlias, , , 'X460' )
		
	//--------------------------------------------------------------
	// Exporta Reg X470 - Capacita็ใo de Informแtica e Inclusใo Digital
	//--------------------------------------------------------------	
	EcfExpVis(oProcess, cRevisao, cAlias, , , 'X470' )
		
	//--------------------------------------------------------------
	// Exporta Reg X480 - Repes, Recap, Padis, PATVD, Reidi, Repenec,
	//                    Reicomp, Retaero, Recine, Resํduos S๓lidos,
	//                    Recopa, Copa do Mundo, Retid, REPNBL-Redes,
	//                    Reif e Olimpํadas
	//--------------------------------------------------------------	
	EcfExpVis(oProcess, cRevisao, cAlias, , , 'X480' )
		
	//--------------------------------------------------------------
	// Exporta Reg X490 - P๓lo Industrial de Manaus e Amaz๔nia Ocidental
	//--------------------------------------------------------------	
	EcfExpVis(oProcess, cRevisao, cAlias, , , 'X490' )
		
	//--------------------------------------------------------------
	// Exporta Reg X500 -  Zonas de Processamento de Exporta็ใo (ZPE)
	//--------------------------------------------------------------	
	EcfExpVis(oProcess, cRevisao, cAlias, , , 'X500' )
		
	//--------------------------------------------------------------
	// Exporta Reg X510 - มreas de Livre Com้rcio (ALC)
	//--------------------------------------------------------------	
	EcfExpVis(oProcess, cRevisao, cAlias, , , 'X510' )
	
	//--------------------------------------------------------------
	// Exporta Reg Y671 - OUTRAS INFORMAวีES (Lucro Real)
	//--------------------------------------------------------------	
	EcfExpDIPJ(oProcess, cRevisao, cAlias, 'Y671' )

	//--------------------------------------------------------------
	// Exporta Reg Y672 - OUTRAS INFORMAวีES (Lucro Presumido ou Lucro Arbitrado)
	//--------------------------------------------------------------	
	EcfExpDIPJ(oProcess, cRevisao, cAlias, 'Y672' )
	
	//--------------------------------------------------------------
	// Exporta Reg Y681 - 
	//--------------------------------------------------------------
	EcfExpVis(oProcess, cRevisao, cAlias, , , 'Y681' )
	
	//--------------------------------------------------------------
	// Exporta Reg Y800
	//--------------------------------------------------------------	
	EcfExpRTF(oProcess, cRevisao, cAlias, 'Y800' )
	
	//--------------------------------------------------------------
	// Exporta DIPJ cTicket
	//--------------------------------------------------------------
	If (cAliasCSZ)->CSZ_VENEXP == '1' //Se for igual a SIM
		lVndaPjExp := .T.
	EndIf
	
	If (cAliasCSZ)->CSZ_COMEXP == '1'
		lPjComExp := .T.
	EndIf
	
	If lDipj
		If !lAutomato
			MsgRun( 'Extraํndo Dados da DIPJ','Extra็ใo - TAF', { || EcfInfoEcon(cFilDipj, cTicket,aReg, STOD((cAliasCSZ)->CSZ_DTINI),STOD((cAliasCSZ)->CSZ_DTFIM), aFiliais, cNrLivro, lVndaPjExp, lPjComExp, cTpExp, cMetodoExp, cMetodoImp, cTpImp, cAlterCap, cEscBcCsll, cPessoaVinc, nPercSelic, aFilY540, lCentraliz ) } )
		Else
			EcfInfoEcon(cFilDipj, cTicket,aReg, STOD((cAliasCSZ)->CSZ_DTINI),STOD((cAliasCSZ)->CSZ_DTFIM), aFiliais, cNrLivro, lVndaPjExp, lPjComExp, cTpExp, cMetodoExp, cMetodoImp, cTpImp, cAlterCap, cEscBcCsll, cPessoaVinc, nPercSelic, aFilY540, lCentraliz )
		EndIf
	EndIf
			
	(cAlias)->(dbCloseArea())
	(cAliasCSZ)->(dbCloseArea())			
EndIf

TcRefresh(cAlias)

If Select(cAlias) > 0
	(cAlias)->(dbCloseArea())
EndIf

If !lAutomato	
	If Aviso('Aten็ใo','Deseja continuar o processo de exporta็ใo dos dados para o TAF?' + CRLF + ;
                                    'Este processo irแ executar os Jobs 0 e 2, Continuar?', {'Sim', 'Nใo'},2) == 1
		TAFAPIERP( '3' )
	EndIf
Else		
	If lAutoJobs
		TAFAPIERP( '3', lAutomato )
	EndIf
EndIf


If !lRet
	Alert('Exporta็ใo TAF abortada ou executada parcialmente!', 'Aten็ใo')
Else
	MsgInfo('Exporta็ใo TAF executada com sucesso!', '')
EndIf 

//--------------------------------
//Prote็ใo para ambientes oracle
// Nใo retirar esta instru็ใo
//--------------------------------
TcRefresh(cAlias)

If Select(cAlias) >0
	(cAlias)->(dbCloseArea())
EndIf

RestArea(aAreaCS0)
RestArea(aArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcfExpPara   บAutorณFelipe Cunha 	  บ Data ณ  01/01/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta Parametros ECF					                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS103                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcfExpPara(oProcess, cRevisao, cAlias)
Local aArea		:= GetArea()
Local cMsg		:= ''
Local cMsgCqp	:= ''
Local cQuery	:= ''
Local cKey		:= ''
Local lRet		:= .T.
Local lTabCQL		:=.F.

Default cAliasCSZ	:= "CSZ"
Default cFilCSZ   	:= xFilial( "CSZ" )
Default oProcess	:= Nil
Default cRevisao 	:= ''
Default cAlias		:= 'TAFST1'

//-----------------------------------------------------
// Barra de Progresso
//-----------------------------------------------------
If oProcess <> Nil
	oProcess:IncRegua1( "Exportando Parametros ECF" )
	oProcess:SetRegua2(0)
	oProcess:IncRegua2( '' )	
Endif

DbSelectArea( "CSZ" )
DbSetOrder(1)
CSZ->(dbSetOrder(1))
CSZ->(dbSeek(xFilial("CSZ") + cRevisao))
If VAL(CS0->CS0_LEIAUT) >=3 .and. !empty(CSZ->CSZ_IDRG21)
	lTabCQL:=.T.
Endif 


//-----------------------------------------------------
// Seleciona Dados
//-----------------------------------------------------
If __lDefTop
	cQuery := '' 
	cQuery := "SELECT CSZ.CSZ_FILIAL,"
	cQuery += "       CSZ.CSZ_CODREV,"
	cQuery += "       CSZ.CSZ_DTINI, "
	cQuery += "       CSZ.CSZ_DTFIM, "
	cQuery += "       CSZ.CSZ_SITPER,"
	cQuery += "       CSZ.CSZ_SITESP,"
	cQuery += "       CSZ.CSZ_PATREM,"
	cQuery += "       CSZ.CSZ_DTSITE,"
	cQuery += "       CSZ.CSZ_RETIFI,"
	cQuery += "       CSZ.CSZ_NUMREC,"
	cQuery += "       CSZ.CSZ_TIPECF,"
	cQuery += "       CSZ.CSZ_CODSCP,"
	cQuery += "       CSZ.CSZ_APTREF,"
	cQuery += "       CSZ.CSZ_APTPAE,"
	cQuery += "       CSZ.CSZ_FMTRIB,"
	cQuery += "       CSZ.CSZ_FMAPUR,"
	cQuery += "       CSZ.CSZ_QUALPJ,"
	cQuery += "       CSZ.CSZ_FMTPER,"
	cQuery += "       CSZ.CSZ_MESBRE,"
	cQuery += "       CSZ.CSZ_TPESCR,"
	cQuery += "       CSZ.CSZ_TPENTI,"
	cQuery += "       CSZ.CSZ_FMAPUI,"
	cQuery += "       CSZ.CSZ_APUCSL,"
	cQuery += "       CSZ.CSZ_EXTRTT,"
	cQuery += "       CSZ.CSZ_DIFFCO,"
	cQuery += "       CSZ.CSZ_ALICSL,"
	cQuery += "       CSZ.CSZ_QTDSCP,"
	cQuery += "       CSZ.CSZ_ADMCLU,"
	cQuery += "       CSZ.CSZ_PARTCO,"
	cQuery += "       CSZ.CSZ_OPEXT, " 
	cQuery += "       CSZ.CSZ_OPVINC,"
	cQuery += "       CSZ.CSZ_PJENQU,"
	cQuery += "       CSZ.CSZ_PARTEX,"
	cQuery += "       CSZ.CSZ_ATIVRU,"
	cQuery += "       CSZ.CSZ_LUCEXP,"
	cQuery += "       CSZ.CSZ_REDISE,"
	cQuery += "       CSZ.CSZ_FIN,   "   
	cQuery += "       CSZ.CSZ_DOAELE,"
	cQuery += "       CSZ.CSZ_PCOLIG,"
	cQuery += "       CSZ.CSZ_VENEXP,"
	cQuery += "       CSZ.CSZ_RECEXT,"
	cQuery += "       CSZ.CSZ_ATIVEX,"
	cQuery += "       CSZ.CSZ_COMEXP,"
	cQuery += "       CSZ.CSZ_PGTOEX,"
	cQuery += "       CSZ.CSZ_ECOMTI,"
	cQuery += "       CSZ.CSZ_ROYREC,"
	cQuery += "       CSZ.CSZ_ROYPAG,"
	cQuery += "       CSZ.CSZ_RENDSE,"
	cQuery += "       CSZ.CSZ_PGTORE,"
	cQuery += "       CSZ.CSZ_INOVTE,"
	cQuery += "       CSZ.CSZ_CAPINF,"
	cQuery += "       CSZ.CSZ_PJHAB, " 
	cQuery += "       CSZ.CSZ_POLOAM,"
	cQuery += "       CSZ.CSZ_ZONEXP,"
	cQuery += "       CSZ.CSZ_ESTOQU,"
	cQuery += "       CSZ.CSZ_AREACO"
	If VAL(CS0->CS0_LEIAUT) >=3
		cQuery += ","
		cQuery += "       CSZ.CSZ_REGIME,"
		cQuery += "       CSZ.CSZ_DEPAIS"
	Endif 	
	If VAL(CS0->CS0_LEIAUT) >=4
		cQuery += ","
		cQuery += "       CSZ.CSZ_DEREX"
	Endif 	
	If lTabCQL
       cQuery += ","
  	   cQuery +=  "		CQL.CQL_CODID,"
       cQuery += "       CQL.CQL_REG,   "
       cQuery += "       CQL.CQL_DESCRI," 
       cQuery += "       CQL.CQL_REPES, "
       cQuery += "       CQL.CQL_RECAP, "
       cQuery += "       CQL.CQL_PADIS, "
       cQuery += "       CQL.CQL_PADTVD," 
       cQuery += "       CQL.CQL_REIDI, "
       cQuery += "       CQL.CQL_REPENE," 
       cQuery += "       CQL.CQL_REICOM," 
       cQuery += "       CQL.CQL_RETAER," 
       cQuery += "       CQL.CQL_RECINE," 
       cQuery += "       CQL.CQL_RESIDU," 
       cQuery += "       CQL.CQL_RECOPA," 
       cQuery += "       CQL.CQL_COPMUN," 
       cQuery += "       CQL.CQL_RETID, "
       cQuery += "       CQL.CQL_REPNBL," 
       cQuery += "       CQL.CQL_REIF,  "
       cQuery += "       CQL.CQL_OLIMPI "
	Endif 
	cQuery += " FROM " + RetSqlName( "CSZ" ) + " CSZ "
	If lTabCQL
		cQuery += ", " + RetSqlName( "CQL" ) + " CQL "
	Endif		
	cQuery += " WHERE CSZ.D_E_L_E_T_ = ' '"
	cQuery	+= " AND CSZ_FILIAL = '" + cFilCSZ + "'"
	cQuery += " AND CSZ_CODREV = '" + cRevisao	+ "'"
	If lTabCQL
	   cQuery += "AND CQL.CQL_FILIAL =CSZ.CSZ_FILIAL  "
	   cQuery += "AND CQL.CQL_CODID= CSZ_IDRG21       "
	   cQuery += "AND CQL.CQL_FILIAL =CSZ.CSZ_FILIAL  "
	   cQuery += "AND CQL.D_E_L_E_T_	= ' '         "		
	Endif	
	cQuery 		:= ChangeQuery( cQuery )
	
	cAliasCSZ 	:= GetNextAlias()
	
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCSZ )	
Endif

//-----------------------------------------------------
// Exporta Dados parea tabela TAFST1
//-----------------------------------------------------
If (cAliasCSZ)->(!Eof()) .AND. (cAliasCSZ)->CSZ_FILIAL == cFilCSZ
	If ( oProcess <> Nil ) 
		oProcess:IncRegua2( "Revisใo: " + (cAliasCSZ)->CSZ_CODREV ) //"Revisใo: "
	EndIf
	
	//Montagem campo TAFMSG	
	cMsg := ''
	cMsg := '|' + 'T127'								// REGISTRO
	cMsg += '|' + ( cAliasCSZ)->CSZ_DTINI 		   		// DT_INI
	cMsg += '|' + ( cAliasCSZ)->CSZ_DTFIM    			// DT_FIN
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_SITPER ) 	// IND_SIT_INI_PER
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_SITESP )   	// SIT_ESPECIAL
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_PATREM )   	// PAT_REMAN_CIS
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_DTSITE )	// DT_SIT_ESP 
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_TIPECF )   	// TIP_ECF
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_CODSCP )   	// COD_SCP
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_APTREF )   	// OPT_REFIS
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_APTPAE )   	// OPT_PAES
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_FMTRIB )   	
	
	If !((cAliasCSZ)->CSZ_FMTRIB $ '8|9') 				// COD_QUALIF_PJ
		cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_FMAPUR )   	// FORMA_APUR
		cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_QUALPJ )   	
	Else
		cMsg += '|'
		cMsg += '|'  
	EndIf
	 
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_FMTPER )   	// FORMA_TRIB_PER
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_MESBRE )   	// MES_BAL_RED
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_TPESCR )   	// TIP_ESC_PRE
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_TPENTI )   	// TIP_ENT
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_FMAPUI )   	// FORMA_APUR_I
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_APUCSL )   	// APUR_CSLL
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_EXTRTT )   	// OPT_EXT_RTT  		
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_DIFFCO )   	// DIF_FCONT
	
	If AllTrim( (cAliasCSZ)->CSZ_ALICSL  ) == "0"
		cMsg += '|'
	Else
		cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_ALICSL )   	// IND_ALIQ_CSLL
	EndIf

	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_QTDSCP )   	// IND_QTE_SCP
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_ADMCLU )   	// IND_ADM_FUN_CLU
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_PARTCO )   	// IND_PART_CONS
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_OPEXT  )   	// IND_OP_EXT
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_OPVINC )   	// IND_OP_VINC
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_PJENQU )   	// IND_PJ_ENQUAD
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_PARTEX )   	// IND_PART_EXT
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_ATIVRU )   	// IND_ATIV_RURAL
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_LUCEXP )   	// IND_LUC_EXP
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_REDISE )   	// IND_RED_ISEN
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_FIN    )   	// IND_FIN
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_DOAELE )   	// IND_DOA_ELEIT
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_PCOLIG )   	// IND_PART_COLIG
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_VENEXP )   	// IND_VEND_EXP
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_RECEXT )   	// IND_ REC_EXT
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_ATIVEX )   	// IND_ATIV_EXT
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_COMEXP )   	// IND_COM_EXP
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_PGTOEX )   	// IND_PGTO_EXT
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_ECOMTI )   	// IND_E-COM_TI
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_ROYREC )   	// IND_ROY_REC
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_ROYPAG ) 	// IND_ROY_PAG
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_RENDSE )   	// IND_REND_SERV
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_PGTORE )   	// IND_PGTO_REM
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_INOVTE )   	// IND_INOV_TEC
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_CAPINF )   	// IND_CAP_INF
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_PJHAB  )   	// IND_PJ_HAB
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_POLOAM )   	// IND_POLO_AM
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_ZONEXP )   	// IND_ZON_EXP
	cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_AREACO )   	// IND_AREA_COM
	cMsg += "|"												//ID da SCP
	If VAL(CS0->CS0_LEIAUT) >=3
		cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_REGIME )   	// Ind.Rec.Rec
		cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_DEPAIS )   	// Ind. Pais
	Endif 
	If lTabCQL
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_REPES  )   	//Reg.Esp.Trib
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_RECAP  )   	//Reg.Esp.ABCE
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_PADIS  )   	//Prg.Apo.Des.
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_PADTVD )   	//Prg.PATVD
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_REIDI  )   	//Reg.Esp.Infr
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_REPENE )   	//Reg.REPENEC
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_REICOM )   	//R.Esp.Cmp.Ed
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_RETAER )   	//Reg.Esp.Aero
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_RECINE )   	//Reg.Esp.Cine
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_RESIDU )   	//Reg.Res.Soli
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_RECOPA )   	//R.E.RECOPA
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_COPMUN )   	//Hab.Copa.Mud
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_RETID  )   	//Reg.Ind.Dfsa
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_REPNBL )   	//R.E.PNBLIRT
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_REIF   )   	//Ind. Reif
		cMsg += '|' + Alltrim( (cAliasCSZ)->CQL_OLIMPI )   	//Hab.Jog.Olmp
	Else
		If VAL(CS0->CS0_LEIAUT) >=3
			cMsg += '|' 												//Reg.Esp.Trib
			cMsg += '|' 												//Reg.Esp.ABCE
			cMsg += '|' 												//Prg.Apo.Des.
			cMsg += '|' 												//Prg.PATVD
			cMsg += '|' 												//Reg.Esp.Infr
			cMsg += '|'  												//Reg.REPENEC
			cMsg += '|' 												//R.Esp.Cmp.Ed
			cMsg += '|' 												//Reg.Esp.Aero
			cMsg += '|' 												//Reg.Esp.Cine
			cMsg += '|' 												//Reg.Res.Soli
			cMsg += '|' 												//R.E.RECOPA
			cMsg += '|' 												//Hab.Copa.Mud
			cMsg += '|'  												//Reg.Ind.Dfsa
			cMsg += '|' 												//R.E.PNBLIRT
			cMsg += '|' 												//Ind. Reif
			cMsg += '|' 												//Hab.Jog.Olmp
		Endif  
	Endif  
	If VAL(CS0->CS0_LEIAUT) >=4
		cMsg += '|' + Alltrim( (cAliasCSZ)->CSZ_DEREX )   	//DEREX
	EndIf
	cMsg += "|"	
	
	//Monta a chave do registro

	cKey := (cAliasCSZ)->CSZ_FILIAL + (cAliasCSZ)->CSZ_CODREV + 'T127' 
	
	//Grava Dados na tabela TAFST1
	lRet := EcfGrvSt1(cAlias, cFilCSZ, cKey, 'T127', cMsg)	
EndIf

RestArea(aArea)
	
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcfExpSCP   บAutorณFelipe Cunha 		  บ Data ณ  01/01/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta Dados de Identifica็ใo das SCP	                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS103                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcfExpSCP(oProcess, cRevisao, cAlias)
Local aArea		:= GetArea()
Local cAliasCSR	:= "CSR"
Local cFilCSR   := xFilial( "CSR" )
Local cMsg		:= ''
Local cQuery	:= ''
Local cKey		:= ''
Local cCnpj     := ''
Local cAliasCVS := ''
Local cIdtScp   := ''
Local cDataLib  := ''
Local lRet		:= .T.
Local nPos      := 0
Local nlA       := 0
Local aChkDpl   := {}
Local aUtilFlds := { "M0_CGC" }
Local aUtilData := {}

Default oProcess	:= Nil
Default cRevisao 	:= ''
Default cAlias		:= 'TAFST1'

//-----------------------------------------------------
// Barra de Progresso
//-----------------------------------------------------
If oProcess <> Nil
	oProcess:IncRegua1( "Exportando Identifica็ใo das SCP - 0035" )
	oProcess:SetRegua2(0)	
	oProcess:IncRegua2( '' )
Endif

//-----------------------------------------------------
// Seleciona Dados
//-----------------------------------------------------
If __lDefTop
	cQuery := '' 
	cQuery := "SELECT CSR.CSR_FILIAL,"
	cQuery += "       CSR.CSR_CODREV,"
	cQuery += "       CSR.CSR_IDTSCP,"				
	cQuery += "       CSR.CSR_NOMSCP "							
	cQuery += " FROM " + RetSqlName( "CSR" ) + " CSR "		
	cQuery += " WHERE CSR.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND CSR_FILIAL = '" + cFilCSR + "'"
	cQuery += " AND CSR_CODREV = '" + cRevisao	+ "'"
	
	cQuery := ChangeQuery( cQuery + " ORDER BY " + SqlOrder(CSR->(IndexKey())))
	cAliasCSR := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCSR )	
EndIf

//-----------------------------------------------------
// Exporta Dados parea tabela TAFST1
//-----------------------------------------------------
// T001
cMsg := ''
cMsg := "|" + 'T001'			//01 REGISTRO
cMsg += "|"	+ cEmpAnt + cFilAnt	//02 GRUPO EMPRESA+FILIAL  CADASTRADO NO COMPLEMENTO DE EMPRESA DO TAF
for nlA := 3 to 32 //Da posicao 03 ate 32 (vide extfisxtaf)
	cMsg += "|" + NAO_GRAVAR //30x
next nlA

While (cAliasCSR)->CSR_FILIAL == cFilCSR .AND. (cAliasCSR)->(!Eof())
	If oProcess <> Nil 
		oProcess:IncRegua2( "SCP: "+ (cAliasCSR)->CSR_NOMSCP ) //"SCP: "
	EndIf
	
	cIdtScp := Alltrim( (cAliasCSR)->CSR_IDTSCP)
	aadd( aChkDpl, cIdtScp )

	//Montagem campo TAFMSG	
	//T001AM
	cMsg += CRLF
	cMsg += "|" + 'T001AM'								//REGISTRO
	cMsg += "|" + cIdtScp								//COD_SCP
	cMsg += "|" + Alltrim( (cAliasCSR)->CSR_NOMSCP)		//DESC_SCP
	cMsg += "|" + '.'									//INF_COMP
	cMsg += "|"		
	
	//Monta a chave do registro
	cKey := (cAliasCSR)->CSR_FILIAL + (cAliasCSR)->CSR_CODREV + 'T001' + (cAliasCSR)->CSR_IDTSCP
	
	//Grava Dados na tabela TAFST1
	lRet := EcfGrvSt1(cAlias, cFilCSR, cKey, 'T001', cMsg)
	
	(cAliasCSR)->( dbSkip() )	
EndDo

(cAliasCSR)->(dbCloseArea())

//Obtem o CNPJ da SCP que esta sendo processada
If FindFunction( "FWLibVersion" )
	cDataLib := FWLibVersion()
Else
	//Verifica data de um fonte da LIB que foi alterado na release 12.1.005
	cDataLib := DToS( GetAPOInfo( "PROTHEUSFUNCTIONMVC.PRX" )[4] )
EndIf
if cDataLib >= "20210104"
	aUtilData := FWSM0Util():GetSM0Data( cEmpAnt , cFilAnt , aUtilFlds )
else
	aadd( aUtilData, { SM0->M0_CODIGO + SM0->M0_CODFIL, SM0->M0_CGC } )
Endif
if len(aUtilData) > 0
	if len(aUtilData[1][2]) == 14
		cCnpj := aUtilData[1][2]
	endif
endif
//Verifica CVS caso exista sera necessario enviar o T001AM para gravar a CUW(SCP) no TAF. 
//Obs Cliente vinculou SCP da filial 02 na filial 01 (a tabela CVS consta totalmente exclusiva) 
//e esta gerando na central de obrigacao, apenas a SCP com tudo vinculado na filial 02 
//(filial logada, apenas essa filial selecionada e seu proprio Nr de SCP).
if !Empty( cCnpj )
	If __lDefTop
		cQuery := "SELECT"
		cQuery += " CVS.CVS_IDTSCP, CVS.CVS_NOMSCP "
		cQuery += " FROM " + RetSqlName( "CVS" ) + " CVS "
		cQuery += " WHERE CVS.D_E_L_E_T_ = ' ' "
		cQuery += " AND CVS_IDTSCP = '" + cCnpj	+ "'"
		cQuery := ChangeQuery( cQuery + " ORDER BY CVS.R_E_C_N_O_ DESC " )
		cAliasCVS := GetNextAlias()
		dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCVS )
	EndIf
	if (cAliasCVS)->(!Eof()) //verifica se a scp esta vinculada a qualquer filial.
		cIdtScp := Alltrim( (cAliasCVS)->CVS_IDTSCP)
		nPos := aScan( aChkDpl, {|x| x == cIdtScp } )
		if nPos == 0
			If oProcess <> Nil
				oProcess:IncRegua2( "SCP: "+ (cAliasCVS)->CVS_NOMSCP ) //"SCP: "
			EndIf			
			//Montagem campo TAFMSG T001AM
			cMsg += CRLF
			cMsg += "|" + 'T001AM'							//REGISTRO
			cMsg += "|" + cIdtScp							//COD_SCP
			cMsg += "|" + Alltrim( (cAliasCVS)->CVS_NOMSCP)	//DESC_SCP
			cMsg += "|" + '.'								//INF_COMP
			cMsg += "|"
			//Monta a chave do registro
			cKey := cFilAnt + RetSqlName( "CVS" ) + 'T001' + (cAliasCVS)->CVS_IDTSCP
			//Grava Dados na tabela TAFST1
			lRet := EcfGrvSt1(cAlias, cFilAnt, cKey, 'T001', cMsg)
		endif
	endif
	(cAliasCVS)->(dbCloseArea())
endif

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcfExpSign   บAutorณFelipe Cunha 		  บ Data ณ  01/01/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta Dados de Signatแrio				                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS103                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcfExpSign(oProcess, cRevisao, cAlias)
Local aArea		:= GetArea()
Local cAliasCS8	:= "CS8"
Local cFilCS8   := xFilial( "CS8" )
Local cMsg		:= ''
Local cQuery	:= ''
Local cKey		:= ''
Local lRet		:= .T.

Default oProcess	:= Nil
Default cRevisao 	:= ''
Default cAlias		:= 'TAFST1'

//-----------------------------------------------------
// Barra de Progresso
//-----------------------------------------------------
If oProcess <> Nil
	oProcess:IncRegua1( "Exportando Signatแrios - 0930" )
	oProcess:SetRegua2(0)	
	oProcess:IncRegua2( '' )
Endif

//-----------------------------------------------------
// Seleciona Dados
//-----------------------------------------------------
If __lDefTop
	cQuery := '' 
	cQuery := "SELECT CS8.CS8_FILIAL,"
	cQuery += "       CS8.CS8_CODREV,"
	cQuery += "       CS8.CS8_CODSIG,"				
	cQuery += "       CS8.CS8_NOME,  "
	cQuery += "       CS8.CS8_CPF,   "  
	cQuery += "       CS8.CS8_CGC,   "
	cQuery += "       CS8.CS8_QUALIF,"
	cQuery += "       CS8.CS8_CODASS,"
	cQuery += "       CS8.CS8_CRC,   "
	cQuery += "       CS8.CS8_EMAIL, "
	cQuery += "       CS8.CS8_FONE   "							
	cQuery += " FROM " + RetSqlName( "CS8" ) + " CS8 "		
	cQuery += " WHERE CS8.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND CS8_FILIAL = '" + cFilCS8 + "'"
	cQuery += " AND CS8_CODREV = '" + cRevisao	+ "'"
	
	cQuery := ChangeQuery( cQuery + " ORDER BY " + SqlOrder(CS8->(IndexKey())))
	cAliasCS8 := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCS8 )	
EndIf

//-----------------------------------------------------
// Exporta Dados parea tabela TAFST1
//-----------------------------------------------------
While (cAliasCS8)->CS8_FILIAL == cFilCS8 .AND. (cAliasCS8)->(!Eof())
	If oProcess <> Nil 
		oProcess:IncRegua2( "Signatแrio: "+ (cAliasCS8)->CS8_NOME ) //"Signatแrio: "
	EndIf
	
	//Montagem campo TAFMSG	
	cMsg := ''
	cMsg := "|" + 'T002'								//REGISTRO
	
	If Alltrim( (cAliasCS8)->CS8_CPF) != ''
		cMsg += "|1"									//TP_ESTAB
	Else
		cMsg += "|2"									//TP_ESTAB
	EndIf
	
	cMsg += "|" + Alltrim( (cAliasCS8)->CS8_NOME)		//NOME
	cMsg += "|" + Alltrim( (cAliasCS8)->CS8_CPF)		//CPF
	cMsg += "|" + AllTrim( (cAliasCS8)->CS8_CRC)		//CRC
	cMsg += "|" + Alltrim( (cAliasCS8)->CS8_CGC)		//CNPJ
	cMsg += "|"											//CEP 			- Nใo necessแrio para ECF
	cMsg += "|"											//TP_LOGR 		- Nใo necessแrio para ECF
	cMsg += "|"											//END 			- Nใo necessแrio para ECF
	cMsg += "|"											//NUM 			- Nใo necessแrio para ECF
	cMsg += "|"											//COMPL 		- Nใo necessแrio para ECF
	cMsg += "|"											//TP_BAIRRO 	- Nใo necessแrio para ECF
	cMsg += "|"											//BAIRRO 		- Nใo necessแrio para ECF
	cMsg += "|"											//DDD 			- Nใo necessแrio para ECF
	cMsg += "|" + AllTrim( (cAliasCS8)->CS8_FONE   )	//FONE
	cMsg += "|"											//DDD 			- Nใo necessแrio para ECF
	cMsg += "|"											//FAX 			- Nใo necessแrio para ECF
	cMsg += "|" + AllTrim( (cAliasCS8)->CS8_EMAIL  )	//EMAIL
	cMsg += "|"											//UF 			- Nใo necessแrio para ECF
	cMsg += "|"											//COD_MUN 		- Nใo necessแrio para ECF
	cMsg += "|" + AllTrim( (cAliasCS8)->CS8_CODASS )	//IDENT_QUALIF
	cMsg += "|"		
	
	//Monta a chave do registro
	cKey := (cAliasCS8)->CS8_FILIAL + (cAliasCS8)->CS8_CODREV + 'T002' + (cAliasCS8)->CS8_CODSIG
	
	//Grava Dados na tabela TAFST1
	lRet := EcfGrvSt1(cAlias, cFilCS8, cKey, 'T002', cMsg)
	
	(cAliasCS8)->( dbSkip() )	
EndDo

(cAliasCS8)->(dbCloseArea())

RestArea(aArea)
	
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcfExpCta  บAutorณFelipe Cunha 		  บ Data ณ  01/01/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta Dados de Plano de Contas	/ Plano de Contas Ref.	  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS103                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcfExpCta(oProcess, cRevisao, cAlias )
Local aArea		:= GetArea()
Local cAliasCS3	:= "CS3"
Local cFilCS3  	:= xFilial( "CS3" )
Local cMsg		:= ''
Local cQuery	:= ''
Local cWhere	:= ''
Local cKey		:= ''
Local cTabPlRef := ''
Local cAnt		:= ''
Local lRet		:= .T.
Local lRefer	:= .F.
Local cIsNull	:= ''
Local cTipoDB	:= Alltrim(Upper(TCGetDB()))

Default oProcess	:= Nil
Default cRevisao 	:= ''
Default cAlias		:= 'TAFST1'

//-----------------------------------------------------
// Barra de Progresso
//-----------------------------------------------------
If oProcess <> Nil
	oProcess:IncRegua1( "Exportando Plano de Contas - J050/J051/J053" )
	oProcess:SetRegua2(0)
	oProcess:IncRegua2( '' )
Endif

//-------------------------------------------------------
// Tratamento realizado devido aus๊ncia se ChangeQuery() 
//-------------------------------------------------------
If ("INFORMIX" $ cTipoDB) .Or. ("ORACLE" $ cTipoDB)
	cIsNull  := " NVL"
ElseIf ("DB2" $ cTipoDB)  .Or. ("POSTGRES" $ cTipoDB)
	cIsNull := " COALESCE"
Else
	cIsNull := " ISNULL"
EndIf

//-----------------------------------------------------
//Verifica o plano de contas referencial selecionado
//-----------------------------------------------------
cTabPlRef := VerPlanRef(.T.)

DbSelectArea( "CS3" )
DbSetOrder(1)

DbSelectArea( "CS4" )
DbSetOrder(1)

//-----------------------------------------------------
// Seleciona Dados
//-----------------------------------------------------
If __lDefTop
	cQuery := ''
	cWhere := ''
	cQuery := "Select CS3.CS3_FILIAL, "
	cQuery += "       CS3.CS3_CODREV, "
	cQuery += "       CS3.CS3_DTALT,  "
	cQuery += "       CS3.CS3_CODNAT, "
	cQuery += "       CS3.CS3_INDCTA, "
	cQuery += "       CS3.CS3_NIVEL,  "
	cQuery += "       CS3.CS3_CONTA,  "
	cQuery += "       CS3.CS3_NOMECT, "
	cQuery += "       CS3.CS3_CTASUP, "
	If CS3->( FieldPos("CS3_NORMAL") ) > 0
		cQuery += "       CS3.CS3_NORMAL, "
	EndIf

	cQuery += " " + cIsNull + "(CS4.CS4_FILIAL,'') AS CS4_FILIAL, "
	cQuery += " " + cIsNull + "(CS4.CS4_CONTA,'') AS CS4_CONTA,  "
	cQuery += " " + cIsNull + "(CS4.CS4_CCUSTO,'') AS CS4_CCUSTO, "
	cQuery += " " + cIsNull + "(CS4.CS4_CTAREF,'') AS CS4_CTAREF, "
	cQuery += " " + cIsNull + "(CST.CST_FILIAL,'') AS CST_FILIAL, "
	cQuery += " " + cIsNull + "(CST.CST_CODREV,'') AS CST_CODREV, "
	cQuery += " " + cIsNull + "(CST.CST_CTAPAI,'') AS CST_CTAPAI, "
    cQuery += " " + cIsNull + "(CST.CST_CODIDT,'') AS CST_CODIDT, "
    cQuery += " " + cIsNull + "(CST.CST_SUBCTA,'') AS CST_SUBCTA, "
    cQuery += " " + cIsNull + "(CST.CST_NATSUB,'') AS CST_NATSUB  "       			
	cQuery += " FROM "      + RetSqlName( "CS3" ) + " CS3 	"
	cQuery += " LEFT JOIN " + RetSqlName( "CS4" ) + " CS4 	"	
	cQuery += "   ON CS3.CS3_FILIAL    = CS4.CS4_FILIAL   	"
	cQuery += "     AND CS3.CS3_CODREV   = CS4.CS4_CODREV 	"
	cQuery += "     AND CS3.CS3_CONTA    = CS4.CS4_CONTA  	"
	cQuery += "     AND CS4.D_E_L_E_T_   = ' '            	"	
    cQuery += " LEFT JOIN " + RetSqlName( "CST" ) + " CST 	"	
	cQuery += "   ON CS3.CS3_FILIAL = CST.CST_FILIAL		" 
    cQuery += "     AND CS3.CS3_CODREV = CST.CST_CODREV		" 
    cQuery += "     AND CS3.CS3_CONTA = CST.CST_CTAPAI		"
    cQuery += "     AND (CS3.CS3_CONTA = CST.CST_CTAPAI		"
    cQuery += "          OR CS4.CS4_CONTA = CST.CST_CTAPAI )"
    cQuery += "     AND CST.D_E_L_E_T_ = ' ' 				"    
	cQuery += " WHERE CS3.CS3_CODREV = '" + cRevisao	+ "'"
	cQuery	+= " AND CS3_FILIAL = '" + cFilCS3 + "'"
	cQuery += " AND CS3.D_E_L_E_T_   = ' '                  "
	cQuery += "ORDER BY CS3.CS3_FILIAL,CS3.CS3_CODREV,CS3.CS3_CONTA,CS4.CS4_CTAREF,CS4.CS4_CCUSTO"
	
	
	If TCGetDb() == "POSTGRES" .OR. TCGetDb() == "DB2"
		cQuery := ChangeQuery(cQuery) //Nใo retirar 
	EndIf
	cAliasCS3 := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCS3 )	
Endif

//-----------------------------------------------------
// Exporta Dados parea tabela TAFST1
//-----------------------------------------------------
While (cAliasCS3)->CS3_FILIAL == cFilCS3 .AND. (cAliasCS3)->(!Eof())
      
      lRefer      := .F.
      
      If oProcess <> Nil 
            oProcess:IncRegua2( "Plano de Contas: " + (cAliasCS3)->CS3_CONTA )
      EndIf
      
      //Monta a chave do registro
      cKey := (cAliasCS3)->CS3_FILIAL + (cAliasCS3)->CS3_CODREV + 'T010' + (cAliasCS3)->CS3_CONTA

      //Montagem campo TAFMSG - J050
      cMsg := ''
      cMsg := "|" + 'T010'                                              //REGISTRO
      cMsg += "|" + (cAliasCS3)->CS3_DTALT                              //DT_ALT 
      cMsg += "|" + Alltrim((cAliasCS3)->CS3_CODNAT)                    //COD_NAT_CC
      cMsg += "|" + If(Alltrim((cAliasCS3)->CS3_INDCTA) = 'S','0','1') 	//IND_CTA 
      cMsg += "|" + AllTrim(Str((cAliasCS3)->CS3_NIVEL ))				//NอVEL 
      cMsg += "|" + Alltrim((cAliasCS3)->CS3_CONTA )                    //COD_CTA 
      cMsg += "|" + Alltrim((cAliasCS3)->CS3_NOMECT)                    //NOME_CTA
      cMsg += "|"                                                       //COD_CTA_REF     - Nใo necessแrio para ECF
      cMsg += "|"                                                       //CNPJ_EST        - Nใo necessแrio para ECF   
      cMsg += "|" + Alltrim((cAliasCS3)->CS3_CTASUP)                    //COD_CTA_SUP
      cMsg += "|" + (cAliasCS3)->CS3_DTALT			                   //DT_INC
	  If CS3->( FieldPos("CS3_NORMAL") ) > 0
      		cMsg += "|" + (cAliasCS3)->CS3_NORMAL
     Else
      		cMsg += "|" 
     EndIf			                        
      cMsg += "|"

      //Montagem campo TAFMSG - J053
      If (cAliasCS3)->CST_CODIDT != ' ' 
            cMsg += CRLF
            cMsg += "|" + 'T010AB'                                     	//REGISTRO  
            cMsg += "|" +  Alltrim((cAliasCS3)->CST_CODIDT)      		//COD_IDT
            cMsg += "|" +  Alltrim((cAliasCS3)->CST_SUBCTA)      		//COD_CNT_CORR
            cMsg += "|" +  AllTrim(Str(Val((cAliasCS3)->CST_NATSUB)))  	//NAT_SUB_CNT
      		cMsg += "|" +  Alltrim(Str(Year(CS0->CS0_DTFIM)))   		//DT_INC            
            cMsg += "|" 
      EndIf
      
      //Montagem campo TAFMSG - J051
      If (cAliasCS3)->CS4_CTAREF != ' ' 
            
            cAnt := Alltrim((cAliasCS3)->CS3_CONTA )
            
            While cAnt == Alltrim((cAliasCS3)->CS3_CONTA )
                  cMsg += CRLF
                  cMsg += "|" + 'T010AA'                                           //REGISTRO
                  cMsg += "|" + Alltrim((cAliasCS3)->CS4_CCUSTO)       //COD_CCUS
                  
                  //Este ponto serแ alterado no release 12.1.5, unificando os codigos
                  If (cAliasCSZ)->CSZ_FMTRIB $ "1/2"                 
                        If (cAliasCS3)->CS3_CODNAT == "04"
                             cMsg += "|" + StrZero(Val(cTabPlRef) + 3,2)    //TAB_ECF
                        Else
                             cMsg += "|" + cTabPlRef                        //TAB_ECF
                        EndIf
				ElseIf (cAliasCSZ)->CSZ_FMTRIB $ "3/4/5/7"                 
                        If (cAliasCS3)->CS3_CODNAT == "04"
                             cMsg += "|" + StrZero(Val(cTabPlRef) + 1,2)    //TAB_ECF
                        Else
                             cMsg += "|" + cTabPlRef                              //TAB_ECF
                        EndIf
                  ElseIf (cAliasCSZ)->CSZ_FMTRIB $ '8|9'
                        If (cAliasCS3)->CS3_CODNAT == "04"
                             cMsg += "|" + StrZero(Val(cTabPlRef) + 5,2)                
                        Else              
                             cMsg += "|" + cTabPlRef
                        EndIf
                  EndIf
                  
                  cMsg += "|" + Alltrim((cAliasCS3)->CS4_CTAREF)	//COD_CTA_REF
                  cMsg += "|" + Alltrim(Str(Year(CS0->CS0_DTFIM)))	//DT_INC
                  cMsg += "|"
                  
                  cAnt := Alltrim((cAliasCS3)->CS3_CONTA )
                  
                  (cAliasCS3)->( dbSkip() )
                  lRefer := .T.
            EndDo
      EndIf
      
      //Grava Dados na tabela TAFST1
      lRet := EcfGrvSt1(cAlias, cFilCS3, cKey, 'T010', cMsg)
                  
      
      If !(lRefer)
            (cAliasCS3)->( dbSkip() )
      EndIf
EndDo	

(cAliasCS3)->(dbCloseArea())

RestArea(aArea)
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcfExpCust  บAutorณFelipe Cunha 		  บ Data ณ  01/01/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta Dados de Centro de Custo				              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS103                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcfExpCust(oProcess, cRevisao, cAlias )
Local aArea		:= GetArea()
Local cAliasCS5	:= "CS5"
Local cFilCS5  	:= xFilial( "CS5" )
Local cMsg		:= ''
Local cQuery	:= ''
Local cKey		:= ''
Local lRet		:= .T.

Default oProcess	:= Nil
Default cRevisao 	:= ''
Default cAlias		:= 'TAFST1'

//-----------------------------------------------------
// Barra de Progresso
//-----------------------------------------------------
If oProcess <> Nil
	oProcess:IncRegua1( "Exportando Centro de Custo - J100" )
	oProcess:SetRegua2(0)
	oProcess:IncRegua2( '' )
Endif

DbSelectArea( "CS5" )
DbSetOrder(1)

//-----------------------------------------------------
// Seleciona Dados
//-----------------------------------------------------
If __lDefTop
	//Query sele็ใo Dados
	cQuery := ''
	cQuery := "SELECT CS5.CS5_FILIAL,"
	cQuery += "       CS5.CS5_CODREV,"
	cQuery += "       CS5.CS5_DTALT, "
	cQuery += "       CS5.CS5_CUSTO, "
	cQuery += "       CS5.CS5_NOME   "		
	cQuery += " FROM " + RetSqlName( "CS5" ) + " CS5 "
	cQuery += " WHERE CS5.D_E_L_E_T_ = ' ' "
	cQuery	+= " AND CS5_FILIAL = '" + cFilCS5 + "'"
	cQuery += " AND CS5_CODREV       = '" + cRevisao	+ "'"
	
	cQuery := ChangeQuery( cQuery + " ORDER BY " + SqlOrder(CS5->(IndexKey())))
	cAliasCS5 := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCS5 )	
Endif

//-----------------------------------------------------
// Exporta Dados parea tabela TAFST1
//-----------------------------------------------------
While (cAliasCS5)->CS5_FILIAL == cFilCS5 .AND. (cAliasCS5)->(!Eof())
	If oProcess <> Nil
		oProcess:IncRegua2( "Centro de Custo: " + Alltrim((cAliasCS5)->CS5_CUSTO)) 
	EndIf
	
	//Montagem campo TAFMSG
	cMsg := ''
	cMsg := "|" + 'T011'							//REGISTRO
	cMsg += "|" + Alltrim((cAliasCS5)->CS5_DTALT)	//DT_ALT 
	cMsg += "|" + Alltrim((cAliasCS5)->CS5_CUSTO)	//CCOD_CCUS
	cMsg += "|" + Alltrim((cAliasCS5)->CS5_NOME)	//CCUS 	
	cMsg += "|" + Alltrim((cAliasCS5)->CS5_DTALT)	//DT_INC	
	cMsg += "|"
	
	//Monta a chave do registro
	cKey := (cAliasCS5)->CS5_FILIAL + (cAliasCS5)->CS5_CODREV + 'T011' + (cAliasCS5)->CS5_CUSTO

	//Grava Dados na tabela TAFST1
	lRet := EcfGrvSt1(cAlias, cFilCS5, cKey, 'T011', cMsg)
	
	(cAliasCS5)->( dbSkip() )
EndDo

(cAliasCS5)->(dbCloseArea())
	
RestArea(aArea)
	
Return lRet
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcfExpSldC  บAutorณFelipe Cunha 		  บ Data ณ  01/01/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta Dados de Saldos Contabeis			              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS103                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcfExpSldC(oProcess, cRevisao, cAlias, cBloco)
Local aArea		:= GetArea()
Local cAliasCSC	:= "CSC"
Local cFilCSC  	:= xFilial( "CSC" )
Local cFilCSK		:= xFilial( "CSK" )
Local cMsg		:= ''
Local cQuery	:= ''
Local cKey		:= ''
Local cAnt		:= ''	//Controle de Identifca็ใo do Perํodo
Local cTab		:= ''
Local cTabRef	:= ''  
Local cTabPlRef	:= ''
Local lRet		:= .T.
Local cSeq		:= '001'

Default oProcess	:= Nil
Default cRevisao 	:= ''
Default cAlias		:= 'TAFST1'
Default cBloco		:= ''

//-----------------------------------------------------
//Verifica o plano de contas referencial selecionado
//-----------------------------------------------------
cTabPlRef := VerPlanRef(.T.)


//-----------------------------------------------------
// Barra de Progresso
//-----------------------------------------------------
If oProcess <> Nil
	oProcess:IncRegua1( "Exportando Saldos Contabeis" )
	oProcess:SetRegua2(0)
	oProcess:IncRegua2( '' )
Endif

DbSelectArea( "CSC" )
DbSetOrder(1)

//-----------------------------------------------------
// Seleciona Dados
//-----------------------------------------------------
If __lDefTop
	//Query sele็ใo Dados
	cQuery := ''
	cQuery := "	SELECT CSC.CSC_FILIAL,	"
	cQuery += "		   CSC.CSC_CODREV,	"
	cQuery += "		   CSC.CSC_PERIOD,	"
	cQuery += "		   CSC.CSC_DTINI,	"
	cQuery += "		   CSC.CSC_DTFIM,	"
	cQuery += "		   CSC.CSC_REGIST,	"
	cQuery += "		   CSC.CSC_CONTA,	"
	cQuery += "		   CSC.CSC_CCUSTO,	"
	cQuery += "		   CSC.CSC_VALINI,	"
	cQuery += "		   CSC.CSC_INDINI,	"
	cQuery += "		   CSC.CSC_VALDEB,	"
	cQuery += "		   CSC.CSC_VALCRE,	"
	cQuery += "		   CSC.CSC_VALFIN,	"
	cQuery += "		   CSC.CSC_INDFIM,	"
	cQuery += "		   CSC.CSC_CLASSE,	"
	cQuery += "		   CSK.CSK_FILIAL,	"
	cQuery += "		   CSK.CSK_CODREV,	"
	cQuery += "		   CSK.CSK_PERIOD,	"
	cQuery += "		   CSK.CSK_CTAREF,	"
	cQuery += "		   CSK.CSK_VALFIN,	"
	cQuery += "		   CSK.CSK_INDFIM,	"
	cQuery += "		   CSK.CSK_PERIOD,	"
	cQuery += "		   CSK.CSK_REGIST,	"
	cQuery += "		   CSK.CSK_CLASSE,	"	
	cQuery += "		   CSK.CSK_VALINI,	"
	cQuery += "		   CSK.CSK_INDINI,	"
	cQuery += "		   CSK.CSK_VALDEB,	"
	cQuery += "		   CSK.CSK_VALCRE	"	
	cQuery += "  FROM " + RetSqlName( "CSC" ) + " CSC," +  RetSqlName( "CSK" ) + " CSK "	
	cQuery += "	 WHERE CSC.CSC_FILIAL = CSK.CSK_FILIAL	"
	cQuery += "	 AND   CSC.CSC_CODREV = CSK.CSK_CODREV	"
	cQuery += "	 AND   CSC.CSC_CONTA  = CSK.CSK_CONTA	"	
	cQuery += "	 AND   CSC.CSC_CCUSTO = CSK.CSK_CCUSTO	"
	cQuery += "	 AND   CSC.CSC_PERIOD = CSK.CSK_PERIOD	"
	cQuery += "  AND   CSC.CSC_CLASSE = CSK.CSK_CLASSE  "
	cQuery += "  AND   CSC.CSC_VALINI = CSK.CSK_VALINI  "
	cQuery += "  AND   CSC.CSC_INDINI = CSK.CSK_INDINI  "
	cQuery += "  AND   CSC.CSC_VALDEB = CSK.CSK_VALDEB  "
	cQuery += "  AND   CSC.CSC_VALCRE = CSK.CSK_VALCRE  "
	cQuery += "	 AND   CSC.D_E_L_E_T_ = ' '				"
	cQuery += "	 AND   CSK.D_E_L_E_T_ = ' '				"	
	cQuery	+= "	 AND 	CSC_FILIAL = '" + cFilCSC + "'"	
	cQuery += "	 AND   CSC_CODREV     = '" + cRevisao	+ "'"
	cQuery	+= "	 AND 	CSK_FILIAL = '" + cFilCSK + "'"
	cQuery += "	 AND   CSK_CODREV     = '" + cRevisao	+ "'"

	If cBloco == 'K'
		cQuery += "	  AND CSC_CLASSE   = '2' "
		cQuery += "	  AND CSK_CLASSE   = '2' "
		cQuery += "	  AND ( (CSC.CSC_REGIST = 'K155' AND CSK.CSK_REGIST = 'K156') OR (CSC.CSC_REGIST = 'K355' AND CSK.CSK_REGIST = 'K356') ) " 		 	
	EndIf

	cQuery += "	  Order By  CSC.CSC_PERIOD, CSC.CSC_REGIST, CSC.CSC_CONTA, CSC.CSC_CCUSTO"

	cQuery := ChangeQuery( cQuery )
	cAliasCSC := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCSC )	
Endif

//-----------------------------------------------------
// Grava Dados TAFST1
//-----------------------------------------------------
While (cAliasCSC)->CSC_FILIAL == cFilCSC .AND. (cAliasCSC)->(!Eof())

	//Monta a chave do registro
	cKey := (cAliasCSC)->CSC_FILIAL + (cAliasCSC)->CSC_CODREV + 'T087' + (cAliasCSC)->CSC_PERIOD	

	//----------------------------------------
	// K030 - Identifica็ใo do Periodo
	//----------------------------------------	
	//Montagem campo TAFMSG
	cMsg := ''
	cMsg := "|" + 'T087'							//REGISTRO
	cMsg += "|" + Alltrim((cAliasCSC)->CSC_DTINI)	//DT_INI
	cMsg += "|" + Alltrim((cAliasCSC)->CSC_DTFIM)	//DT_FIM
	cMsg += "|" + Alltrim((cAliasCSC)->CSC_PERIOD)	//PER_APUR 		
	cMsg += "|"	
	
	cAnt 	:= (cAliasCSC)->CSC_PERIOD
	cSeq	:=  '001'
		
	While cAnt == (cAliasCSC)->CSC_PERIOD
	
		//Identifica as tabelas de destino	
		If (cAliasCSC)->CSC_REGIST = 'K155'
			cTab 	:= 'T087AA' 
			cTabRef := 'T087AB'
		ElseIf (cAliasCSC)->CSC_REGIST = 'K355'
			cTab 	:= 'T087AC'
			cTabRef := 'T087AD'
		EndIf
	
		If oProcess <> Nil
			oProcess:IncRegua1( "Exportando Saldos Contabeis - " + (cAliasCSC)->CSC_REGIST )
			oProcess:IncRegua2( "Saldos Contแbeis: " + Alltrim((cAliasCSC)->CSC_PERIOD) + " / " + Alltrim((cAliasCSC)->CSC_CONTA)) 
		EndIf
		
		//------------------------------------------------
		// Somente pula linha na primeira sequencia
		// As demais nใo tem cabe็alho
		//------------------------------------------------
		If !Empty(cMsg)
			cMsg += CRLF
		EndIf
		
		cMsg += "|" + cTab									//REGISTRO
		cMsg += "|" + Alltrim((cAliasCSC)->CSC_CONTA)		//COD_CTA
		cMsg += "|" + Alltrim((cAliasCSC)->CSC_CCUSTO)		//COD_CCUS
		
		If (cAliasCSC)->CSC_REGIST = 'K155'
			cMsg += "|" + AllTrim(Str((cAliasCSC)->CSC_VALINI))				//VL_SLD_INI
			cMsg += "|" + If(Alltrim((cAliasCSC)->CSC_INDINI) = 'D','1','2')//IND_VL_SLD_INI
			cMsg += "|" + AllTrim(Str((cAliasCSC)->CSC_VALDEB))				//VL_DEB
			cMsg += "|" + AllTrim(Str((cAliasCSC)->CSC_VALCRE))				//VL_CRED
		EndIf
		
		cMsg += "|" + AllTrim(Str((cAliasCSC)->CSC_VALFIN))				//VL_SLD_FIN
		cMsg += "|" + If(Alltrim((cAliasCSC)->CSC_INDFIM) = 'D','1','2')//IND_VL_SLD_FIN
		cMsg += "|"
		
		cAnt := (cAliasCSC)->CSC_PERIOD
		
		// K156/K356
		cMsg += CRLF
		cMsg += "|" + cTabRef										//REGISTRO
		
		//Este ponto serแ alterado no release 12.1.5, unificando os codigos
		//cMsg += "|" + cTabPlRef									//TAB_ECF
		If (cAliasCSZ)->CSZ_FMTRIB $ '1/2'			
			If (cAliasCSC)->CSC_REGIST = 'K355'
				cMsg += "|" + StrZero(Val(cTabPlRef) + 3,2)			//TAB_ECF
			Else
				cMsg += "|" + cTabPlRef								//TAB_ECF
			EndIf
		ElseIf (cAliasCSZ)->CSZ_FMTRIB $ '3/4/5/7'			
			If (cAliasCSC)->CSC_REGIST = 'K355'
				cMsg += "|" + StrZero(Val(cTabPlRef) + 1,2)			//TAB_ECF
			Else
				cMsg += "|" + cTabPlRef								//TAB_ECF
			EndIf
		ElseIf (cAliasCSZ)->CSZ_FMTRIB $ '8|9'
			If (cAliasCSC)->CSC_REGIST = 'K355'
				cMsg += "|" + StrZero(Val(cTabPlRef) + 5,2)			
			Else			
				cMsg += "|" + StrZero(Val(cTabPlRef),2)	
			EndIf
		EndIf
		
		cMsg += "|" + Alltrim((cAliasCSC)->CSK_CTAREF)					//COD_CTA_REF
		cMsg += "|" + AllTrim(Str((cAliasCSC)->CSK_VALFIN))				//VL_SLD_FIN
		cMsg += "|" + If(Alltrim((cAliasCSC)->CSK_INDFIM) = 'D','1','2')//IND_VL_SLD_FIN
				
		//Altera็ใo layout 5 - 2018/2019
		If (cAliasCSC)->CSK_REGIST = 'K156'
			If VAL(CS0->CS0_LEIAUT) >= 5
				cMsg += "|" + AllTrim(Str((cAliasCSC)->CSK_VALINI))				//VL_SLD_INI - 3		
				cMsg += "|" + If(Alltrim((cAliasCSC)->CSK_INDINI) = 'D','1','2')//IND_VL_SLD_INI - 4
				cMsg += "|" + AllTrim(Str((cAliasCSC)->CSK_VALDEB))				//VL_DEB - 5
				cMsg += "|" + AllTrim(Str((cAliasCSC)->CSK_VALCRE))				//VL_CRED - 6				
			Endif
		Endif
		
		cMsg += "|"
		
		//Tratamento para gravar os dados na tabela TAFST1 
		// quando ultrapassar 10000 registros
		If Len( cMsg ) > 10000
			lRet := EcfGrvSt1(cAlias, cFilCSC, cKey, 'T087', cMsg ,cSeq)
			lUpdSt1 := .T.
			cMsg := ""
			cSeq := Soma1(cSeq)
			
		EndIf
		
		(cAliasCSC)->( dbSkip() )
	EndDo
	
	cMsg := cMsg + " "
	
	//Grava Dados na tabela TAFST1
	lRet := EcfGrvSt1(cAlias, cFilCSC, cKey, 'T087', cMsg , cSeq)
	
	lUpdSt1 := .F.
EndDo

(cAliasCSC)->(dbCloseArea())

RestArea(aArea)
	
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcfExpSldR  บAutorณFelipe Cunha 		  บ Data ณ  01/01/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta Dados de Saldo Contas Referencias	              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS103                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcfExpSldR(oProcess, cRevisao, cAlias, cBloco )
Local aArea		:= GetArea()
Local cAliasCSK	:= "CSK"
Local aForTrib		:= {}
Local cFilCSK  	:= xFilial( "CSK" )
Local cMsg		:= ''
Local cMsgA		:= ''
Local cQuery	:= ''
Local cWhere	:= ''
Local cOrder	:= ''	
Local cGroup	:= ''
Local cKey		:= ''
Local lRet		:= .T.
Local cTab1		:= ''
Local cTab2		:= ''
Local cTab3		:= ''
Local cAnt		:= ''
Local cTabPlRef	:= ''
Local cContaRef := ''
Local cRegist	:= ''
Local cIndIni	:= ''
Local cIndFim	:= ''
Local nValIni	:= 0
Local nValFim	:= 0
Local nValIniD:= 0
Local nValIniC:= 0
Local nValFimD:= 0
Local nValFimC:= 0
Local nValDeb := 0
Local nValCre := 0
Local nReg		:= 0
Local nX		:= 0
Local dDataIni	:= ''
Local dDataFin	:= ''

Default oProcess	:= Nil
Default cRevisao 	:= ''
Default cAlias		:= 'TAFST1'
Default cBloco 		:= ''

//-----------------------------------------------------
// Barra de Progresso
//-----------------------------------------------------
If oProcess <> Nil
	If cBloco == 'L'
		oProcess:IncRegua1( "Exp. Dem. L030/L100/L210/L300" )
	ElseIf cBloco == 'P'
		oProcess:IncRegua1( "Exp. Dem. P030/P130/P150/P200/P230/P300/P400/P500" )
	ElseIf cBloco == 'U'
		oProcess:IncRegua1( "Exp. Dem. U030/U100/U150/U180/ U182" )
	EndIf
	
	oProcess:SetRegua2(0)
	oProcess:IncRegua2( '' )	
Endif

//-----------------------------------------------------
//Verifica o plano de contas referencial selecionado
//-----------------------------------------------------
cTabPlRef := VerPlanRef(.F.)

//-----------------------------------------------------
//Verifica as Tabelas de Destino
//-----------------------------------------------------
If cBloco == 'L'
	cTab1 := 'T088'
	cTab2 := 'T088AA'
	cTab3 := 'T088AD
ElseIf  cBloco == 'P'
	cTab1 := 'T092'
	cTab2 := 'T092AA'
	cTab3 := 'T092AC
ElseIf cBloco == 'U'
	cTab1 := 'T094'
	cTab2 := 'T094AA'
	cTab3 := 'T094AC'	
EndIf
			
//-----------------------------------------------------
//Verifica se os dados serใo extraidos pela amarra็ใo
//   do plano referencial.
//Senใo os dados serใo extraidos por visใo (CSE)
//-----------------------------------------------------
DbSelectArea( "CSK" )
DbSetOrder(1)

//-----------------------------------------------------
// Seleciona Dados
//-----------------------------------------------------
If __lDefTop
	nReg := 0
	
	cQuery := "SELECT COUNT(CSK.CSK_CODREV) NCTDCTK	"
	cQuery += "  FROM " + RetSqlName( "CSK" ) + " CSK "
	cQuery	+= "  WHERE CSK_FILIAL = '" + cFilCSK + "'"	
	cQuery += "  AND CSK.CSK_CODREV = '" + cRevisao+ "'"
	cQuery += "  AND CSK.D_E_L_E_T_ = ' ' "
	
	If cBloco == 'L'
		cQuery += "  AND ( (CSK.CSK_REGIST = 'L100') OR (CSK.CSK_REGIST = 'L300') ) "
	ElseIf  cBloco == 'P'
		cQuery += "  AND ( (CSK.CSK_REGIST = 'P100') OR (CSK.CSK_REGIST = 'P150') ) "
	ElseIf cBloco == 'U'
		cQuery += "  AND ( (CSK.CSK_REGIST = 'U100') OR (CSK.CSK_REGIST = 'U150') ) "
	EndIF

	cQuery := ChangeQuery( cQuery )
	cAliasCSK := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCSK )
	(cAliasCSK)->(DbGoTop())
	nReg := (cAliasCSK)->NCTDCTK
	(cAliasCSK)->(dbCloseArea())

	If nReg > 0 	// Seleciona Dados - Por Conta Referencial
		cQuery := ''
		cWhere := ''
		cQuery := "SELECT CSK.CSK_FILIAL,	"
		cQuery += "    CSK.CSK_CODREV,	 	"
		cQuery += "    CSK.CSK_DTINI,	    "
		cQuery += "    CSK.CSK_DTFIM,		"
		cQuery += "    CSK.CSK_CONTA,		"
		cQuery += "    CSK.CSK_CTAREF,		"						
		cQuery += "    SUM(CSK.CSK_VALINI) CSK_VALINI, 		"
		cQuery += "    CSK.CSK_INDINI,		"
		cQuery += "    SUM(CSK.CSK_VALFIN) CSK_VALFIN, 		"
		cQuery += "    CSK.CSK_INDFIM,		"
		cQuery += "    CSK.CSK_PERIOD,		"
		cQuery += "    CSK.CSK_REGIST,		"
		cQuery += "    CSK.CSK_VALDEB,		"
		cQuery += "    CSK.CSK_VALCRE		"		
		cQuery += "  FROM " + RetSqlName( "CSK" ) + " CSK "			
		cQuery	+= "  WHERE CSK.CSK_FILIAL = '" + cFilCSK + "'"
		cQuery += "  AND CSK.CSK_CODREV = '" + cRevisao+ "'"
		cQuery += "  AND CSK.D_E_L_E_T_ = ' ' "
		
		If cBloco == 'L'
			cQuery += "  AND ( (CSK.CSK_REGIST = 'L100') OR (CSK.CSK_REGIST = 'L300') ) "
		ElseIf  cBloco == 'P'
			cQuery += "  AND ( (CSK.CSK_REGIST = 'P100') OR (CSK.CSK_REGIST = 'P150') ) "
		ElseIf cBloco == 'U'
			cQuery += "  AND ( (CSK.CSK_REGIST = 'U100') OR (CSK.CSK_REGIST = 'U150') ) "
		EndIf
			
		cQuery += " GROUP BY CSK_FILIAL,CSK_CODREV,CSK.CSK_DTINI,CSK.CSK_DTFIM,CSK.CSK_CONTA,CSK_CTAREF,"
				cQuery += "   CSK_PERIOD,CSK_REGIST,CSK_INDINI,CSK_INDFIM,CSK_VALDEB,CSK_VALCRE "
		cQuery += " ORDER BY CSK_FILIAL,CSK_CODREV,CSK_PERIOD,CSK_REGIST,CSK_CTAREF" 
		
		cQuery := ChangeQuery( cQuery + cWhere + cGroup + cOrder )
		cAliasCSK := GetNextAlias()
		dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCSK )

		//-----------------------------------------------------
		// Exporta Dados parea tabela TAFST1
		//-----------------------------------------------------
		While (cAliasCSK)->(!Eof()) .AND. ( (cAliasCSK)->CSK_FILIAL == cFilCSK )	
			//Monta a chave do registro
			cKey := (cAliasCSK)->CSK_FILIAL + (cAliasCSK)->CSK_CODREV +  cTab1 + (cAliasCSK)->CSK_PERIOD
			
			//Reg. 030 - Identifica็ใo do Periodo
			cMsg := ''
			cMsg := "|" + cTab1								//REGISTRO
			cMsg += "|" + Alltrim((cAliasCSK)->CSK_DTINI)	//DT_INI
			cMsg += "|" + Alltrim((cAliasCSK)->CSK_DTFIM)	//DT_FIM
			cMsg += "|" + Alltrim((cAliasCSK)->CSK_PERIOD)	//PER_APUR 		
			cMsg += "|"
			
			If cBloco == 'L'
				//Reg. L200
				If ( cAliasCSZ)->CSZ_ESTOQU != '0' .AND. cMsg != ''
					cMsg += CRLF
					cMsg += '|' + 'T088AB'						// REGISTRO
					cMsg += '|' + ( cAliasCSZ)->CSZ_ESTOQU 		// IND_AVAL_ESTOQ
					cMsg += "|"	
				EndIf
				
				//Reg. L210
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, (cAliasCSK)->CSK_PERIOD, cMsg, 'L210' )
			ElseIf cBloco == 'P'
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, (cAliasCSK)->CSK_PERIOD, cMsg, 'P130' )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, (cAliasCSK)->CSK_PERIOD, cMsg, 'P200' )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, (cAliasCSK)->CSK_PERIOD, cMsg, 'P230' )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, (cAliasCSK)->CSK_PERIOD, cMsg, 'P300' )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, (cAliasCSK)->CSK_PERIOD, cMsg, 'P400' )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, (cAliasCSK)->CSK_PERIOD, cMsg, 'P500' )
			ElseIf cBloco == 'U'		
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, (cAliasCSK)->CSK_PERIOD, cMsg, 'U180' )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, (cAliasCSK)->CSK_PERIOD, cMsg, 'U182' )
			EndIf
			
			cAnt 		:= (cAliasCSK)->CSK_PERIOD
		
			While ( cAliasCSK)->(!Eof() ) .AND. ( (cAliasCSK)->CSK_FILIAL == cFilCSK ) .AND. ( cAnt == (cAliasCSK)->CSK_PERIOD )
				cContaRef 	:= Alltrim((cAliasCSK)->CSK_CTAREF)
				cIndIni	:= ''
				cIndFim	:= ''
				nValIni	:= 0
				nValFim	:= 0
				nValIniD	:= 0
				nValIniC	:= 0
				nValFimD	:= 0
				nValFimC	:= 0
				nValDeb 	:= 0
				nValCre		:= 0
				
				//-------------------------------------------------
				//Verifica a existencia de mais um registro 
				//  para a mesma conta referencial
				//Neste caso os saldos seใo acumulados
				//-------------------------------------------------
				//Se os indicadores de saldo forem iguais,
				//  somos os valores e mantenho o mesmo indicador.
				//------------------------------------------------
				//Se os indicadores de saldo forem diferentes
				//  subtraio os valores e atualizo o indicador
				//------------------------------------------------	
				While ( cAliasCSK)->(!Eof() ) .AND. ( (cAliasCSK)->CSK_FILIAL == cFilCSK ) .AND. ( cAnt == (cAliasCSK)->CSK_PERIOD ) .AND. ( cContaRef == Alltrim((cAliasCSK)->CSK_CTAREF) )	
					
					cRegist := (cAliascsk)->CSK_REGIST
					
					If Alltrim((cAliasCSK)->CSK_INDINI) == 'D'
						nValIniD := nValIniD + (cAliasCSK)->CSK_VALINI
					Else
						nValIniC := nValIniC + (cAliasCSK)->CSK_VALINI
					EndIf
					
					If Alltrim((cAliasCSK)->CSK_INDFIM) == 'D'
						nValFimD := nValFimD + (cAliasCSK)->CSK_VALFIN
					Else
						nValFimC := nValFimC + (cAliasCSK)->CSK_VALFIN
					EndIf
					nValDeb += (cAliasCSK)->CSK_VALDEB
					nValCre += (cAliasCSK)->CSK_VALCRED

					(cAliasCSK)->( dbSkip() )
				EndDo
				
				nValIni := ABS(nValIniD - nValIniC)
				If (nValIniD - nValIniC) >= 0
					cIndIni	:= 'D' 
				Else
					cIndIni	:= 'C'
				EndIf 

				nValFim := ABS(nValFimD - nValFimC)
				If (nValFimD - nValFimC) >= 0
					cIndFim	:= 'D' 
				Else
					cIndFim	:= 'C'
				EndIf
		
				//Reg. (L100/L300) (P100/P150) (U100/U150)
				If oProcess <> Nil
					oProcess:IncRegua2( "Periodo/Conta: " + Alltrim((cAliasCSK)->CSK_PERIOD) + " " + Alltrim((cAliasCSK)->CSK_CTAREF) ) 
				EndIf
				
				//Registro (L100/L300) (P100/P150) (U100/U150))
				cMsg += CRLF
				
				//Define se os dados sใo referentes ao BP ou DRE
				If cRegist $ 'L100|P100|U100"
					cMsg += "|" + cTab2									//REGISTRO
				ElseIf cRegist $ 'L300|P150|U150"
					cMsg += "|" + cTab3									//REGISTRO
				EndIf
				
				If cBloco $ 'L|U'
					cMsg += "|" + AllTrim(Str(Val(cTabPlRef)))			//REG_ECF
				EndIf
				
				cMsg += "|" + Alltrim(cContaRef)						//COD_CTA_REF
				
				If cRegist $ 'L100|P100|U100"
					cMsg += "|" + AllTrim(Str(ABS(nValIni))) 		//VAL_CTA_REF_INI
					cMsg += "|" + If( cIndIni = 'D','1','2' )		//IND_VAL_CTA_REF_INI
				EndIf
				
				cMsg += "|" + AllTrim(Str(ABS(nValFim)))			//VAL_CTA_REF_FIN
				 
				//Tratativa adicionada de forma provisoria
				// Manual de orienta็ใo da Receita,
				// invertei os indicadores para os registros de DRE
				If cRegist $ 'L300|P150|U150"
					cMsg += "|" + If( cIndFim = 'C','1','2')			//IND_VAL_CTA_REF_FIN
				Else
					cMsg += "|" + If( cIndFim = 'D','1','2')			//IND_VAL_CTA_REF_FIN
				EndIf

				//Altera็๕es layout 5 - 2018/2019
				If cRegist $ 'L100|U100|P100'
					If VAL(CS0->CS0_LEIAUT) >= 5
						cMsg += "|" + AllTrim(Str(ABS(nValDeb)))		//VAL_CTA_REF_DEB
						cMsg += "|" + AllTrim(Str(ABS(nValCre)))		//VAL_CTA_REF_CRED
					EndIf
				Endif

				cMsg += "|"
			EndDo
				
			cAnt 		:= (cAliasCSK)->CSK_PERIOD
			
			//Grava Dados na tabela TAFST1
			lRet := EcfGrvSt1(cAlias, cFilCSK, cKey, cTab1, cMsg)			
		EndDo
		(cAliasCSK)->(dbCloseArea())
	Else 	// Seleciona Dados - Por Visใo Gerencial
		cMsg := ''

		//Periodos
		If (cAliasCSZ)->CSZ_FMAPUR == '1'
			aForTrib := {"T01","T02","T03","T04" }
		ElseIf (cAliasCSZ)->CSZ_FMAPUR == '2'
			aForTrib := {"A00","A01","A02","A03","A04","A05","A06","A07","A08","A09","A10","A11","A12" }
		EndIf
		
		For nX := 1 to Len(aForTrib)
			cMsg := ''				
			If cBloco == 'L'							
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, aForTrib[nX], cMsg, 'L100', @dDataIni, @dDataFin )
				
				//Reg. L200
				If ( (cAliasCSZ)->CSZ_ESTOQU != '0' ) .AND. cMsg != ''
					cMsg += CRLF
					cMsg += '|' + 'T088AB'						// REGISTRO
					cMsg += '|' + ( cAliasCSZ)->CSZ_ESTOQU 		// IND_AVAL_ESTOQ
					cMsg += "|"	
				EndIf
				
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, aForTrib[nX], cMsg, 'L210', @dDataIni, @dDataFin )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, aForTrib[nX], cMsg, 'L300', @dDataIni, @dDataFin )
			ElseIf cBloco == 'P'
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, aForTrib[nX], cMsg, 'P100', @dDataIni, @dDataFin )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, aForTrib[nX], cMsg, 'P130', @dDataIni, @dDataFin )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, aForTrib[nX], cMsg, 'P150', @dDataIni, @dDataFin )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, aForTrib[nX], cMsg, 'P200', @dDataIni, @dDataFin )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, aForTrib[nX], cMsg, 'P230', @dDataIni, @dDataFin )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, aForTrib[nX], cMsg, 'P300', @dDataIni, @dDataFin )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, aForTrib[nX], cMsg, 'P400', @dDataIni, @dDataFin )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, aForTrib[nX], cMsg, 'P500', @dDataIni, @dDataFin )
			ElseIf cBloco == 'U'		
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, aForTrib[nX], cMsg, 'U100', @dDataIni, @dDataFin )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, aForTrib[nX], cMsg, 'U150', @dDataIni, @dDataFin )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, aForTrib[nX], cMsg, 'U180', @dDataIni, @dDataFin )
				cMsg := EcfExpVis(oProcess, cRevisao, cAlias, aForTrib[nX], cMsg, 'U182', @dDataIni, @dDataFin )
			EndIf
			
			If cMsg != ''
				//Monta a chave do registro
				cKey := (cAliasCSZ)->CSZ_FILIAL + cRevisao +  cTab1 + aForTrib[nX]
				
				//Reg. 030 - Identifica็ใo do Periodo
				cMsgA := "|" + cTab1		//REGISTRO
				cMsgA += "|" + dDataIni		//DT_INI
				cMsgA += "|" + dDataFin		//DT_FIM
				cMsgA += "|" + aForTrib[nX]	//PER_APUR 		
				cMsgA += "|"
				cMsgA += cMsg
				
				//Grava Dados na tabela TAFST1
				lRet := EcfGrvSt1(cAlias, cFilCSK, cKey, cTab1, cMsgA)
			EndIf

		Next nX
	EndIf			
Endif

RestArea(aArea)
	
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcfExpVis  บAutorณFelipe Cunha 		  บ Data ณ  01/01/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta Dados estraidos de visใo gerencial                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS103                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcfExpVis(oProcess, cRevisao, cAlias, cPeriod, cMsg, cReg, dDataIni, dDataFin )
Local aArea		:= GetArea()
Local cAliasCSE	:= "CSE"
Local cFilCSE   := xFilial( "CSE" )
Local cQuery	:= ''
Local cKey		:= '' // Chave do registro na TAFST1
Local lRet		:= .T.
Local cTab		:= ''
Local cReg2		:= ''
Local cTabPlRef := ''
Local cAnt		:= ''

Default oProcess	:= Nil
Default cRevisao 	:= ''
Default cPeriod		:= ''
Default cAlias		:= 'TAFST1'
Default cMsg		:= ''
Default cReg		:= ''
Default dDataIni	:= ''
Default dDataFin	:= ''

DbSelectArea( "CSE" )
DbSetOrder(1)

cTabPlRef := VerPlanRef(.F.)

If cReg == 'L100'
	cTab := 'T088AA'
ElseIf cReg == 'L210'
	cTab := 'T088AC'
ElseIf cReg == 'L300'
	cTab := 'T088AD'
ElseIf cReg == 'P100'
	cTab := 'T092AA'
ElseIf cReg == 'P150'
	cTab := 'T092AC'		
ElseIf cReg $ 'P130|P200|P230|P300|P400|P500'
	cTab := 'T092AB'
	
	If cReg $ 'P130'
		cReg2 := '01'
	ElseIf cReg == 'P200'
		cReg2 := '02'
	ElseIf cReg == 'P230'
		cReg2 := '03'
	ElseIf cReg == 'P300'
		cReg2 := '04'
	ElseIf cReg == 'P400'
		cReg2 := '05'
	ElseIf cReg == 'P500'
		cReg2 := '06'
	EndIf
ElseIf cReg == 'U100'
	cTab := 'T094AA'
ElseIf cReg == 'U150'
	cTab := 'T094AC'		
ElseIf cReg $ 'U180|U182'
	cTab := 'T094AB'
	
	If cReg $ 'U180'
		cReg2 := '01'
	ElseIf cReg == 'U182'
		cReg2 := '02'
	EndIf
ElseIf cReg $ 'Y681'
	cTab := 'T120AA'
Else
	cTab := 'T096'
EndIf

//-----------------------------------------------------
// Barra de Progresso
//-----------------------------------------------------
If oProcess <> Nil .AND. !(cReg $ 'L100|L210|L300|P100|P130|P150|P200|P230|P300|P400|P500|U100|U150|U180|U182')
	oProcess:IncRegua1( "Exp. Informa็๕es Economicas/Gerais" )
	oProcess:SetRegua2(0)
	oProcess:IncRegua2( '' )	
Endif

//-----------------------------------------------------
// Seleciona Dados
//-----------------------------------------------------
If __lDefTop
	cQuery := ''
	cQuery := "	SELECT CSD.CSD_FILIAL, "
	cQuery += "        CSD.CSD_CODREV, "
	cQuery += "        CSD.CSD_CODVIS, "
	cQuery += "        CSD.CSD_REGIST, "
	cQuery += "        CSD.CSD_DTINI,  "
	cQuery += "        CSD.CSD_DTFIN,  "
	cQuery += "        CSD.CSD_PERIOD, "	
	cQuery += "        CSE.CSE_FILIAL, "
	cQuery += "        CSE.CSE_CODREV, "
	cQuery += "        CSE.CSE_CODVIS, "
	cQuery += "        CSE.CSE_REGIST, "
	cQuery += "        CSE.CSE_TPDEM,  "
	cQuery += "        CSE.CSE_CODAGL, "
	cQuery += "        CSE.CSE_DESCRI, "
	cQuery += "        CSE.CSE_CLASSE, "
	cQuery += "        CSE.CSE_NIVEL,  "
	cQuery += "        CSE.CSE_NATCTA, "
	cQuery += "        CSE.CSE_CTASUP, "
	cQuery += "        CSE.CSE_INDVAL, "
	cQuery += "        CSE.CSE_PERIOD, "
	cQuery += "        CSE.CSE_VALOR,  "
	cQuery += "        CSE.CSE_VLRINI, "
	cQuery += "        CSE.CSE_INDINI, "
	cQuery += "        CSE.CSE_VLRFIM, "
	cQuery += "        CSE.CSE_INDFIM,  "
	cQuery += "        CSE.CSE_VALDEB,  "
	cQuery += "        CSE.CSE_VALCRE  "
	cQuery +=  "FROM " + RetSqlName( "CSD" ) + " CSD," +  RetSqlName( "CSE" ) + " CSE "
	cQuery +=  "WHERE CSE_FILIAL = '" + cFilCSE + "'" 
	cQuery +=  "  AND CSD.CSD_FILIAL = CSE.CSE_FILIAL   " 
	cQuery +=  "  AND CSD.CSD_CODREV   = CSE.CSE_CODREV  "
	cQuery +=  "  AND CSD.CSD_CODVIS   = CSE.CSE_CODVIS   "
	cQuery +=  "  AND CSD.CSD_REGIST   = CSE.CSE_REGIST   "
	cQuery +=  "  AND CSD.CSD_PERIOD   = CSE.CSE_PERIOD   "
	cQuery +=  "  AND CSD.CSD_CODREV = '" + cRevisao + "' "
	cQuery +=  "  AND CSE.CSE_CODREV = '" + cRevisao + "' "	
	cQuery +=  "  AND CSD.CSD_REGIST = '" + cReg 	 + "' "
	cQuery +=  "  AND CSE.CSE_REGIST = '" + cReg 	 + "' "
	
	//Esse filtro nใo ้ usado para registros dos bloco X e Y
	If cReg $ 'L100|L210|L300|P100|P130|P150|P200|P230|P300|P400|P500|U100|U150|U180|U182'
		cQuery +=  "  AND CSE.CSE_PERIOD = '" + cPeriod  + "' "
		cQuery +=  "  AND CSD.CSD_PERIOD = '" + cPeriod  + "' "
	EndIf
	
	cQuery +=  "  AND CSD.D_E_L_E_T_ = ' '                "
	cQuery +=  "  AND CSE.D_E_L_E_T_ = ' '                "
	cQuery +=  "GROUP BY CSD.CSD_FILIAL, CSD.CSD_CODREV, CSD.CSD_CODVIS, CSD.CSD_REGIST, CSD.CSD_DTINI, CSD.CSD_DTFIN, CSD.CSD_PERIOD, CSE.CSE_FILIAL, CSE.CSE_CODREV, CSE.CSE_CODVIS, CSE.CSE_REGIST, CSE.CSE_TPDEM , CSE.CSE_CODAGL, CSE.CSE_DESCRI, CSE.CSE_CLASSE, CSE.CSE_NIVEL , CSE.CSE_NATCTA, CSE.CSE_CTASUP, CSE.CSE_INDVAL, CSE.CSE_PERIOD, CSE.CSE_VALOR, CSE.CSE_VLRINI, CSE.CSE_INDINI, CSE.CSE_VLRFIM, CSE.CSE_INDFIM, CSE.CSE_VALDEB, CSE.CSE_VALCRE " 	 
	cQuery +=  "ORDER BY CSE.CSE_PERIOD,CSE.CSE_REGIST,CSE.CSE_CODAGL "
	
	cQuery := ChangeQuery( cQuery )
	cAliasCSE := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCSE)
Endif

If Empty(dDataFin) .OR. ( dDataFin != (cAliasCSE)->CSD_DTFIN .AND. !Empty((cAliasCSE)->CSD_DTFIN) ) // Verifica se Mudou o Perํodo
	dDataIni	:= (cAliasCSE)->CSD_DTINI
	dDataFin 	:= (cAliasCSE)->CSD_DTFIN
EndIf

//-----------------------------------------------------
// Exporta Dados parea tabela TAFST1
//-----------------------------------------------------
While (cAliasCSE)->(!Eof()) .AND. (cAliasCSE)->CSE_FILIAL == cFilCSE
	If cReg $ 'L100|U100'
		cMsg += CRLF
		cMsg += '|' + cTab													// REGISTRO
		cMsg += '|' + AllTrim(Str(Val(cTabPlRef)))							// REGECF
		cMsg += '|' + Alltrim((cAliasCSE)->CSE_CODAGL)						// CODIGO
		cMsg += '|' + AllTrim(Str((cAliasCSE)->CSE_VLRINI))					// VALOR INICIAL
		cMsg += "|" + If( Alltrim((cAliasCSE)->CSE_INDINI) = 'D','1','2' )	// IND_VAL_CTA_REF_INI
		cMsg += '|' + AllTrim(Str((cAliasCSE)->CSE_VLRFIM))					// VALOR FINAL	
		cMsg += '|' + If( Alltrim((cAliasCSE)->CSE_INDFIM) = 'D','1','2' ) 	// IND FIM
		If VAL(CS0->CS0_LEIAUT) >= 5
			cMsg += '|' + AllTrim(Str((cAliasCSE)->CSE_VALDEB))					// VALOR DEBITO	
			cMsg += '|' + AllTrim(Str((cAliasCSE)->CSE_VALCRE))					// VALOR CREDITO
		Endif
		cMsg += "|"
	ElseIf cReg == 'L210'
		cMsg += CRLF
		cMsg += '|' + cTab										// REGISTRO
		cMsg += '|' + AllTrim(Str(Val((cAliasCSE)->CSE_CODAGL)))// CODIGO	
		cMsg += '|' + AllTrim(Str((cAliasCSE)->CSE_VALOR))		// VALOR
		cMsg += "|"
	ElseIf cReg $ 'L300|U150'
		cMsg += CRLF
		cMsg += '|' + cTab													// REGISTRO
		cMsg += '|' + AllTrim(Str(Val(cTabPlRef)))							// REGECF
		cMsg += '|' + Alltrim((cAliasCSE)->CSE_CODAGL)						// CODIGO
		cMsg += '|' + AllTrim(Str((cAliasCSE)->CSE_VALOR))					// VALOR
		
		//Tratativa adicionada de forma provisoria
		// Manual de orienta็ใo da Receita,
		// invertei os indicadores para os registros de DRE
		cMsg += '|' + If( Alltrim((cAliasCSE)->CSE_INDFIM) = 'C','1','2' )	// IND VALOR
		
		cMsg += "|"
	ElseIf cReg == 'P100'
		cMsg += CRLF
		cMsg += '|' + cTab													// REGISTRO
		cMsg += '|' + Alltrim((cAliasCSE)->CSE_CODAGL)						// CODIGO
		cMsg += '|' + AllTrim(Str((cAliasCSE)->CSE_VLRINI))					// VALOR INICIAL
		cMsg += '|' + If( Alltrim((cAliasCSE)->CSE_INDINI) = 'D','1','2' )	// IND INI
		cMsg += '|' + AllTrim(Str((cAliasCSE)->CSE_VLRFIM))					// VALOR FINAL	
		cMsg += '|' + If( Alltrim((cAliasCSE)->CSE_INDFIM) = 'D','1','2' )	// IND FIM
		If VAL(CS0->CS0_LEIAUT) >= 5
			cMsg += '|' + AllTrim(Str((cAliasCSE)->CSE_VALDEB))					// VALOR DEBITO	
			cMsg += '|' + AllTrim(Str((cAliasCSE)->CSE_VALCRE))					// VALOR CREDITO
		Endif
		cMsg += "|"
	ElseIf cReg == 'P150'
		cMsg += CRLF

		cMsg += '|' + cTab													// REGISTRO		
		cMsg += '|' + Alltrim((cAliasCSE)->CSE_CODAGL)						// CODIGO
		cMsg += '|' + AllTrim(Str((cAliasCSE)->CSE_VALOR))					// VALOR
		
		//Tratativa adicionada de forma provisoria
		// Manual de orienta็ใo da Receita,
		// invertei os indicadores para os registros de DRE
		cMsg += '|' + If( Alltrim((cAliasCSE)->CSE_INDFIM) = 'C','1','2' )	// IND FIM
		
		cMsg += "|"
	ElseIf cReg $ 'P130|P200|P230|P300|P400|P500|U180|U182'
		If Alltrim((cAliasCSE)->CSE_CODAGL)	!= '00'
			cMsg += CRLF
			cMsg += '|' + cTab											// REGISTRO
			cMsg += '|' + cReg2											// REGECF
			cMsg += '|' + Alltrim(Str(Val((cAliasCSE)->CSE_CODAGL)))	// CODIGO	
			cMsg += '|' + AllTrim(Str((cAliasCSE)->CSE_VALOR))			// VALOR
			cMsg += "|"
		EndIf
	ElseIf cReg == 'Y681'				
		cMsg := "|" + 'T120'										//REGISTRO
		cMsg += "|" + (cAliasCSE)->CSD_DTFIN						//PERIODO
		cMsg += "|" + StrZero(Month(Stod((cAliasCSE)->CSD_DTFIN)),2)//MES		
		cMsg += "|"
	
		cKey := (cAliasCSE)->CSE_FILIAL + (cAliasCSE)->CSE_CODREV + 'T120' + (cAliasCSE)->CSE_PERIOD
			
		cAnt := (cAliasCSE)->CSE_PERIOD
		
		While ( (cAliasCSE)->(!Eof()) ) .AND. ( (cAliasCSE)->CSE_FILIAL == cFilCSE)  .AND. ( cAnt == (cAliasCSE)->CSE_PERIOD )
			If Alltrim((cAliasCSE)->CSE_CODAGL)	!= '00'
				cMsg += CRLF
				cMsg += '|' + cTab		// REGISTRO
				cMsg += '|' + Alltrim((cAliasCSE)->CSE_CODAGL)						// CODIGO
				cMsg += '|' + AllTrim(Str((cAliasCSE)->CSE_VALOR))					// VALOR
				cMsg += "|"			
				cAnt := (cAliasCSE)->CSE_PERIOD
			EndIf
			(cAliasCSE)->( dbSkip() )	 
		EndDo
	
		lRet := EcfGrvSt1(cAlias, cFilCSE, cKey, 'T120', cMsg)
		
	Else
		If oProcess <> Nil
			oProcess:IncRegua2( "Exp. Reg. " + cReg) 
		EndIf
		
		If Alltrim((cAliasCSE)->CSE_CODAGL)	!= '00'
			cMsg := ''
			cMsg += '|' + cTab											// REGISTRO
			cMsg += '|' + cReg											// REGECF
			cMsg += '|' + (cAliasCSZ)->CSZ_DTFIM						// PERIODO
			cMsg += '|' + Alltrim(Str(Val((cAliasCSE)->CSE_CODAGL)))	// CODIGO	
			cMsg += '|' + AllTrim(Str((cAliasCSE)->CSE_VALOR))			// VALOR
			cMsg += "|"	
			
			cKey := (cAliasCSE)->CSE_FILIAL + (cAliasCSE)->CSE_CODREV + cTab + (cAliasCSE)->CSE_REGIST + (cAliasCSE)->CSE_CODAGL
			lRet := EcfGrvSt1(cAlias, cFilCSE, cKey, cTab, cMsg)
		EndIf
	EndIf
	
	(cAliasCSE)->( dbSkip() )			
EndDo

(cAliasCSE)->(dbCloseArea())

RestArea(aArea)
	
Return cMsg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcfExpVis  บAutorณFelipe Cunha 		  บ Data ณ  01/01/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta Dados estraidos de visใo gerencial                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS103                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcfExpDIPJ(oProcess, cRevisao, cAlias, cReg )
Local aArea		:= GetArea()
Local cAliasCSE	:= "CSE"
Local cFilCSE   := xFilial( "CSE" )
Local cQuery	:= ''
Local cKey		:= '' // Chave do registro na TAFST1
Local lRet		:= .T.
Local cMsg		:= ''
Local cTab		:= ''

Default oProcess	:= Nil
Default cRevisao 	:= ''
Default cAlias		:= 'TAFST1'
Default cReg		:= ''

DbSelectArea( "CSE" )
DbSetOrder(1)

If cReg == 'X350'
	cTab := 'T099AA'
ElseIf cReg == 'Y671'
	cTab := 'T118' 
ElseIf cReg == 'Y672'
	cTab := 'T119' 
EndIf

//-----------------------------------------------------
// Barra de Progresso
//-----------------------------------------------------
If oProcess <> Nil
	oProcess:IncRegua1( "Exp. Inform. Econom./Gerais - " + cReg )
	oProcess:SetRegua2(0)
	oProcess:IncRegua2( '' )	
Endif

//-----------------------------------------------------
// Seleciona Dados
//-----------------------------------------------------
If __lDefTop
	cQuery := ''
	cQuery := "	SELECT CSD.CSD_FILIAL, "
	cQuery += "        CSD.CSD_CODREV, "
	cQuery += "        CSD.CSD_CODVIS, "
	cQuery += "        CSD.CSD_REGIST, "
	cQuery += "        CSD.CSD_DTINI,  "
	cQuery += "        CSD.CSD_DTFIN,  "
	cQuery += "        CSD.CSD_PERIOD, "	
	cQuery += "        CSE.CSE_FILIAL, "
	cQuery += "        CSE.CSE_CODREV, "
	cQuery += "        CSE.CSE_CODVIS, "
	cQuery += "        CSE.CSE_REGIST, "
	cQuery += "        CSE.CSE_TPDEM,  "
	cQuery += "        CSE.CSE_CODAGL, "
	cQuery += "        CSE.CSE_DESCRI, "
	cQuery += "        CSE.CSE_CLASSE, "
	cQuery += "        CSE.CSE_NIVEL,  "
	cQuery += "        CSE.CSE_NATCTA, "
	cQuery += "        CSE.CSE_CTASUP, "
	cQuery += "        CSE.CSE_INDVAL, "
	cQuery += "        CSE.CSE_PERIOD, "
	cQuery += "        CSE.CSE_VALOR   "
	cQuery +=  "FROM " + RetSqlName( "CSD" ) + " CSD, " +  RetSqlName( "CSE" ) + " CSE "
	cQuery +=  "WHERE CSE_FILIAL = '" + cFilCSE + "'" 
	cQuery +=  "	AND CSD.CSD_FILIAL = CSE.CSE_FILIAL     " 
	cQuery +=  "  AND CSD.CSD_CODREV   = CSE.CSE_CODREV   "
	cQuery +=  "  AND CSD.CSD_CODVIS   = CSE.CSE_CODVIS   "
	cQuery +=  "  AND CSD.CSD_REGIST   = CSE.CSE_REGIST   "
	cQuery +=  "  AND CSD.CSD_PERIOD   = CSE.CSE_PERIOD   "
	cQuery +=  "  AND CSD.CSD_CODREV = '" + cRevisao + "' "
	cQuery +=  "  AND CSE.CSE_CODREV = '" + cRevisao + "' "	
	cQuery +=  "  AND CSD.CSD_REGIST = '" + cReg 	 + "' "
	cQuery +=  "  AND CSE.CSE_REGIST = '" + cReg 	 + "' "
	cQuery +=  "  AND CSD.D_E_L_E_T_ = ' '                "
	cQuery +=  "  AND CSE.D_E_L_E_T_ = ' '                "
	cQuery +=  "GROUP BY CSD.CSD_FILIAL, CSD.CSD_CODREV, CSD.CSD_CODVIS, CSD.CSD_REGIST, CSD.CSD_DTINI, CSD.CSD_DTFIN, CSD.CSD_PERIOD, CSE.CSE_FILIAL, CSE.CSE_CODREV, CSE.CSE_CODVIS, CSE.CSE_REGIST, CSE.CSE_TPDEM , CSE.CSE_CODAGL, CSE.CSE_DESCRI, CSE.CSE_CLASSE, CSE.CSE_NIVEL , CSE.CSE_NATCTA, CSE.CSE_CTASUP, CSE.CSE_INDVAL, CSE.CSE_PERIOD, CSE.CSE_VALOR " 
	cQuery +=  "ORDER BY CSE.CSE_PERIOD,CSE.CSE_CODAGL "
	
	cQuery := ChangeQuery( cQuery )
	cAliasCSE := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCSE)
Endif

//-----------------------------------------------------
// Exporta Dados parea tabela TAFST1
//-----------------------------------------------------
While (cAliasCSE)->(!Eof()) 
	cKey := (cAliasCSE)->CSE_FILIAL + (cAliasCSE)->CSE_CODREV + cTab + (cAliasCSE)->CSE_REGIST + (cAliasCSE)->CSE_CODAGL
	
	cMsg := ''
	cMsg += '|' + cTab									// REGISTRO
	cMsg += '|' + (cAliasCSE)->CSD_DTFIN				// REGISTRO
	
	While (cAliasCSE)->CSE_FILIAL == cFilCSE .AND. (cAliasCSE)->(!Eof())
		If Alltrim((cAliasCSE)->CSE_CODAGL)	!= '00'
			cMsg += '|' + AllTrim(Str((cAliasCSE)->CSE_VALOR))	// VALOR		
		EndIf			
		(cAliasCSE)->( dbSkip() )			
	EndDo
	
	If cReg == 'Y672'
		cMsg += '|0' // Regime de Apura็ใo das Receitas
		
		If ( cAliasCSZ)->CSZ_ESTOQU != '0'
			cMsg += '|' + ( cAliasCSZ)->CSZ_ESTOQU 		// IND_AVAL_ESTOQ
		Else
			cMsg += '|' 
		EndIf
	ElseIf cReg == 'Y671'
	 	cMsg += '||'
	EndIf
	
	cMsg += "|"
	lRet := EcfGrvSt1(cAlias, cFilCSE, cKey, cTab, cMsg)
EndDo
	
(cAliasCSE)->(dbCloseArea())

RestArea(aArea)
	
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcfExpBlW      บAutorณEduardo.FLima	  บ Data ณ  12/05/2017บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Exporta Bloco W       					                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS103                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcfExpBlW(oProcess, cRevisao, cAlias)
Local aArea		:= GetArea()
Local cMsg		:= ''
Local cQuery	:= ''
Local cKey		:= ''
Local lRet		:= .T.
Local cCodId	:=""
Local cAnt		:=""
Local cAnt2 	:=""
Local lSkip:=.T.
Local lTabCQN		:=.F.
Local lTabCQO		:=.F.
Local lTabCQP		:=.F.

Default cAliasCQM	:= "CQM"
Default cFilCQM  	:= xFilial( "CQM" )
Default oProcess	:= Nil
Default cRevisao 	:= ''
Default cAlias	    := 'TAFST1'

//-----------------------------------------------------
// Barra de Progresso
//-----------------------------------------------------
If oProcess <> Nil
	oProcess:IncRegua1( "Exportando Parametros ECF" )
	oProcess:SetRegua2(0)
	oProcess:IncRegua2( '' )	
Endif

DbSelectArea( "CSZ" )
DbSetOrder(1)
DbSelectArea("CSZ")
CSZ->(dbSetOrder(1))
CSZ->(dbSeek(xFilial("CSZ") + cRevisao))
cCodId	:= CSZ->CSZ_IDBLW


DbSelectArea( "CQN" )
CQN->(dbSetOrder(1))
lTabCQN:= CQN->(dbSeek(xFilial("CQN") + cCodId))

DbSelectArea( "CQO" )
CQO->(dbSetOrder(1))
lTabCQO:= lTabCQN .and. CQO->(dbSeek(xFilial("CQO") + cCodId))

DbSelectArea( "CQP" )
CQP->(dbSetOrder(1))
lTabCQP:= CQP->(dbSeek(xFilial("CQP") + cCodId))


//-----------------------------------------------------
// Seleciona Dados
//-----------------------------------------------------
If __lDefTop
	cQuery := "Select CQM.CQM_FILIAL, "
	cQuery += "    CQM.CQM_CODID, "
	cQuery += "    CQM.CQM_REG, "
	cQuery += "    CQM.CQM_DESCRI, "
	cQuery += "    CQM.CQM_NMULTI, "
	cQuery += "    CQM.CQM_CONTRO, "
	cQuery += "    CQM.CQM_NOME, "
	cQuery += "    CQM.CQM_JURCON, "
	cQuery += "    CQM.CQM_TINCON, "
	cQuery += "    CQM.CQM_INDENT, "
	cQuery += "    CQM.CQM_INDMOD, "
	cQuery += "    CQM.CQM_NSUBST, "
	cQuery += "    CQM.CQM_JURSUB, "
	cQuery += "    CQM.CQM_TINSUB, "
	cQuery += "    CQM.CQM_DTINI, "
	cQuery += "    CQM.CQM_DTFIN, "
	cQuery += "    CQM.CQM_TIPMOE, "
	cQuery += "    CQM.CQM_IDIOMA"
	If lTabCQN
		cQuery += ", "
		cQuery += "    CQN.CQN_FILIAL, "
		cQuery += "    CQN.CQN_CODID, "
		cQuery += "    CQN.CQN_ITEM, "
		cQuery += "    CQN.CQN_REG, "
		cQuery += "    CQN.CQN_JURI, "
		cQuery += "    CQN.CQN_RECNR, "
		cQuery += "    CQN.CQN_RECREE, "
		cQuery += "    CQN.CQN_RECREL, "
		cQuery += "    CQN.CQN_RETOTE, "
		cQuery += "    CQN.CQN_RECTOT, "
		cQuery += "    CQN.CQN_LAIPRE, "
		cQuery += "    CQN.CQN_LPAIR, "
		cQuery += "    CQN.CQN_IRPAGE, "
		cQuery += "    CQN.CQN_IRPAGO, "
		cQuery += "    CQN.CQN_IRDEVE, "
		cQuery += "    CQN.CQN_IRDEV, "
		cQuery += "    CQN.CQN_CPSOLE, "
		cQuery += "    CQN.CQN_CPSOC, "
		cQuery += "    CQN.CQN_LUCAC, "
		cQuery += "    CQN.CQN_ATTAN, "
		cQuery += "    CQN.CQN_NUMEMP, "
		cQuery += "    CQN.CQN_RECNRE, "
		cQuery += "    CQN.CQN_IRDEV, "
		cQuery += "    CQN.CQN_LUCACE, "
		cQuery += "    CQN.CQN_ATTANE"
	Endif 
	If lTabCQO
		cQuery += ", "
		cQuery += "    CQO.CQO_FILIAL, "
		cQuery += "    CQO.CQO_CODID, "
		cQuery += "    CQO.CQO_ITEM, "
		cQuery += "    CQO.CQO_SUBITE, "
		cQuery += "    CQO.CQO_REG, "
		cQuery += "    CQO.CQO_JURDIF, "
		cQuery += "    CQO.CQO_NOME, "
		cQuery += "    CQO.CQO_TIN, "
		cQuery += "    CQO.CQO_JURTIN, "
		cQuery += "    CQO.CQO_NI, "
		cQuery += "    CQO.CQO_JURNI, "
		cQuery += "    CQO.CQO_TIPONI, "
		cQuery += "    CQO.CQO_TIPEND, "
		cQuery += "    CQO.CQO_ENDERE, "
		cQuery += "    CQO.CQO_NUMTEL, "
		cQuery += "    CQO.CQO_EMAIL, "
		cQuery += "    CQO.CQO_ATIV1, "
		cQuery += "    CQO.CQO_ATIV2, "
		cQuery += "    CQO.CQO_ATIV3, "
		cQuery += "    CQO.CQO_ATIV4, "
		cQuery += "    CQO.CQO_ATIV5, "
		cQuery += "    CQO.CQO_ATIV6, "
		cQuery += "    CQO.CQO_ATIV7, "
		cQuery += "    CQO.CQO_ATIV8, "
		cQuery += "    CQO.CQO_ATIV9, "
		cQuery += "    CQO.CQO_ATIV10, "
		cQuery += "    CQO.CQO_ATIV11, "
		cQuery += "    CQO.CQO_ATIV12, "
		cQuery += "    CQO.CQO_ATIV13, "
		cQuery += "    CQO.CQO_DESOUT, "
		cQuery += "    CQO.CQO_OBSERV, "
		cQuery += "    CQO.R_E_C_N_O_ RECCQO"
	Endif 
	If lTabCQP
		cQuery += ", "		
		cQuery += "    CQP.CQP_CODID, "
		cQuery += "    CQP.CQP_JURI,  "
		cQuery += "    CQP.CQP_RECNRE,"
		cQuery += "    CQP.CQP_RECREL,"
		cQuery += "    CQP.CQP_RECTOT,"
		cQuery += "    CQP.CQP_LUPAIR,"
		cQuery += "    CQP.CQP_IRPAGO,"
		cQuery += "    CQP.CQP_IRDEVI,"
		cQuery += "    CQP.CQP_CAPSOC,"
		cQuery += "    CQP.CQP_LUCACU,"
		cQuery += "    CQP.CQP_ATTANG,"
		cQuery += "    CQP.CQP_NUMEMP,"
		cQuery += "    CQP.CQP_OBSERV,"
		cQuery += "    CQP.R_E_C_N_O_ RECCQP"
	Endif   
	cQuery +=  "	FROM "+ RetSqlName( "CQM" )+ " CQM"
	If lTabCQN
		cQuery += ", " + RetSqlName( "CQN" )+" CQN"
	Endif 
	If lTabCQO
		cQuery += ", " +RetSqlName( "CQO" )+" CQO"
	Endif 
	If lTabCQP
		cQuery += ", " +RetSqlName( "CQP" )+" CQP"
	Endif	
	cQuery +=  "   WHERE CQM.D_E_L_E_T_ = ' '"
	cQuery +=  "   			AND CQM.CQM_FILIAL = '" + cFilCQM + "'"
	cQuery +=  "             AND CQM_CODID = '" + cCodId+ "'"
	If lTabCQN //Filho	
		cQuery +=  "				AND  CQN.CQN_FILIAL = CQM.CQM_FILIAL                       "
		cQuery +=  "             AND  CQN.CQN_CODID  = CQM.CQM_CODID                        "
		cQuery +=  "             AND  CQN.D_E_L_E_T_ = ' '									   "
	Endif  		
	If lTabCQO //Neto
		cQuery +=  "             AND CQO.CQO_FILIAL  = CQN.CQN_FILIAL                      "
		cQuery +=  "             AND CQO.CQO_CODID  =	 CQN.CQN_CODID                       "
		cQuery +=  "             AND CQO.CQO_ITEM  = CQN.CQN_ITEM                          "
		cQuery +=  "             AND CQO.D_E_L_E_T_ = ' '										  "		
	Endif 
	If lTabCQP	//Irmใo
		cQuery +=  "				AND CQP.CQP_FILIAL = CQM.CQM_FILIAL   "
		cQuery +=  "             AND CQP.CQP_CODID = CQM.CQM_CODID  "
		cQuery +=  "             AND CQP.D_E_L_E_T_ = ' '									   "
	Endif
	
	
	cQuery 		:= ChangeQuery( cQuery )
		
	cAliasCQM 	:= GetNextAlias()
		
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCQM )	
Endif

//-----------------------------------------------------
// Exporta Dados parea tabela TAFST1
//-----------------------------------------------------
While (cAliasCQM)->(!Eof()) .AND. (cAliasCQM)->CQM_FILIAL == cFilCQM
	If ( oProcess <> Nil ) 
		oProcess:IncRegua2( "Revisใo: " + cCodId ) //"Revisใo: "
	EndIf
	
	//Montagem campo TAFMSG	
	cMsg := ''
	cMsg := '|' + 'T132'								  	// REGISTRO
	cMsg += '|' + Alltrim( ( cAliasCQM)->CQM_NMULTI)	// Nome Mult
	cMsg += '|' + Alltrim( ( cAliasCQM)->CQM_CONTRO)	// Ind. Control
	cMsg += '|' + Alltrim( ( cAliasCQM)->CQM_NOME)		// Nome. Contr.
	cMsg += '|' + Alltrim( ( cAliasCQM)->CQM_JURCON)	// Jurisd.Contr
	cMsg += '|' + Alltrim( ( cAliasCQM)->CQM_TINCON)	// Tin. Control
	cMsg += '|' + Alltrim( ( cAliasCQM)->CQM_INDENT)	// Resp.Entr.PP
	cMsg += '|' + Alltrim( ( cAliasCQM)->CQM_INDMOD)	// Ind. Modalid
	cMsg += '|' + Alltrim( ( cAliasCQM)->CQM_NSUBST)	// Substitututa
	cMsg += '|' + Alltrim( ( cAliasCQM)->CQM_JURSUB)	// Jur.Substit.
	cMsg += '|' + Alltrim( ( cAliasCQM)->CQM_TINSUB)	// TIN. Substit
	cMsg += '|' + ( cAliasCQM)->CQM_DTINI    			// Dt. Inicio
	cMsg += '|' + ( cAliasCQM)->CQM_DTFIN    			// Dt. Fim
	cMsg += '|' + ( cAliasCQM)->CQM_TIPMOE   			// Tip.Moeda
	cMsg += '|' + Alltrim( ( cAliasCQM)->CQM_IDIOMA)	// Idioma
	cMsg += "|"
	If lTabCQP	//Irmใo
		//MONTAGEM DA MENSAEM AUXILIAR PARA SER ADCIONADO A MENSAGEM PRINCIPAL	
		cMsgCqp := '|' + 'T132AC'								  	// REGISTRO
		cMsgCqp += '|' + Alltrim( ( cAliasCQM)->CQP_JURI)  //Jurisdicao
		cMsgCqp += '|' + Alltrim( ( cAliasCQM)->CQP_RECNRE)//Rec.N.Relaci
		cMsgCqp += '|' + Alltrim( ( cAliasCQM)->CQP_RECREL)//Rec.Relacion
		cMsgCqp += '|' + Alltrim( ( cAliasCQM)->CQP_RECTOT)//Receit.Total
		cMsgCqp += '|' + Alltrim( ( cAliasCQM)->CQP_LUPAIR)//Luc.Pre.A.IR
		cMsgCqp += '|' + Alltrim( ( cAliasCQM)->CQP_IRPAGO)//Ind.IR Pago
		cMsgCqp += '|' + Alltrim( ( cAliasCQM)->CQP_IRDEVI)//IR Devido
		cMsgCqp += '|' + Alltrim( ( cAliasCQM)->CQP_CAPSOC)//Ind.Cap.Soc.
		cMsgCqp += '|' + Alltrim( ( cAliasCQM)->CQP_LUCACU)//Luc.Acumulad
		cMsgCqp += '|' + Alltrim( ( cAliasCQM)->CQP_ATTANG)//Ativo Tangiv
		cMsgCqp += '|' + Alltrim( ( cAliasCQM)->CQP_NUMEMP)//Ind.Num.Empr
		DbSelectArea("CQP")
		DbGoTo(( cAliasCQM)->RECCQP)
		cMsgCqp += '|' + Alltrim(StrTran(CQP->CQP_OBSERV, CRLF, " " )) //Observacoes
		DbSelectArea((cAliasCQM))
		cMsgCqp += "|"
	Endif
	cAnt:=(cAliasCQM)->CQM_FILIAL + (cAliasCQM)->CQM_CODID
	
	While lTabCQN .and. (((cAliasCQM)->CQM_FILIAL + (cAliasCQM)->CQM_CODID) == cAnt) //Filho
		lSkip:=.T.
		cMsg += CRLF
		cMsg += '|'  +'T132AA'					   			// REGISTRO
		cMsg += '|' + Alltrim(( cAliasCQM)->CQN_JURI)	// Jurisdicao
		If VAL(CS0->CS0_LEIAUT) < 7
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_RECNRE))// Receit. Estr
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_RECNR ))// Vl.Rec.Real  
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_RECREE))// Vl.Rel.Estr.
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_RECREL))// Vl.Rec.Real		
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_RETOTE))// Vl.Rec.Tot.E
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_RECTOT))// Rec.Total
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_LAIPRE))// Lucr.Prej.Es
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_LPAIR ))// Lucr.Prej.Re
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_IRPAGE))// Vl.IR.Estran
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_IRPAGO))// Vl.Ir.Real
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_IRDEVE))// Vl.Dev.Estr.
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_IRDEV ))// Vl.Dev.Real
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_CPSOLE ))//Cap.Soc.Estr
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_CPSOC  ))//Cap.Soc.Real
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_LUCACE ))//Lucr.Acmul.E
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_LUCAC  ))//Lucr.Acuml.R
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_ATTANE  ))//Ativ.Tang.E
			cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_ATTAN   ))//Ativ.Tang.R
		Else
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_RECNRE)))// Receit. Estr
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_RECNR )))// Vl.Rec.Real  
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_RECREE)))// Vl.Rel.Estr.
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_RECREL)))// Vl.Rec.Real		
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_RETOTE)))// Vl.Rec.Tot.E
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_RECTOT)))// Rec.Total
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_LAIPRE)))// Lucr.Prej.Es
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_LPAIR )))// Lucr.Prej.Re
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_IRPAGE)))// Vl.IR.Estran
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_IRPAGO)))// Vl.Ir.Real
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_IRDEVE)))// Vl.Dev.Estr.
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_IRDEV )))// Vl.Dev.Real
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_CPSOLE )))//Cap.Soc.Estr
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_CPSOC  )))//Cap.Soc.Real
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_LUCACE )))//Lucr.Acmul.E
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_LUCAC  )))//Lucr.Acuml.R
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_ATTANE  )))//Ativ.Tang.E
			cMsg += '|' + Alltrim(Str(Int((cAliasCQM)->CQN_ATTAN   )))//Ativ.Tang.R
		EndIf
		cMsg += '|' + Alltrim(Str(( cAliasCQM)->CQN_NUMEMP   ))//Num.Empreg. 
		cMsg += "|"
		cAnt2:=(cAliasCQM)->CQN_FILIAL +(cAliasCQM)->CQN_CODID + (cAliasCQM)->CQN_ITEM
		While lTabCQO .AND. (((cAliasCQM)->CQN_FILIAL +(cAliasCQM)->CQN_CODID + (cAliasCQM)->CQN_ITEM) == cAnt2) //NETO
			cMsg += CRLF
			cMsg += '|'  +'T132AB'					   		// REGISTRO			
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_JURDIF)	// Jurididc.Dif
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_NOME  )	// Nome
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_TIN   )	// TAX Iden.Num
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_JURTIN)	// Jur.Emis.TIN
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_NI    )	// Num. Identif
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_JURNI )	// Jur.Emiss.NI
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_TIPONI )	// Tipo do NI
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_TIPEND )	// Tipo Enderec
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_ENDERE )	// Endereco
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_NUMTEL )	// Num.Telefone
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_EMAIL  )	// E-mail Cont.
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_ATIV1  ) // Pesq.Desenv.
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_ATIV2  ) //Gest.Intelec
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_ATIV3  ) //Compras
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_ATIV4  ) //Manuf.Produc
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_ATIV5  ) //Ven.Mark.Dis
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_ATIV6  ) //Srv.Gest.Sup
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_ATIV7  ) //P.S.Parts.NR
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_ATIV8  ) //Dpt.Fin.Grup
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_ATIV9  ) //Serv.Fin.Reg
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_ATIV10  ) //Seguro
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_ATIV11  ) //Gstao Acoes
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_ATIV12  ) //Inativa
			cMsg += '|' + Alltrim(( cAliasCQM)->CQO_ATIV13  ) //Outros
			DbSelectArea("CQO")
			DbGoTo((cAliasCQM)->RECCQO)
			cMsg += '|' + Alltrim(StrTran(CQO->CQO_DESOUT, CRLF, " " )) //Desc.Ativ.ED
			cMsg += '|' + Alltrim(StrTran(CQO->CQO_OBSERV, CRLF," " ))  //Observacao
			DbSelectArea((cAliasCQM))
			cMsg += "|"
			(cAliasCQM)->( dbSkip() )	
			lSkip:=.F.		
		Enddo
		If lSkip 
			(cAliasCQM)->( dbSkip() )
		Endif
	Enddo
	If lTabCQP	//Irmใo	
		cMsg += CRLF
		cMsg+= cMsgCqp
	Endif 
	//Monta a chave do registro
	cKey := (cAliasCSZ)->CSZ_FILIAL + (cAliasCSZ)->CSZ_CODREV + 'T132' 
	
	//Grava Dados na tabela TAFST1
	lRet := EcfGrvSt1(cAlias, cFilCSZ, cKey, 'T132', cMsg)	
	(cAliasCQM)->( dbSkip() )			
EndDo


RestArea(aArea)
	
Return lRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcfGrvSt1  บAutorณFelipe Cunha 		  บ Data ณ  01/01/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava dados na tabela TAFST1				                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS103                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function EcfGrvSt1(cAlias, cFil, cKey, cTab, cMsg, cSeq)
Local cSeparador	:= ''
Local cCast 		:= ''
Local cBanco 		:= Alltrim(Upper(TcGetDb()))
Default cAlias 	:= ''
Default cFil 	:= ''
Default cKey 	:= ''
Default cTab 	:= ''
Default cMsg 	:= ''

Default cSeq	:= '001'

RecLock( cAlias , .T. )
TAFST1->TAFFIL	:= CS0->CS0_CODEMP + CS0->CS0_CODFIL
TAFST1->TAFCODMSG	:= '1'
TAFST1->TAFSEQ	:= cSeq
TAFST1->TAFTPREG	:= cTab
TAFST1->TAFKEY	:= cKey
TAFST1->TAFMSG	:= cMsg
TAFST1->TAFSTATUS	:= '1'
TAFST1->TAFTICKET	:= cTicket
TAFST1->TAFDATA	:= cData
TAFST1->TAFHORA	:= cHora
MsUnLock()

DbCommit()

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณEcfLmpSt1  บAutorณFelipe Cunha 		  บ Data ณ  01/01/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava dados na tabela TAFST1				                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS103                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function EcfLmpSt1(cAlias,lAutomato)
Local lRet			:= .T.
Local cQuery 		:= ''
Local cQryCount		:= ''
Local cAliasCount	:= ''
Local lFOpnTab		:= FindFunction( "FOpnTabTAf" )
Local aCamposAux	:= {}

Default cAlias	:= 'TAFST1'
Default lAutomato	:= .F.

//--------------------------------------------------------------
// Cria conexใo com a tabela TAFST1
//--------------------------------------------------------------
//Carrega estrutura da tabela
If lFOpnTab
	aCamposAux 	:= aClone(aCampos)
	lRet		:= FOpnTabTAf(cAlias,cAlias)
	aCampos 	:= aClone(aCamposAux)
Else
	lRet := .F.
EndIf

If !lRet 
	Alert('Tabela TAFST1 nใo localizada ou nใo existente. Execute o Wizard de Configura็ใo do TAF.')
	lRet:= .F.
	Return lRet
EndIf

//-------------------------------------------
// NรO RETIRAR ESTA INSTRIวรO
//  Prote็ใo para for็ar a atualiza็ใo do TOP
//-------------------------------------------

TcRefresh(cAlias)	
DbSelectArea(cAlias)
DbGobottom()
DbGoTop()

If __lDefTop .AND. lRet
	
	//Verifica se existe registro na TAFST1
	cQryCount := ''
	cQryCount := 'Select Count(*) TAFCOUNT from TAFST1'
	cAliasCount := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQryCount) , cAliasCount,.T.,.T.)
	
	//Se nใo existir for็o a cria็ใo de um registro
	// Isso ira atualizar a tabela e evitar os seguintes erros
	// 1 - Gravar o campo TAFMSG em branco
	// 2 - Gravar os dados do campo TAFMSG errado
	If (cAliasCount)->(Eof()) .Or. (cAliasCount)->TAFCOUNT <= 0
		RecLock( "TAFST1" , .T. )
		nRecno := TAFST1->(Recno())
		DbSelectArea("TAFST1")
		MsUnlock()		
		//-----------------------------------------
		//Quando for ambiente Oracle o registro jแ 
		//  ้ incluso deletado
		//-----------------------------------------
		DbGoTo(nRecno)
		RecLock( "TAFST1" , .F. )
		DbDelete()
		MsUnlock()		
	//Caso exista fa็o a limpeza
	ElseIf lAutomato
	
		cQuery := ''
		cQuery := "UPDATE TAFST1           "
		cQuery += " SET D_E_L_E_T_ = '*'   "
		cQuery += " WHERE TAFTICKET LIKE 'ECF_%' "
		cQuery += " AND TAFFIL = '" + CS0->CS0_CODEMP + CS0->CS0_CODFIL + "'"
		cQuery += " AND D_E_L_E_T_ = ' ' "
		
		TcSQLExec(cQuery)
		DbCommit()
	
	ElseIf Aviso('Aten็ใo','Deseja continuar o processo de exporta็ใo dos dados para o TAF?' + CRLF + ;
                                    'Este processo irแ fazer a limpeza da tabela TAFST1, Continuar?', {'Sim', 'Nใo'},2) == 1
		cQuery := ''
		cQuery := "UPDATE TAFST1           "
		cQuery += " SET D_E_L_E_T_ = '*'   "
		cQuery += " WHERE TAFTICKET LIKE 'ECF_%' "
		cQuery += " AND TAFFIL = '" + CS0->CS0_CODEMP + CS0->CS0_CODFIL + "'"
		cQuery += " AND D_E_L_E_T_ = ' ' "
		
		TcSQLExec(cQuery)
		DbCommit()
	Else
		lRet := .F.
	EndIf
	(cAliasCount)->( dbCloseArea() )
Else
	lRet := .F.
EndIf

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVerPlanRef  บAutorณFelipe Cunha 		  บ Data ณ  01/01/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica Cod Plano Referencial			                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS103                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function VerPlanRef(lPlanoRef)
Local cTabPlRef := ''

Default lPlanoRef := .F.

//--------------------------------------------------------------------------
//Esta fun็ใo existe, somente pois os codigos de Plano Referencial, no
//   ambiente TAF NรO estใo padronizados, jแ foi aberto um chamado para eles,
//   para a padroniza็ใo desta informa็๕es.
//--------------------------------------------------------------------------

If (cAliasCSZ)->CSZ_FMTRIB $ '1/2'
	//1 - L100A = PJ em Geral
	//2 - L100B = PJ Componente do Sistema Financeiro
	//3 - L100C = Sociedades Seguradoras, de Capitaliza็ใo ou Entidade Aberta de Previd๊ncia Complementar
	//4 - L300A = PJ em Geral
	//5 - L300B = PJ Componente do Sistema Financeiro
	//6 - L300C = Sociedades Seguradoras, de Capitaliza็ใo ou Entidade Aberta de Previd๊ncia Complementar	
	cTabPlRef := (cAliasCSZ)->CSZ_QUALPJ 
ElseIf (cAliasCSZ)->CSZ_FMTRIB $ '3/4/5/7'
	cTabPlRef := '07'
ElseIf (cAliasCSZ)->CSZ_FMTRIB $ '8|9' 
	If lPlanoRef
		//9  - U100A – Imunes e Isentas em Geral (99)
		//10 - U100B – Associa็ใo de Poupan็a e Empr้stimo (11)
	 	//11 - U100C – Entidades Abertas de Previd๊ncia Complementar (12)
	 	//12 - U100D – Entidades Fechadas de Previd๊ncia Complementar (06)
	 	//13 - U100E – Partidos Polํticos (15)
		If ( (cAliasCSZ)->CSZ_TPENTI  == '99' ) .OR. (cAliasCSZ)->CSZ_TPENTI = '' 
			cTabPlRef := '09'
		ElseIf ( (cAliasCSZ)->CSZ_TPENTI  == '11' )
			cTabPlRef := '10'
		ElseIf ( (cAliasCSZ)->CSZ_TPENTI  == '12' )
			cTabPlRef := '11'
		ElseIf ( (cAliasCSZ)->CSZ_TPENTI  == '16' )
			cTabPlRef := '12'
		ElseIf ( (cAliasCSZ)->CSZ_TPENTI  == '15' )
			cTabPlRef := '13'
		Else
			cTabPlRef := '09'			
		EndIf
	ElseIf !lPlanoRef
		//1 - U100A – Imunes e Isentas em Geral (99)
		//2 - U100B – Associa็ใo de Poupan็a e Empr้stimo (11)
	 	//3 - U100C – Entidades Abertas de Previd๊ncia Complementar (12)
	 	//4 - U100D – Entidades Fechadas de Previd๊ncia Complementar (06)
	 	//5 - U100E – Partidos Polํticos (15)
		If ( (cAliasCSZ)->CSZ_TPENTI  == '99' ) .OR. (cAliasCSZ)->CSZ_TPENTI = '' 
			cTabPlRef := '1'
		ElseIf ( (cAliasCSZ)->CSZ_TPENTI  == '11' )
			cTabPlRef := '2'
		ElseIf ( (cAliasCSZ)->CSZ_TPENTI  == '12' )
			cTabPlRef := '3'
		ElseIf ( (cAliasCSZ)->CSZ_TPENTI  == '16' )
			cTabPlRef := '4'
		ElseIf ( (cAliasCSZ)->CSZ_TPENTI  == '15' )
			cTabPlRef := '5'
		Else
			cTabPlRef := '1'
		EndIf
	EndIf
EndIf

Return cTabPlRef

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณECFExpRTF  บAutorณFelipe Cunha 		  บ Data ณ  01/01/2015บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica Cod Plano Referencial			                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS103                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ECFExpRTF(oProcess, cRevisao, cAlias, cReg )
Local aArea		:= GetArea()
Local cAliasCSF	:= "CSF"
Local cFilCSF   := xFilial( "CSF" )
Local cQuery	:= ''
Local cKey		:= '' // Chave do registro na TAFST1
Local lRet		:= .T.
Local cMsg		:= ''
Local lFirst 	:= .T.

Default oProcess	:= Nil
Default cRevisao 	:= ''
Default cAlias		:= 'TAFST1'
Default cReg		:= ''

DbSelectArea( "CSF" )
DbSetOrder(1)

//-----------------------------------------------------
// Barra de Progresso
//-----------------------------------------------------
If oProcess <> Nil
	oProcess:IncRegua1( "Exp. Y800 - Outras informa็๕es" )
	oProcess:SetRegua2(0)
	oProcess:IncRegua2( '' )	
Endif

//-----------------------------------------------------
// Seleciona Dados
//-----------------------------------------------------
If __lDefTop
	cQuery := ''
	cQuery := "	SELECT CSF.CSF_FILIAL,	"
	cQuery += "        CSF.CSF_CODREV,	"
	cQuery += "        CSF.CSF_NOMDEM,	"
	cQuery += "        CSF.CSF_DTFIM, 	"
	cQuery += "        CSF.CSF_LINHA, 	"	
	cQuery += "        CSF.CSF_ARQRTF,  "
	cQuery += "        CSF.R_E_C_N_O_ RECCSF  "
	cQuery +=  "FROM " + RetSqlName( "CSF" ) + " CSF "
	cQuery +=  "WHERE CSF.CSF_FILIAL = '" + cFilCSF + "'	" 
	cQuery +=  "  AND CSF.CSF_CODREV = '" + cRevisao + "'"
	cQuery +=  "  AND CSF.D_E_L_E_T_ = ' '	"	 
	cQuery +=  "ORDER BY CSF.CSF_LINHA "
	
	cQuery := ChangeQuery( cQuery )
	cAliasCSF := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCSF)
Endif

//-----------------------------------------------------
// Exporta Dados parea tabela TAFST1
//-----------------------------------------------------
cKey := (cAliasCSF)->CSF_FILIAL + (cAliasCSF)->CSF_CODREV + 'T123' + (cAliasCSF)->CSF_NOMDEM
	
While (cAliasCSF)->CSF_FILIAL == cFilCSF .AND. (cAliasCSF)->(!Eof())
	cMsg := ''
	
	If lFirst
		cMsg += '|' + 'T123'						// REGISTRO
		cMsg += '|' + (cAliasCSF)->CSF_DTFIM + '|'	// PER_LANC
	EndIf
		
	cMsg += ECDGetTxt((cAliasCSF)->RECCSF)	// ARQ_RTF
	
	lFirst := .F.
	
	lRet := EcfGrvSt1(cAlias, cFilCSF, cKey, 'T123', cMsg, StrZero(Val((cAliasCSF)->CSF_LINHA),3) )
	
	(cAliasCSF)->( dbSkip() )			
EndDo	

(cAliasCSF)->(dbCloseArea())

RestArea(aArea)
	
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDipjReg  บAutorณ Andr้ Luiz	 	บ Data ณ  23/09/15           บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega array aReg - Registros a serem gerados p/ DIPJ     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ CTBS103                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function DipjReg(aRetWizd)

Local aRegDipj := {}

If aRetWizd[ECF_REGX291_DIPJ] == 1 .Or. aRetWizd[ECF_REGX292_DIPJ] == 1
	aAdd( aRegDipj, 'T096')
EndIf
	
If aRetWizd[ECF_REGX300_DIPJ] == 1 .Or. aRetWizd[ECF_REGX310_DIPJ] == 1			
	aAdd( aRegDipj, 'T097')
EndIf

If aRetWizd[ECF_REGX320_DIPJ] == 1 .Or. aRetWizd[ECF_REGX330_DIPJ] == 1
	aAdd( aRegDipj, 'T098')
EndIf

If aRetWizd[ECF_REGY540_DIPJ] == 1
	aAdd( aRegDipj, 'T105')
EndIf

If aRetWizd[ECF_REGY550_DIPJ] == 1
	aAdd( aRegDipj, 'T106')
EndIf

If aRetWizd[ECF_REGY560_DIPJ] == 1
	aAdd( aRegDipj, 'T107')
EndIf

If aRetWizd[ECF_REGY600_DIPJ] == 1
	aAdd( aRegDipj, 'T111')
EndIf

If aRetWizd[ECF_REGY570_DIPJ] == 1
	aAdd( aRegDipj, 'T108')
EndIf

Return aRegDipj



//-------------------------------------------------------------------
/*/{Protheus.doc} EcfExpBl_V
Exportacao Bloco V=ECF=DEREX

@author TOTVS
@since 03/05/2017
@version P11.8
/*/
//-------------------------------------------------------------------

  
Static Function EcfExpBl_V(oProcess, cRevisao, cAlias)
Local aArea		:= GetArea()
Local cMsg			:= ''
Local cQuery		:= ''
Local cKey			:= ''
Local lRet			:= .T.
Local cIdBlV		:=""
Local lPrimMes 	:= .T.
Local cCdInstFi 	:= ""

Local cAliasCVU	:= "CVU"
Local cFilCVU  	:= xFilial( "CVU" )
Local cAliasCVV	:= "CVV"
Local cFilCVV  	:= xFilial( "CVV" )
Local cFilCSE  	:= xFilial( "CSE" )
Local aStruct := {}
Local nX
Local cOpConcat	:= ""
Local lOracle	:= "ORACLE" $ __cGetDB 
Local lPostgres	:= "POSTGRES" $ __cGetDB 
Local lDB2		:= "DB2" $ __cGetDB 
Local lInformix	:= "INFORMIX" $ __cGetDB 
Local cCodigo := ""

Default oProcess	:= Nil
Default cRevisao 	:= ''
Default cAlias	    := 'TAFST1'

//-----------------------------------------------------
// Barra de Progresso
//-----------------------------------------------------
If oProcess <> Nil
	oProcess:IncRegua1( "Exportando ECF - Bloco V - Derex" )
	oProcess:SetRegua2(0)
	oProcess:IncRegua2( '' )	
Endif
//TABELA DE RESPONSAVEIS PELA INSTITUICAO
DbSelectArea("CVV")
CVV->(dbSetOrder(1))
//TABELA DADOS DA ECF
DbSelectArea( "CSZ" )
DbSetOrder(1)
DbSelectArea("CSZ")
CSZ->(dbSetOrder(1))
CSZ->(dbSeek(xFilial("CSZ") + cRevisao))
cIdBlV	:= CSZ->CSZ_IDBLV

If __lDefTop


	//-----------------------------------------------------
	// Seleciona Dados INSTITUICAO FINANCEIRA
	//-----------------------------------------------------
	
	//concatena็ใo
	cOpConcat  	:= If( lOracle .Or. lPostgres .Or. lDB2 .Or. lInformix, " || ", " + " ) 

	//REGISTRO T134
	cQuery := " SELECT 'T134' REGISTRO, CVU_IDBLV ,CVU_CODIGO , CVU_NOME NOME_INSTITUICAO, CVU_PAIS PAIS, CVU_MOEDA TIP_MOEDA " 
	cQuery += " FROM " + RetSqlName('CVU') +  " CVU "
	cQuery += " WHERE CVU_FILIAL = '" + cFilCVU + "' "
	cQuery += "   AND CVU_IDBLV =  '" + cIdBlV + "' "
	cQuery += "   AND CVU.D_E_L_E_T_ = ' ' "

	cQuery 		:= ChangeQuery( cQuery )
		
	cAliasCVU 	:= GetNextAlias()
		
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCVU )

	//-----------------------------------------------------
	// Exporta Dados parea tabela TAFST1
	//-----------------------------------------------------
	While (cAliasCVU)->( ! Eof() )
		
		If ( oProcess <> Nil ) 
			oProcess:IncRegua2( "Revisใo: " + cIdBlV ) //"Revisใo: "
		EndIf
		
		//monta codigo, no postgres estava trazendo espa็os em branco
		cCodigo := (cAliasCVU)->CVU_IDBLV + (cAliasCVU)->CVU_CODIGO

		//Montagem campo TAFMSG	
		cMsg := ''
		cMsg := '|' + (cAliasCVU)->REGISTRO                           	// REGISTRO T134
		cMsg += '|' + Alltrim( cCodigo )	    				// CODIGO COMPOSTO CVU_IDBLV + CVU_CODIGO
		cMsg += '|' + Alltrim( (cAliasCVU)->NOME_INSTITUICAO)			// NOME_INSTITUICAO = CVU_NOME
		cMsg += '|' + Alltrim( (cAliasCVU)->PAIS)							// PAIS = CVU_PAIS
		cMsg += '|' + Alltrim( (cAliasCVU)->TIP_MOEDA)					// TIP_MOEDA = CVU_MOEDA TABELA DA RECEITA
		cMsg += '|'
		cMsg += CRLF
		
		//Monta a chave do registro
		cKey := (cAliasCSZ)->CSZ_FILIAL + (cAliasCSZ)->CSZ_CODREV + 'T134' + cCodigo
		
		CVV->(dbSetOrder(1))		
		If CVV->(dbSeek(xFilial("CVV")+cCodigo))
			While CVV->(CVV_FILIAL+CVV_IDBLV+CVV_CODIGO) == xFilial("CVV")+cCodigo
			
				cMsg += '|T134AA'				                         	// REGISTRO T134AA				
				cMsg += '|' + AllTrim( CVV->CVV_NRODOC )					// DOC_RESP Nro Documento Responsavel
				cMsg += '|' + AllTrim( CVV->CVV_IDCTA  )					// CTA_RESP Nro da Conta do Responsavel
				cMsg += '|'
				cMsg += CRLF

				CVV->(dbSkip())
			EndDo
		EndIf

		//Grava Dados na tabela TAFST1
		lRet := EcfGrvSt1(cAlias, cFilCSZ, cKey, 'T134', cMsg)	

		(cAliasCVU)->( dbSkip() )
					
	EndDo

	(cAliasCVU)->( dbCloseArea() )

	//-----------------------------------------------------------
	// Seleciona Dados RESPONSAVEIS PELA INSTITUICAO FINANCEIRA
	//-----------------------------------------------------------

	//REGISTRO T135  - RESPONSAVEL 
	cQuery := " SELECT 'T135' REGISTRO,  CVV_TIPDOC TIPO_DO_C, CVV_NRODOC NI, CVV_NOMRSP NOME, CVV_ENDRSP ENDERECO, CVV_IDCTA IDCTA " 
	cQuery += " FROM " + RetSqlName('CVV') + " CVV "
	cQuery += " WHERE CVV_FILIAL = '" + cFilCVV + "' "
	cQuery += "   AND CVV_IDBLV =  '" + cIdBlV + "' "
	cQuery += "   AND CVV.D_E_L_E_T_ = ' ' "

	cQuery 		:= ChangeQuery( cQuery )
		
	cAliasCVV 	:= GetNextAlias()
		
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCVV )

	//-----------------------------------------------------
	// Exporta Dados parea tabela TAFST1
	//-----------------------------------------------------
	While (cAliasCVV)->( ! Eof() )
		
		If ( oProcess <> Nil ) 
			oProcess:IncRegua2( "Revisใo: " + cIdBlV ) //"Revisใo: "
		EndIf
		
		//Montagem campo TAFMSG	
		cMsg := ''
		cMsg := '|' + (cAliasCVV)->REGISTRO                           	// REGISTRO T135
		cMsg += '|' + Alltrim( (cAliasCVV)->TIPO_DO_C )	    			// CVV_TIPDOC =  TIPO_DO_C
		cMsg += '|' + Alltrim( (cAliasCVV)->NI)							// CVV_NRODOC =  NI
		cMsg += '|' + Alltrim( (cAliasCVV)->NOME)							// CVV_NOMRSP = NOME
		cMsg += '|' + Alltrim( (cAliasCVV)->ENDERECO)						// CVV_ENDRSP = ENDERECO
		cMsg += "|"
		cMsg += CRLF
	
		//Monta a chave do registro
		cKey := (cAliasCSZ)->CSZ_FILIAL + (cAliasCSZ)->CSZ_CODREV + 'T135' + (cAliasCVV)->NI + (cAliasCVV)->IDCTA
		
		//Grava Dados na tabela TAFST1
		lRet := EcfGrvSt1(cAlias, cFilCSZ, cKey, 'T135', cMsg)	
		(cAliasCVV)->( dbSkip() )
					
	EndDo

	(cAliasCVV)->( dbCloseArea() )

	//-----------------------------------------------------------
	// Seleciona Dados VALORES POR MES POR INSTITUICAO FINANCEIRA
	//-----------------------------------------------------------

	//REGISTRO T136 - MES / VALORES -> ECF: REGISTRO V030: DEREX - Perํodo - M๊s e V100: Demonstrativo dos recursos em moeda estrangeira decorrentes do recebimento de exporta็๕es
	//ESTES REGISTROS NAS TABELAS CSD/CSE SE REFEREM A VISAO GERENCIAL INFORMADA NA CONFIG LIVROS NO CADASTRO BLOCO V TABELA CVW
	cQuery := ''
	cQuery := "	SELECT CSD.CSD_FILIAL, "
	cQuery += "        CSD.CSD_CODREV, "
	cQuery += "        CSD.CSD_CODVIS, "
	cQuery += "        CSD.CSD_REGIST, "
	cQuery += "        CSD.CSD_DTINI,  "
	cQuery += "        CSD.CSD_DTFIN,  "
	cQuery += "        CSD.CSD_PERIOD, "	
	cQuery += "        CSD.CSD_IDBLV, "	
	cQuery += "        CSD.CSD_CDINST, "	
	cQuery += "        CSE.CSE_FILIAL, "
	cQuery += "        CSE.CSE_CODREV, "
	cQuery += "        CSE.CSE_CODVIS, "
	cQuery += "        CSE.CSE_REGIST, "
	cQuery += "        CSE.CSE_TPDEM,  "
	cQuery += "        CSE.CSE_CODAGL, "
	cQuery += "        CSE.CSE_DESCRI, "
	cQuery += "        CSE.CSE_CLASSE, "
	cQuery += "        CSE.CSE_NIVEL,  "
	cQuery += "        CSE.CSE_NATCTA, "
	cQuery += "        CSE.CSE_CTASUP, "
	cQuery += "        CSE.CSE_INDVAL, "
	cQuery += "        CSE.CSE_PERIOD, "
	cQuery += "        CSE.CSE_VALOR,  "
	cQuery += "        CSE.CSE_VLRINI, "
	cQuery += "        CSE.CSE_INDINI, "
	cQuery += "        CSE.CSE_VLRFIM, "
	cQuery += "        CSE.CSE_INDFIM  "
	cQuery +=  "FROM " + RetSqlName( "CSD" ) + " CSD," +  RetSqlName( "CSE" ) + " CSE "
	cQuery +=  "WHERE CSE_FILIAL = '" + cFilCSE + "'" 
	cQuery +=  "  AND CSD.CSD_FILIAL = CSE.CSE_FILIAL   " 
	cQuery +=  "  AND CSD.CSD_CODREV   = CSE.CSE_CODREV  "
	cQuery +=  "  AND CSD.CSD_CODVIS   = CSE.CSE_CODVIS   "
	cQuery +=  "  AND CSD.CSD_REGIST   = CSE.CSE_REGIST   "
	cQuery +=  "  AND CSD.CSD_PERIOD   = CSE.CSE_PERIOD   "
	cQuery +=  "  AND CSD.CSD_IDBLV    = CSE.CSE_IDBLV   "
	cQuery +=  "  AND CSD.CSD_CDINST   = CSE.CSE_CDINST   "
	cQuery +=  "  AND CSD.CSD_CODREV 	= '" + cRevisao + "' "
	cQuery +=  "  AND CSE.CSE_CODREV 	= '" + cRevisao + "' "	
	cQuery +=  "  AND CSD.CSD_REGIST 	= 'V100' "
	cQuery +=  "  AND CSE.CSE_REGIST 	= 'V100' "
	cQuery +=  "  AND CSD.CSD_IDBLV    = '" + cIdBlV + "' "
	cQuery +=  "  AND CSE.CSE_IDBLV    = '" + cIdBlV + "' "
	cQuery +=  "  AND CSE.CSE_CLASSE    = '2' "
	cQuery +=  "  AND CSD.D_E_L_E_T_ = ' '                "
	cQuery +=  "  AND CSE.D_E_L_E_T_ = ' '                "
	cQuery +=  "GROUP BY CSD.CSD_FILIAL, CSD.CSD_CODREV, CSD.CSD_CODVIS, CSD.CSD_REGIST, CSD.CSD_IDBLV, CSD.CSD_CDINST, CSD.CSD_DTINI, CSD.CSD_DTFIN, CSD.CSD_PERIOD, CSE.CSE_FILIAL, CSE.CSE_CODREV, CSE.CSE_CODVIS, CSE.CSE_REGIST, CSE.CSE_IDBLV, CSE.CSE_CDINST, CSE.CSE_TPDEM , CSE.CSE_CODAGL, CSE.CSE_DESCRI, CSE.CSE_CLASSE, CSE.CSE_NIVEL , CSE.CSE_NATCTA, CSE.CSE_CTASUP, CSE.CSE_INDVAL, CSE.CSE_PERIOD, CSE.CSE_VALOR, CSE.CSE_VLRINI, CSE.CSE_INDINI, CSE.CSE_VLRFIM, CSE.CSE_INDFIM " 	 
	cQuery +=  "ORDER BY CSE.CSE_REGIST,CSE.CSE_IDBLV,CSE.CSE_CDINST,CSE.CSE_CODAGL "
	
	cQuery := ChangeQuery( cQuery )
	cAliasCSE := GetNextAlias()
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCSE)

	aStruct   := CSE->(dbStruct())

	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C" .And. FieldPos(aStruct[nX][1])<>0
			TcSetField(cAliasCSE,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf
	Next nX

	//-----------------------------------------------------
	// Exporta Dados parea tabela TAFST1
	//-----------------------------------------------------
	While (cAliasCSE)->( ! Eof() )
		
		If ( oProcess <> Nil ) 
			oProcess:IncRegua2( "Revisใo: " + cIdBlV ) //"Revisใo: "
		EndIf

		cCdInstFi := (cAliasCSE)->CSD_CDINST

		//POSICIONA NA TABELA DE RESPONSAVEIS - SEMPRE PEGA O PRIMEIRO DA LISTA
		CVV->( dbSeek( xFilial("CVV") + cIdBlV + cCdInstFi ) )

		lPrimMes := .T.

		While (cAliasCSE)->( ! Eof() ) .And. (cAliasCSE)->CSD_CDINST == cCdInstFi
		
		
			If Alltrim( (cAliasCSE)->CSE_CODAGL ) == '00'  					//CONTA SINTETICA PAI
				(cAliasCSE)->( dbSkip() )
				Loop
			EndIf
	  
			//Montagem campo TAFMSG
			cMsg := ''
			cMsg := '|' + 'T136'														// REGISTRO
			cMsg += '|' + (cAliasCSE)->CSD_IDBLV + (cAliasCSE)->CSD_CDINST 	// CODIGO_INSTITUICAO - ID BLOCO V + CODIGO DA INST FINANC
			
			cMsg += '|' + Alltrim( CVV->CVV_TIPDOC ) 								// TIPO_DO_C - TAB CVV RESP INST FINANC
			cMsg += '|' + Alltrim( CVV->CVV_NRODOC ) 								// NI - TAB CVV RESP INST FINANC
			
			cMsg += '|' + Alltrim( (cAliasCSE)->CSD_DTFIN )   					// DATA
			
			If Alltrim( (cAliasCSE)->CSE_CODAGL ) == '01'  					//Saldo inicial da escritura็ใo
			
				cMsg += '|' + '1'                                 												// CODIGO
				If lPrimMes
					cMsg += '|' + Alltrim( Str( (cAliasCSE)->CSE_VLRINI * If((cAliasCSE)->CSE_INDINI=='C',1,-1) ) )		// VALOR
					lPrimMes := .F.
				Else
					cMsg += '|0'                                                                           // VALOR ZERADO 
				EndIf 
			
			ElseIf Alltrim( (cAliasCSE)->CSE_CODAGL ) == '02'   				//somente titulo Movimenta็๕es
			
				cMsg += '|' + '2'                                 												// CODIGO
				cMsg += '|0'                                        												// VALOR ZERADO 
			
			ElseIf Alltrim( (cAliasCSE)->CSE_CODAGL ) == '03'   				//Saldo inicial do m๊s

				cMsg += '|' + '3'                                 												// CODIGO
				cMsg += '|' + Alltrim( Str( (cAliasCSE)->CSE_VLRINI * If((cAliasCSE)->CSE_INDINI=='C',1,-1) ) )			// VALOR
			
			Else                                                				//demais contas da visao gerencial	
			
				cMsg += '|' + Alltrim( (cAliasCSE)->CSE_CODAGL )   												// CODIGO
				cMsg += '|' + Alltrim( Str( (cAliasCSE)->CSE_VALOR )	)											// VALOR
			
			EndIf 
	
			cMsg += '|' + Alltrim( CVV->CVV_IDCTA )   							// IDENT_CONTA - TAB CVV RESP INST FINANC
			cMsg += "|"
			cMsg += CRLF
		
			//Monta a chave do registro
			cKey := (cAliasCSZ)->CSZ_FILIAL + (cAliasCSZ)->CSZ_CODREV + (cAliasCSE)->CSD_CDINST + (cAliasCSE)->CSE_PERIOD + (cAliasCSE)->CSE_CODAGL + 'T136' 
			
			//Grava Dados na tabela TAFST1
			lRet := EcfGrvSt1(cAlias, cFilCSZ, cKey, 'T136', cMsg)	
			(cAliasCSE)->( dbSkip() )
		
		EndDo
					
	EndDo

	(cAliasCSE)->( dbCloseArea() )

Endif

RestArea(aArea)
	
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} DBClick
Fun็ใo auxiliar para marcar/desmarcar filiais da tela de sele็ใo de filiais para o registro Y540

@param oFil     -> Objeto TWBrowse
@param aFilY540 -> Array com as filiais a serem marcadas/desmarcadas
@param cMatriz  -> Filial Centralizadora ( nใo serแ desmarcada, pois o registro Y540 deve ser gerado considerando essa filial )

@Author Wesley Pinheiro
@Since 04/08/2020
/*/
Static Function DBClick( oFil, aFilY540, cMatriz )
	
	If Alltrim( aFilY540[oFil:nAt,3] ) != AllTrim( cMatriz )
		aFilY540[oFil:nAt,1] := !aFilY540[oFil:nAt,1]
		oFil:Refresh( )
	EndIf
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} HeadClick
Fun็ใo auxiliar para marcar/desmarcar filiais da tela de sele็ใo de filiais para o registro Y540 
a partir do click na primeira coluna do MarkBrowse

@param oFil     -> Objeto TWBrowse
@param nOpcY540 -> Array com as filiais a serem marcadas/desmarcadas
@param cMatriz  -> Filial Centralizadora ( nใo serแ desmarcada, pois o registro Y540 deve ser gerado considerando essa filial )

@Author Wesley Pinheiro
@Since 04/08/2020
/*/
Static Function HeadClick( oFil, aFilY540, cMatriz )
	
	Local nX := 0

	for nX := 1 to Len( aFilY540 )

		If Alltrim( aFilY540[nX,3] ) != AllTrim( cMatriz )
			aFilY540[nX,1] := !aFilY540[nX,1]
		EndIf

	Next nX

	oFil:Refresh( )
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} changePanel
Fun็ใo auxiliar para a execu็ใo dos passos da wizard DIPJ.
Dependendo da configura็ใo da escritura็ใo ( "Com centraliza็ใo" ) e gera็ใo do registro Y540, 
้ necessแrio solicitar sele็ใo de filiais para a gera็ใo desse registro.

@param  cAction  -> String auxiliar patra identificar qual a็ใo foi solicitada para a wizard
@param  nOpcY540 -> Op็ใo de sele็ใo para gerar registro Y540 1=sim, 2=nใo
@param lCentraliz  -> Indica se a Escritura็ใo contแbil foi configurada para ser do tipo "Com Centraliza็ใo"

@Author Wesley Pinheiro
@Since 04/08/2020
/*/
Static Function changePanel( cAction, nOpcY540, lCentraliz )

	Local nPanel := 1

	/*
		A wizard para a gera็ใo da DIPJ pode ter 3 pain้is ( "Sem Centraliza็ใo" )

		oWizard:AHEADERTITLE[1][1]: "Exporta็ใo de Dados"
		oWizard:AHEADERTITLE[2][1]: "Exporta็ใo de Dados DIPJ"
		oWizard:AHEADERTITLE[3][1]: "Exporta็ใo de Dados Finalizada"

		ou

		4 pain้is ( "Com Centraliza็ใo e gera็ใo Y540 1=sim" )

		oWizard:AHEADERTITLE[1][1]: "Exporta็ใo de Dados"
		oWizard:AHEADERTITLE[2][1]: "Exporta็ใo de Dados DIPJ"
		oWizard:AHEADERTITLE[3][1]: "Quais filiais devem gerar o registro Y540 para a DIPJ?"
		oWizard:AHEADERTITLE[4][1]: "Exporta็ใo de Dados Finalizada"

		OBS: Os blocos de c๓digo para as a็๕es "NEXT" e "BACK" sใo montados assim:

		ONEXT
			BACTION:"{ || IF(EVAL(SELF:ACBVALID[SELF:NPANEL,2]),(SELF:NPANEL+=1,SELF:NAVIGATOR(2),EVAL(SELF:ACBEXECUTE[SELF:NPANEL])),)}"

		OBACK
			BACTION:"{ ||  IF(EVAL(SELF:ACBVALID[SELF:NPANEL,1]),(SELF:NPANEL-=1,SELF:NAVIGATOR(1),EVAL(SELF:ACBEXECUTE[SELF:NPANEL])),)}"


		Com incremento SELF:NPANEL+=1 e decremento SELF:NPANEL-=1, por isso foi montado a l๓gica abaixo,
		considerando os paineis montados acima.

	*/

	If cAction == "next"

		If nOpcY540 == 1
			nPanel := 2
		Else
			nPanel := Iif( lCentraliz, 3, 2 )
		EndIf

	Else
		If nOpcY540 == 1
			nPanel := Iif( lCentraliz, 4, 3 )
		Else
			nPanel := 3
		EndIf

	EndIf

Return nPanel

//-------------------------------------------------------------------
/*/{Protheus.doc} Lay7ECF
Retorna .F. para perguntas a ser desabilitada a partir do leiaute 7


@author Totvs
@since 18-02-2021
@version P12.1.33
/*/
//-------------------------------------------------------------------
Static Function Lay7ECF()
Local lRet := .T.

If Val(CS0->CS0_LEIAUT) >= 7
	lRet := .F.
EndIf

Return(lRet)
