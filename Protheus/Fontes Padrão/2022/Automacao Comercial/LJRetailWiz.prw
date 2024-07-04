#INCLUDE 'Protheus.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "POSCSS.CH" 
#INCLUDE "STPOS.CH" 
#INCLUDE "FILEIO.CH"
#INCLUDE "STFMOBWIZARD.CH"
#INCLUDE "LJRETAILWIZ.CH"
#DEFINE CRLF CHR(13)+CHR(10)

Static oStepWiz 	:= Nil	//Objto tipo Wizard
Static oNewPag		:= Nil	//Objeto que adiciona nova pagina no wizard

Static cEmpPnl1   	:= ""	// Company Name
Static cNomePnl2	:= ""	// Nome do Usuário
Static cSobrePnl2 	:= ""	// SobreNome do Usuário
Static cEmailPnl2	:= "" 	// Email do Usuário
Static cPathPnl3   	:= ""   // Caminho para geração dos arquivos de configuração inicial

Static aFilsPnl1	:= {}   // Filiais para exportacao
Static cUrlConPnl2	:= ''   // Url de Conexao
Static cUrlPostPnl2	:= ''   // Url de Transmissao

Static cEmailPnl3	:= Space(50) // Email do Usuário
Static cPassPnl3	:= Space(15) // Password do Usuário
Static cDiasProc	:= "001"   // Dias para processamento, default 001, alteração deverá ser via configurador
Static cDiasMov		:= ""   // Dias para processamento via Botao em tela
Static cTESValid	:= PadR("Exemplo : 501,502,503",180)  // TES para processamento
Static cTimeAuto	:= ""	// Tempo do job
Static cParAPP0		:= ""  
Static cParAPP1		:= "" 
Static lCheckAut	:= .F.


//-----------------------------------------------------------
/*/{Protheus.doc} LJRetailSI
Wizard de geração do setup inicial da integraçao RetailApp
@author Mauricio Canalle
@since 22/06/2017
@return NIL
/*/
//-----------------------------------------------------------
Function LJRetailSI()

Private oGetDados
Private aHeadFil	:= {}
Private aColsFil   := {}

oStepWiz 	:= Nil	//Objto tipo Wizard
oNewPag		:= Nil	//Objeto que adiciona nova pagina no wizard
cEmpPnl1   	:= ""	// Company Name
cNomePnl2	:= ""	// Nome do Usuário
cSobrePnl2 	:= ""	// SobreNome do Usuário
cEmailPnl2	:= "" 	// Email do Usuário
cPathPnl3   	:= '\retailapp\'+Space(50)   // Caminho para geração dos arquivos de configuração inicial

If !ValidSX6() // Verifica se os parametros foram criados
	Return Nil
EndIf

If !VldPreCfg()
	Return Nil
EndIf

If FindFunction('__FWWIZCTLR')   // valida se a classe FWWizardControl existe no RPO
	//Instancia a classe FWWizard
	oStepWiz:= FWWizardControl():New(,)// Define o tamanho do wizard  ex: {600,800}
	oStepWiz:ActiveUISteps()

	// 01 ------------------------------ "Empresa/Filiais"
	oNewPag := oStepWiz:AddStep("1")//Adiciona a primeira tela do wizard
	oNewPag:SetStepDescription(STR0001) //Altera a descrição do step //'Empresa/Filiais'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    
	oNewPag:SetConstruction({|Panel|cria_SI1(Panel)}) //Define o bloco de construção
	oNewPag:SetNextAction({||  valida_SI1() })//Define o bloco ao clicar no botão Próximo
	oNewPag:SetCancelAction({|| .T. })//Valida acao cancelar

	// 02 ------------------------------ "Usuário ADM"
	oNewPag := oStepWiz:AddStep("2", {|Panel|cria_SI2(Panel)})
	oNewPag:SetStepDescription(STR0002) //'Usuário ADM'                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
	oNewPag:SetNextAction({||valida_SI2()})
	oNewPag:SetCancelAction({|| .T. })//Valida acao cancelar
	//oNewPag:SetCancelWhen({||.F.})

	// 03 ------------------------------ "Configuração Inicial"
	oNewPag := oStepWiz:AddStep("3", {|Panel|cria_SI3(Panel)})
	oNewPag:SetStepDescription(STR0003) //'Configuração Inicial'
	oNewPag:SetNextAction({|| valida_SI3() })
	oNewPag:SetCancelAction({|| .T. })//Valida acao cancelar
	//oNewPag:SetCancelWhen({||.F.})

	//Ativa Wizard
	oStepWiz:Activate()

	//Desativa Wizard
	oStepWiz:Destroy()
Else
	Alert(STR0004) //'Classe FWWizardControl não disponível. É necessário a atualização do pacote LIB disponivel no portal do cliente.'	
Endif

Return .T.

//-------------------------------------------------------------------	
/*/{Protheus.doc} cria_SI1
Cria wizard de Configurações para mobile pg1
@param  oPanel - Panel de Fundo
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function cria_SI1(oPanel)
Local oList1
Local oOk		:= LoadBitmap( GetResources(), "LBOK")
Local oNo      := LoadBitmap( GetResources(), "LBNO")
Local cVarQ
Local oSay1
Local oSay2
Local oTGet1
Local oBtn1
Local nRegSM0 := 0
Local nX		    := 0
Local aCpoGDa       := {}
Local aAlter       	:= NIL
Local nOpc         	:= GD_INSERT +  GD_UPDATE + GD_DELETE
Local cLinOk       	:= "Allwaystrue"
Local cTudoOk      	:= "Allwaystrue"
Local cFieldOk     	:= "Allwaystrue"
Local cDelOk        := "Allwaystrue"
Local cIniCpos     	:= '+CID'
Local nFreeze      	:= 000
Local nMax         	:= 999
Local cSuperDel     := NIL
Local lEditCell		:= .F.
cEmpPnl1  := SM0->M0_NOME

//---------- Seleciona Filiais
oSay1:= TSay():New(05,10,{|| STR0005 },oPanel,,,,,,.T.,,,250,070) //'Informe o Nome da Companhia (Global Company Name)'
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_LABEL_NORMAL )) 

oTGet1 := TGet():New(15,10,{|u| if( PCount() > 0, cEmpPnl1 := u, cEmpPnl1 ) } ,oPanel,110,020, ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cEmpPnl1,,,, )
oTGet1:SetCSS( POSCSS (GetClassName(oTGet1), CSS_GET_NORMAL ))

oSay2:= TSay():New(45,10,{|| STR0006 },oPanel,,,,,,.T.,,,250,070) //'Selecione as Filiais que enviarão dados para o RetailApp (Organization Structure)'
oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_NORMAL )) 

aAdd( aHeadFil, { 'Codigo', ; // 01 - Titulo
		'CID'	, ;			// 02 - Campo
		'999'	 , ;			// 03 - Picture
		3	 , ;			// 04 - Tamanho
		0	 , ;			// 05 - Decimal
		''  , ;			// 06 - Valid
		''  	, ;			// 07 - Usado
		'N'			   	, ;			// 08 - Tipo
		''		   , ;			// 09 - F3
		''   , ;         // 10 - Contexto
		''	  , ; 		// 11 - ComboBox
		''   , ;         // 12 - Relacao
		''  , ;			// 13 - Inicializador Browse
		'S'  })			// 14 - Mostra no Browse

aAdd( aHeadFil, { 'Nivel', ; // 01 - Titulo
		'CNIVEL'	, ;			// 02 - Campo
		'9'	 , ;			// 03 - Picture
		1	 , ;			// 04 - Tamanho
		0	 , ;			// 05 - Decimal
		"NaoVazio() .AND. M->CNIVEL >= '2' .AND. M->CNIVEL <= '4'"  , ;			// 06 - Valid
		''  	, ;			// 07 - Usado
		'C'			   	, ;			// 08 - Tipo
		''		   , ;			// 09 - F3
		''   , ;         // 10 - Contexto
		''	  , ; 		// 11 - ComboBox
		''   , ;         // 12 - Relacao
		''  , ;			// 13 - Inicializador Browse
		'S'  } )			// 14 - Mostra no Browse
		
aAdd( aHeadFil, { 'Descrição', ; // 01 - Titulo
		'CDESC'	, ;			// 02 - Campo
		'@!'	 , ;			// 03 - Picture
		45	 , ;			// 04 - Tamanho
		0	 , ;			// 05 - Decimal
		'NaoVazio()'  , ;			// 06 - Valid
		''  	, ;			// 07 - Usado
		'C'			   	, ;			// 08 - Tipo
		''		   , ;			// 09 - F3
		''   , ;         // 10 - Contexto
		''	  , ; 		// 11 - ComboBox
		''   , ;         // 12 - Relacao
		''  , ;			// 13 - Inicializador Browse
		'S'  })			// 14 - Mostra no Browse
		
aAdd( aHeadFil, { 'Codigo Pai', ; // 01 - Titulo
		'CIDPAI'	, ;			// 02 - Campo
		'999'	 , ;			// 03 - Picture
		3	 , ;			// 04 - Tamanho
		0	 , ;			// 05 - Decimal
		""   , ;			// 06 - Valid
		''  	, ;			// 07 - Usado
		'N'			   	, ;			// 08 - Tipo
		''		   , ;			// 09 - F3
		''   , ;         // 10 - Contexto
		''	  , ; 		// 11 - ComboBox
		''   , ;         // 12 - Relacao
		''  , ;			// 13 - Inicializador Browse
		'S'  }) 		// 14 - Mostra no Browse
		
aAdd( aHeadFil, { 'Filial Protheus', ; // 01 - Titulo
		'CFILPRO'	, ;			// 02 - Campo
		''	 , ;			// 03 - Picture
		15	 , ;			// 04 - Tamanho
		0	 , ;			// 05 - Decimal
		'LjValidFil()'  , ;			// 06 - Valid
		''  	, ;			// 07 - Usado
		'C'			   	, ;			// 08 - Tipo
		'EMP'		   , ;			// 09 - F3
		''   , ;         // 10 - Contexto
		''	  , ; 		// 11 - ComboBox
		''   , ;         // 12 - Relacao
		''  , ;			// 13 - Inicializador Browse
		'S'  })			// 14 - Mostra no Browse

aAdd( aColsFil, { 1, '1', 'GLOBAL'+Space(50), 0 , Space(10), .F. } )

oGetDados := MsNewGetDados():New( 055, 010, 190, 290, nOpc, , cTudoOk, cIniCpos, {'CNIVEL','CDESC','CIDPAI','CFILPRO'}, 1, nMax, cFieldOk, cSuperDel, cDelOk, oPanel, aHeadFil, aColsFil )

Return Nil

//-------------------------------------------------------------------	
/*/{Protheus.doc} valida_SI1
Cria Validacao do wizard de Configurações para mobile pg1
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function valida_SI1()
Local lRet		:= .T.		//Retorno da validacao
Local nI		:= 0
Local aHeader	:= oGetDados:aHeader
Local aCols		:= oGetDados:aCols
Local aValNivel	:= {.F., .F., .F., .F.}  // ARRAY PARA VALIDAR SE OS 4 NIVEIS FORAM INFORMADOS

IIf(lRet					, lRet := !Empty(cEmpPnl1) 			,)    // Valida se a Empresa foi informada

If Len(aCols) == 1
   Alert(STR0007) //'Estrutura Organizacional não informada.'
   lRet := .F.
Else
	For nI := 1 to Len(aCols)  // Valida os dados da organização
		//valida se a linha está deletada
		If !aCols[nI,Len(aHeader)+1]	
		    If aCols[nI, 2] <> '1'  .AND. aCols[nI, 4] == 0 
				Alert(STR0008+Str(aCols[nI, 1], 3)+STR0009) //'Codigo '#' - Não foi informado Codigo Pai'
	   			lRet := .F. 
	   			Exit
			EndIf
			If aCols[nI, 4] > 0 // valido se o Codigo Pai é do nivel acima que o filho
			   nPosIDPai := aScan(aCols, {|x| x[1] == aCols[nI, 4]}) 
	
			   If nPosIDPai > 0
			      If (Val(aCols[nI, 2]) - Val(aCols[nPosIDPai, 2])) <> 1
					Alert(STR0008+Str(aCols[nI, 1], 3)+STR0010) //' - Nível do Codigo Pai inválido'
	   				lRet := .F. 	
	   				Exit		  
				  EndIf
			   EndIf
			EndIf
			If Empty(aCols[nI, 3]) 
				Alert(STR0008+Str(aCols[nI, 1], 3)+ STR0011) //' - Não foi informada a Descrição da Entidade'
	   			lRet := .F. 
	   			Exit
			EndIf
		    If aCols[nI, 2] == '4'  .AND. Empty(aCols[nI, 5])  
				Alert(STR0008+Str(aCols[nI, 1], 3)+ STR0012) //' - Não foi informada a Filial'
	   			lRet := .F. 
	   			Exit
			EndIf	   
		    If aCols[nI, 2] <> '4'  .AND. !Empty(aCols[nI, 5])  
				Alert(STR0008+Str(aCols[nI, 1], 3)+ STR0013) //' - Filial só deve ser informada no menor nível (4).'
	   			lRet := .F. 
	   			Exit			   
			EndIf
			If Val(aCols[nI, 2]) > 0
				aValNivel[Val(aCols[nI, 2])] := .T.
			Else
				aValNivel[nI] := .F.
			EndIf
		EndIf
	Next

	// Valida se foram informados os 4 niveis obrigatorios na organizacao
	For nI := 1 to Len(aValNivel)
	    If !aValNivel[nI]
			Alert(STR0014 +Str(nI, 1)) //'A Estrutura Organizacional não possui nenhum elemento de nível '
   			lRet := .F. 			   		
		Endif
	Next	
Endif	

Return lRet

//-------------------------------------------------------------------	
/*/{Protheus.doc} cria_SI2
Cria wizard de Configurações para mobile pg2
@param  oPanel - Panel de Fundo
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function cria_SI2(oPanel)
Local oSay1
Local oSay2
Local oSay3
Local oTGet1
Local oTGet2
Local oTGet3

cNomePnl2   := Space(050)
cSobrePnl2  := Space(050)
cEmailPnl2  := Space(150)
cPathPnl2	:= Space(70)

oSay1:= TSay():New(05,10,{|| STR0015 },oPanel,,,,,,.T.,,,450,070) //'Informe o Nome do Usuário ADM do RetailApp'
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_LABEL_NORMAL )) 

oTGet1 := TGet():New(20,10,{|u| if( PCount() > 0, cNomePnl2 := u, cNomePnl2 ) } ,oPanel,170,020, ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cNomePnl2,,,, )
oTGet1:SetCSS( POSCSS (GetClassName(oTGet1), CSS_GET_NORMAL ))

oSay2:= TSay():New(50, 10,{|| STR0016 },oPanel,,,,,,.T.,,,450,070) //'Informe o Sobrenome do Usuário ADM do RetailApp'
oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_NORMAL )) 

oTGet2 := TGet():New(65,10,{|u| if( PCount() > 0, cSobrePnl2 := u, cSobrePnl2 ) } ,oPanel,170,020, ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cSobrePnl2,,,, )
oTGet2:SetCSS( POSCSS (GetClassName(oTGet2), CSS_GET_NORMAL ))

oSay3:= TSay():New(95,10,{|| STR0017 },oPanel,,,,,,.T.,,,550,070) //'Informe o e-mail do Usuário ADM do RetailApp'
oSay3:SetCSS( POSCSS (GetClassName(oSay3), CSS_LABEL_NORMAL )) 

oTGet3 := TGet():New(110,10,{|u| if( PCount() > 0, cEmailPnl2 := u, cEmailPnl2 ) } ,oPanel,250,020, ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cEmailPnl2,,,, )
oTGet3:SetCSS( POSCSS (GetClassName(oTGet3), CSS_GET_NORMAL ))

Return Nil

//-------------------------------------------------------------------	
/*/{Protheus.doc} valida_SI2
Cria Validacao do wizard de Configurações para mobile pg2
@author  Varejo
@version P11.8
@since   27/05/2015
@return  lRet - Retorno da validacao
/*/
//-------------------------------------------------------------------	
Static Function valida_SI2()
Local lRet := .T.		//Retorno da validacao
Local cMsg	:= ""
If Empty(cNomePnl2)
	lRet := .F.
	cMsg	:= STR0018//"Favor preencher o campo Nome do Usuário ADM"
EndIf	
If lRet .And. Empty(cSobrePnl2)
	lRet := .F.
	cMsg	:= STR0019//"Favor preencher o campo Sobrenome do Usuário ADM"
EndIf	
If lRet .And. Empty(cEmailPnl2)
	lRet := .F.
	cMsg	:= STR0020//"Favor preencher o campo E-mail do Usuário ADM"
EndIf	

If !lRet
	MsgWzValid(cMsg)//Mensagem validacao
EndIf	

Return lRet

//-------------------------------------------------------------------	
/*/{Protheus.doc} cria_SI3
Cria wizard de Configurações para mobile pn3
@param  oPanel - Panel de Fundo
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function cria_SI3(oPanel)
Local oSay1
Local oSay2
Local oTGet1

cPathPnl3 := '\retailapp\'+Space(50)

oSay1:= TSay():New(05,10,{|| STR0021 },oPanel,,,,,,.T.,,,450,070) //"Pasta para gravação dos arquivos de configuração inicial (Initial Setup)"
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_LABEL_NORMAL )) 

oTGet1 := TGet():New(15,10,{|u| if( PCount() > 0, cPathPnl3 := u, cPathPnl3 ) } ,oPanel,170,020, ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cPathPnl3,,,, )

oTGet1:SetCSS( POSCSS (GetClassName(oTGet1), CSS_GET_NORMAL ))

oSay2:= TSay():New(45,10,{|| STR0022 },oPanel,,,,,,.T.,,,450,070) //"Confirma a geração dos arquivos de configuração inicial ? (Initial Setup)"
oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_NORMAL )) 

Return Nil

//-------------------------------------------------------------------	
/*/{Protheus.doc} valida_SI3
Cria Validacao do wizard de Configurações para mobile pg3

@author  Varejo
@version P11.8
@since   27/05/2015
@return  lRet - Retorno da validacao
/*/
//-------------------------------------------------------------------	
Static Function valida_SI3()

Local lRet := .T.		//Retorno da validacao

IIf(lRet					, lRet := !Empty(cPathPnl3) 	 		,)

If !lRet
	MsgWzValid()//Mensagem validacao
Else	
	Processa({|lEnd| GeraSetup(lEnd)},STR0023) //"Gerando arquivos de configuração inicial..."
EndIf	

Return lRet

//-------------------------------------------------------------------	
/*/{Protheus.doc} MsgWzValid
Mensagem validacao padrao wizard

@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function MsgWzValid(cMsg)
Default cMsg := ""
Alert(STR0088 + CHR(13) + CHR(10) + cMsg)//"Campos obrigatórios não informados!"
Return Nil

//-------------------------------------------------------------------	
/*/{Protheus.doc} GeraSetup
Gera os arquivos CSV de integracao

@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function GeraSetup(lEnd)
Local cPathCSV		:= ''    // Pasta para geracao dos arquivos de carga inicial
Local cPathBase		:= alltrim(cPathPnl3)
Local aValores		:= {}
Local aCols			:= oGetDados:aCols
Local lRet			:= .T.
Local lExistFile	:= .F.
Local aFilesProc	:= {}
Local nCont			:= 0
ProcRegua(Len(aCols))

// Geracao dos Arquivos CSV da Carga Inicial
If !ExistDir(cPathBase)
	MakeDir(cPathBase)
Endif

cPathCSV := cPathBase+"initial_files\"

If !ExistDir(cPathCSV)
	MakeDir(cPathCSV)
Endif

//Company Name
If !File(cPathCSV+"company.csv")
	aValores := LjRCompany()
	lRet := LJGerCSV("company.csv", "CompanyName,DefaultCurrencyCode", aValores,cPathCSV)
Else
	lExistFile := .T.
EndIf

//Organization Structure
If lRet .And. !File(cPathCSV+"organization_structure.csv")
	aValores := LjROrganiz()
	lRet := LJGerCSV("organization_structure.csv", "EntityNumber,EntityName,ParentNumber,Level,UniqueID,EntityCurrencyCode", aValores,cPathCSV)
Else
	lExistFile := .T.
EndIf

//Corporate Users - Admin
If lRet .And. !File(cPathCSV+"users.csv")
	aValores := LjRAdmin()
	lRet := LJGerCSV("users.csv", "FirstName,LastName,Email,AppUser,AppAdmin,EntityName", aValores,cPathCSV)
Else
	lExistFile := .T.
EndIf

If lExistFile 
	MsgInfo(STR0024,STR0025) //"Arquivos já existentes no diretório!!!"#"Wizard Carga Inicial"
	Return
EndIf
If lRet
	If MsgYesNo(STR0026) //"Arquivos gerados com sucesso no servidor, deseja salvar os arquivos localmente?"
		//Caso o arquivo foi gravado na estrutura do Protheus, é necessário abrir janela para o usuário salvar o arquivo
		aFilesProc  := Directory(cPathCSV+"\*.csv") //pego os arquivos a serem copiados
		cDirDes := cGetFile("TOTVS","Selecione o diretório para salvar os arquivos" ,,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY)
		IF !Empty(cDirDes)
			For nCont := 1 To Len(aFilesProc)
			    CpyS2T( cPathCSV+aFilesProc[nCont,1] , cDirDes , .F. )
			Next nCont
		EndIf    
	EndIf
	
	LjAvisoGen(6, STR0099) //"RetailApp - Wizard Setup Inicial"#"Por favor, compactar os arquivos gerados e enviar para a Retailapp."
	    
EndIf

Return NIL

//-----------------------------------------------------------
/*/{Protheus.doc} LjRCompany
Retorna as filiais e a moeda utilizada
@author Leandro Lima
@since 11/05/2017
@return array com 2 posições: 1 - Nome da Empresa, 2 - Moeda (BRL)
/*/
//-----------------------------------------------------------
Static Function LjRCompany()
Local aCompany	:= {}

   aAdd(aCompany,'"'+AllTrim(cEmpPnl1)+'"'+",BRL")

Return(aCompany)

//-----------------------------------------------------------
/*/{Protheus.doc} LjROrganiz
Retorna as lojas ( SM0 e SLJ	)
@author Leandro Lima
@since 11/05/2017
@return array com as lojas
/*/
//-----------------------------------------------------------
Static Function LjROrganiz()
Local aOrganiz	:= {}
Local aStruct	:= {'global', 'region', 'district', 'store'}
Local nI		:= 0
Local aHeader	:= oGetDados:aHeader
Local aCols 	:= oGetDados:aCols

For nI := 1 to Len(aCols)
    IncProc()
	If !aCols[nI,Len(aHeader)+1]
	
		aAdd(aOrganiz,	Alltrim(str(aCols[nI, 1]))		+","+;	// EntityNumber
						Alltrim(aCols[nI, 3]) 		+","+;	// EntityName
						If(aCols[nI, 4]<>0, Alltrim(Str(aCols[nI, 4])), '')		+","+;	// ParentNumber
						aStruct[Val(aCols[nI, 2])]	+","+;	// Level
						'"'+Alltrim(aCols[nI, 5])	+'"')	// UniqueID
	EndIf

Next

Return(aOrganiz)

//-----------------------------------------------------------
/*/{Protheus.doc} LjRAdmin
Gera apenas o usuário ADMIN no RetailApp - Apenas para a Carga Inicial
@author Mauricio Canalle
@since 15/05/2017
@return array com o uruario ADMIN
/*/
//-----------------------------------------------------------
Static Function LjRAdmin()
Local aUsers 	:= {}

aAdd(aUsers,Alltrim(cNomePnl2)		+","+; // Nome
			Alltrim(cSobrePnl2)				+","+; // Sobrenome
			Alltrim(cEmailPnl2)				+","+; // email
			"Y"						+","+; // Usa o app
			'Y'						+","+; // Adm do app é o ADM Protheus 
			'"'+AllTrim(cEmpPnl1)+'"') // Nome da Entidade TO DO trocar pelo SLJ

Return(aUsers)

//-----------------------------------------------------------
/*/{Protheus.doc}LJGerCSV
Gera o arquivo CSV na pasta informada
@author Mauricio Canalle
@since 15/05/2017
@return array com o usuario ADMIN
/*/
//------------------------------------------------------------
Function LJGerCSV(cNomeArquivo, cColunas, aValores, cDirCsv)
local nFileCsv		:= 0
local nI			:= 0
Local lRet			:= .T.
Default cDirCsv		:= "\retailapp\"

If Empty(cDirCsv) .And. !isBlind()
	cDirCsv := cGetFile("TOTVS","Selecione o diretorio",,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY)
EndIf
nFileCsv := FCreate(cDirCsv+cNomeArquivo,0,,.F.)
If nFileCsv > 0
	If len(cColunas) > 0
    	FWrite(nFileCSV,cColunas+CRLF)
    EndIf
    
    For nI := 1 TO Len(aValores)
        FWrite(nFileCSV,aValores[nI]+CRLF)
    Next nI
    FClose(nFileCSV)
Else
    lRet := .F.
EndIf
Return lRet

//-----------------------------------------------------------
/*/{Protheus.doc} LJRetailDF
Wizard de geração dos arquivos de movimento DATA FILES
@author Mauricio Canalle
@since 22/06/2017
@return NIL
/*/
//-----------------------------------------------------------
Function LJRetailDF()

oStepWiz 	:= Nil	//Objeto tipo Wizard
oNewPag		:= Nil	//Objeto que adiciona nova pagina no wizard
aFilsPnl1	:= {}   // Filiais para exportacao
cUrlConPnl2	:= ''   // Url de Conexao
cUrlPostPnl2	:= ''   // Url de Transmissao
cTimeAuto	:= ""	// Tempo do job
cParAPP0	:= SuperGetMv("MV_LJRAPP0", Nil, .F.) //utilizado default logico para validar se o param existe na rotina ValidSX6 
cParAPP1	:= SuperGetMv("MV_LJRAPP1", Nil, .F.) //utilizado default logico para validar se o param existe na rotina ValidSX6
lCheckAut	:= .F.

If !ValidSX6() // Verifica se os parametros foram criados
	Return(Nil)
EndIf

If !FindFunction('__FWWIZCTLR')   // valida se a classe FWWizardControl existe no RPO e os parametros MV_LJRAPP0 e MV_LJRAPP1
	Alert(STR0027) //'Classe FWWizardControl não disponível. É necessário a atualização do pacote LIB disponivel no portal do cliente.'
	Return(Nil)
EndIf

// Carrega as filiais do arquivo CSV de organizacao para carregar no listbox
aFilsCSV := LerCSVOrg()

//Validação para carregar o wizard somente quando o arquivo de Filiais existir
If Len(aFilsCSV) == 0
	LjAvisoGen(1)
	Return
EndIf

//Instancia a classe FWWizard
oStepWiz:= FWWizardControl():New(,)// Define o tamanho do wizard  ex: {600,800}
oStepWiz:ActiveUISteps()

// 01 ------------------------------ "Empresa/Filiais"
oNewPag := oStepWiz:AddStep("1")//Adiciona a primeira tela do wizard
oNewPag:SetStepDescription(STR0001) //Altera a descrição do step  //'Empresa/Filiais'
oNewPag:SetConstruction({|Panel|cria_DF1(Panel)}) //Define o bloco de construção
oNewPag:SetNextAction({||  valida_DF1() })//Define o bloco ao clicar no botão Próximo
oNewPag:SetCancelAction({|| .T. })//Valida acao cancelar

// 02 ------------------------------ "Urls"
oNewPag := oStepWiz:AddStep("2", {|Panel|cria_DF2(Panel)})
oNewPag:SetStepDescription(STR0028) //'Urls RetailApp'
oNewPag:SetNextAction({||valida_DF2()})
oNewPag:SetCancelAction({|| .T.})
//oNewPag:SetCancelWhen({||.F.})

// 03 ------------------------------ "Usuario de Conexao"
oNewPag := oStepWiz:AddStep("3", {|Panel|cria_DF3(Panel)})
oNewPag:SetStepDescription(STR0029) //'Usuário de Conexão'
oNewPag:SetNextAction({|| valida_DF3(.F.) })
oNewPag:SetCancelAction({|| .T.})
//oNewPag:SetCancelWhen({||.F.})

// 04 ------------------------------ "Rotina Automáticaa"
oNewPag := oStepWiz:AddStep("4", {|Panel|cria_DF4(Panel)})
oNewPag:SetStepDescription(STR0030) //'Rotina Automática'
oNewPag:SetNextAction({|| valida_DF4() })
oNewPag:SetPrevAction({|| valida_DF3(.T.) })
oNewPag:SetCancelAction({|| .T.})
//oNewPag:SetCancelWhen({||.F.})

// 05 ------------------------------ "Periodo de Carga"
oNewPag := oStepWiz:AddStep("5", {|Panel|cria_DF5(Panel)})
oNewPag:SetStepDescription(STR0031) //'Período de Carga'
oNewPag:SetNextAction({|| valida_DF5() })
oNewPag:SetCancelAction({|| .T.})
//oNewPag:SetCancelWhen({||.F.})

oStepWiz:Activate()//Ativa Wizard
oStepWiz:Destroy()//Desativa Wizard

Return NIL

//-------------------------------------------------------------------	
/*/{Protheus.doc} cria_DF1
Cria wizard de Configurações para mobile pg1

@param  oPanel - Panel de Fundo
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function cria_DF1(oPanel)
Local cVarQ		:= ""
Local nRegSM0	:= 0
Local nCont		:= 0
Local aFilsCSV	:= {}
Local oSay1		
Local oSay2		
Local oTGet1	
Local oBtn1		
Local oList1
Local oOk		:= LoadBitmap( GetResources(), "LBOK")
Local oNo		:= LoadBitmap( GetResources(), "LBNO")
Local oCheck	:= nil
Local lCheck	:= .T.
Default oPanel	:= Nil // Panel 

cEmpPnl1  := SM0->M0_NOME
aFilsPnl1 := {}

// Carrega as filiais do arquivo CSV de organizacao para carregar no listbox
//aFilsCSV := LerCSVOrg()
aFilsPnl1 := LerCSVOrg()				

//---------- Seleciona Filiais
oSay2:= TSay():New(05,10,{|| STR0032 },oPanel,,,,,,.T.,,,250,070) //'Selecione as Filiais que enviarão dados para o RetailApp'
oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_NORMAL )) 

@ 15,10 LISTBOX oList1 VAR cVarQ Fields HEADER "", OemToAnsi(STR0037), OemToAnsi(STR0033),OemToAnsi(STR0034),  OemToAnsi(STR0035), OemToAnsi(STR0036) ON DBLCLICK (aFilsPnl1:=MtFClTroca(oList1:nAt, aFilsPnl1, .F., @oList1, .T. ),oList1:Refresh()) SIZE 280,150 OF oPanel PIXEL //"Empresa"#"Filial"#"Nome"#"UF"#"Cidade"
oList1:SetArray(aFilsPnl1)
oList1:bLine := { || {If(aFilsPnl1[oList1:nAt,1],oOk,oNo),aFilsPnl1[oList1:nAt,2],aFilsPnl1[oList1:nAt,3],aFilsPnl1[oList1:nAt,4],aFilsPnl1[oList1:nAt,5],aFilsPnl1[oList1:nAt,6]}}

oCheck := TCHECKBOX():NEW(175,10,STR0038,{ | U | IF( PCOUNT() == 0, lCheck, lCheck := U ) },oPanel,60,7,,{|| (AEVAL(aFilsPnl1,{|X|X[1]:=lCheck}),oList1:REFRESH())},,,,, .F. , .T. ,, .F. ,) //"Marca/Desmarca"

Return Nil

//-------------------------------------------------------------------	
/*/{Protheus.doc} valida_DF1
Cria Validacao do wizard de Configurações para mobile pg1

@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function valida_DF1()
Local lRet 	:= .F.		//Retorno da validacao
Local nI    := 0

For nI := 1 to Len(aFilsPnl1)  // Valida se ao menos uma filial esta marcada
    If aFilsPnl1[nI, 1]
	   lRet := .T.
	Endif
Next

If !lRet
	MsgWzValid() //Mensagem validacao
EndIf	

Return lRet

//-------------------------------------------------------------------	
/*/{Protheus.doc} MtFClTroca
Marca ou desmarca todas as linhas
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function MtFClTroca(nIt, aArray, lAll, oList1, lDblCli)
Local nI := 0

If !lDblCli
	//Marca linhas
	For nI := 1 To Len(aArray)
		If aArray[nI,1] != lAll
			aArray[nI,1] := lAll
		EndIf
	Next
Else
	aArray[nIt,1] := !aArray[nIt,1]
Endif	
Return aArray

//-------------------------------------------------------------------	
/*/{Protheus.doc} cria_DF2
Cria wizard de Configurações para mobile pg1

@param  oPanel - Panel de Fundo
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function cria_DF2(oPanel)
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oTGet1
Local oTGet2
Local oTGet3
Local aVetTrab := {}

aVetTrab := StrToKArr(cParAPP0, '|')

If len(aVetTrab) == 2
	cUrlConPnl2  := aVetTrab[1]
	cUrlPostPnl2 := aVetTrab[2]
	
Else
	cUrlConPnl2  := space(100)
	cUrlPostPnl2 := space(100)
	
Endif

oSay1:= TSay():New(05,10,{|| STR0039 },oPanel,,,,,,.T.,,,450,070) //'Informe a URL de Login (api/login)' 
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_LABEL_NORMAL )) 

oTGet1 := TGet():New(20,10,{|u| if( PCount() > 0, cUrlConPnl2 := u, cUrlConPnl2 ) } ,oPanel,250,020, ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cUrlConPnl2,,,, )
oTGet1:SetCSS( POSCSS (GetClassName(oTGet1), CSS_GET_NORMAL ))

oSay2:= TSay():New(50, 10,{|| STR0040 },oPanel,,,,,,.T.,,,450,070) //'Informe a URL de Transmissão de Dados (api/data)'
oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_NORMAL )) 

oTGet2 := TGet():New(65,10,{|u| if( PCount() > 0, cUrlPostPnl2 := u, cUrlPostPnl2 ) } ,oPanel,250,020, ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cUrlPostPnl2,,,, )
oTGet2:SetCSS( POSCSS (GetClassName(oTGet2), CSS_GET_NORMAL ))

oSay4:= TSay():New(145,10,{|| STR0042 },oPanel,,,,,,.T.,,,450,070) //'URLs informadas pelo RetailApp. Só devem ser alteradas caso a RetailApp informe novas URLs.'
oSay4:SetCSS( POSCSS (GetClassName(oSay4), CSS_LABEL_NORMAL )) 

Return Nil

//-------------------------------------------------------------------	
/*/{Protheus.doc} valida_DF2
Cria Validacao do wizard de Configurações para mobile pg1

@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function valida_DF2()
Local lRet := .T.		//Retorno da validacao
Local cMsg	:= ""
If Empty(cUrlConPnl2)
	lRet := .F.
	cMsg	:= STR0043 //"Favor preencher o campo URL de Login (api/login)"
EndIf
If lRet .AND. Empty(cUrlPostPnl2)
	lRet := .F.
	cMsg	:= STR0044 //"Favor preencher o campo URL de Transmissão de Dados (api/data)"
EndIf

If !lRet
	MsgWzValid(cMsg)//Mensagem validacao
EndIf	

Return lRet

//-------------------------------------------------------------------	
/*/{Protheus.doc} cria_DF3
Cria wizard de Configurações para mobile pg1

@param  oPanel - Panel de Fundo
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Static Function cria_DF3(oPanel)
Local oSay1
Local oSay2
Local oSay3
Local oTGet1
Local oTGet2
Local oTGet3
Local aVetTrab := {}
Local oBtn1

aVetTrab := StrToKArr(cParAPP1, '|')

If Len(aVetTrab) >= 4
	cEmailPnl3	:= PadR(aVetTrab[1],50)
	cPassPnl3	:= PadR(aVetTrab[2],15)
	cDiasProc	:= PadR(aVetTrab[3],03)
	cTESValid	:= PadR(aVetTrab[4],180)
EndIf

oSay1:= TSay():New(05,10,{|| STR0046 },oPanel,,,,,,.T.,,,450,070) //'Informe o usuário/email de conexão do RetailApp'
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_LABEL_NORMAL )) 

oTGet1 := TGet():New(20,10,{|u| if( PCount() > 0, cEmailPnl3 := u, cEmailPnl3 ) } ,oPanel,250,020, ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cEmailPnl3,,,, )
oTGet1:SetCSS( POSCSS (GetClassName(oTGet1), CSS_GET_NORMAL ))

oSay2 := TSay():New(50, 10,{|| STR0047 },oPanel,,,,,,.T.,,,450,070) //'Informe a senha para conexão do RetailApp'
oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_NORMAL )) 

oTGet2 := TGet():New(65,10,{|u| if( PCount() > 0, cPassPnl3 := u, cPassPnl3 ) } ,oPanel,170,020, ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cPassPnl3,,,, )
oTGet2:SetCSS( POSCSS (GetClassName(oTGet2), CSS_GET_NORMAL ))
oTGet2:lPassword := .T.

oSay3 := TSay():New(95, 10,{|| STR0048 },oPanel,,,,,,.T.,,,450,070) //'Informe aqui os tipos(TES) que deverão ser considerados como vendas separadas por virgula'
oSay3:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_NORMAL )) 

oTGet3 := TGet():New(110,10,{|u| if( PCount() > 0, cTESValid := u, cTESValid ) } ,oPanel,250,020, ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTESValid,,,, )
oTGet3:SetCSS( POSCSS (GetClassName(oTGet2), CSS_GET_NORMAL ))

Return Nil

//-------------------------------------------------------------------	
/*/{Protheus.doc} valida_DF3
Cria Validacao do wizard de Configurações para mobile pg1
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function valida_DF3(lPrev)
Local lRet 		:= .T.		//Retorno da validacao
Local cSubStr	:= ""
Local cStrValid := "0123456789,"
Local nX		:= 0
Local nY		:= 0
Local aCodTes	:= {}
Local aAux		:= {}
Local nCont		:= 0
Local nFil		:= 0
Local cMsg		:= "" 
Local cModoSf4	:= ""
Local cTesNoFound:= ""
Local cBkpcTESValid := AllTrim(cTESValid) 

cModoSf4 := FWModeAccess("SF4",3)

If !lPrev
	If Empty(cEmailPnl3) 
		lRet := .F.
		cMsg	:= STR0049 //"Favor preencher o campo usuário/email de conexão"
	ElseIf	(!Empty(cEmailPnl3) .And. !JurIsEMail(cEmailPnl3))
		lRet := .F.
		cMsg	:= STR0050 //"Favor preencher o campo senha para a conexão"
	EndIf
	If lRet .AND. Empty(cPassPnl3)
		lRet := .F.
		cMsg	:= STR0051 //"Favor preencher o campo senha para a conexão"
	EndIf
	If lRet .AND. Empty(cTESValid)
		lRet := .F.
		cMsg	:= STR0052 //"Favor preencher o campo TES"
	EndIf
	
	If lRet //.AND. !Empty(cTESValid)  //Somente permite caracteres validos
		cTESValid := AllTrim(cTESValid)
		For nX := 1 To Len(cTESValid)
			cSubStr := SubStr(cTESValid,nX,1)
			If "U" == UPPER(cSubStr) //Verifica se é uma função de usuario e macro executa para buscas as TES que vai retornar.
				If ExistFunc(cTESValid)
					cTESValid := &(cTESValid) //mater a mesma varivel para validação das TES nos blocos abaixo.
					LjGrvLog("valida_DF3","Retorno da User Function lista de TES - ",{cTESValid})
				else
					LjGrvLog("valida_DF3","Função de usuario nao existe no repositorio - ",{cTESValid})
					lRet := .F.
					cMsg := STR0102	// Função de usuario para retono das TES não encontrado.
				EndIf	
				
				Exit
			EndIf
			nY := At(cSubStr,cStrValid)
			If nY = 0 
				lRet := .F.
			EndIf
		Next nX
		
	EndIf 
	
	If !lRet
		MsgWzValid(cMsg)//Mensagem validacao
	Else
		//Validar os códigos digitados se existem e se são de saída
		aAux := Separa(cTESValid,',',.F.)
		
		For nCont := 1 To Len(aAux)
			aAdd(aCodTes,{aAux[nCont],"N"})
		Next nCont
		
		SF4->(DbSetOrder(1))
		If cModoSF4 == "C" 
			For nCont := 1 To Len(aCodTes)
				If !(SF4->(DbSeek(xFilial("SF4")+aCodTes[nCont][1])) .And. SF4->F4_TIPO == "S") 
					LjAvisoGen(3, aCodTes[nCont][1])
					lRet := .F.
				EndIf		
			Next nCont
		Else
			For nFil := 1 To Len(aFilsPnl1)
				For nCont := 1 To Len(aCodTes)
					If (SF4->(DbSeek(PadR(aFilsPnl1[nFil,3],TamSX3("F4_FILIAL")[1]," ")+aCodTes[nCont,1])) .And. SF4->F4_TIPO == "S") .And. aCodTes[nCont,2] == "N"
						aCodTes[nCont,2] := "S"	
					EndIf		
				Next nCont
			Next nFil
			
			For nCont := 1 To Len(aCodTes) 
				If aCodTes[nCont,2] == "N"
					cTesNoFound +=  ", " + aCodTes[nCont,1]
				EndIf
			Next nCont
			
			If !Empty(cTesNoFound)
				//retiro "," da primeira posição
				If AT(",",cTesNoFound) == 1
					cTesNoFound := SubStr(cTesNoFound,2,Len(cTesNoFound))	
				EndIf
				lRet := .F.
				LjAvisoGen(3, cTesNoFound)
			EndIf
		EndIf
	EndIf
Else
	cEmailPnl3 := PadR(cEmailPnl3,50)
	cPassPnl3  := PadR(cPassPnl3,15)
	cTESValid  := PadR(cTESValid,180)
EndIf

If Upper(SubStr(cBkpcTESValid,1,1) ) == 'U' // Para nao alterar os processos do legado volta cTESValid para o conteudo original
	LjGrvLog("valida_DF3","Voltando Bkp da variavel cTESValid - ",{cTESValid,cBkpcTESValid})
	cTESValid := cBkpcTESValid
EndIf

Return lRet

//-------------------------------------------------------------------	
/*/{Protheus.doc} cria_DF4
Cria wizard de Configurações para mobile pg1
@param  oPanel - Panel de Fundo
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
@obs     
@sample
/*/
//-------------------------------------------------------------------	
Static Function cria_DF4(oPanel)
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oTGet1
Local oCheck
Local aVetTrab	:= {}

aVetTrab := StrToKArr(cParAPP1, '|')

If Len(aVetTrab) == 5
	cTimeAuto	:= PadR(aVetTrab[5],3)
Else
	cTimeAuto 	:= Space(3)
Endif

oSay1:= TSay():New(05,10,{|| STR0053 },oPanel,,,,,,.T.,,,450,070) //'Essa opção permite configurar a rotina para envio automático das movimentações (Vendas).' 
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_LABEL_NORMAL )) 

oSay2:= TSay():New(15,10,{|| STR0054 },oPanel,,,,,,.T.,,,450,070) //'(Configurações de Job são gravadas no arquivo appserver.ini)' 
oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_NORMAL )) 

oCheck := TCHECKBOX():NEW(30,10, STR0055 ,{ | U | IF( PCOUNT() == 0, lCheckAut, lCheckAut := U ) },oPanel,200,7,,{|| LjConfAuto(lCheckAut, oTGet1),oTGet1:REFRESH()},,,,, .F. , .T. ,, .F. ,) //"Deseja inserir as configurações automáticas no appserver.ini?"

oSay3 := TSay():New(45, 10,{|| STR0056 },oPanel,,,,,,.T.,,,450,070) //'Informe aqui os minutos para a atualização automática:'
oSay3:SetCSS( POSCSS (GetClassName(oSay3), CSS_LABEL_NORMAL )) 

oTGet1 := TGet():New(55,10,{|u| if( PCount() > 0, cTimeAuto := u, cTimeAuto ) } ,oPanel,050,020,,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTimeAuto,,,, )
oTGet1:SetCSS( POSCSS (GetClassName(oTGet1), CSS_GET_NORMAL ))

oSay4 := TSay():New(100, 10,{|| STR0057 },oPanel,,,,,,.T.,,,450,070) //'Recomendado a criação de um serviço a parte (appserver.ini) para a configuração e execução'
oSay4:SetCSS( POSCSS (GetClassName(oSay3), CSS_LABEL_NORMAL )) 

oSay5 := TSay():New(110, 10,{|| STR0058},oPanel,,,,,,.T.,,,450,070) //'automática (JOB) do Retailapp.' 
oSay5:SetCSS( POSCSS (GetClassName(oSay3), CSS_LABEL_NORMAL )) 

Return Nil

//-------------------------------------------------------------------	
/*/{Protheus.doc} valida_DF4
Cria Validacao do wizard de Configurações para mobile pg1
@author  Varejo
@version P11.8
@since   11/07/2017
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function valida_DF4()
Local lRet 		:= .T.		
Local cMsg		:= "" 
Local cFuncJob	:= ""
Local aJobs		:= {}
Local lJobs		:= .F.
Local nCont		:= 0
If lCheckAut .And. Empty(cTimeAuto) 
	lRet := .F.
	cMsg	:= STR0059 //"Favor preencher o campo Minutos para atualização automática."
	MsgWzValid(cMsg)//Mensagem validacao
Else
	If lCheckAut .AND. MsgYesNo(STR0060) //"Deseja adicionar as configurações da rotina automática no appserver.ini?"
		cFuncJob	:= GetPvProfString("ONSTART","Jobs","",GetAdv97())
		aJobs := Iif(!Empty(AllTrim(cFuncJob)),StrToKArr(AllTrim(cFuncJob), ','),{})
		For nCont := 1 To Len(aJobs)
			If !("RETAILAPP" $ aJobs[nCont])
				lJobs := .T.
				Exit
				
			EndIf	
		Next nCont
					
		If lJobs
			LjAvisoGen(4,STR0061 + CRLF + STR0075) //"Jobs já configurado no appserver.ini. É possível configurar os jobs em servidores diferentes. Para prosseguir desmarque a opção de configuração automática." ##"#"Mais detalhes em : http://tdn.totvs.com.br/pages/viewpage.action?pageId=281982366"
			lRet := .F.	
		Else
			If Val(cTimeAuto) >= 60
				LjAjustIni()
			Else
				lRet := .F.
				LjAvisoGen(5,STR0062) //"A rotina automática deve ser configurada com no minímo de 15 minutos, por favor ajustar o campo Minutos."
			EndIf
		EndIf
	EndIf
EndIf
		
Return lRet

//-------------------------------------------------------------------	
/*/{Protheus.doc} cria_DF5
Cria wizard de Configurações para mobile pg1
@param  oPanel - Panel de Fundo
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function cria_DF5(oPanel)
Local oSay
Local oSay1
Local oSay2
Local oSay3
Local oSay4
Local oSay5
Local oTGet1
Local oBtn1
Local oBtn2

cDiasMov := "001"

oSay1:= TSay():New(05,10,{|| STR0063 },oPanel,,,,,,.T.,,,450,070) //'Carga Inicial: Envio do movimento dos últimos 12 meses em relação a data atual.'
oSay1:SetCSS( POSCSS (GetClassName(oSay1), CSS_LABEL_NORMAL )) 

oSay2:= TSay():New(15,10,{|| STR0064},oPanel,,,,,,.T.,,,450,070) //'Recomendamos, devido ao volume de dados, que a opção seja utilizada apenas como Carga Inicial'
oSay2:SetCSS( POSCSS (GetClassName(oSay2), CSS_LABEL_NORMAL )) 

oBtn1	:= TButton():New(	30,10,STR0065,oPanel,{|| FWMsgRun(,{|oSay| LjGeraMov(oSay,'I')},STR0066,STR0067) },80,ALTURABTN,,,,.T.,,,,) //"Executa Carga Inicial"#"Executando"#"Aguarde..."
oBtn1:SetCSS( POSCSS (GetClassName(oBtn1), CSS_BTN_BARCODE ))

oSay3:= TSay():New(65,10,{|| STR0068 + CRLF + STR0089 },oPanel,,,,,,.T.,,,450,070) //'Movimento: Envio do movimento conforme os dias definidos no parâmetro abaixo.' ##"Utilizado para Executar o Movimento (Job utiliza  o parâmetro:MV_LJRAPP1)"
oSay3:SetCSS( POSCSS (GetClassName(oSay3), CSS_LABEL_NORMAL )) 

oSay5:= TSay():New(95, 10,{|| STR0070 },oPanel,,,,,,.T.,,,070,070) //'Dias para Processamento'
oSay5:SetCSS( POSCSS (GetClassName(oSay5), CSS_LABEL_NORMAL )) 

oTGet1 := TGet():New(95,70,{|u| if( PCount() > 0, cDiasMov := u, cDiasMov ) } ,oPanel,070,020, '999',,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cDiasMov,,,, )
oTGet1:SetCSS( POSCSS (GetClassName(oTGet1), CSS_GET_NORMAL ))

oBtn2	:= TButton():New(	130,10,STR0071,oPanel,{|| FWMsgRun(,{|oSay| LjGeraMov(oSay,'M')},STR0066,STR0067) },80,ALTURABTN,,,,.T.,,,,) //"Executa Movimento"
oBtn2:SetCSS( POSCSS (GetClassName(oBtn2), CSS_BTN_BARCODE ))

Return Nil

//-------------------------------------------------------------------	
/*/{Protheus.doc} LjGeraMov
Botao que executa a movimentacao das vendas
@param  oPanel - Panel de Fundo
@author  Varejo
@version P11.8
@since   27/05/2017
@return  Nil
/*/
//-------------------------------------------------------------------
Static Function LjGeraMov(oSay,cTipo)

Local lRet		 := .T.

If cTipo == "M" 	
	If Empty(cDiasMov) 
		lRet := .F.
		cMsg	:= STR0072 //"Favor preencher o campo Dias para processamento"
		MsgWzValid(cMsg)//Mensagem validacao
	Else
		lRet := MsgYesNo( STR0090 + cDiasMov + STR0091 + CRLF +;				//"Será realizado o processamento do movimento de: "  ##" dia(s)?"
			 			  STR0092 + CRLF + ;  									//"(As alterações realizadas no Wizard serão efetivadas)" 
 			  			  STR0093)												//"Deseja continuar?"
	EndIf	
EndIf

If lRet .AND. cTipo == "I" 
 	lRet := MsgYesNo(STR0094 + cValToChar(dDataBase - 365) + STR0095 + CRLF + ;		//"A carga inicial irá processar o movimento de vendas a partir da data: "	##" e poderá demorar alguns minutos para processamento."
 					  STR0092 + CRLF + ;											//"(As alterações realizadas no Wizard serão efetivadas)"
 			  		  STR0093)														//"Deseja continuar?"							
EndIf


If lRet
	lRet := FimWizard() //Efetiva a gravação do Wizard
	LJRetailApp(cEmpAnt, cFilAnt, .F., cTipo, aFilsPnl1, oSay,cDiasMov) // chama o LjRetailapp para fazer a trasmissao dos dados
EndIf

Return lRet

//-------------------------------------------------------------------	
/*/{Protheus.doc} FimWizard
Finaliza wizard de Configurações.
Atualiza os parametros MV_LJRAPP0 e MV_LJRAPP1
@author  Varejo
@version P11.8
@since   27/05/2015
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function FimWizard()
Local lRet	:= .F.
PutMV("MV_LJRAPP0", Alltrim(cUrlConPnl2)+'|'+Alltrim(cUrlPostPnl2)) // Urls
If Len(Alltrim(cEmailPnl3)+'|'+Alltrim(cPassPnl3)+'|'+Alltrim(cDiasProc)+'|'+Alltrim(cTESValid)+'|'+Alltrim(cTimeAuto)) > 251
	lRet := MsgYesNo(STR0100 + CRLF + ;		//"O tamanho das informações (E-mail, senha, dias de processamento, TES e os minutos de Job Automático"
 					  STR0101 + CRLF + ;		//"são maior que o tamanho do conteúdo do parâmetro (MV_LJRAPP1), poderá ocorrer perda de informações."
 			  		  STR0093)														//"Deseja continuar?"	
	If lRet
		PutMV("MV_LJRAPP1", Alltrim(cEmailPnl3)+'|'+Alltrim(cPassPnl3)+'|'+Alltrim(cDiasProc)+'|'+Alltrim(cTESValid)+'|'+Alltrim(cTimeAuto))  // dados de conexao e execucao
	EndIf
Else
	lRet := .T.
	PutMV("MV_LJRAPP1", Alltrim(cEmailPnl3)+'|'+Alltrim(cPassPnl3)+'|'+Alltrim(cDiasProc)+'|'+Alltrim(cTESValid)+'|'+Alltrim(cTimeAuto))  // dados de conexao e execucao
EndIf
Return lRet

//-------------------------------------------------------------------	
/*/{Protheus.doc} ValidSX6
Valida a existencia dos parametros MV_LJRAPP0 e MV_LJRAPP1
@author  Varejo
@version P11.8
@since   30/06/2017
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function ValidSX6()
Local lRet := .T.

If ValType(cParAPP0) <> 'C'
  Alert(STR0074+CHR(13)+CHR(10)+STR0075) //"Parâmetro MV_LJRAPP0 não criado,será necessário a sua criação do tipo caracter e conteúdo em branco para a continuação da rotina."#"Mais detalhes em : http://tdn.totvs.com.br/pages/viewpage.action?pageId=281982366"
  lRet := .F.
Endif
// Caso o parametro esteja vazio preenche com conteudo DEFAULT
If lRet .AND. Empty(cParAPP0)
   	// Se tiver criado em branco, preenche com o valor default
   	cParAPP0 := "https://woolton-backend.azurewebsites.net/api/login|https://woolton-backend.azurewebsites.net/api/data|https://woolton-backend.azurewebsites.net/api/calculate"
Endif

If ValType(cParAPP1) <> 'C'
  Alert(STR0076+CHR(13)+CHR(10)+STR0077)	//"O parâmetro MV_LJRAPP1  não criado,será necessário a sua criação do tipo caracter e conteudo em branco para a continuação da rotina."#"Mais detalhes em : http://tdn.totvs.com.br/pages/viewpage.action?pageId=281982366"
  lRet := .F.	
Endif

Return lRet

//-------------------------------------------------------------------	
/*/{Protheus.doc} LerCSVOrg
@author  Varejo
@version P11.8
@since   30/06/2017
@return  Nil
/*/
//-------------------------------------------------------------------	
Function LerCSVOrg()
Local aRet		:= {}
Local cPathBase	:= '\retailapp\'
Local nHandle	:= 0
Local cLine		:= ''
Local aLine		:= {}
Local aFilRet	:= {}
Local nCont		:= 0		

cPathCSV := cPathBase+"initial_files\"
nHandle := FT_FUse(cPathCSV+"organization_structure.csv")

If nHandle <> -1	
	While !FT_FEOF()   
		cLine  := FT_FReadLn() 
		aLine := StrToKArr(cLine, ',')
		If Len(aLine) == 5
		   If !Empty(StrTran(aLine[5], '"', ''))
		   		Aadd(aRet, StrTran(aLine[5], '"', ''))
		   Endif
		Endif
		FT_FSKIP()
	End
EndIf

FT_FUSE()

DbSelectArea( "SM0" )
nRegSM0 := SM0->(Recno())
SM0->(DbGoTop())		
For nCont := 1 To Len(aRet)
	SM0->(DbSeek(aRet[nCont]))
	Aadd(aFilRet, {.T., SM0->M0_CODIGO, SM0->M0_CODFIL, SM0->M0_NOMECOM, SM0->M0_ESTCOB, SM0->M0_CIDCOB})
Next nCont
	
SM0->(DbGoto(nRegSM0))	

Return aFilRet

//-------------------------------------------------------------------	
/*/{Protheus.doc} LjAvisoGen
Tela de aviso genérico
@author  Fábio S. dos Santos
@version P11.8
@since   07/07/2017
@return  Nil
/*/
//-------------------------------------------------------------------	
Static function LjAvisoGen(nIdAviso, cAux)
If nIdAviso == 1
	FWAlertInfo( STR0078  + Chr(13)+Chr(10) + Chr(13)+Chr(10) + STR0079 + Chr(13)+Chr(10) + STR0080 + Chr(13)+Chr(10) + Chr(13)+Chr(10) + STR0081 + Chr(13)+Chr(10)+ Chr(13)+Chr(10) + STR0082) //"RetailApp - Wizard Carga de Dados"#"Não foi possível iniciar o wizard. O arquivo organization_structure.csv,"#"não foi encontrado no diretório: \Protheus_data\retailapp\inicial_files."#"Para acessar esse wizard, é necessário gerar os arquivos de configuração na rotina Setup Inicial!"#"Para maiores informações, acesse: http://tdn.totvs.com/x/nrXOE"
ElseIf nIdAviso == 2
	FWAlertInfo( STR0083  + Chr(13)+Chr(10) + Chr(13)+Chr(10) + STR0084 + Chr(13)+Chr(10) + STR0085) //"RetailApp - Wizard Setup Inicial"#"Não é possível informar filial nesse nível!"#"Apenas nível 4 deve ser informado a filial."
ElseIf nIdAviso == 3
	FWAlertInfo( STR0078  + Chr(13)+Chr(10) + Chr(13)+Chr(10) + STR0086 + cAux + Chr(13)+Chr(10) + STR0087) //"TES não encontrada ou não é de saída: "#"Por favor verificar no cadastro de TES - Tipo de Entrada/Saída."
ElseIf nIdAviso == 4
	FWAlertInfo( STR0078  + Chr(13)+Chr(10) + Chr(13)+Chr(10) + cAux)		
ElseIf nIdAviso == 5
	FWAlertInfo( STR0078  + Chr(13)+Chr(10) + Chr(13)+Chr(10) + cAux)
ElseIf nIdAviso == 6
	FWAlertInfo( STR0083  + Chr(13)+Chr(10) + Chr(13)+Chr(10) + cAux) //"RetailApp - Wizard Setup Inicial"#"Por favor, compactar os arquivos gerados e enviar para a Retailapp."
EndIf

Return

//-------------------------------------------------------------------	
/*/{Protheus.doc} ValidFil
Valida se a filial pode ser informada e se está válida
@author  Fábio S. dos Santos
@version P11.8
@since   10/07/2017
@return  Nil
/*/
//-------------------------------------------------------------------	
Function LjValidFil()
Local lRet		:= .T.
Local aHeader	:= oGetDados:aHeader
Local aCols    := oGetDados:aCols
Local nLinAtu	:= oGetDados:nAt
Local nPosNivel	:= Ascan(aHeader, {|x| AllTrim(x[2]) = "CNIVEL" })
Local nPosFil	:= Ascan(aHeader, {|x| AllTrim(x[2]) = "CFILPRO" })
If aCols[nLinAtu,nPosNivel] <> "4"
	aCols[nLinAtu,nPosFil] := ""
	oGetDados:ForceRefresh()
	LjAvisoGen(2)
	lRet := .F.
Else
	lRet := ExistCpo("SM0",M->CFILPRO)
EndIf
Return lRet

//-------------------------------------------------------------------	
/*/{Protheus.doc} LjConfAuto
Valida se marcou a opção de configuração automática
@author  Fábio S. dos Santos
@version P11.8
@since   12/07/2017
@return  Nil
/*/
//-------------------------------------------------------------------	
Function LjConfAuto(lCkeck, oTGet)

If lCkeck
	oTGet:lReadOnly := .F.
Else
	cTimeAuto	:= Space(3)
	oTGet:lReadOnly := .T.
EndIf 

Return

//-------------------------------------------------------------------	
/*/{Protheus.doc} LjAjustIni
Ajusta o appserver.ini para configurar o job de carga de dados
@author  Fábio S. dos Santos
@version P11.8
@since   12/07/2017
@return  Nil
/*/
//-------------------------------------------------------------------
Static Function LjAjustIni()
Local nRefrRate	:= 0 // Tempo de Refresh estabelecido
Local cFuncRet	:= ""
Local cJobs		:= ""
Local nSeconds	:= Val(cTimeAuto) * 60
cFuncRet	:= GetPvProfString("RETAILAPP","Main"	,""	,GetAdv97())
If Empty (cFuncRet)
	WritePProString("RETAILAPP","Main"			,"LJRetailApp"	,GetAdv97())
	WritePProString("RETAILAPP","Environment"	,GetEnvServer()	,GetAdv97())
	WritePProString("RETAILAPP","nParms"		,"2"			,GetAdv97())
	WritePProString("RETAILAPP","Parm1"			,cEmpAnt		,GetAdv97())
	WritePProString("RETAILAPP","Parm2"			,cFilAnt		,GetAdv97())
EndIf	

cJobs := GetPvProfString("ONSTART","Jobs","",GetAdv97())

If Empty(cJobs)
	WritePProString("ONSTART","Jobs","RETAILAPP",GetAdv97())
Else
	If !("RETAILAPP" $ cJobs)
		WritePProString("ONSTART","Jobs",cJobs+", RETAILAPP",GetAdv97())
	EndIf	
EndIf
// Tratamento para evitar problemas de performance,
// tinha casos que o RefeshRate estava muito pequeno (ex: 1 )   
nRefrRate := Val(GetPvProfString("ONSTART","RefreshRate","",GetAdv97()))

If nRefrRate >= 0 .AND. ( nRefrRate < 3600) 
	WritePProString("ONSTART","REFRESHRATE",AllTrim(Str(nSeconds)),GetAdv97())
EndIf

Return

//-------------------------------------------------------------------	
/*/{Protheus.doc} VldPreCfg
Verifica se ja ocorreu a configuracao e possui os arquivos 
@author  Paulo Henrique Santos de Moura
@version P12.1.17
@since   19/10/2017
@return  Nil
/*/
//-------------------------------------------------------------------
Static Function VldPreCfg

Local lRet		:= .T.
Local cPathCSV  := alltrim(cPathPnl3)+"initial_files\"

If	File(cPathCSV+"company.csv") .OR. ;	
	File(cPathCSV+"organization_structure.csv") .OR.;
	File(cPathCSV+"users.csv")
	
	MsgInfo(STR0096 + cPathCSV + CRLF +;		//"Foram encontrados arquivos de configuração inicial(company.csv,organization_structure.csv,users.csv) na pasta:"
			STR0097,STR0025) //"Não será possível realizar a configuração inicial" ##Wizard Carga Inicial"
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------	
/*/{Protheus.doc} valida_DF5
Cria Validacao do wizard de Configurações para mobile pg1
@author  Paulo Henrique Santos de Moura
@version P12.1.17
@since   19/10/2017
@return  Nil
/*/
//-------------------------------------------------------------------	
Static Function valida_DF5()
Local lRet 	:= MsgYesNo(STR0098 + CRLF + ;	//"As alterações realizadas no Wizard serão efetivadas" 
 			  		  	STR0093)			//"Deseja continuar?"

If lRet
	lRet := FimWizard()
EndIf 

	
Return lRet
