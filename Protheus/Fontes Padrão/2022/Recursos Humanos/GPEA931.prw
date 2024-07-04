#include 'Protheus.ch'
#Include 'fwmvcdef.ch'
#include 'GPEA931.CH'

//Integração com o TAF
Static lIntTAF		:= ((SuperGetMv("MV_RHTAF",, .F.) == .T.) .AND. Val(SuperGetMv("MV_FASESOC",/*lHelp*/,' ')) >= 1 )
Static cVersEnvio	:= ""
Static cVersGPE		:= ""


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    	³ GPEA931    ³ Autor ³ Marcia Moura      		  	                ³ Data ³ 21/11/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao 	³ Agentes Publicos                                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   	³ GPEA931()                                                    	  		            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       	³ Menu SIGAGPE                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.               			            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista     ³ Data     ³ ISSUE                    ³  Motivo da Alteracao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Marcia Moura ³21/11/2016³MRH-2369      ³ Inclusao rotina.                                        ³±±
±±³Marcia Moura ³24/11/2016³MRH-19        ³Inclusao dos controles para  Audesp                      ³±±
±±|Claudinei S. |19/09/2017|DRHESOCP-904  |Incluida validação do MV_AUDESP p/ liberação do cadastro.³±±
±±|Marcos Cout. |12/12/2017|DRHESOCP-2201 |Realizando ajustes no filtro do programa. Somente será   ³±±
±±|             |          |              |exibido os funcionários q se enquadrarem na config certa ³±±
±±|             |          |              |Realizando a criação da função de Commit especifica para ³±±
±±|             |          |              |o Model e integração do evento S-2200 e S-2206           ³±±
±±|Cecília C.   |21/12/2017|DRHESOCP-2463 |Ajuste no campo RS9_PROES para leiaute 2.4.              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function GPEA931 ()
	Local	oMBrowse
	Local	cFiltraRh := ""
	Private lAudesp	:= SuperGetMv('MV_AUDESP',, .F.)
	Private lCargSQ3 := SuperGetMv("MV_CARGSQ3",,.F.)
	Static	cTrabAgPubl := fCatTrabEFD("AGE")

	If !ChkFile("RS9")
		Help( " ", 1, OemToAnsi(STR0025),, OemToAnsi(STR0026) + CRLF + OemToAnsi(STR0032), 1, 0 )	//ATENCAO"###"Foram encontradas divergências no dicionário de dados"
		Return 																								//"Tabela RS9 não encontrada. Execute o UPDDISTR - atualizador de dicionário e base de dados."
	Else

	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias("SRA")
	oMBrowse:SetDescription(OemToAnsi(STR0001)) //Dados Agente Publico

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

	If !lAudesp
		cFiltraRh += " (RA_CATEFD $ '" + cTrabAgPubl + "'"
		cFiltraRh += " .AND. RA_VIEMRAI $ '30|31|35')"
		cFiltraRh += " .AND. (Empty(RA_DEMISSA) .OR. DToS(RA_DEMISSA) >= '" + DToS(dDataBase) + "')"
		cFiltraRh += " .And. RA_CTPCD <> '1'"
	EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oMBrowse:SetFilterDefault( cFiltraRh )
	oMBrowse:SetLocate()
	GpLegMVC(@oMBrowse)

	oMBrowse:ExecuteFilter(.T.)

	oMBrowse:SetCacheView(.F.)
	oMBrowse:Activate()
Endif

Return

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ MenuDef		³Autor³  Glaucia M.       ³ Data ³16/09/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Criacao do Menu do Browse.                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA922                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³aRotina														³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title OemToAnsi(STR0002)  Action 'PesqBrw'			OPERATION 1 ACCESS 0 //"Pesquisar"
ADD OPTION aRotina Title OemToAnsi(STR0003)  Action 'VIEWDEF.GPEA931'	OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina Title OemToAnsi(STR0004)  Action 'VIEWDEF.GPEA931'	OPERATION 4 ACCESS 0 //"Alterar"
ADD OPTION aRotina Title OemToAnsi(STR0005)  Action 'VIEWDEF.GPEA931'	OPERATION 5 ACCESS 0 //"Excluir"

Return aRotina

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ ModelDef		³Autor³  Glaucia M.       ³ Data ³16/09/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Regras de Modelagem da gravacao.                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA922                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³Model em uso.												³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function ModelDef()

	Local oModel		:= Nil
	Local oStruSRA 		:= FWFormStruct( 1, 'SRA')
	Local oStruRS9		:= FWFormStruct(1, 'RS9')
	Local bPosValid 	:= { |oModel| Gp931PosVal( oModel )}
	Local bCommit		:= {|oModel| Gp931Com(oModel)}

	Iif( FindFunction( 'fVersEsoc' ), fVersEsoc("S2200", .F., /*@aRetGPE*/, /*@aRetTAF*/, @cVersEnvio,@cVersGPE), cVersEnvio := "2.2" )

	If RS9->( ColumnPos( "RS9_CAR" ) # 0 ) .And. ! (SRA->RA_CATEFD $ cTrabAgPubl .AND. SRA->RA_VIEMRAI $ '30|31|35')
		oStruRS9:SetProperty( 'RS9_SEG', MODEL_FIELD_OBRIGAT, .F.)
	EndIf

	If cVersEnvio >= "9.0"
		oStruRS9:SetProperty( "RS9_TPPROV", MODEL_FIELD_WHEN,{||.F.})
		oStruRS9:SetProperty( "RS9_SEG"   , MODEL_FIELD_WHEN,{||.F.})
	Endif

	oModel     	:= MPFormModel():New('GPEA931', /*bPreValid*/, bPosValid, bCommit, /*bCancel*/ )
	oStruSRA	:= FWFormStruct(1,"SRA",{|cCampo|  AllTrim(cCampo) $ "|RA_MAT|RA_NOME|RA_ADMISSA|"})
	oModel:AddFields( 'SRATITLE',				, oStruSRA )
	oModel:AddFields( 'RS9MASTER', 'SRATITLE', oStruRS9,,)

	oModel:GetModel( 'RS9MASTER' ):SetDescription(OemToAnsi(STR0001)) //Agente Publico

	oModel:SetRelation('RS9MASTER', {{'RS9_FILIAL', 'xFilial("RS9")'}, {'RS9_MAT', 'RA_MAT'}}, RS9->(IndexKey(1)))


	//Permite grid sem dados
	oModel:GetModel('RS9MASTER'):SetOptional(.T.)
	oModel:GetModel('SRATITLE'):SetOnlyView(.T.)
	oModel:GetModel('SRATITLE'):SetOnlyQuery(.T.)

	// Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel('SRATITLE'):SetDescription(OemToAnsi(STR0006)) // "Funcionários"


Return( oModel )
/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ ViewDef		³Autor³  Glaucia M.       ³ Data ³16/09/2013³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Regras de Interface com o Usuario                           ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³< Vide Parametros Formais >									³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA922                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Retorno  ³View em uso.    											³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³< Vide Parametros Formais >									³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function ViewDef()
Local oView		:= NIL
Local oModel	:= FWLoadModel('GPEA931')
Local oStruSRA	:= FWFormStruct(2, 'SRA')
Local oStruRS9	:= FWFormStruct(2, 'RS9')


oStruSRA		:= FWFormStruct(2,"SRA",{|cCampo|  AllTrim(cCampo) $ "|RA_MAT|RA_NOME|RA_ADMISSA|"})

oView := FWFormView():New()
oView:SetModel(oModel)
oView:AddField("VIEW_SRA",oStruSRA,"SRATITLE")
oView:AddField("VIEW_RS9", oStruRS9, 'RS9MASTER')

oStruSRA:RemoveField("RA_FILIAL")
oStruRS9:RemoveField( 'RS9_MAT' )
oStruRS9:RemoveField( 'RS9_FILIAL' )

If !lAudesp
	oStruRS9:RemoveField( 'RS9_APESC'	)
	oStruRS9:RemoveField( 'RS9_APESP'	)
	oStruRS9:RemoveField( 'RS9_APFPRO'	)
	oStruRS9:RemoveField( 'RS9_APEXER'	)
	oStruRS9:RemoveField( 'RS9_APATIV'	)
	oStruRS9:RemoveField( 'RS9_APFUN'	)
	oStruRS9:RemoveField( 'RS9_MUNLOT'	)
	oStruRS9:RemoveField( 'RS9_ENTLOT'	)
	oStruRS9:RemoveField( 'RS9_CARGOP'	)
	oStruRS9:RemoveField( 'RS9_REGJUR'	)
	oStruRS9:RemoveField( 'RS9_AUTETO'	)
	oStruRS9:RemoveField( 'RS9_NUPROC'	)
	oStruRS9:RemoveField( 'RS9_SITUAC'	)
Else
	oStruRS9:AddGroup( 'Grupo00', OemToAnsi(STR0030) , '', 2 )   	//'AUDESP'
	oStruRS9:SetProperty( "RS9_APESC"	, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRS9:SetProperty( "RS9_APESP"	, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRS9:SetProperty( "RS9_APFPRO"	, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRS9:SetProperty( "RS9_APEXER"	, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRS9:SetProperty( "RS9_APATIV"	, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRS9:SetProperty( "RS9_APFUN"	, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRS9:SetProperty( "RS9_MUNLOT"	, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRS9:SetProperty( "RS9_ENTLOT"	, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRS9:SetProperty( "RS9_CARGOP"	, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRS9:SetProperty( "RS9_REGJUR"	, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRS9:SetProperty( "RS9_AUTETO"	, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRS9:SetProperty( "RS9_NUPROC"	, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
	oStruRS9:SetProperty( "RS9_SITUAC"	, MVC_VIEW_GROUP_NUMBER , 'Grupo00' )
Endif

If cVersEnvio < "9.0" .Or. lAudesp
	oStruRS9:RemoveField( "RS9_TIPPRV" 	)
	oStruRS9:RemoveField( "RS9_SEGR" 	)
	oStruRS9:RemoveField( "RS9_TETORG" 	)
	oStruRS9:RemoveField( "RS9_ABONPE" 	)
	oStruRS9:RemoveField( "RS9_INIABO" 	)
	oStruRS9:RemoveField( "RS9_ACUMCA" 	)
	oStruRS9:RemoveField( "RS9_DTINIC" 	)
	oStruRS9:RemoveField( "RS9_INDREM" 	)
Endif

If RS9->( ColumnPos( "RS9_CAR" ) # 0 )
	If SRA->RA_CATEFD $ cTrabAgPubl .AND. SRA->RA_VIEMRAI $ '30|31|35'
		oStruRS9:AddGroup( 'Grupo01', OemToAnsi(STR0031) , '', 2 )       //'eSocial'
		oStruRS9:SetProperty( "RS9_PROES"	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		If cVersEnvio < "9.0"
			oStruRS9:SetProperty( "RS9_TPPROV"	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
			oStruRS9:SetProperty( "RS9_SEG" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		Endif
		oStruRS9:SetProperty( "RS9_DTNOM" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		oStruRS9:SetProperty( "RS9_DTPOSS"	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		oStruRS9:SetProperty( "RS9_DTEX" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		oStruRS9:SetProperty( "RS9_CAR" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		oStruRS9:SetProperty( "RS9_DTCAR" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		oStruRS9:SetProperty( "RS9_PROC" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		If RS9->( ColumnPos( "RS9_INDCE" ) # 0 )
			oStruRS9:SetProperty( "RS9_INGSP" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
			oStruRS9:SetProperty( "RS9_RGPST" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
			oStruRS9:SetProperty( "RS9_IDABON" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
			oStruRS9:SetProperty( "RS9_DTABON" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
			oStruRS9:SetProperty( "RS9_IDEPR" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
			oStruRS9:SetProperty( "RS9_DTINPR" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
			oStruRS9:SetProperty( "RS9_INDCE" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		Endif
		If RS9->( ColumnPos( "RS9_TETORG" )) <> 0 .And. cVersEnvio >= "9.0" .And. !lAudesp
			oStruRS9:SetProperty( "RS9_TIPPRV" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
			oStruRS9:SetProperty( "RS9_SEGR" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
			oStruRS9:SetProperty( "RS9_TETORG" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
			oStruRS9:SetProperty( "RS9_ABONPE" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
			oStruRS9:SetProperty( "RS9_INIABO" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
			oStruRS9:SetProperty( "RS9_ACUMCA" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
			oStruRS9:SetProperty( "RS9_DTINIC" 	, MVC_VIEW_GROUP_NUMBER , 'Grupo01' )
		Endif
	Else
		oStruRS9:RemoveField( 'RS9_PROES'	)
		oStruRS9:RemoveField( 'RS9_TPPROV'	)
		oStruRS9:RemoveField( 'RS9_DTNOM'	)
		oStruRS9:RemoveField( 'RS9_DTPOSS'	)
		oStruRS9:RemoveField( 'RS9_DTEX'	)
		oStruRS9:RemoveField( 'RS9_SEG'		)
		oStruRS9:RemoveField( 'RS9_CAR'		)
		oStruRS9:RemoveField( 'RS9_DTCAR'	)
		oStruRS9:RemoveField( 'RS9_PROC'	)
		If RS9->( ColumnPos( "RS9_INDCE" ) # 0)
			oStruRS9:RemoveField( 'RS9_INGSP'	)
			oStruRS9:RemoveField( 'RS9_RGPST'	)
			oStruRS9:RemoveField( 'RS9_IDABON'	)
			oStruRS9:RemoveField( 'RS9_DTABON'	)
			oStruRS9:RemoveField( 'RS9_IDEPR'	)
			oStruRS9:RemoveField( 'RS9_DTINPR'	)
			oStruRS9:RemoveField( 'RS9_INDCE'	)
		Endif
	Endif
Endif

oStruSRA:SetNoFolder()
oStruRS9:SetNoFolder()

oView:SetOnlyView('VIEW_SRA')
oView:CreateHorizontalBox( 'SUPERIOR', 16 )
oView:CreateHorizontalBox( 'INFERIOR', 84 )

oView:SetOwnerView('VIEW_SRA', 'SUPERIOR')
oView:SetOwnerView('VIEW_RS9', 'INFERIOR')

oView:EnableTitleView('VIEW_SRA', OemToAnsi(STR0006)) // "Funcionário"
oView:EnableTitleView('VIEW_RS9', OemToAnsi(STR0001)) // "Dados Agente Publico"

Return oView

/*/{Protheus.doc}fGpa931Sit()
- Função responsável por exibir os códigos dos tipo de situações do agente público

@author: 	Claudinei Soares
@since:	31/03/2017
@version: 	1.0
/*/

Function fGpa931Sit()
Local cTitulo  		:= OemToAnsi(STR0021) // "Situações"
Local MvPar    		:= &(ReadVar())
Local MvParDef 		:= ""
Local MvStrRet		:= ""
Local lRet     		:= .T.
Local l1Elem   		:= .F.
Local nGrupo		:= 0
Local aArea			:= GetArea()
Local aContPr			:= {}

Private aGrpVerba	:= {}

VAR_IXB := MvPar

aContPr := {;
OemToAnsi(STR0007),; //"0 - Não Informado"
OemToAnsi(STR0008),; //"1 - Ativo"
OemToAnsi(STR0009),; //"2 - Aposentado"
OemToAnsi(STR0010),; //"3 - Cedido de"
OemToAnsi(STR0011),; //"4 - Cedido para"
OemToAnsi(STR0012),; //"5 - Demitido"
OemToAnsi(STR0013),; //"6 - Encerramento de Lotação"
OemToAnsi(STR0014),; //"7 - Exonerado"
OemToAnsi(STR0015),; //"8 - Falecido"
OemToAnsi(STR0016),; //"9 - Fim de cessão"
OemToAnsi(STR0017),; //"A - Licença sem vencimento"
OemToAnsi(STR0018),; //"B - Licença saúde superior a 15 dias"
OemToAnsi(STR0019),; //"C - Reformado"
OemToAnsi(STR0020)}  //"D - Transferido para Reserva"

MvParDef := "0123456789ABCD"

If f_Opcoes(@MvPar,cTitulo,aContPr,MvParDef,,,l1Elem)
	For nGrupo := 1 To Len(MvPar)
		If (SubStr(MvPar, nGrupo, 1) # "*")
			MvStrRet += SubStr(mvpar, nGrupo, 1)
		Else
			MvStrRet += Space(1)
		Endif
	Next nGrupo
	VAR_IXB := AllTrim(MvStrRet)
EndIf

RestArea(aArea)
Return(lRet)


/*/{Protheus.doc}VldRS9Sit()
- Função responsável por validar os codigos do campo RS9_SITUAC

@author: 	Claudinei Soares
@since:	31/03/2017
@version: 	1.0
/*/


Function VldRS9Sit()(cCodigos)
Local lRet	:= .T.
Local nX	:= 0

cCodigos := StrTran(cCodigos, " ","")
For nx := 0 To Len(cCodigos)
	If !(SUBSTR(cCodigos, nx, 1) $ "0123456789ABCD")
		lRet := .F.
	EndIf
Next nx

Return lRet

/*/{Protheus.doc}Gp931PosVal()
- Função responsável por realizar a validação dos campos do cadastro (TUDOOK)
@author: 	Claudinei Soares
@since:	24/11/2017
@version: 	1.0
/*/

Static Function Gp931PosVal( oModel )

Local lRetorno      := .T.
Local nOperation
Local oModelRS9		:= oModel:GetModel('RS9MASTER')
Local ctpRegPrev    := If(!Empty(SRA->RA_TPPREVI), SRA->RA_TPPREVI , "1")
Local cCBO			:= ""
Local lIndRem		:= .F.


nOperation := oModelRS9:GetOperation()

If (nOperation == MODEL_OPERATION_UPDATE .Or. nOperation == MODEL_OPERATION_INSERT) .And. !lAudesp
	If RS9->( ColumnPos( "RS9_DTEX")) > 0 .And. Empty(oModelRS9:GetValue('RS9_DTEX'))
		Help( " ", 1, OemToAnsi(STR0025),, OemToAnsi(STR0056), 1, 0 )	//ATENCAO"###"O preenchimento do campo Dt Entrada Exercício (RS9_DTEX) é obrigatorio"
		lRetorno := .F.
	ElseIf cVersEnvio < "9.0"
		If RS9->( ColumnPos( "RS9_CAR")) > 0 .And. RS9->( ColumnPos( "RS9_DTCAR")) > 0
			If !Empty(oModelRS9:GetValue('RS9_CAR')) .And. Empty(oModelRS9:GetValue('RS9_DTCAR'))
				Help( " ", 1, OemToAnsi(STR0025),, OemToAnsi(STR0028), 1, 0 )	//ATENCAO"###"É necessário o preenchimento do campo Dt.Ing.Car (RS9_DTCAR), quando o campo Cód Carreira (RS9_CAR) estiver preenchido."
				lRetorno := .F.
			Endif
		Endif

		If lRetorno .And. RS9->( ColumnPos( "RS9_PROC")) > 0 .And. RS9->( ColumnPos( "RS9_PROES")) > 0
			If Empty(oModelRS9:GetValue('RS9_PROC')) .And. oModelRS9:GetValue('RS9_PROES') == "2"
				Help( " ", 1, OemToAnsi(STR0025),, OemToAnsi(STR0029), 1, 0 )	//ATENCAO"###"É necessário o preenchimento do campo Processo (RS9_PROC), quando o campo Indic Provim (RS9_PROES) for preenchido com '2'."
				lRetorno := .F.
			Endif
		Endif

		If lRetorno .And. RS9->( ColumnPos( "RS9_PROES")) > 0
			If oModelRS9:GetValue('RS9_PROES') == "3"
				Help( " ", 1, OemToAnsi(STR0025),, OemToAnsi(STR0033), 1, 0 )	//ATENCAO"###"Opção inválida a partir do leiaute 2.4 do eSocial."
				lRetorno := .F.
			Endif
		Endif

	Else //S-1.0
		If lRetorno .And. RS9->( ColumnPos( "RS9_TIPPRV")) > 0
			If Empty( oModelRS9:GetValue('RS9_TIPPRV ') )
				Help( " ", 1, OemToAnsi(STR0025),, OemToAnsi(STR0050), 1, 0 )	//ATENCAO"###"O preenchimento do campo Provimento eSocial (RS9_TIPPRV) é obrigatorio"
				lRetorno := .F.
			Endif
		Endif

		If lRetorno .And. RS9->( ColumnPos( "RS9_TIPPRV")) > 0
			If SRA->RA_CATEFD == "302" .And.  oModelRS9:GetValue('RS9_TIPPRV ') <> "2"
				Help( " ", 1, OemToAnsi(STR0025),, OemToAnsi(STR0051), 1, 0 )	//ATENCAO"###"Para a categoria 302 o preenchimento do campo Provimento eSocial (RS9_TIPPRV) deve ser igual a opção '2'."
				lRetorno := .F.
			Endif
		Endif

		If lRetorno .And. RS9->( ColumnPos( "RS9_INDREM")) > 0
			 // Utiliza SQ3
			If lCargSQ3			
				cCBO	:= Posicione("SQ3", 1, xFilial("SQ3", SRA->RA_FILIAL)+SRA->RA_CARGO, "Q3_CBO")
				lIndRem	:= SRA->RA_CATEFD $ "304*305*308" .And. cCBO $ ("111120*111250*111255")
				If (lIndRem .And. Empty( oModelRS9:GetValue('RS9_INDREM') )) .Or. (!lIndRem .And. !Empty( oModelRS9:GetValue('RS9_INDREM') ) )
					//ATENCAO"###"O preenchimento do campo Rem Carg Efe (RS9_INDREM) é obrigatorio e exclusivo para as categorias eSocial 304, 305 e 308 com CBO contidos em 111120, 111250, 111255."
					Help( " ", 1, OemToAnsi(STR0025),, OemToAnsi(STR0059), 1, 0 )	
					lRetorno := .F.
				EndIf				
			// Utiliza SRJ
			Else
				If (!(SRA->RA_CATEFD $ "304*305*308") .And. !Empty( oModelRS9:GetValue('RS9_INDREM') )) .Or. (SRA->RA_CATEFD $ "304*305*308" .And. Empty( oModelRS9:GetValue('RS9_INDREM') ))
					//ATENCAO"###"O preenchimento do campo Rem Carg Efe (RS9_INDREM) é obrigatorio e exclusivo apenas para as categorias eSocial 304, 305 e 308." 
					Help( " ", 1, OemToAnsi(STR0025),, OemToAnsi(STR0060), 1, 0 )	
					lRetorno := .F.
				EndIf
			EndIf
		EndIf

		If ctpRegPrev == "2"
			If lRetorno .And. RS9->( ColumnPos( "RS9_SEGR")) > 0
				If Empty( oModelRS9:GetValue('RS9_SEGR') )
					Help( " ", 1, OemToAnsi(STR0025),, OemToAnsi(STR0052), 1, 0 )	//ATENCAO"###"O preenchimento do campo Tp Plano Segregação Massa (RS9_SEGR) é obrigatorio"
					lRetorno := .F.
				Endif
			Endif
			If lRetorno .And. RS9->( ColumnPos( "RS9_TETORG")) > 0
				If Empty( oModelRS9:GetValue('RS9_TETORG') )
					Help( " ", 1, OemToAnsi(STR0025),, OemToAnsi(STR0053), 1, 0 )	//ATENCAO"###"O preenchimento do campo Sujeito ao teto do RGPS (RS9_TETORG) é obrigatorio"
					lRetorno := .F.
				Endif
			Endif
			If lRetorno .And. RS9->( ColumnPos( "RS9_ABONPE")) > 0
				If Empty( oModelRS9:GetValue('RS9_ABONPE') )
					Help( " ", 1, OemToAnsi(STR0025),, OemToAnsi(STR0054), 1, 0 )	//ATENCAO"###"O preenchimento do campo Abono Permanência (RS9_ABONPE) é obrigatorio"
					lRetorno := .F.
				elseIf oModelRS9:GetValue('RS9_ABONPE') == "1" .And. Empty( oModelRS9:GetValue('RS9_INIABO') )
					Help( " ", 1, OemToAnsi(STR0025),, OemToAnsi(STR0057), 1, 0 )	//ATENCAO"###"O preenchimento do campo Dt. Início Abono (RS9_INIABO) é obrigatorio quando o campo Abono Permanência (RS9_ABONPE) = Sim"
					lRetorno := .F.
				elseIf oModelRS9:GetValue('RS9_ABONPE') == "2" .And. !Empty( oModelRS9:GetValue('RS9_INIABO') )
					Help( " ", 1, OemToAnsi(STR0025),, OemToAnsi(STR0058), 1, 0 )	//ATENCAO"###"O campo Dt. Início Abono (RS9_INIABO) não deve ser informado quando o campo Abono Permanência (RS9_ABONPE) = Não"
					lRetorno := .F.
				Endif
			Endif
		Else
			If lRetorno .And. RS9->( ColumnPos( "RS9_SEGR")) > 0 .And. RS9->( ColumnPos( "RS9_TETORG")) > 0 .And. RS9->( ColumnPos( "RS9_ABONPE")) > 0
				If 	!Empty( oModelRS9:GetValue('RS9_SEGR'))  .Or. !Empty( oModelRS9:GetValue('RS9_TETORG') ) .Or. !Empty( oModelRS9:GetValue("RS9_ABONPE") )
					Help( " ", 1, OemToAnsi(STR0025),, OemToAnsi(STR0055), 1, 0 )	//ATENCAO"###"O preenchimento dos campos: Tp Plano Segregação Massa (RS9_SEGR), Sujeito ao teto do RGPS (RS9_TETORG) e Abono Permanência (RS9_ABONPE) somente para Regime Próprio de Previdência Social - RPPS"
					lRetorno := .F.
				Endif
			Endif
		Endif
	Endif
Endif


Return lRetorno

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³ Gp931Com   	³Autor³  Marcos Coutinho.  ³ Data ³05/12/2017³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ³
³Descri‡„o ³Commit do Model Trabalhadores Agentes Publicos              ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
³Sintaxe   ³Gp931Com(oModel)                                            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³ Uso      ³GPEA931 - Verifica o valor do parametro MV_RHTAF e se neces_³
³          ³sario realiza a integração com o TAF                        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
³ Retorno  ³Boolean                                                     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
³Parametros³O Model para "commit" dos dados                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function Gp931Com(oModel)
Local aArea	:= GetArea()
Local lRet		:= .F.
Local cStatus	:= ""
Local cCPF		:= ""
Local cCateg	:= ""
Local aTpAlt	:= {.F., .F., .F., .F.}
Local lTpAge	:= .F.
Local oMdlRS9	:= oModel:GetModel("RS9MASTER")
Local aCampos	:= oMdlRS9:GetStruct():GetFields()
Local aErros	:= {}
Local nOpc		:= oModel:GetOperation()
Local nI
Local lCat2300		:= cVersEnvio >=  "9.0" .And. SRA->RA_CATEFD $ '304*305*308' .And. RS9->( ColumnPos( "RS9_INDREM")) > 0
Local lGeraMat		:= SRA->(ColumnPos("RA_DESCEP")) > 0 .And. SRA->RA_DESCEP == "1"

cCPF	:= SRA->RA_CIC
cCateg	:= SRA->RA_CATEFD

If lCat2300
	Iif( FindFunction( 'fVersEsoc' ), fVersEsoc("S2300", .F., /*@aRetGPE*/, /*@aRetTAF*/, @cVersEnvio,@cVersGPE), cVersEnvio := "2.2" )
Else
	Iif( FindFunction( 'fVersEsoc' ), fVersEsoc("S2200", .F., /*@aRetGPE*/, /*@aRetTAF*/, @cVersEnvio,@cVersGPE), cVersEnvio := "2.2" )
EndIf

// Grava histórico dos campos alterados na SR9
If nOpc == MODEL_OPERATION_UPDATE
	For nI := 1 To Len(aCampos)
		If "FHIST" $ Upper(aCampos[nI][15] )
			fGravaSr9( aCampos[nI][3], oMdlRS9:GetValue(aCampos[nI][3]), RS9->(&(aCampos[nI][3])), , .T. )
		EndIf
	Next
EndIf

//--------------------------------
//| Verifica se existe integração
//--------------------------------
If lIntTAF .AND. FunName() != "GPEM035"
	If cCateg $ cTrabAgPubl

		//Verificação de qual o tipo de alteração foi realizada - RS9
		fVerAltAge(@lTpAge, oMdlRS9)

		//Carregando valores na memória
		RegToMemory("SRA")

		//Verificação de qual o tipo de alteração foi realizada - SRA
		lRet := fVTpAltNew(@aTpAlt,,lTpAge,cVersEnvio)

		If lRet
		
			//---------------------------------------
			//| Verifica existencia ou Status <> "4"
			//| Se status <> "4" ou não existir, cria reg
			//--------------------------------------------
			If aTpAlt[1] .Or. aTpAlt[2]				
				If  lCat2300
					cGeraMat := If (lGeraMat, "1", "2")
					lRet :=  fInt2300New("SRA",,nOpc,"S2300",,,cVersEnvio,,,@aErros,,,,,,,cGeraMat)
				Else
					lRet := fIntAdmiss("SRA",/*lAltCad*/,nOpc,"S2200",/*cTFilial*/,/*aDep*/,/*cCodUnico*/,/*oModel*/, "ADM", @aErros, cVersEnvio,/*oMdlRFZ*/,/*aFilial*/,oMdlRS9)
				EndIf
			Else
				//-----------------------------------------
				//| Registro Status == "4" e tem alteração
				//| Verifica se foi alteração cadastral ou contratual
				//| Faz uma analise dentro da SRA (Cad/Con) e RFS (Con)
				//------------------------------------------------------
				If aTpAlt[3]
					lRet := fIntAdmiss("SRA",,4,"S2205",,,)
				EndIf

				If aTpAlt[4]
					If lCat2300
						lRet := fInt2306New("SRA",, nOpc, "S2306",,, cVersEnvio,,,,,, @aErros)
					Else
						lRet := fInt2206("SRA", /*lAltCad*/, nOpc,"S2206",/*cTFilial*/,/*dtEf*/,/*cTurno*/,/*cRegra*/,/*cSeqT*/,/*oModel*/, cVersEnvio,oMdlRS9)
					EndIf
				EndIf
			EndIf			

			If lRet
				FWFormCommit(oModel)

				//Envia mensagem de integração
				If aTpAlt[1] .OR. aTpAlt[2] .OR. aTpAlt[3] .OR. aTpAlt[4]
				  	IF FindFunction("fEFDMsg")
						fEFDMsg()
					EndIf
				Endif
			EndIf

		Endif
	Else
		//Se não for da categoria de agente público, deixa salvar o formulário. (Só os dados da AUDESP carregados na view)
		FWFormCommit(oModel)
		lRet := .T.
	Endif
Else
	//Se não tiver integração com o TAF, Salva registro diretamente
	FWFormCommit(oModel)
	lRet := .T.
Endif

RestArea(aArea)
Return lRet

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Funcao    ³ fVerAltAge   	³Autor³  Marcos Coutinho   ³ Data ³06/12/2017³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ³
³Descricao ³Realizar a verificacao das alteracoes do Agente Publico     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
³Sintaxe   ³fVerAltAge( lTpAge )          						         	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
³ Uso      ³GPEA931 - Verifica se houve alguma alteração no registro    ³
³          ³corrente do agente publico                                  ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
³ Retorno  ³Boolean													            	³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ³
³Parametros³ Uma variavel lógica base para retorno             			³
ÀÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Function fVerAltAge( lTpAge, oMdl )
Local aCpos			:= {"RS9_SEG", "RS9_CAR", "RS9_DTCAR"}
Local aCposS1		:= {"RS9_SEGR", "RS9_TETORG", "RS9_ABONPE", "RS9_INDREM"}
Local nI			:= 0
Local cTrabAgePub	:= fCatTrabEFD("AGE")
Default lTpAge := .F.

	If cPaisLoc == "BRA"
		If SRA->RA_CATEFD $ cTrabAgePub
			If cVersEnvio < "9.0"
				For nI := 1 To Len(aCpos)
					If &('RS9->' + aCpos[nI]) <> oMdl:GetValue(aCpos[nI])
						lTpAge := .T.
					Endif
				neXT nI
			ElseIf RS9->(ColumnPos("RS9_SEGR")) > 0
				For nI := 1 To Len(aCposS1)
					If &('RS9->' + aCposS1[nI]) <> oMdl:GetValue(aCposS1[nI])
						lTpAge := .T.
					Endif
				Next nI
			EndIf
		EndIf
	EndIf
Return

/*/{Protheus.doc} fValTpProv
Funcao de validação do campo RS9_TPPROV
@author Claudinei Soares
@since 29/08/2018
@version 1.0
@return lRet  	 - Indica é permitida a inclusão da opção
/*/
Function fValTpProv()
Local lRet		:= .T.
Local cTpProv	:= ''
Local aTpProv	:= {}
/*	//1 -  Nomeação em cargo efetivo
	//2 -  Nomeação exclusivamente em cargo em comissão
	//3 -  Incorporação (militar)
	//4 -  Matrícula (militar)
	//5 -  Redistribuição
	//6 -  Diplomação
	//7 -  Contratação por tempo determinado
	//8 -  Remoção(em caso de alteração do órgão declarante)
	//9 -  Designação
	//99 - Outros não relacionados acima
*/

If cVersGPE >= "9.0.00"
	cTpProv	:= '  # 1# 2# 3# 4# 5# 6# 7# 8# 9#10#99'
Else
	cTpProv	:= '  # 1# 2# 3# 4# 5# 6# 7# 8# 9#99'
Endif

aTpProv	:= strToArray(cTpProv, "#")
If !aScan(aTpProv,{|x| x == Alltrim(M->RS9_TPPROV)})>0
	lRet:= .F.
	Help( , , 'HELP', , OemToAnsi(STR0044), 1, 0 )//Informe um código válido
EndIf

Return lRet

/*/{Protheus.doc} fValTpProv
Função para disponibilizar uma lista de opcoes dos codigos de incidencia tributaria da rubrica de acordo com o campo RS9_TPPROV
@author Claudinei Soares
@since 29/08/2018
@version 1.0
@return lRet  	 - Indica é permitida a inclusão da opção
/*/
Function fRetOpcRS9(cCampo)
Local cTitulo	:= ""
Local MvPar		:= ""
Local MvParDef	:= ""
Local lRet		:= .T.
Local l1Elem	:= .T.
Local aArea		:= GetArea()
Local MvStrRet	:= ""
Local nGrupo	:= 0

Private aOcor	:={}

cAlias 	:= Alias() 					// Salva Alias Anterior
MvPar	:=&(Alltrim(ReadVar()))		// Carrega Nome da Variavel do Get em Questao
MvRet	:=Alltrim(ReadVar())		// Iguala Nome da Variavel ao Nome variavel de Retorno

VAR_IXB := MvPar

//--------------------------------------------------
//| Realiza a atribuicao de valores dentro da lista
//| Caso seja excluído algum dos itens abaixo, deve ser removida
//| da variavel MvParDef o valor removido
//----------------------------------------------------------------

If !Empty(ReadVar())

	//--------------------------------
	//| Programacao do campo RS9_TPPROV
	//--------------------------------
	If cCampo == 'RS9_TPPROV'
		cTitulo           := "Provimento eSocial"
		AADD(aOcor, OemToAnsi(STR0034)) //" 1=Nomeação em cargo efetivo"
		AADD(aOcor, OemToAnsi(STR0035))	//" 2=Nomeação exclusivamente em cargo em comissão"
		AADD(aOcor, OemToAnsi(STR0036))	//" 3=Incorporação (militar)"
		AADD(aOcor, OemToAnsi(STR0037))	//" 4=Matrícula (militar)"
		AADD(aOcor, OemToAnsi(STR0038))	//" 5=Redistribuição"
		AADD(aOcor, OemToAnsi(STR0039))	//" 6=Diplomação"
		AADD(aOcor, OemToAnsi(STR0040)) //" 7=Contratação por tempo determinado"
		AADD(aOcor, OemToAnsi(STR0041))	//" 8=Remoção(em caso de alteração do órgão declarante)"
		AADD(aOcor, OemToAnsi(STR0042))	//" 9=Designação"
		If cVersGPE >= '9.0.00'
			AADD(aOcor, OemToAnsi(STR0045))	//"10=Mudança de CPF"
		Endif
		AADD(aOcor, OemToAnsi(STR0043)) //"99=Outros não relacionados acima"
		ASORT(aOcor,,, { |x, y| x < y } )

		If cVersGPE >= '9.0.00'
			MvParDef := " 1 2 3 4 5 6 7 8 91099"
		Else
			MvParDef := " 1 2 3 4 5 6 7 8 999"
		Endif
	Endif

	If f_Opcoes(@MvPar,cTitulo,aOcor,MvParDef,,,l1Elem,2)
		For nGrupo := 1 To Len(MvPar) Step 2
	 		If (SubStr(MvPar, nGrupo, 2) # "*")
	   			MvStrRet += SubStr(mvpar, nGrupo, 2)
	      	Else
	       		MvStrRet += Space(1)
			Endif
		Next nGrupo
		VAR_IXB := AllTrim(MvStrRet)
	EndIf

	If MvStrRet $ MvParDef
		lRet := .T.
	Else
		lRet := .F.
	EndIf

EndIf
RestArea(aArea)
Return(lRet)


Function fOpcTpProv()
	Local cOpcBox := ""

	If FindFunction("fVersEsoc")
		fVersEsoc("S2200", .F.,,, @cVersEnvio, @cVersGPE)
	EndIf

	cOpcBox += ( OemToAnsi(STR0034) + ";"  ) //" 1=Nomeação em cargo efetivo"
	cOpcBox += ( OemToAnsi(STR0035) + ";"  ) //" 2=Nomeação exclusivamente em cargo em comissão"
	cOpcBox += ( OemToAnsi(STR0036) + ";"  ) //" 3=Incorporação (militar)"
	cOpcBox += ( OemToAnsi(STR0038) + ";"  ) //" 5=Redistribuição ou Reforma Administrativa"
	cOpcBox += ( OemToAnsi(STR0039) + ";"  ) //" 6=Diplomação"
	cOpcBox += ( OemToAnsi(STR0040) + ";"  ) //" 7=Contratação por tempo determinado"
	cOpcBox += ( OemToAnsi(STR0041) + ";"  ) //" 8=Remoção(em caso de alteração do órgão declarante)"
	cOpcBox += ( OemToAnsi(STR0042) + ";"  ) //" 9=Designação"
	cOpcBox += ( OemToAnsi(STR0045) + ";"  ) //"10=Mudança de CPF"
	cOpcBox += ( OemToAnsi(STR0061) + ";"  ) //"11=Estabilizados - Art. 19 do ADCT"
	cOpcBox += ( OemToAnsi(STR0043) + ";"  ) //"99=Outros não relacionados acima"

Return cOpcBox
