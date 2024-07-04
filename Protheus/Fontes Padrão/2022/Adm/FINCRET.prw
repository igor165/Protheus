#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEDITPANEL.CH'
#INCLUDE 'FINCRET.CH'

Static __cAlias 	:= ''	
Static __lEstrang 	:= .F.
Static __nDescFil 	:= 0
Static __oQrySE1	:= Nil
Static __oQrySE2	:= Nil

//-----------------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Consulta Rateio Multiplas Naturezas.
@author Mauricio Pequim Jr
@since  22/11/2017
@version 12
/*/	
//-----------------------------------------------------------------------------
Function FINCRET(cAlias)

	Local aEnableButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,Nil},{.T.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //"Confirmar"###"Fechar"
	Local cChaveTit := ""

	DEFAULT cAlias :=""

	If __nDescFil == 0
		__nDescFil := Len(FWFilialName(,cFilAnt))
	Endif

	If !(Empty(cAlias))	
		__cAlias := cAlias

		If __cAlias == 'SE1'
			cChaveTit := xFilial("SE1",SE1->E1_FILORIG) + "|" +;
							SE1->E1_PREFIXO	+ "|" +;
							SE1->E1_NUM		+ "|" +;
							SE1->E1_PARCELA	+ "|" +;
							SE1->E1_TIPO	+ "|" +;
							SE1->E1_CLIENTE	+ "|" +;
							SE1->E1_LOJA

			__lEstrang := (SE1->E1_MOEDA > 1)

		Else
			cChaveTit := xFilial("SE2",SE2->E2_FILORIG) + "|" +;
							SE2->E2_PREFIXO	+ "|" +;
							SE2->E2_NUM		+ "|" +;
							SE2->E2_PARCELA	+ "|" +;
							SE2->E2_TIPO	+ "|" +;
							SE2->E2_FORNECE	+ "|" +;
							SE2->E2_LOJA	

			__lEstrang := (SE2->E2_MOEDA > 1)

		EndIf

		FWExecView( STR0001 + " - " + STR0002 ,"FINCRET", MODEL_OPERATION_VIEW,/**/,/**/,/**/,,aEnableButtons )	//'Consulta de Impostos por titulo'###'Visualizar'
		
	Endif

	__cAlias := ''	
	__lEstrang := .F.

Return 

//-----------------------------------------------------------------------------
/*/{Protheus.doc}ViewDef
Interface.
@author Mauricio Pequim Jr	
@since  22/11/2017
@version 12
/*/	
//-----------------------------------------------------------------------------
Static Function ViewDef()

	Local oView	:= FWFormView():New()
	Local oModel:= FWLoadModel("FINCRET")
	Local oFK7	:= FWFormStruct(2,'FK7')
	Local oBXA	:= Nil
	Local oTIT	:= Nil
	Local oFK3E	:= FWFormStruct(2,'FK3')
	Local oFK3B := FWFormStruct(2,'FK3')
	Local oFK4E	:= FWFormStruct(2,'FK4')
	Local oFK4B := FWFormStruct(2,'FK4')
	Local cInfo := ""
	Local cDesCliFor := ""

	If __cAlias == 'SE1'
		oTIT := FWFormStruct(2,'SE1', { |x| ALLTRIM(x) $ 'E1_NUM, E1_PARCELA, E1_PREFIXO, E1_TIPO, E1_CLIENTE, E1_LOJA, E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_SALDO, E1_VALOR, E1_NATUREZ' } )
		oBXA := FWFormStruct(2,'FK1')
		cInfo := STR0003 	//'Contas a Receber' 
		oBXA:RemoveField('FK1_IDFK1')
		oBXA:RemoveField('FK1_RECPAG')
		oBXA:RemoveField('FK1_ORDREC')
		oBXA:RemoveField('FK1_ARCNAB')
		oBXA:RemoveField('FK1_CNABOC')
		oBXA:RemoveField('FK1_SERREC')
		oBXA:RemoveField('FK1_MULNAT')
		oBXA:RemoveField('FK1_AUTBCO')
		oBXA:RemoveField('FK1_NODIA')
		oBXA:RemoveField('FK1_LA')
		oBXA:RemoveField('FK1_IDDOC')
		oBXA:RemoveField('FK1_IDPROC')
		oBXA:RemoveField('FK1_IDCOMP')
		oBXA:RemoveField('FK1_VENCTO')
		oBXA:RemoveField('FK1_NATURE')
		oBXA:RemoveField('FK1_TPDOC')
		oBXA:RemoveField('FK1_MOTBX')
		oBXA:RemoveField('FK1_ORIGEM')
		oBXA:RemoveField('FK1_CCUSTO')
		oBXA:RemoveField('FK1_FILORI')

		If !__lEstrang
			oBXA:RemoveField('FK1_VLMOE2')
			oBXA:RemoveField('FK1_TXMOED')
		Endif

		oTIT:SetProperty( 'E1_VALOR'	, MVC_VIEW_ORDEM,	'06')
		oTIT:SetProperty( 'E1_CLIENTE'	, MVC_VIEW_ORDEM,	'07')
		oTIT:SetProperty( 'E1_LOJA'		, MVC_VIEW_ORDEM,	'08')
		oTIT:SetProperty( 'E1_NOMCLI'	, MVC_VIEW_ORDEM,	'09')
		oTIT:SetProperty( 'E1_EMISSAO'	, MVC_VIEW_ORDEM,	'10')
		oTIT:SetProperty( 'E1_VENCREA'	, MVC_VIEW_ORDEM,	'11')
		oTIT:SetProperty( 'E1_NATUREZ'	, MVC_VIEW_ORDEM,	'12')

		oBXA:SetProperty( 'FK1_DATA'	, MVC_VIEW_ORDEM,	'02')
		oBXA:SetProperty( 'FK1_MOEDA'	, MVC_VIEW_ORDEM,	'04')
		oBXA:SetProperty( 'FK1_VALOR'	, MVC_VIEW_ORDEM,	'05')

		If __lEstrang
			oBXA:SetProperty( 'FK1_VLMOE2'	, MVC_VIEW_ORDEM,	'06')
			oBXA:SetProperty( 'FK1_TXMOED'	, MVC_VIEW_ORDEM,	'07')
		Endif

	Else 
		oTIT  := FWFormStruct(2,'SE2', { |x| ALLTRIM(x) $ 'E2_NUM, E2_PARCELA, E2_PREFIXO, E2_TIPO, E2_FORNECE, E2_LOJA, E2_NOMFOR, E2_EMISSAO, E2_VENCREA, E2_SALDO, E2_VALOR, E2_NATUREZ' } )
		oBXA  := FWFormStruct(2,'FK2')
		cInfo := STR0004	//'Contas a Pagar' 
		oBXA:RemoveField('FK2_IDFK2')
		oBXA:RemoveField('FK2_RECPAG')
		oBXA:RemoveField('FK2_ORDREC')
		oBXA:RemoveField('FK2_ARCNAB')
		oBXA:RemoveField('FK2_CNABOC')
		oBXA:RemoveField('FK2_SERREC')
		oBXA:RemoveField('FK2_MULNAT')
		oBXA:RemoveField('FK2_AUTBCO')
		oBXA:RemoveField('FK2_NODIA')
		oBXA:RemoveField('FK2_LA')
		oBXA:RemoveField('FK2_IDDOC')
		oBXA:RemoveField('FK2_IDPROC')
		oBXA:RemoveField('FK2_IDCOMP')
		oBXA:RemoveField('FK2_VENCTO')
		oBXA:RemoveField('FK2_NATURE')
		oBXA:RemoveField('FK2_TPDOC')
		oBXA:RemoveField('FK2_MOTBX')
		oBXA:RemoveField('FK2_ORIGEM')
		oBXA:RemoveField('FK2_CCUSTO')
		oBXA:RemoveField('FK2_FILORI')

		If !__lEstrang
			oBXA:RemoveField('FK2_VLMOE2')
			oBXA:RemoveField('FK2_TXMOED')
		Endif

		oTIT:SetProperty( 'E2_VALOR'	, MVC_VIEW_ORDEM,	'06')
		oTIT:SetProperty( 'E2_FORNECE'	, MVC_VIEW_ORDEM,	'07')
		oTIT:SetProperty( 'E2_LOJA'		, MVC_VIEW_ORDEM,	'08')
		oTIT:SetProperty( 'E2_NOMFOR'	, MVC_VIEW_ORDEM,	'09')
		oTIT:SetProperty( 'E2_EMISSAO'	, MVC_VIEW_ORDEM,	'10')
		oTIT:SetProperty( 'E2_VENCREA'	, MVC_VIEW_ORDEM,	'11')
		oTIT:SetProperty( 'E2_NATUREZ'	, MVC_VIEW_ORDEM,	'12')

		oBXA:SetProperty( 'FK2_DATA'	, MVC_VIEW_ORDEM,	'02')
		oBXA:SetProperty( 'FK2_MOEDA'	, MVC_VIEW_ORDEM,	'03')
		oBXA:SetProperty( 'FK2_VALOR'	, MVC_VIEW_ORDEM,	'04')
		
		If __lEstrang
			oBXA:SetProperty( 'FK2_VLMOE2'	, MVC_VIEW_ORDEM,	'05')
			oBXA:SetProperty( 'FK2_TXMOED'	, MVC_VIEW_ORDEM,	'06')
		Endif

	Endif

	oView:CreateHorizontalBox( 'BOXTIT', 17 )
	oView:CreateHorizontalBox( 'INFERIOR', 83 )

	oView:CreateFolder("PRINCIPAL", "INFERIOR")
	oView:AddSheet( 'PRINCIPAL' , 'RET_EMIS' , STR0005 )  // "Emissao"
	oView:AddSheet( 'PRINCIPAL' , 'RET_BX'   , STR0006 )  // "Baixas"

	oTIT:AddField( "DESCNAT","13", STR0007, STR0007, {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição da Natureza"
	
	oBXA:AddField( "DESFILBX","01", 'Filial', 'Filial', {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição da Natureza"

	oFK3E:AddField("FK3_DESIMPE","07", STR0008 , STR0008 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição do Imposto"
	oFK3B:AddField("FK3_DESIMPB","07", STR0008 , STR0008 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição do Imposto"
	oFK4E:AddField("FK4_DESIMPE","07", STR0008 , STR0008 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição do Imposto"
	oFK4B:AddField("FK4_DESIMPB","07", STR0008 , STR0008 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Descrição do Imposto"

	oFK3E:AddField("FK3_SITUACE","07", STR0009 , STR0009 , {}, "G", "",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Situação"
	oFK3B:AddField("FK3_SITUACB","07", STR0009 , STR0009 , {}, "G", "",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Situação"
	oFK4E:AddField("FK4_SITUACE","07", STR0009 , STR0009 , {}, "G", "",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Situação"
	oFK4B:AddField("FK4_SITUACB","07", STR0009 , STR0009 , {}, "G", "",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Situação"

	cDesCliFor := If(__cAlias == 'SE1',STR0019, STR0020)	//"Nome Cliente"###"Nome Fornecedor"

	oFK3E:AddField("FK3_DESCLFE","07", cDesCliFor , cDesCliFor , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Nome Cliente/Fornecedor"
	oFK3B:AddField("FK3_DESCLFB","07", cDesCliFor , cDesCliFor , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Nome Cliente/Fornecedor"
	oFK4E:AddField("FK4_DESCLFE","07", cDesCliFor , cDesCliFor , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Nome Cliente/Fornecedor"
	oFK4B:AddField("FK4_DESCLFB","07", cDesCliFor , cDesCliFor , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Nome Cliente/Fornecedor"

	oFK3E:AddField("FK3_DESFILE","07", STR0021 , STR0021 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Filial"
	oFK3B:AddField("FK3_DESFILB","07", STR0021 , STR0021 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Filial"
	oFK4E:AddField("FK4_DESFILE","07", STR0021 , STR0021 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Filial"
	oFK4B:AddField("FK4_DESFILB","07", STR0021 , STR0021 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Filial"

	oFK4E:AddField("FK4_CODRETE","07", STR0022 , STR0022 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//"Cód. Retenção"
	oFK4B:AddField("FK4_CODRETB","07", STR0022 , STR0022 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//Cód. Retenção"
	oFK4E:AddField("FK4_TITIMPE","20", STR0023 , STR0023 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//'Título de Imposto Gerado'
	oFK4B:AddField("FK4_TITIMPB","20", STR0023 , STR0023 , {}, "G", "@!",/*bPictVar*/,/*cLookUp*/,/*lCanChange*/,"1"/*cFolder*/)//'Título de Imposto Gerado'

	oFK3E:RemoveField('FK3_IDFK3')
	oFK3E:RemoveField('FK3_RECPAG')
	oFK3E:RemoveField('FK3_IDORIG')
	oFK3E:RemoveField('FK3_TABORI') 
	oFK3E:RemoveField('FK3_IDRET')
	oFK3E:RemoveField('FK3_VLMOE2') 
	oFK3E:RemoveField('FK3_STATUS')
	oFK3E:RemoveField('FK3_NATURE')
	oFK3E:RemoveField('FK3_ORIGEM')
	oFK3E:RemoveField('FK3_FILORI')

	oFK3B:RemoveField('FK3_IDFK3')
	oFK3B:RemoveField('FK3_RECPAG')
	oFK3B:RemoveField('FK3_IDORIG')
	oFK3B:RemoveField('FK3_TABORI')
	oFK3B:RemoveField('FK3_IDRET')
	oFK3B:RemoveField('FK3_VLMOE2')
	oFK3B:RemoveField('FK3_STATUS')
	oFK3B:RemoveField('FK3_NATURE')
	oFK3B:RemoveField('FK3_ORIGEM')	
	oFK3B:RemoveField('FK3_FILORI')	

	oFK4E:RemoveField('FK4_IDFK4')
	oFK4E:RemoveField('FK4_RECPAG')
	oFK4E:RemoveField('FK4_IDORIG')
	oFK4E:RemoveField('FK4_VLMOE2')
	oFK4E:RemoveField('FK4_STATUS')
	oFK4E:RemoveField('FK4_NATURE')
	oFK4E:RemoveField('FK4_ORIGEM')
	oFK4E:RemoveField('FK4_FILORI')	

	oFK4B:RemoveField('FK4_IDFK4')
	oFK4B:RemoveField('FK4_RECPAG')
	oFK4B:RemoveField('FK4_IDORIG')
	oFK4B:RemoveField('FK4_VLMOE2')
	oFK4B:RemoveField('FK4_STATUS') 
	oFK4B:RemoveField('FK4_NATURE')
	oFK4B:RemoveField('FK4_ORIGEM')	
	oFK4B:RemoveField('FK4_FILORI')	

	oFK3E:SetProperty( 'FK3_DESFILE', MVC_VIEW_ORDEM,	'01')
	oFK3E:SetProperty( 'FK3_DATA'	, MVC_VIEW_ORDEM,	'02')
	oFK3E:SetProperty( 'FK3_CODFKM'	, MVC_VIEW_ORDEM,	'03')
	oFK3E:SetProperty( 'FK3_IMPOS'	, MVC_VIEW_ORDEM,	'04')
	oFK3E:SetProperty( 'FK3_DESIMPE', MVC_VIEW_ORDEM,	'05')
	oFK3E:SetProperty( 'FK3_BASIMP'	, MVC_VIEW_ORDEM,	'06')
	oFK3E:SetProperty( 'FK3_VALOR'	, MVC_VIEW_ORDEM,	'07')
	oFK3E:SetProperty( 'FK3_MOEDA'	, MVC_VIEW_ORDEM,	'08')
	oFK3E:SetProperty( 'FK3_SITUACE', MVC_VIEW_ORDEM,	'09')
	oFK3E:SetProperty( 'FK3_CLIFOR'	, MVC_VIEW_ORDEM,	'10')
	oFK3E:SetProperty( 'FK3_LOJA'	, MVC_VIEW_ORDEM,	'11')
	oFK3E:SetProperty( 'FK3_DESCLFE', MVC_VIEW_ORDEM,	'12')
	oFK3E:SetProperty( 'FK3_CGC'	, MVC_VIEW_ORDEM,	'13')
	oFK3E:SetProperty( 'FK3_RAICGC'	, MVC_VIEW_ORDEM,	'14')

	oFK3B:SetProperty( 'FK3_DESFILB', MVC_VIEW_ORDEM,	'01')
	oFK3B:SetProperty( 'FK3_DATA'	, MVC_VIEW_ORDEM,	'02')
	oFK3B:SetProperty( 'FK3_CODFKM'	, MVC_VIEW_ORDEM,	'03')
	oFK3B:SetProperty( 'FK3_IMPOS'	, MVC_VIEW_ORDEM,	'04')
	oFK3B:SetProperty( 'FK3_DESIMPB', MVC_VIEW_ORDEM,	'05')
	oFK3B:SetProperty( 'FK3_BASIMP'	, MVC_VIEW_ORDEM,	'06')
	oFK3B:SetProperty( 'FK3_VALOR'	, MVC_VIEW_ORDEM,	'07')
	oFK3B:SetProperty( 'FK3_MOEDA'	, MVC_VIEW_ORDEM,	'08')
	oFK3B:SetProperty( 'FK3_SITUACB', MVC_VIEW_ORDEM,	'09')
	oFK3B:SetProperty( 'FK3_CLIFOR'	, MVC_VIEW_ORDEM,	'10')
	oFK3B:SetProperty( 'FK3_LOJA'	, MVC_VIEW_ORDEM,	'11')
	oFK3B:SetProperty( 'FK3_DESCLFB', MVC_VIEW_ORDEM,	'12')
	oFK3B:SetProperty( 'FK3_CGC'	, MVC_VIEW_ORDEM,	'13')
	oFK3B:SetProperty( 'FK3_RAICGC'	, MVC_VIEW_ORDEM,	'14')

	oFK4E:SetProperty( 'FK4_DESFILE', MVC_VIEW_ORDEM,	'01')
	oFK4E:SetProperty( 'FK4_DATA'	, MVC_VIEW_ORDEM,	'02')
	oFK4E:SetProperty( 'FK4_CODFKM'	, MVC_VIEW_ORDEM,	'03')
	oFK4E:SetProperty( 'FK4_IMPOS'	, MVC_VIEW_ORDEM,	'04')
	oFK4E:SetProperty( 'FK4_DESIMPE', MVC_VIEW_ORDEM,	'05')
	oFK4E:SetProperty( 'FK4_BASIMP'	, MVC_VIEW_ORDEM,	'06')
	oFK4E:SetProperty( 'FK4_VALOR'	, MVC_VIEW_ORDEM,	'07')
	oFK4E:SetProperty( 'FK4_MOEDA'	, MVC_VIEW_ORDEM,	'08')
	oFK4E:SetProperty( 'FK4_SITUACE', MVC_VIEW_ORDEM,	'09')
	oFK4E:SetProperty( 'FK4_CLIFOR'	, MVC_VIEW_ORDEM,	'10')
	oFK4E:SetProperty( 'FK4_LOJA'	, MVC_VIEW_ORDEM,	'11')
	oFK4E:SetProperty( 'FK4_DESCLFE', MVC_VIEW_ORDEM,	'12')
	If cPaisLoc<>"RUS"
		oFK4E:SetProperty( 'FK4_CGC'	, MVC_VIEW_ORDEM,	'13')
	EndIf
	oFK4E:SetProperty( 'FK4_RAICGC'	, MVC_VIEW_ORDEM,	'14')

	oFK4B:SetProperty( 'FK4_DESFILB', MVC_VIEW_ORDEM,	'01')
	oFK4B:SetProperty( 'FK4_DATA'	, MVC_VIEW_ORDEM,	'02')
	oFK4B:SetProperty( 'FK4_CODFKM'	, MVC_VIEW_ORDEM,	'03')
	oFK4B:SetProperty( 'FK4_IMPOS'	, MVC_VIEW_ORDEM,	'04')
	oFK4B:SetProperty( 'FK4_DESIMPB', MVC_VIEW_ORDEM,	'05')
	oFK4B:SetProperty( 'FK4_BASIMP'	, MVC_VIEW_ORDEM,	'06')
	oFK4B:SetProperty( 'FK4_VALOR'	, MVC_VIEW_ORDEM,	'07')
	oFK4B:SetProperty( 'FK4_MOEDA'	, MVC_VIEW_ORDEM,	'08')
	oFK4B:SetProperty( 'FK4_SITUACB', MVC_VIEW_ORDEM,	'09')
	oFK4B:SetProperty( 'FK4_CLIFOR'	, MVC_VIEW_ORDEM,	'10')
	oFK4B:SetProperty( 'FK4_LOJA'	, MVC_VIEW_ORDEM,	'11')
	oFK4B:SetProperty( 'FK4_DESCLFB', MVC_VIEW_ORDEM,	'12')
	If cPaisLoc<>"RUS"
		oFK4B:SetProperty('FK4_CGC', MVC_VIEW_ORDEM, '13')
	EndIf
	oFK4B:SetProperty( 'FK4_RAICGC'	, MVC_VIEW_ORDEM,	'14')
	
	oTIT:SetNoFolder()

	oFK3E:SetProperty('*' ,MVC_VIEW_CANCHANGE ,.F. )
	oFK4E:SetProperty('*' ,MVC_VIEW_CANCHANGE ,.F. )	
	//
	oView:SetModel( oModel )			
	oView:AddField("VIEWTIT" ,oTIT , "TITMASTER" )
	oView:AddGrid("VIEWBXA"  ,oBXA , "BXADETAIL" )
	oView:AddGrid("VIEWFK3E" ,oFK3E, "FK3EDETAIL")
	oView:AddGrid("VIEWFK3B" ,oFK3B, "FK3BDETAIL")
	oView:AddGrid("VIEWFK4E" ,oFK4E, "FK4EDETAIL")	
	oView:AddGrid("VIEWFK4B" ,oFK4B, "FK4BDETAIL")
	//
	oView:CreateHorizontalBox( 'BOXFK3E', 50,,, 'PRINCIPAL', 'RET_EMIS' )
	oView:CreateHorizontalBox( 'BOXFK4E', 50,,, 'PRINCIPAL', 'RET_EMIS' )

	oView:CreateHorizontalBox( 'BOXBXA' , 34,,, 'PRINCIPAL', 'RET_BX' )
	oView:CreateHorizontalBox( 'BOXFK3B', 33,,, 'PRINCIPAL', 'RET_BX' )
	oView:CreateHorizontalBox( 'BOXFK4B', 33,,, 'PRINCIPAL', 'RET_BX' )	
	//
	oView:SetOwnerView('VIEWTIT' , 'BOXTIT' )
	oView:SetOwnerView('VIEWBXA' , 'BOXBXA' ) 
	oView:SetOwnerView('VIEWFK3E', 'BOXFK3E')
	oView:SetOwnerView('VIEWFK3B', 'BOXFK3B')
	oView:SetOwnerView('VIEWFK4E', 'BOXFK4E')	
	oView:SetOwnerView('VIEWFK4B', 'BOXFK4B')
	//
	oView:EnableTitleView('VIEWTIT'  , cInfo )
	oView:EnableTitleView('VIEWBXA'  , STR0011 )	//'Informacoes de Baixas'
	oView:EnableTitleView('VIEWFK3E' , STR0012 )	//'Impostos Calculados - Emissão'
	oView:EnableTitleView('VIEWFK3B' , STR0013 )	//'Impostos Calculados - Baixa'
	oView:EnableTitleView('VIEWFK4E' , STR0014 )	//'Impostos Retidos - Emissão'
	oView:EnableTitleView('VIEWFK4B' , STR0015 )	//'Impostos Retidos - Baixa'

	oView:SetOnlyView( 'VIEWTIT' )

Return oView

//-----------------------------------------------------------------------------
/*/{Protheus.doc}ModelDef
Modelo de dados.
@author Mauricio Pequim Jr	
@since  22/11/2017
@version 12
/*/	
//-----------------------------------------------------------------------------
Static Function ModelDef()

	Local oModel	:= MPFormModel():New('FINCRET',/*Pre*/,/*Pos*/,/*Commit*/)
	Local oTIT		:= 	NIL
	Local oFK3E 	:= FWFormStruct(1, 'FK3')
	Local oFK3B		:= FWFormStruct(1, 'FK3')
	Local oFK4E 	:= FWFormStruct(1, 'FK4')
	Local oFK4B		:= FWFormStruct(1, 'FK4')
	Local oFK7		:= FWFormStruct(1, 'FK7')
	Local oBXA		:= NIL
	Local aAuxFK7	:= {}
	Local aAuxBXA	:= {}
	Local aAuxFK3E	:= {}
	Local aAuxFK3B	:= {}
	Local aAuxFK4E	:= {}
	Local aAuxFK4B	:= {}
	Local nTamDNat 	:= TamSx3("ED_DESCRIC")[1]
	Local nTamDFKK 	:= TamSx3("FKK_DESCR")[1]
	Local bLoadBXA	:= {|oGridModel| LoadBXA(oGridModel)}
	Local nTamTit 	:= TamSX3("FK7_CHAVE")[1]
	Local nTamDCli 	:= TamSx3("E1_NOMCLI")[1]
	Local nTamCodRt := TamSx3("FKK_CODRET")[1]
	Local cDesCliFor := If(__cAlias == 'SE1',STR0019, STR0020)	//"Nome Cliente"###"Nome Fornecedor"
	Local nIndFK3       := Iif(FWSIXUtil():ExistIndex('FK3' , '3'), 3,1)

	IF __cAlias == 'SE1'
		oTIT := FWFormStruct(1, 'SE1')
		oBXA := FWFormStruct(1, 'FK1')
	Else
		oTIT := FWFormStruct(1, 'SE2')
		oBXA := FWFormStruct(1, 'FK2')
	EndIf	

	oTIT:AddField(			;
	STR0007					, ;	// [01] Titulo do campo		//"Descrição da Natureza"
	STR0007					, ;	// [02] ToolTip do campo 	//"Descrição da Natureza"
	"DESCNAT"				, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDNat				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('SED')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual


	//----------------------------------------------------------------------------------------------------------
	//Grid Impostos Calculados - Emissão
	oBXA:AddField(			;
	STR0021					, ;	// [01] Titulo do campo		//"Filial"
	STR0021					, ;	// [02] ToolTip do campo 	//"Filial"
	"DESFILBX"				, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	__nDescFil				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK1F')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual



	//----------------------------------------------------------------------------------------------------------
	//Grid Impostos Calculados - Emissão
	oFK3E:AddField(			;
	STR0021					, ;	// [01] Titulo do campo		//"Filial"
	STR0021					, ;	// [02] ToolTip do campo 	//"Filial"
	"FK3_DESFILE"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	__nDescFil				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK3F')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual

	oFK3E:AddField(			;
	STR0008					, ;	// [01] Titulo do campo		//"Descrição do Imposto"
	STR0008					, ;	// [02] ToolTip do campo 	//"Descrição do Imposto"
	"FK3_DESIMPE"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDFKK				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK3')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual

	oFK3E:AddField(			;
	STR0009					, ;	// [01] Titulo do campo		//"Situação"
	STR0009					, ;	// [02] ToolTip do campo 	//"Situação"
	"FK3_SITUACE"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	15						, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK3S')") ,,,;// [11] Inicializador Padrão do campo
	.T.)	

	oFK3E:AddField(			;
	cDesCliFor				, ;	// [01] Titulo do campo		//"Nome Cliente/Fornecedor"
	cDesCliFor				, ;	// [02] ToolTip do campo 	//"Nome Cliente/Fornecedor"
	"FK3_DESCLFE"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDCli				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK3C')") ,,,;// [11] Inicializador Padrão do campo
	.T.)	


	//----------------------------------------------------------------------------------------------------------
	//Grid de Impostos Calculados - Baixa
	oFK3B:AddField(			;
	STR0021					, ;	// [01] Titulo do campo		//"Filial"
	STR0021					, ;	// [02] ToolTip do campo 	//"Filial"
	"FK3_DESFILB"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	__nDescFil				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK3F')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual

	oFK3B:AddField(			;
	STR0008					, ;	// [01] Titulo do campo		//"Descrição do Imposto"
	STR0008					, ;	// [02] ToolTip do campo 	//"Descrição do Imposto"
	"FK3_DESIMPB"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDFKK				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK3')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual

	oFK3B:AddField(			;
	STR0009					, ;	// [01] Titulo do campo		//"Situação"
	STR0009					, ;	// [02] ToolTip do campo 	//"Situação"
	"FK3_SITUACB"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	15						, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK3S')") ,,,;// [11] Inicializador Padrão do campo
	.T.)	

	oFK3B:AddField(			;
	cDesCliFor				, ;	// [01] Titulo do campo		//"Nome Cliente/Fornecedor"
	cDesCliFor				, ;	// [02] ToolTip do campo 	//"Nome Cliente/Fornecedor"
	"FK3_DESCLFB"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDCli				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK3C')") ,,,;// [11] Inicializador Padrão do campo
	.T.)	


	//----------------------------------------------------------------------------------------------------------
	//Grid de Impostos Retidos - Emissão
	oFK4E:AddField(			;
	STR0021					, ;	// [01] Titulo do campo		//"Filial"
	STR0021					, ;	// [02] ToolTip do campo 	//"Filial"
	"FK4_DESFILE"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	__nDescFil				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK4F')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual

	oFK4E:AddField(			;
	STR0008					, ;	// [01] Titulo do campo		//"Descrição do Imposto"
	STR0008					, ;	// [02] ToolTip do campo 	//"Descrição do Imposto"
	"FK4_DESIMPE"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDFKK				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK4')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual

	oFK4E:AddField(			;
	STR0009					, ;	// [01] Titulo do campo		//"Situação"
	STR0009					, ;	// [02] ToolTip do campo 	//"Situação"
	"FK4_SITUACE"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	15						, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK4S')") ,,,;// [11] Inicializador Padrão do campo
	.T.)	

	oFK4E:AddField(			;
	cDesCliFor				, ;	// [01] Titulo do campo		//"Nome Cliente/Fornecedor"
	cDesCliFor				, ;	// [02] ToolTip do campo 	//"Nome Cliente/Fornecedor"
	"FK4_DESCLFE"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDCli				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK4C')") ,,,;// [11] Inicializador Padrão do campo
	.T.)	

	oFK4E:AddField(			;
	STR0022					, ;	// [01] Titulo do campo		//"Cód. Retenção"
	STR0022					, ;	// [02] ToolTip do campo 	//"Cód. Retenção"
	"FK4_CODRETE"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamCodRt				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK4CR')") ,,,;// [11] Inicializador Padrão do campo
	.T.)

	oFK4E:AddField(			;
	STR0023					, ;	// [01] Titulo do campo		//'Título de Imposto Gerado'
	STR0023					, ;	// [02] ToolTip do campo 	//'Título de Imposto Gerado'
	"FK4_TITIMPE"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamTit					, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK4T')") ,,,;// [11] Inicializador Padrão do campo
	.T.)	

	//----------------------------------------------------------------------------------------------------------
	//Grid de Impostos Retidos - Baixa
	oFK4B:AddField(			;
	STR0021					, ;	// [01] Titulo do campo		//"Filial"
	STR0021					, ;	// [02] ToolTip do campo 	//"Filial"
	"FK4_DESFILB"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	__nDescFil				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK4F')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual

	oFK4B:AddField(			;
	STR0008					, ;	// [01] Titulo do campo		//"Descrição do Imposto"
	STR0008					, ;	// [02] ToolTip do campo 	//"Descrição do Imposto"
	"FK4_DESIMPB"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDFKK				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK4')") ,,,;// [11] Inicializador Padrão do campo
	.T.)							//[14] Virtual

	oFK4B:AddField(			;
	STR0009					, ;	// [01] Titulo do campo		//"Situação"
	STR0009					, ;	// [02] ToolTip do campo 	//"Situação"
	"FK4_SITUACB"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	15						, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK4S')") ,,,;// [11] Inicializador Padrão do campo
	.T.)	

	oFK4B:AddField(			;
	cDesCliFor				, ;	// [01] Titulo do campo		//"Nome Cliente/Fornecedor"
	cDesCliFor				, ;	// [02] ToolTip do campo 	//"Nome Cliente/Fornecedor"
	"FK4_DESCLFB"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDCli				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK4C')") ,,,;// [11] Inicializador Padrão do campo
	.T.)	

	oFK4B:AddField(			;
	STR0022					, ;	// [01] Titulo do campo		//"Cód. Retenção"
	STR0022					, ;	// [02] ToolTip do campo 	//"Cód. Retenção"
	"FK4_CODRETB"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamDCli				, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK4CR')") ,,,;// [11] Inicializador Padrão do campo
	.T.)

	oFK4B:AddField(			;
	STR0023					, ;	// [01] Titulo do campo		//'Título de Imposto Gerado'
	STR0023					, ;	// [02] ToolTip do campo 	//'Título de Imposto Gerado'
	"FK4_TITIMPB"			, ;	// [03] Id do Field
	"C"						, ;	// [04] Tipo do campo
	nTamTit					, ;	// [05] Tamanho do campo
	0						, ;	// [06] Decimal do campo
	{ || .T. }				, ;	// [07] Code-block de validação do campo
	{ || .F. }				, ;	// [08] Code-block de validação When do campo
							, ;	// [09] Lista de valores permitido do campo
	.F.						, ;	// [10] Indica se o campo tem preenchimento obrigatório
	FWBuildFeature( STRUCT_FEATURE_INIPAD, "FINIniDsc('FK4T')") ,,,;// [11] Inicializador Padrão do campo
	.T.)	


	oTIT:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)
	oBXA:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)
	oFK7:SetProperty('*',MODEL_FIELD_OBRIGAT, .F.)

	oModel:AddFields("TITMASTER",/*cOwner*/	, oTIT)
	// Emissao
	oModel:AddGrid("FK7DETAIL"  ,"TITMASTER"  , oFK7)
	oModel:AddGrid("FK3EDETAIL" ,"FK7DETAIL"  , oFK3E)
	oModel:AddGrid("FK4EDETAIL" ,"FK3EDETAIL" , oFK4E)
	// Baixa
	oModel:AddGrid("BXADETAIL"  ,"FK7DETAIL", oBXA, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, bLoadBXA)
	oModel:AddGrid("FK3BDETAIL" ,"BXADETAIL", oFK3B)
	oModel:AddGrid("FK4BDETAIL" ,"FK3BDETAIL", oFK4B)

	//--------------------------------------------------------------------------
	// Emissao
	//--------------------------------------------------------------------------
	aAdd( aAuxFK7, {"FK7_FILIAL","xFilial('FK7')"} )
	IF __cAlias == 'SE1'
		oModel:SetPrimaryKey({'E1_FILIAL','E1_PREFIXO','E1_NUM','E1_PARCELA','E1_TIPO','E1_CLIENTE','E1_LOJA'})
		aAdd( aAuxFK7, {"FK7_ALIAS","'SE1'"})
		aAdd( aAuxFK7, {"FK7_CHAVE","SE1->E1_FILIAL + '|' + SE1->E1_PREFIXO + '|' + SE1->E1_NUM + '|' + SE1->E1_PARCELA + '|' + SE1->E1_TIPO + '|' + SE1->E1_CLIENTE + '|' + SE1->E1_LOJA"})
	Else
		oModel:SetPrimaryKey({'E2_FILIAL','E2_PREFIXO','E2_NUM','E2_PARCELA','E2_TIPO','E2_FORNECE','E2_LOJA'})
		aAdd( aAuxFK7, {"FK7_ALIAS","'SE2'"})
		aAdd( aAuxFK7, {"FK7_CHAVE","SE2->E2_FILIAL + '|' + SE2->E2_PREFIXO + '|' + SE2->E2_NUM + '|' + SE2->E2_PARCELA + '|' + SE2->E2_TIPO + '|' + SE2->E2_FORNECE + '|' + SE2->E2_LOJA"})
	Endif
	oModel:SetRelation("FK7DETAIL", aAuxFK7 , FK7->(IndexKey(2) ) ) 
	//
	aAdd(aAuxFK3E, {"FK3_FILIAL", "xFilial('FK3')"})
	aAdd(aAuxFK3E, {"FK3_IDORIG",  "FK7_IDDOC"})
	oModel:SetRelation("FK3EDETAIL", aAuxFK3E , FK3->(IndexKey(nIndFK3) ) ) 
	//
	aAdd(aAuxFK4E, {"FK4_FILIAL" , "xFilial('FK4')"})
	aAdd(aAuxFK4E, {"FK4_IDFK4"  , "FK3EDETAIL.FK3_IDRET"})
	oModel:SetRelation("FK4EDETAIL", aAuxFK4E , FK4->(IndexKey(1) ) ) 
	
	//--------------------------------------------------------------------------
	// Baixa
	//--------------------------------------------------------------------------	
	IF __cAlias == 'SE1'
		aAdd( aAuxBXA, {"FK1_FILIAL","xFilial('FK1')"} )
		aAdd( aAuxBXA, {"FK1_IDDOC","FK7_IDDOC"})
		oModel:SetRelation("BXADETAIL", aAuxBXA , FK1->(IndexKey(2) ) )
		//
		aAdd(aAuxFK3B, {"FK3_FILIAL" , "xFilial('FK3')"})
		aAdd(aAuxFK3B, {"FK3_IDORIG", "FK1_IDFK1"})
		oModel:SetRelation("FK3BDETAIL", aAuxFK3B , FK3->(IndexKey(nIndFK3) ) ) 
		//
		aAdd(aAuxFK4B, {"FK4_FILIAL" , "xFilial('FK4')"})
		aAdd(aAuxFK4B, {"FK4_IDFK4"  , "FK3BDETAIL.FK3_IDRET"})
		oModel:SetRelation("FK4BDETAIL", aAuxFK4B , FK4->(IndexKey(1) ) ) 
	Else
		aAdd( aAuxBXA, {"FK2_FILIAL","xFilial('FK2')"} )
		aAdd( aAuxBXA, {"FK2_IDDOC","FK7_IDDOC"})
		oModel:SetRelation("BXADETAIL", aAuxBXA , FK2->(IndexKey(2) ) )
		//
		aAdd(aAuxFK3B, {"FK3_FILIAL" , "xFilial('FK3')"})
		aAdd(aAuxFK3B, {"FK3_IDORIG", "FK2_IDFK2"})
		oModel:SetRelation("FK3BDETAIL", aAuxFK3B , FK3->(IndexKey(nIndFK3) ) ) 
		//
		aAdd(aAuxFK4B, {"FK4_FILIAL" , "xFilial('FK4')"})
		aAdd(aAuxFK4B, {"FK4_IDFK4"  , "FK3BDETAIL.FK3_IDRET"})
		oModel:SetRelation("FK4BDETAIL", aAuxFK4B , FK4->(IndexKey(1) ) ) 
	EndIf

	//
	oModel:GetModel( 'FK7DETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'BXADETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'FK3EDETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'FK3BDETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'FK4EDETAIL' ):SetOptional( .T. )
	oModel:GetModel( 'FK4BDETAIL' ):SetOptional( .T. )

	oModel:GetModel( 'FK7DETAIL' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'BXADETAIL' ):SetOnlyQuery( .T. )
	oModel:GetModel( 'TITMASTER' ):SetOnlyQuery( .T. )
	//
	//Se o model for chamado via adapter de baixas.
	oModel:GetModel( 'BXADETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'FK3EDETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'FK3BDETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'FK4EDETAIL' ):SetNoInsertLine(.T.)
	oModel:GetModel( 'FK4BDETAIL' ):SetNoInsertLine(.T.)

	oModel:GetModel( "BXADETAIL" ):SetNoDeleteLine(.T.)
	oModel:GetModel( "FK3EDETAIL" ):SetNoDeleteLine(.T.)
	oModel:GetModel( "FK3BDETAIL" ):SetNoDeleteLine(.T.)
	oModel:GetModel( "FK4EDETAIL" ):SetNoDeleteLine(.T.)
	oModel:GetModel( "FK4BDETAIL" ):SetNoDeleteLine(.T.)

	// Para dado diferente
	oModel:GetModel( 'FK3EDETAIL' ):SetLoadFilter( { { 'FK3_CODFKM', "'    '", MVC_LOADFILTER_NOT_EQUAL } } )
	oModel:GetModel( 'FK3BDETAIL' ):SetLoadFilter( { { 'FK3_CODFKM', "'    '", MVC_LOADFILTER_NOT_EQUAL } } )
	oModel:GetModel( 'FK4EDETAIL' ):SetLoadFilter( { { 'FK4_CODFKM', "'    '", MVC_LOADFILTER_NOT_EQUAL } } )
	oModel:GetModel( 'FK4BDETAIL' ):SetLoadFilter( { { 'FK4_CODFKM', "'    '", MVC_LOADFILTER_NOT_EQUAL } } )

Return oModel


//-------------------------------------------------------------------
/*/ {Protheus.doc} LoadBXA
Funcao de carregamento das informacoes de baixas

@param oGridModel - Model que chamou o bLoad

@author Mauricio Pequim Jr
@since 22/11/2017

@return Array com informacoes para composicao do grid
/*/
//-------------------------------------------------------------------
Static Function LoadBXA(oGridModel As Object) As Array

	Local aBaixas	As Array
	Local aBXAStru	As Array
	Local aCampos	As Array
	Local aAux 		As Array
	Local cAlias	As Character
	Local cSelect	As Character
	Local cQry		As Character
	Local cKeyTit	As Character
	Local nX		As Numeric
	Local oTmp		As Object
	Local cIdDoc	As Character

	aBaixas		:= {}
	aBXAStru	:= {}
	aCampos		:= {}
	aAux		:= {}
	cAlias		:= CriaTrab(,.F.)
	cSelect		:= ""
	cQry		:= ""
	cKeyTit		:= ""
	nX			:= 0
	oTmp		:= Nil
	cIdDoc		:= ""

	If __cAlias == 'SE1'
		aBXAStru := FK1->(dbStruct())
		cKeyTit  := xFilial("SE1",SE1->E1_FILORIG) + "|" +;
					SE1->E1_PREFIXO	+ "|" +;
					SE1->E1_NUM		+ "|" +;
					SE1->E1_PARCELA	+ "|" +;
					SE1->E1_TIPO	+ "|" +;
					SE1->E1_CLIENTE	+ "|" +;
					SE1->E1_LOJA
	Else
		aBXAStru := FK2->(dbStruct())
		cKeyTit  := xFilial("SE2",SE2->E2_FILORIG) + "|" +;
					SE2->E2_PREFIXO	+ "|" +;
					SE2->E2_NUM		+ "|" +;
					SE2->E2_PARCELA	+ "|" +;
					SE2->E2_TIPO	+ "|" +;
					SE2->E2_FORNECE	+ "|" +;
					SE2->E2_LOJA
	Endif

	cIdDoc := FINBuscaFK7(cKeyTit, __cAlias)

	// Prepara estrutura de campos para temporaria (aCampos)
	For nX := 1 to Len(aBXAStru) //   Tipo,			  Tamanho,		  Decimal
		aAdd(aCampos,{aBXAStru[nX][1], aBXAStru[nX][2],aBXAStru[nX][3],aBXAStru[nX][4]})
		// Prepara Select
		cSelect += aBXAStru[nX][1] + ", "
	Next nX

	Aadd(aCampos, {"DESFILBX","C",__nDescFil,0}) 

 	// Criacao da tabela temporaria
	If oTmp <> Nil
		oTmp:Delete()
		oTmp:= Nil
	Endif	

	oTmp := FwTemporaryTable():New(cAlias)
	oTmp:SetFields(aCampos)

	// Filtra baixas
	If __cAlias == 'SE1'
		oTmp:AddIndex("1",{"FK1_FILIAL","FK1_IDDOC","FK1_SEQ"})
	Else
		oTmp:AddIndex("1",{"FK2_FILIAL","FK2_IDDOC","FK2_SEQ"})
	Endif

	oTmp:Create()

	// Filtra baixas
	If __cAlias == 'SE1'
		If __oQrySE1 == Nil
			cQry += " SELECT " + cSelect + " FK1.R_E_C_N_O_ RECNO FROM " + RetSqlName("FK1") + " FK1"
			cQry += " WHERE "
			cQry += " FK1.FK1_FILIAL = ? "
			cQry += " AND FK1.FK1_IDDOC = ? "
			cQry += " AND FK1.D_E_L_E_T_ = ' ' "
			cQry += " AND NOT EXISTS( "
			cQry += " 	SELECT FK1EST.FK1_IDDOC FROM " + RetSqlName("FK1") +" FK1EST"
			cQry += " 	WHERE FK1EST.FK1_FILIAL = FK1.FK1_FILIAL"
			cQry += " 	AND FK1EST.FK1_IDDOC = FK1.FK1_IDDOC "
			cQry += " 	AND FK1EST.FK1_SEQ = FK1.FK1_SEQ "
			cQry += " 	AND FK1EST.FK1_DOC = FK1.FK1_DOC "
			cQry += " 	AND FK1EST.FK1_TPDOC = 'ES' "
			cQry += " 	AND FK1EST.D_E_L_E_T_ = ' ') "
			
			cQry := ChangeQuery(cQry)
			__oQrySE1 := FWPreparedStatement():New(cQry)
		EndIf
		__oQrySE1:SetString(1,xFilial("FK1"))
		__oQrySE1:SetString(2,cIdDoc)
		cQry := __oQrySE1:GetFixQuery()
	Else
		If __oQrySE2 == Nil		
			cQry += " SELECT " + cSelect + " FK2.R_E_C_N_O_ RECNO FROM " + RetSqlName("FK2") + " FK2"
			cQry += " WHERE "
			cQry += " FK2.FK2_FILIAL = ? "
			cQry += " AND FK2.FK2_IDDOC = ? "
			cQry += " AND FK2.D_E_L_E_T_ = ' ' "
			cQry += " AND NOT EXISTS( "
			cQry += " 	SELECT FK2EST.FK2_IDDOC FROM " + RetSqlName("FK2") +" FK2EST"
			cQry += " 	WHERE FK2EST.FK2_FILIAL = FK2.FK2_FILIAL"
			cQry += " 	AND FK2EST.FK2_IDDOC = FK2.FK2_IDDOC "
			cQry += " 	AND FK2EST.FK2_SEQ = FK2.FK2_SEQ "
			cQry += " 	AND FK2EST.FK2_DOC = FK2.FK2_DOC "
			cQry += " 	AND FK2EST.FK2_TPDOC = 'ES' "
			cQry += " 	AND FK2EST.D_E_L_E_T_ = ' ') "
	
			cQry := ChangeQuery(cQry)
			__oQrySE2 := FWPreparedStatement():New(cQry)
		EndIf
		__oQrySE2:SetString(1,xFilial("FK2"))
		__oQrySE2:SetString(2,cIdDoc)
		cQry := __oQrySE2:GetFixQuery()
	EndIf
	
	MPSysOpenQuery(cQry, cAlias) //***Ivan -> Não materializar a query, aproveitar o cursor para alimentar o array de aBaixas, lembrando de executar o TCSetField() apos criar o cursor 

	DbSelectArea(cAlias)
	(cAlias)->(dbGoTop())

	// Formata estrutura
	For nX := 1 to Len(aCampos)
		If aCampos[nX][2] <> "C"
			TCSetField(cAlias, aCampos[nX][1], aCampos[nX][2], aCampos[nX][3], aCampos[nX][4])
		EndIf
	Next nX

	// Prepara estrutura de composicao do grid
	While !(cAlias)->(EoF())

		For nX := 1 to Len(aCampos)
			If aCampos[nX][1] == "DESFILBX"
				aAdd( aAux, FINIniDsc('FK1F') )
			Else
				aAdd( aAux, (cAlias)->&(aCampos[nX][1]) )
			EndIf
		Next nX
		
		aAdd(aBaixas,{(cAlias)->RECNO, aAux})
		dbSkip()
		aAux := {}
	
	EndDo

	(cAlias)->(dbCloseArea())
	oTmp:Delete()
	oTmp:= Nil

Return aBaixas

//-------------------------------------------------------------------
/*/ {Protheus.doc} FINIniDsc
Funcao de retorno do inicializador padrão dos campos de descrição
adicionados ao Model

@author Mauricio Pequim Jr
@since 22/11/2017

@return Descrição da natureza (SED)
/*/
//-------------------------------------------------------------------
Function FINIniDsc(cFonte)

	Local cDescric := ""
	Local cIdDoc := ''

	DEFAULT cFonte := ""

	If !Empty(cFonte)
		If cFonte == 'SED'		//Descrição da Natureza
			If __cAlias == 'SE1'
				cDescric := Posicione('SED',1,xFilial('SED')+SE1->E1_NATUREZ,'ED_DESCRIC')
			Else
				cDescric := Posicione('SED',1,xFilial('SED')+SE2->E2_NATUREZ,'ED_DESCRIC')
			Endif

		ElseIf cFonte == 'FK3'		//Descrição da Configuração de retenção
			cDescric := Posicione('FKK',3,xFilial('FKK')+'1'+FK3->FK3_CODFKM,'FKK_DESCR')

		ElseIf cFonte == 'FK4'		//Descrição da Configuração de retenção
			cDescric := Posicione('FKK',3,xFilial('FKK')+'1'+FK4->FK4_CODFKM,'FKK_DESCR')

		ElseIf cFonte == 'FK3C'		//Descrição do Cliente/Fornecedor
			If __cAlias == 'SE1'
				cDescric := Posicione('SA1',1,xFilial('SA1')+FK3->(FK3_CLIFOR+FK3_LOJA),'A1_NREDUZ')
			Else
				cDescric := Posicione('SA2',1,xFilial('SA2')+FK3->(FK3_CLIFOR+FK3_LOJA),'A2_NREDUZ')
			Endif

		ElseIf cFonte == 'FK4C'		//Descrição do Cliente/Fornecedor
			If __cAlias == 'SE1'
				cDescric := Posicione('SA1',1,xFilial('SA1')+FK4->(FK4_CLIFOR+FK4_LOJA),'A1_NREDUZ')
			Else
				cDescric := Posicione('SA2',1,xFilial('SA2')+FK4->(FK4_CLIFOR+FK4_LOJA),'A2_NREDUZ')
			Endif

		ElseIf cFonte == 'FK3S'		//Descrição da Situação
			If FK3->FK3_STATUS == '1'
				If Empty(FK3->FK3_IDRET)
					cDescric := STR0016		//"Calculado"
				Else
					cDescric := STR0017		//"Retido"
				Endif
			ElseIf FK3->FK3_STATUS == '2'
				cDescric := STR0018		//"Estornado"
			Endif

		ElseIf cFonte == 'FK4S'		//Descrição da Situação
			If FK4->FK4_STATUS == '1'
				cDescric := STR0017		//"Retido"
			Else
				cDescric := STR0018		//"Estornado"
			Endif

		ElseIf cFonte == 'FK4CR'		//Codigo de Retenção
			cDescric := Posicione('FKK',3,xFilial('FKK')+'1'+FK4->FK4_CODFKM,'FKK_CODRET')

		ElseIf cFonte == 'FK1F'		//Descrição Filial
			If __cAlias == 'SE1'
				cDescric := FWFilialName(,FK1->FK1_FILORI)
			Else
				cDescric := FWFilialName(,FK2->FK2_FILORI)
			EndIf

		ElseIf cFonte == 'FK3F'		//Descrição Filial
			cDescric := FWFilialName(,FK3->FK3_FILORI)

		ElseIf cFonte == 'FK4F'		//Descrição Filial
			cDescric := FWFilialName(,FK4->FK4_FILORI)

		ElseIf cFonte == 'FK4T'		//Titulo de imposto
			cIdDoc := Posicione('FK0',4,xFilial('FK0')+FK4->(FK4_IDORIG+FK4_CODFKM),'FK0_IDDOC')
			cDescric := Posicione('FK7',1,xFilial('FK7')+cIdDoc,'FK7_CHAVE')

		EndIf

	EndIf

Return cDescric

/*/{Protheus.doc} FCRetStat()
Função para definir os valores das variáveis estáticas, quando o modelo é instânciado através de outras rotinas.

@param cAliasMR, Alias que será considerado na instância do model (SE1 ou SE2)

@author Pedro Alencar
@since 20/03/2018
@version 12
/*/
Function FCRetStat ( cAliasMR As Char )
	Default cAliasMR := "SE2"
		
	__cAlias := cAliasMR
	
	If __cAlias == "SE1"
		__lEstrang := ( SE1->E1_MOEDA > 1 )
	Else
		__lEstrang := ( SE2->E2_MOEDA > 1 )
	EndIf
	
	If __nDescFil == 0
		__nDescFil := Len( FWFilialName( , cFilAnt ) )
	EndIf
	
Return Nil
