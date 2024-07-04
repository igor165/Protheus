#INCLUDE "Protheus.CH"
#INCLUDE "FwMVCDef.CH"
#INCLUDE "TAFA442.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA442

Cadastro MVC de Informa��es de identifica��o do registrador da CAT

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
 
/*/
//------------------------------------------------------------------
Function TAFA442()

Local oBrw := FWmBrowse():New()

oBrw:SetDescription( STR0001 ) //"Codifica��o de Acidente de Trabalho"
oBrw:SetAlias( "LE5" )
oBrw:SetMenuDef( "TAFA442" )
LE5->( DBSetOrder( 1 ) )
oBrw:Activate()

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Funcao generica MVC com as opcoes de menu

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Return xFunMnuTAF( "TAFA442",,,, .T. )

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Funcao generica MVC do model

@Return oModel - Objeto do Modelo MVC

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oStruLE5 := FwFormStruct( 1, "LE5" )
Local oModel   := MpFormModel():New( "TAFA442" )

oModel:AddFields( "MODEL_LE5", /*cOwner*/, oStruLE5 )
oModel:GetModel ( "MODEL_LE5" ):SetPrimaryKey( { "LE5_FILIAL", "LE5_ID" } )

Return( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Funcao generica MVC do View

@Return oView - Objeto da View MVC

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FwLoadModel( "TAFA442" )
Local oStruLE5 := FwFormStruct( 2, "LE5" )
Local oView    := FwFormView():New()

oView:SetModel( oModel )
oView:AddField( "VIEW_LE5", oStruLE5, "MODEL_LE5" )
oView:EnableTitleView( "VIEW_LE5", STR0001 ) //"Informa��es de identifica��o do registrador da CAT"
oView:CreateHorizontalBox( "FIELDSLE5", 100 )
oView:SetOwnerView( "VIEW_LE5", "FIELDSLE5" )

Return( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} FAtuCont

Rotina para carga e atualiza��o da tabela autocontida:
LE5 - (Info. iden. registrador da CAT) 
Informa��es de identifica��o do registrador da CAT

@Param		nVerEmp	-	Vers�o corrente na empresa
			nVerAtu	-	Vers�o atual ( passado como refer�ncia )

@Return	aRet		-	Array com estrutura de campos e conte�do da tabela

@Author	Mick William da Silva
@Since		25/02/2016
@Version	1.0
/*/
//-------------------------------------------------------------------
Static Function FAtuCont( nVerEmp, nVerAtu )

Local aHeader	:=	{}
Local aBody	:=	{}
Local aRet		:=	{}

nVerAtu := 1032.01

If nVerEmp < nVerAtu
	aAdd( aHeader, "LE5_FILIAL" )
	aAdd( aHeader, "LE5_ID" )
	aAdd( aHeader, "LE5_CODIGO" )
	aAdd( aHeader, "LE5_DESCRI" )
	aAdd( aHeader, "LE5_VALIDA" )

	aAdd( aBody, { "", "000001", "1.0.01", "LES�O CORPORAL  QUE CAUSE A MORTE OU A PERDA OU REDU��O, PERMANENTE OU TEMPOR�RIA, DA CAPACIDADE PARA O TRABALHO, DESDE QUE NAO ENQUADRADA EM NENHUM DOS DEMAIS CODIGOS.", "" } )
	aAdd( aBody, { "", "000002", "1.0.02", "PERTURBA��O FUNCIONAL QUE CAUSE A MORTE OU A PERDA OU REDU��O, PERMANENTE OU TEMPORARIA, DA CAPACIDADE PARA O TRABALHO, DESDE QUE N�O ENQUADRADA EM NENHUM DOS DEMAIS CODIGOS.", "" } )
	aAdd( aBody, { "", "000003", "2.0.01", "DOEN�A PROFISSIONAL, ASSIM ENTENDIDA A PRODUZIDA OU DESENCADEADA PELO EXERCICIO DO TRABALHO PECULIAR A DETERMINADA ATIVIDADE E CONSTANTE DA RESPECTIVA RELA��O ELABORADA PELO MINISTERIO TRAB. E PREVID.SOCIAL, DESDE QUE NAO ENQUADRADA EM NENHUM DOS DEMAIS C�DIGOS.", "" } )
	aAdd( aBody, { "", "000004", "2.0.02", "DOEN�A DO TRABALHO, ASSIM ADQUIRIDA OU DESENCADEADA EM FUN��O DE CONDI��ES ESPECIAIS EM QUE O TRABALHO E REALIZADO E COM ELE SE RELACIONE DIRETAMENTE, CONSTANTE DA RESPECTIVA RELA��O ELABORADA PELO MINIST. TRAB. E PREVID. SOCIAL, DESDE QUE N�O ENQUADRADA NOS DEMAIS C�DIGOS.", "" } )
	aAdd( aBody, { "", "000005", "2.0.03", "DOEN�A PROVENIENTE DE CONTAMINA��O ACIDENTAL DO EMPREGADO NO EXERC�CIO DE SUA ATIVIDADE.", "" } )
	aAdd( aBody, { "", "000006", "2.0.04", "DOEN�A ENDEMICA ADQUIRIDA POR SEGURADO HABITANTE DE REGI�O EM QUE ELA SE DESENVOLVA QUANDO RESULTANTE DE EXPOSI��O OU CONTATO DIRETO DETERMINADO PELA NATUREZA DO TRABALHO.", "" } )
	aAdd( aBody, { "", "000007", "2.0.05", "DOEN�A PROFISSIONAL OU DO TRABALHO NAO INCLUIDA NA RELA��O ELABORADA PELO MINISTERIO DO TRABALHO E PREVIDENCIA SOCIAL QUANDO RESULTANTE DAS CONDI�OES ESPECIAIS EM QUE O TRABALHO E EXECUTADO E COM ELE SE RELACIONA DIRETAMENTE.", "" } )
	aAdd( aBody, { "", "000008", "2.0.06", "DOEN�A PROFISSIONAL OU DO TRABALHO ENQUADRADA NA RELA��O ELABORADA PELO MINIST�RIO DO TRABALHO E PREVID�NCIA SOCIAL RELATIVA NEXO T�CNICO EPIDEMIOLOGICO PREVIDENCI�RIO - NTEP.", "" } )
	aAdd( aBody, { "", "000009", "3.0.01", "ACIDENTE LIGADO AO TRABALHO QUE, EMBORA N�O TENHA SIDO A CAUSA �NICA, HAJA CONTRIBU�DO DIRETAMENTE PARA A MORTE DO SEGURADO, PARA REDU��O OU PERDA DA SUA CAPACIDADE PARA O TRABALHO, OU PRODUZIDO LES�O QUE EXIJA ATEN��O MEDICA PARA A SUA RECUPERA��O.", "" } )
	aAdd( aBody, { "", "000010", "3.0.02", "ACIDENTE SOFRIDO PELO SEGURADO NO LOCAL E NO HOR�RIO DO TRABALHO, EM CONSEQ�ENCIA DE  ATO DE AGRESS�O, SABOTAGEM OU TERRORISMO PRATICADO POR TERCEIRO OU COMPANHEIRO DE TRABALHO.", "" } )
	aAdd( aBody, { "", "000011", "3.0.03", "ACIDENTE SOFRIDO PELO SEGURADO NO LOCAL E NO HOR�RIO DO TRABALHO, EM CONSEQ�ENCIA DE OFENSA FISICA INTENCIONAL, INCLUSIVE DE TERCEIRO, POR MOTIVO DE DISPUTA RELACIONADA AO TRABALHO.", "" } )
	aAdd( aBody, { "", "000012", "3.0.04", "ACIDENTE SOFRIDO PELO SEGURADO NO LOCAL E NO HOR�RIO DO TRABALHO, EM CONSEQ�ENCIA DE ATO DE IMPRUD�NCIA, DE NEGLIG�NCIA OU DE IMPERICIA DE TERCEIRO OU DE COMPANHEIRO DE TRABALHO.", "" } )
	aAdd( aBody, { "", "000013", "3.0.05", "ACIDENTE SOFRIDO PELO SEGURADO NO LOCAL E NO HOR�RIO DO TRABALHO, EM CONSEQ�ENCIA DE ATO DE PESSOA PRIVADA DO USO DA RAZ�O.", "" } )
	aAdd( aBody, { "", "000014", "3.0.06", "ACIDENTE SOFRIDO PELO SEGURADO NO LOCAL E NO HOR�RIO DO TRABALHO, EM CONSEQ�ENCIA DE DESABAMENTO, INUNDA��O, INCENDIO E OUTROS CASOS FORTUITOS OU DECORRENTES DE FOR�A MAIOR.", "" } )
	aAdd( aBody, { "", "000015", "3.0.07", "ACIDENTE SOFRIDO PELO SEGURADO AINDA QUE FORA DO LOCAL E HOR�RIO DE TRABALHO NA EXECU��O DE ORDEM OU NA REALIZA��O DE SERVI�O SOB A AUTORIDADE DA EMPRESA.", "" } )
	aAdd( aBody, { "", "000016", "3.0.08", "ACIDENTE SOFRIDO PELO SEGURADO AINDA QUE FORA DO LOCAL E HOR�RIO DE TRABALHO NA PRESTA��O ESPONTANEA DE QUALQUER SERVI�O A EMPRESA PARA LHE EVITAR PREJU�ZO OU PROPORCIONAR PROVEITO.", "" } )
	aAdd( aBody, { "", "000017", "4.0.01", "SUSPEITA DE DOEN�AS PROFISSIONAIS OU DO TRABALHOS PRODUZIDAS PELAS CONDI�OES ESPECIAIS DE TRABALHO, NOS TERMOS DO ART 169 DA CLT.", "" } )
	aAdd( aBody, { "", "000018", "4.0.02", "CONSTATA��O DE OCORR�NCIA AGRAVAMENTO DOEN�AS PROFISSIONAIS, ATRAV�S EXAMES MEDICOS QUE INCLUAM OS DEFINIDOS NA NR07; OU VERIFICADAS ALTERA��ES QUE REVELEM QUALQUER TIPO DE DISFUN��O DE ORG�O OU SISTEMA BIOL�GICO ATRAV�S DOS EXAMES DO QUADRO I (APENAS AQUELES COM INTERPRETA��O SC) E II, E DO ITEM 7.4.2.3 DESTA NR, MESMO SEM SINTOMATOLOGIA, CABER� AO M�DICO-COORDENADOR OU ENCARREGADO.", "" } )
	aAdd( aBody, { "", "000019", "5.0.01", "OUTROS.", "" } )
	aAdd( aBody, { "", "000020", "3.0.09", "ACID. SOFRIDO PELO SEGURADO AINDA QUE FORA DO LOCAL/HOR. TRAB. EM VIAGEM A SERV. DA EMP., INCLUSIVE P/ ESTUDO QUANDO FINAN. POR ESTA DENTRO DE SEUS PLANOS PARA CAPAC. DE MO., INDEP. DO MEIO DE LOCOMO��O UTILIZADO, INCLUSIVE DE PROPRIEDADE SEGURADO.", "" } )
	aAdd( aBody, { "", "000021", "3.0.10", "ACIDENTE SOFRIDO PELO SEGURADO AINDA QUE FORA DO LOCAL E HOR�RIO DE TRABALHO NO PERCURSO DA RESID�NCIA PARA O LOCAL DE TRABALHO OU DESTE PARA AQUELA, QUALQUER QUE SEJA O MEIO DE LOCOMO��O, INCLUSIVE VE�CULO DE PROPRIEDADE DO SEGURADO.", "" } )
	aAdd( aBody, { "", "000022", "3.0.11", "ACIDENTE SOFRIDO PELO SEGURADO NOS PERIODOS DESTINADOS A REFEI��O OU DESCANSO, OU POR OCASI�O DA SATISFA��O DE OUTRAS NECESSIDADES FISIOLOGICAS, NO LOCAL DO TRABALHO OU DURANTE ESTE.", "" } )
	
	aAdd( aRet, { aHeader, aBody } )

EndIf

Return( aRet )