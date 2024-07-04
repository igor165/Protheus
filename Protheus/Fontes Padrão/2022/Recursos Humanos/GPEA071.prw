#INCLUDE "TOTVS.CH"  
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GPEA071.CH"

Static	_aCodFol	:= {}

/*/
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
����������������������������������������������������������������������������������������ı�
���Fun��o     � GPEA071                                                                  ��
����������������������������������������������������������������������������������������ı�
���Descri�ao  � Rotina de manuten��o da tabela de provisao rateada (RHT)                ���
����������������������������������������������������������������������������������������ı�
���Sintaxe    � GPEA071()                                                               ���
����������������������������������������������������������������������������������������ı�
���Uso        � GPEA071()                                                               ���
����������������������������������������������������������������������������������������ı�
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.                           ���
����������������������������������������������������������������������������������������ı�
���Programador  � Data     � FNC          �  Motivo da Alteracao                        ���
���C�cero Alves �08/09/2016�TVXPEZ     	  �Ajuste para verificar se existe o novo    	���
���             �          �              �grupo de perguntas e para posicionar no   	���
���             �          �              �registro correto na S052					 	���
����������������������������������������������������������������������������������������ı�
����������������������������������������������������������������������������������������ı�
�������������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������������
/*/

/*/{Protheus.doc} GPEA071()
Tela para manuten��o da tabela RHT (Provis�o Rateada)
@author Gabriel de Souza Almeida
@since 20/10/2015
@version P12
/*/
Function GPEA071()

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("SRA")
	oBrowse:SetDescription(STR0001) //"Funcion�rios"
	
	oBrowse:DisableDetails()
	oBrowse:Activate()

Return

/*/{Protheus.doc} ModelDef()
Regras de modelagem da grava��o
@author Gabriel de Souza Almeida
@since 20/10/2015
@version P12
@return objeto, oModel
/*/
Static Function ModelDef()

	Local oModel
	Local oStruSRT := FWFormModelStruct():New()
	Local oStruRHT := FWFormModelStruct():New()
	Local oStruSRA := FWFormModelStruct():New()
		
	oModel := MPFormModel():New( 'GPEA071', /*bPreValid*/, /*bTudoOK*/, /*bCommiM040*/, /*bCancel*/ )
		
	oStruSRA := FWFormStruct(1,"SRA", { |cCampo| fSRAStruct(cCampo) })
	
	oModel:AddFields('GPEA071_SRA' , /*cOwner*/, oStruSRA , /*Pre-Validacao*/,/*Pos-Validacao*/,/*Carga*/)
	oModel:GetModel( 'GPEA071_SRA' ):SetDescription( OemToAnsi(STR0004) ) // Provis�o Rateada
	oModel:GetModel( 'GPEA071_SRA' ):SetOnlyView ( .T. ) // Apenas Visualiza��o
	oModel:GetModel( 'GPEA071_SRA' ):SetOnlyQuery ( .T. ) //N�o grava dados
	
	oStruSRT := FWFormStruct(1,"SRT")
	
	// Adicionando novo campo na estrutura
	oStruSRT:AddField(;
	"Verba Convertida"    , ;              // [01] Titulo do campo
	"Verba Convertida"    , ;              // [02] ToolTip do campo
	"VERBACONV"           , ;              // [03] Id do Field
	"C"                   , ;              // [04] Tipo do campo
	4                     , ;              // [05] Tamanho do campo
	0                     , ;              // [06] Decimal do campo
	{|| .T.}              , ;              // [07] Code-block de valida��o do campo
	{|| .T.}              , ;              // [08] Code-block de valida��o When do campo
	{}                    , ;              // [09] Lista de valores permitido do campo
	.F.                   , ;              // [10] Indica se o campo tem preenchimento obrigat�rio
	{|| ""}               , ;              // [11] Code-block de inicializacao do campo
	Nil                   , ;              // [12] Indica se trata-se de um campo chave
	Nil                   , ;              // [13] Indica se o campo n�o pode receber valor em uma opera��o de update.
	.T.)                                   // [14] Indica se o campo � virtual
	
	oStruSRT:AddField(;
	"Tipo Prov"    , ;              // [01] Titulo do campo
	"Tipo Prov"    , ;              // [02] ToolTip do campo
	"TIPOPROVCONV"           , ;              // [03] Id do Field
	"C"                   , ;              // [04] Tipo do campo
	1                     , ;              // [05] Tamanho do campo
	0                     , ;              // [06] Decimal do campo
	{|| .T.}              , ;              // [07] Code-block de valida��o do campo
	{|| .T.}              , ;              // [08] Code-block de valida��o When do campo
	{}                    , ;              // [09] Lista de valores permitido do campo
	.F.                   , ;              // [10] Indica se o campo tem preenchimento obrigat�rio
	{|| ""}               , ;              // [11] Code-block de inicializacao do campo
	Nil                   , ;              // [12] Indica se trata-se de um campo chave
	Nil                   , ;              // [13] Indica se o campo n�o pode receber valor em uma opera��o de update.
	.T.)                                   // [14] Indica se o campo � virtual
	
	
	oModel:AddGrid("GPEA071_SRT","GPEA071_SRA" , oStruSRT,/*bLinePre*/, /* bLinePost*/, /*bPre*/,  /*bPost*/, {|oGrid| CargaSRT(oGrid) } ) 
	oModel:SetRelation( 'GPEA071_SRT', { { 'RT_FILIAL', 'RA_FILIAL' }, { 'RT_MAT', 'RA_MAT' }}, SRT->( IndexKey( 1 ) ) )
	oModel:GetModel( 'GPEA071_SRT' ):SetOnlyView ( .T. )
	oModel:GetModel( 'GPEA071_SRT' ):SetOnlyQuery ( .T. )
	
	oStruRHT := FWFormStruct(1,"RHT")
	
	oModel:AddGrid("GPEA071_RHT","GPEA071_SRT" , oStruRHT,/*bLinePre*/, /*bLinePos*/, /*bPre*/,  /*bPost*/, /*bLoad*/ ) 
	oModel:SetRelation( 'GPEA071_RHT', { { 'RHT_FILIAL', 'xFilial("RHT",RA_FILIAL)' }, { 'RHT_MAT', 'RA_MAT' }, { 'RHT_DTCALC', 'RT_DATACAL' }, { 'RHT_TPPROV', 'TIPOPROVCONV' }, { 'RHT_VERBA', 'VERBACONV'} }, RHT->( IndexKey( 1 ) ) )
	oModel:GetModel( 'GPEA071_RHT' ):SetOptional ( .T. ) // Retirando a obrigatoriedade de dados no grid da RHT
	oStruRHT:SetProperty( "*", MODEL_FIELD_OBRIGAT, .F. ) // Retirando a obrigatoriedade de preenchimento dos campos
	oModel:GetModel( 'GPEA071_RHT' ):SetNoInsertLine( .T. ) // N�o permite inser��o de linhas

Return oModel

/*/{Protheus.doc} ViewDef()
Regras de Interface
@author Gabriel de Souza Almeida
@since 20/10/2015
@version P12
@return objeto, oView
/*/
Static Function ViewDef()

	Local oModel := FWLoadModel( 'GPEA071' )
	Local oStruSRA := FWFormStruct(2,"SRA", { |cCampo| fSRAStruct(cCampo) })
	Local oStruSRT := FWFormStruct(2,"SRT")	
	Local oStruRHT := FWFormStruct(2,"RHT")
	Local oView
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	
	oView:AddField("VIEW_TMP0", oStruSRA, "GPEA071_SRA" )
	oStruSRA:SetNoFolder()
	
	oView:AddGrid( 'VIEW_TMP1', oStruSRT, 'GPEA071_SRT' )
	oView:AddGrid( 'VIEW_TMP2', oStruRHT, 'GPEA071_RHT' )
	
	oStruSRT:RemoveField( "RT_MAT" )
	oStruRHT:RemoveField( "RHT_MAT" )
	
	oStruRHT:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)// N�o permite altera��o nos campos
		
	oView:CreateHorizontalBox( 'CABECALHO', 10 )
	oView:CreateHorizontalBox( 'SUPERIOR', 45 )
	oView:CreateHorizontalBox( 'INFERIOR', 45 )
		
	oView:SetOwnerView( 'VIEW_TMP0', 'CABECALHO' )
	oView:SetOwnerView( 'VIEW_TMP1', 'SUPERIOR' )
	oView:SetOwnerView( 'VIEW_TMP2', 'INFERIOR' )
	
	oView:EnableTitleView( "GPEA071_SRT", OemToAnsi(STR0002) ) //"SRT - Provis�o"
	oView:EnableTitleView( "GPEA071_RHT", OemToAnsi(STR0003) ) //"RHT - Rateio da Provis�o"
	
	oView:SetCloseOnOk({ || .T. }) //Fecha tela apos commit

Return oView

/*/{Protheus.doc} fSRAStruct
Carregamento dos campos da estrutura
@author Gabriel de Souza Almeida
@since 20/10/2015
@version P12
@param cCampo, varchar, Campo a ser carregado
@return aRet
/*/
Static Function fSRAStruct( cCampo )
	Local lRet := .F.
	
	cCampo := AllTrim( cCampo )
	If cCampo $ 'RA_MAT*RA_NOME' 
		lRet := .T.
	EndIf
	
Return lRet

/*/{Protheus.doc} fIdOrgProv
Retorna o c�digo da verba correspondente na RHT
@author Gabriel de Souza Almeida
@since 20/10/2015
@version P12
@param cVerba, varchar, C�digo da Verba
@param cTpProv, varchar, Tipo de Provis�o
@return cRet
/*/
Function fIdOrgProv(cVerba,cTpProv)
Local cRet := ""
Local cIdPlr := SuperGetMv("MV_PLRVER",,"XXX;XX1;XX2;XX3;XX4")
Local aPdPlr		:= {}
Local _cPDPlr 	  	:= "XXX"
Local _cPdBxPLR 	:= "XX1"
Local _cPdMesPLR 	:= "XX2"
Local _cPDTrfPLR 	:= "XX3"
Local _cPDResPLR 	:= "XX4"
If !Empty(cIdPlr) .And. ";" $ cIdPlr
	aPdPlr := Separa(cIdPlr,";")
EndIf
//plr
If Len(aPdPlr) == 5
	 _cPDPlr 	  := aPdPlr[1]
	 _cPdBxPLR 	  := aPdPlr[2]
	 _cPdMesPLR 	  := aPdPlr[3]
	 _cPDTrfPLR 	  := aPdPlr[4]
	 _cPDResPLR 	  := aPdPlr[5]
EndIf
	
	If !Empty(_aCodFol) .Or. (Empty(_aCodFol) .And. Fp_CodFol(@_aCodFol,xFilial("SRV", SRT->RT_FILIAL)))
		If cTpProv $ "1*2"
			Do Case
				Case cVerba == _aCodFol[130,1]
					cRet := _aCodFol[960,1]
				Case cVerba == _aCodFol[254,1]
					cRet := _aCodFol[962,1]
				Case cVerba == _aCodFol[255,1]
					cRet := _aCodFol[961,1]
				Case cVerba == _aCodFol[131,1]
					cRet := _aCodFol[963,1]
				Case cVerba == _aCodFol[132,1]
					cRet := _aCodFol[964,1]
				Case cVerba == _aCodFol[416,1]
					cRet := _aCodFol[965,1]
				Case cVerba $ (_aCodFol[233,1]+"/"+_aCodFol[234,1]+"/"+_aCodFol[235,1]+"/"+_aCodFol[258,1]+"/"+_aCodFol[259,1]+"/"+_aCodFol[418,1]+"/"+;//Baixa Provisao Ferias
								_aCodFol[239,1]+"/"+_aCodFol[240,1]+"/"+_aCodFol[241,1]+"/"+_aCodFol[260,1]+"/"+_aCodFol[261,1]+"/"+_aCodFol[419,1]+"/"+;//Baixa Provisao Ferias Transferidos
								_aCodFol[262,1]+"/"+_aCodFol[263,1]+"/"+_aCodFol[264,1]+"/"+_aCodFol[265,1]+"/"+_aCodFol[266,1]+"/"+_aCodFol[420,1])//Baixa Provisao Ferias Transferidos
					cRet := cVerba
				OtherWise
					cRet := ""
			EndCase
		ElseIf cTpProv = "9"
			Do Case 
				Case cVerba == _cPDPlr
					cRet := _cPdMesPLR
				Case cVerba == _cPdBxPLR
					cRet := _cPdBxPLR
				OtherWise
					cRet := ""
			EndCase
		Else
			Do Case
				Case cVerba == _aCodFol[136,1]
					cRet := _aCodFol[966,1]
				Case cVerba == _aCodFol[267,1]
					cRet := _aCodFol[967,1]
				Case cVerba == _aCodFol[268,1]
					cRet := _aCodFol[968,1]
				Case cVerba == _aCodFol[137,1]
					cRet := _aCodFol[969,1]
				Case cVerba == _aCodFol[138,1]
					cRet := _aCodFol[970,1]
				Case cVerba == _aCodFol[421,1]
					cRet := _aCodFol[971,1]
				Case cVerba $ (_aCodFol[332,1]+"/"+_aCodFol[333,1]+"/"+_aCodFol[334,1]+"/"+_aCodFol[335,1]+"/"+_aCodFol[336,1]+"/"+_aCodFol[423,1]+"/"+;//Baixa Provisao 13o Salario
								_aCodFol[270,1]+"/"+_aCodFol[271,1]+"/"+_aCodFol[272,1]+"/"+_aCodFol[273,1]+"/"+_aCodFol[424,1]+"/"+;//Baixa Provisao 13o Salario Transferido
								_aCodFol[274,1]+"/"+_aCodFol[275,1]+"/"+_aCodFol[276,1]+"/"+_aCodFol[277,1]+"/"+_aCodFol[425,1])//Baixa Provisao 13o Salario Transferido
					cRet := cVerba
				OtherWise
					cRet := ""
			EndCase
		EndIf
	EndIf
	
Return cRet


/*/{Protheus.doc} CargaSRT
Carrega a SRT
@author Gabriel de Souza Almeida
@since 20/10/2015
@version P12
/*/
Static Function CargaSRT(oGrid)
	Local aRet		:= {}
	Local aArea		:= GetArea()
	Local aAux		:= {}
	Local cFil		:= xFilial("SRT",RA_FILIAL)
	Local cMat		:= RA_MAT
	Local dDataDe
	Local dDataAte
	Local aHeader 	:= oGrid:aHeader
	Local nX		:= 0
	Local nY		:= 0
	//--Verifica se o grupo de perguntas existe na base
	dbSelectarea("SX1")
	DbSetOrder(1)
	If ! dbSeek("GPEA071")
		Help(" ",1,"NOPERG")
		Return 
	EndIf
	
	Pergunte("GPEA071",.T.)
	
	dDataDe := MV_PAR01
	dDataAte := MV_PAR02
		
	DbSelectArea("SRT")
	SRT->(DbSetOrder(1))
	RHT->(DbSetOrder(1))
	
	If SRT->(MsSeek(cFil+cMat))
		While SRT->(!Eof()) .And. (SRT->(RT_FILIAL+RT_MAT) == cFil+cMat)
			If SRT->RT_DATACAL >= dDataDe .And. SRT->RT_DATACAL <= dDataAte
				aAux := {}
				Aadd(aRet,{SRT->(Recno())})
				nY ++
				For nX := 1 To Len(aHeader)
					If aHeader[nX,2] == "RT_DESCVER"
						Aadd(aAux,PosAlias( "SRV", SRT->RT_VERBA, xFilial( "SRV" ,SRT->RT_FILIAL), "RV_DESC", 1 ))
					ElseIf aHeader[nX,2] == "VERBACONV"
						Aadd(aAux,fIdOrgProv(SRT->RT_VERBA,SRT->RT_TIPPROV))
					ElseIf aHeader[nX,2] == "TIPOPROVCONV"
						Aadd(aAux,If(SRT->RT_TIPPROV=="9","4",SRT->RT_TIPPROV))	
					Else
						Aadd(aAux,&(aHeader[nX,2]))
					EndIf
				Next nX
				Aadd(aRet[nY],aAux)
			EndIf
			SRT->(DbSkip())
		EndDo
	Else
		MsgInfo(STR0005)
	EndIf
	
	RestArea( aArea )

Return aRet
