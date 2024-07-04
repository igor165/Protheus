#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TJURREVPREFAT.CH"

/******************************************
//Estrutura do array de Casos......
**/
#DEFINE cLojaAuto        SuperGetMv( "MV_JLOJAUT" , .F. , "2" ,  ) //Indica se a Loja do Caso deve ser preenchida automaticamente. (1-Sim; 2-Não)
#DEFINE NPOSREVISA		 1	//	Retirar Lançamentos do caso?
#DEFINE NPOSRET			 2	//	Retirar Lançamentos do caso?
#DEFINE NPOSTSREV		 3	//	Marcas todos TSs como Revisado.
#DEFINE NPOSDPREV		 4	//	Marcas todas Desps como Revisado.
#DEFINE NPOSTBREV		 5	//	Marcas todos Tabeladoss como Revisado.
#DEFINE NPOSCPART		 6	//	Cód Revisor.
#DEFINE NPOSDPART		 7	//	Desc Revisor.
#DEFINE NPOSCLI			 8	//	Cód Cliente.
#DEFINE NPOSLOJA		 9	//	Cód Loja.
#DEFINE NPOSCASO         Iif(cLojaAuto == "1", 09, 10) // Cód Caso.
#DEFINE NPOSVTS          Iif(cLojaAuto == "1", 10, 11) // Valor de Time-Sheets.
#DEFINE NPOSVDESP        Iif(cLojaAuto == "1", 11, 12) // Valor de Despesas.
#DEFINE NPOSVTAB         Iif(cLojaAuto == "1", 12, 13) // Valor de Tabelados.
#DEFINE NPOSVDESC        Iif(cLojaAuto == "1", 13, 14) // Desconto.
#DEFINE NPOSNOMECL       Iif(cLojaAuto == "1", 14, 15) // Nome do Cliente.
#DEFINE NPOSTITCAS       Iif(cLojaAuto == "1", 15, 16) // Título do Caso.


Function __TJURREVPREFAT() // Function Dummy
ApMsgInfo( "TJURREVPREFAT -> Utilizar Classe ao inves da funcao" )
Return NIL 

//-------------------------------------------------------------------
/*/ { Protheus.doc } Class TJURREVPREFAT
Classe para controlar a revisão de pré-fatura.

@author David Fernandes
@since 01/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------

Class TJURREVPREFAT

	Data oPanel

	Data oRespTime
	Data oRespDesp
	Data oRespTabe

	Data oButTop
	Data oButPUp
	Data oButPDn
	Data oButBot
	Data oAtivo
	Data oInAtivo
	Data oFolPDet
	Data oPIEFold
	
	Data oCliente
	Data oloja
	Data oCaso

	Data cPreFt

	Data cClien
	Data cLoja
	Data cCaso
	Data oDscCaso
	
	Data oBtRefresh
	
	Data oMoeda
	Data oCotac
    Data oIdioma
	Data oVTS
	Data oVHon
	Data oVDesp
	Data oVPF
	Data oVAdi

	Data oVDescL	
	Data oTpDesc
	Data oVDescE
	Data oPDescE

	Data cCodMoed
	Data cDesMoed
	Data nCotac
	Data cCIdioma
	Data cDIdioma
	Data nVlTS
	Data vlDesp
	Data vlHon
	Data VlPF
	Data VlSldAdi	

	Data cTpDesc
	Data nPcDesE
	Data nVlDesE
	Data nVlDesL
	Data cDscClien
	Data cDscCaso
	Data oPSup
	Data oPDet
	Data oPSupL
	Data oPDetCaso // Grid de casos
	Data oPDetLcTs // Matriz com os lançamentos de Ts
	Data oPDetLcDp // Matriz com os lançamentos de Dp
	Data oPDetLcTb // Matriz com os lançamentos de Tb
	Data oPInfsAdic //Aba de informações adicionais
	Data oFolAdic
	Data oPnlContr
	Data oPnlFixos
	Data oPObserv
	Data oPnlObsFt
	Data oGridCt
	Data oGridFx
	Data oPnlObsCt
	Data oPnlObsCl
	Data aCompsInfs
	Data aSays
	Data cObsCli
	Data cObsCont
	Data oObsRevis
	Data oObsRedat	
	Data cObsRevis
	Data cObsRedat
	Data oPreFt
	Data oAcrHon
	Data oDescHon
	Data oPAct
	Data oPNav
	Data oPBotoes
	Data oBotConf
	Data oBotAtual
	Data oBCasPri
	Data oBCasAnt
	Data oBCasPro
	Data oBCasUlt
	Data oTBitmap
	Data oOk
	Data oNo
	Data cCodUsr
	Data cSiglaUsr
	Data lEnable

	Data oPObs
	Data oGetObs
	
	Data nTipoApon
	Data cCpoLanc
	Data cCpoRev
	Data lRevisa
	
	Data oModel
	
	Method New(OPARENT, oView, cPreFt, cClien, cLoja, cCaso) CONSTRUCTOR

	Method LostFocus(cComp)
	Method ButNaveg(  )

	Method ResTabe(  ) 

	Method CriaArea ( oParent, cTipo, lResumo, oView )
	Method GetListCasos(cTipo) 
	Method CriaAdic ( oView, oParent )
	Method CriaObs ( oView, oParent )
	Method SetValue()
	Method ArrayContr(  )
	Method ArrayFixos(  )
	Method ChangeCt( cContr ) 
	Method CriaGrid(oParent, aHeader, aItems, nSinal, oView)

	Method SelectCaso( )
	Method Refresh()
	Method Habilita()
	Method Desabilita()
	Method ConfirmRev()
	Method MarcaLanc(  )
	Method RetiraLanc( nPosCodlan, nPosCodItem )
	Method Reload(oview)
 
 	Method GridCasos( oParent, oView )
	Method HeaderCampo(cCampo, cGrid)
 	Method GrdValid( oBrowse, aBrowse, oView )
	Method EditarCel(aBrowse, oBrowse, oView, cTipo)
	Method LineChange(cClien, cLoja, cCaso)
 	
	Method MontaGrid(oBrowse, aBrowse, nSinal ) 
	Method LoadCasos()
	Method LoadLancs()
	Method LoadTS() 
	Method LoadDP() 
	Method LoadTB()
	
	Method addNavBar( oParent, oView )

	Method Primeiro()
	Method Ultimo()
	Method Anterior()
	Method Proximo()
	
	Method Destroy()
	Method AddPObservacoes()
	Method Observacao()
	Method MarkCasRev()
	
EndClass

//-------------------------------------------------------------------
/*/ { Protheus.doc } New( cPreFt )
Cria o objeto de revisão de pré

@author David Fernandes
@since 01/12/2011
@version 1.0
/*/
//-------------------------------------------------------------------
Method New( OPARENT, oView, cPreFt, cClien, cLoja, cCaso )  Class TJURREVPREFAT
Local uTemp
Local cTitulo    := ""
Local bWhenDP    :=  { || Iif(Empty(JURX3INFO('NX0_VLFATD', "X3_WHEN")), .T., &(JURX3INFO('NX0_VLFATD', "X3_WHEN")) )}
Local nAjt1      := 0
Local nAjt2      := 0
Local nAjt3      := 0
Local aCposLGPD  := {}
Local aNoAccLGPD := {}
Local aDisabLGPD := {}

	If FindFunction("FwPDCanUse") .And. FwPDCanUse(.T.) // Tratamentos LGPD
		aCposLGPD := {"NVE_CCLIEN", "NVE_LCLIEN" ,"NVE_NUMCAS" ,"NVE_TITULO"}
		aNoAccLGPD := FwProtectedDataUtil():UsrNoAccessFieldsInList(aCposLGPD)
		AEval(aNoAccLGPD, {|x| AAdd( aDisabLGPD, x:CFIELD)})
	EndIf

	self:oPanel := tPanel():New( 00, 00, "", OPARENT, , , , , ,100, 100, .T., .T. )

	self:oModel	:= FWModelActive()

	self:nTipoApon	:= SuperGetMV( 'MV_JURTS2',, 1 )

	Do Case
		Case self:nTipoApon == 1
			self:cCpoLanc	:= "NUE_UTL"
			self:cCpoRev		:= "NUE_UTR"
		Case self:nTipoApon == 2
			self:cCpoLanc	:= "NUE_TEMPOL"
			self:cCpoRev		:= "NUE_TEMPOR"
			
		Case self:nTipoApon == 3
			self:cCpoLanc	:= "NUE_HORAL"
			self:cCpoRev		:= "NUE_HORAR"
	EndCase

	self:cCodUsr	:= JurUsuario(__cUserId)
	self:lEnable	:= ( self:oModel:GetOperation() == MODEL_OPERATION_UPDATE )
	self:oAtivo		:= LoadBitmap( GetResources(), "br_verde" )
	self:oInAtivo	:= LoadBitmap( GetResources(), "br_branco" )
	self:oOk		:= LoadBitmap( GetResources(), "LBOK" )
	self:oNo		:= LoadBitmap( GetResources(), "LBNO" )
	
	self:cPreFt		:= cPreFt
	Self:lRevisa	:=  JA202RCaso(self:cPreFt, self:cCodUsr)
	self:cClien		:= cClien
	self:cLoja		:= cLoja
	self:cCaso		:= cCaso
	
	self:nVlTS		:= FwFldGet("NX0_VTS")
	self:vlDesp		:= FwFldGet("NX0_VLFATD")
	self:vlHon		:= FwFldGet("NX0_VLFATH") - FwFldGet("NX0_VTS")
	
	self:cTpDesc	:= FwFldGet("NX0_TPDESC")
	self:nPcDesE	:= FwFldGet("NX0_PDESCH")
	self:nVlDesE	:= FwFldGet("NX0_DESCH")
	self:nVlDesL	:= FwFldGet("NX0_DESCON")
	
	self:cCodMoed	:= FwFldGet("NX0_CMOEDA")
	self:cDesMoed	:= AllTrim(	JurGetDados("CTO",1,xFilial("CTO")+self:cCodMoed,"CTO_SIMB"))
	self:nCotac		:= 			JurGetDados("NXR",1,xFilial("NXR")+self:cPreFt+self:cCodMoed,"NXR_COTAC")
	Self:cCIdioma	:= FwFldGet("NX0_CIDIO")
	Self:cDIdioma	:= AllTrim(	JurGetDados("NR1",1,xFilial("nr1")+Self:cCIdioma,"NR1_DESC"))
	
	self:cObsRevis	:= FwFldGet("NX0_OBSREV")
	self:cObsRedat	:= FwFldGet("NX0_OBSRED")

	self:VlPF		:= self:nVlTS + self:vlHon + self:vlDesp - self:nVlDesE - self:nVlDesL//
	
	self:VlSldAdi	:= J203SLDAD( self:cClien, self:cLoja, FwFldGet("NX0_CESCR"), FwFldGet("NX0_CMOEDA"), FwFldGet("NX0_DTEMI"), FwFldGet("NX0_CCONTR") )
	
	self:cDscClien	:= AllTrim(JurGetDados("SA1",1,xFilial("SA1")+self:cClien+self:cLoja,"A1_NOME"))
	self:cDscCaso	:= AllTrim(JurGetDados("NVE",1,xFilial("NVE")+self:cClien+self:cLoja+self:cCaso,"NVE_TITULO"))

	self:cObsCli	:= JurGetDados("NUH",1,xFilial("NUH")+self:cClien+self:cLoja, "NUH_OBSCAD")
	self:cObsCont	:= JurGetDados("NT0",1,xFilial("NT0")+FwFldGet("NX0_CCONTR"), "NT0_OBS")
	
	self:cSiglaUsr	:= AllTrim(JurGetDados("RD0",1,xFilial("RD0")+JurUsuario(__cUserId), "RD0_SIGLA"))

//  Paineis PRINCIPAIS  ----------------------------------------------------------------------------------------------------------

	self:oPanel:Align := CONTROL_ALIGN_ALLCLIENT
	self:oPSup		:= tPanel():New( 00, 00, "", self:oPanel, , , , , ,200, 50, .F., .T. )
	self:oPDet		:= tPanel():New( 00, 00, "", self:oPanel, , , , , ,00, 100, .F., .T. )

	// Alinhamentos
	self:oPSup:Align := CONTROL_ALIGN_TOP
	self:oPDet:Align := CONTROL_ALIGN_ALLCLIENT
		
	self:oPSup:ReadClientCoors(.T.,.T.)
	self:oPDet:ReadClientCoors(.T.,.T.)

//  Dados do cliente e selecao de casos - PAINEL SUPERIOR -----------------------------------------------------------------------

	self:oPSupL := tPanel():New( 00, 00, "", self:oPSup, , , , ,  ,600, 00, .F., .F. )
	self:oPSupL:Align := CONTROL_ALIGN_LEFT

	// PréFat
 	self:oPreFt		:= TJurPnlCampo():New( 03, 05, 38, 22, self:oPSupL, "", "NX0_COD",;
                   {|| }, {|| }, cPreFt, /*lVisivel*/, .T./*lEnable*/, /*cF3*/, /*nAlign*/ )
	self:oPreFt:Enable(.F.)

	// Cliente
	self:oCliente	:= TJurPnlCampo():New( 03, 50, 40, 22, self:oPSupL, "", "NVE_CCLIEN",;
                   {|| }, {|| }, self:cClien, /*lVisivel*/, /*lEnable*/, "NVE001"/*cF3*/, /*nAlign*/, /*cListItens*/, /*lAltLote*/, /*lCboxEmpty*/, aScan(aDisabLGPD, "NVE_CCLIEN") > 0 )
	self:oCliente:SetChange( {|| Self:SelectCaso(), .T.} )
	If (cLojaAuto == "1")
		self:oCliente:SetChange( {|| Self:oLoja:SetValue(JurGetLjAt()),;
		                          Self:SelectCaso(), .T.} )
	Else
		self:oCliente:SetChange( {|| Self:SelectCaso(), .T.} )
	EndIf

	self:oLoja := TJurPnlCampo():New( 03, 100, 40, 22, self:oPSupL, "", "NVE_LCLIEN",;
	              {|| }, {|| }, self:cLoja, /*lVisivel*/, /*lEnable*/, /*cF3*/, /*nAlign*/, /*cListItens*/, /*lAltLote*/, /*lCboxEmpty*/, aScan(aDisabLGPD, "NVE_LCLIEN") > 0 )
	self:oLoja:SetChange( {|| Self:SelectCaso(), .T.} )
	If (cLojaAuto == "1")
		self:oLoja:Visible(.F.)
		nAjt1 := 48 //Alinha o campo de núm Caso para o lugar da loja
		nAjt2 := 8  //Diminuir o tamanho do campo núm Caso
		nAjt3 := nAjt1 + nAjt2 // Ajustar o campo de Descrição do caso para o ocupar o espaço em branco
	EndIf

	// Caso
	self:oCaso := TJurPnlCampo():New( 003, 148-nAjt1, 48-nAjt2, 022, self:oPSupL, "", "NVE_NUMCAS",;
	              {|| }, {|| }, self:cCaso, /*lVisivel*/, /*lEnable*/, /*cF3*/ , /*nAlign*/, /*cListItens*/, /*lAltLote*/, /*lCboxEmpty*/, aScan(aDisabLGPD, "NVE_NUMCAS") > 0 )
	self:oCaso:SetChange( {|| Self:SelectCaso(), .T.} )

	// Sinalizador de relacionamento com o contrato
	self:oTBitmap := TBitmap():New(	007,150, 04, 04, "br_verde", , .T., self:oPSupL,;
	               { || MsgInfo( "Sinalizador de relacionamento" ) },,.F.,.T./*lStretch*/,,,.F.,,.T.,,.F.)

	// Titulo
	self:oDscCaso := TJurPnlCampo():New( 003, 205-nAjt3, 190+nAjt3, 022, self:oPSupL, "", "NVE_TITULO",;
	                 {||  }, {||   }, self:cDscCaso, /*lVisivel*/, .F./*lEnable*/, /*cF3*/ , /*nAlign*/, /*cListItens*/, /*lAltLote*/, /*lCboxEmpty*/, aScan(aDisabLGPD, "NVE_TITULO") > 0 )
	self:oDscCaso:Enable(.F.)
	
	self:oIdioma := TJurPnlCampo():New( 003, 405, 140, 022,;
									self:oPSupL,;
									"", "NX0_DIDIO",;
									{ ||  },;
									{ ||  }, ;
									self:cDIdioma ,;
									/*lVisivel*/, .F./*lEnable*/, )
	self:oIdioma:Enable(.F.)

//  Totais e valores da PF  ---------------------------------------------------------------------------------------------------
	
	//  Moeda da pré:
	self:oMoeda := TJurPnlCampo():New( 26, 005, 38, 022,;
									self:oPSupL,;
									"", "NXR_DMOEDA",;
									{ ||  },;
									{ ||  }, ;
									self:cDesMoed ,;
									/*lVisivel*/, .F./*lEnable*/, )
	self:oMoeda:Enable(.F.)

	//  Cotação - moeda da pré
	self:oCotac := TJurPnlCampo():New( 26, 50, 40, 22,;
									self:oPSupL,;
									"", "NXR_COTAC",;
									{ ||  },;
									{ ||  }, ;
									0 ,;
									/*lVisivel*/, .F./*lEnable*/, )
	self:oCotac:Enable(.F.)	


	//	Honorarios Adicionais  
	cTitulo := STR0001  // "Hon. Adicionais" 
	self:oVHon := TJurPnlCampo():New( 26, 100, 40, 022,;
									self:oPSupL,;
									cTitulo, "",;
									{ ||  },;
									{ ||  }, ;
									0 ,;
									/*lVisivel*/, .F./*lEnable*/, )
	self:oVHon:Enable(.F.)
	
	//	Honorarios Timesheet  
	self:oVTS := TJurPnlCampo():New( 26, 148, 58, 022,;
									self:oPSupL,;
									"", "NX0_VTS",;
									{ ||  },;
									{ ||  }, ;
									0 ,;
									/*lVisivel*/, /*lEnable*/, )
	self:oVTS:oCampo:bLostFocus		:= { ||  self:LostFocus(oView, "oVTS")  }

	self:oVTS:Enable(self:lRevisa)

	//	Despesas
	self:oVDesp := TJurPnlCampo():New( 26, 205, 58, 022,;
									self:oPSupL,;
									"", "NX0_VLFATD",;
									{ ||  },;
									{ ||  }, ;
									0 ,;
									/*lVisivel*/, /*lEnable*/, )
	self:oVDesp:oCampo:bLostFocus		:= { ||  self:LostFocus(oView, "oVDesp")  }
	self:oVDesp:SetWhen(bWhenDP)
	self:oVDesp:Enable(self:lRevisa)
	//  Adiantamentos
	cTitulo := STR0002  //"Sld Adiant"
	self:oVAdi := TJurPnlCampo():New( 26, 265, 40, 022,;
									self:oPSupL,;
									cTitulo, "",;
									{ ||  },;
									{ ||  }, ;
									0 ,;
									/*lVisivel*/, .F./*lEnable*/, )
	self:oVAdi:Enable(.F.)
								
	//  Total da PF
	cTitulo := STR0003  //"Vlr Total"
	self:oVPF := TJurPnlCampo():New( 26, 310, 40, 022,;
									self:oPSupL,;
									cTitulo, "",;
									{ ||  },;
									{ ||  }, ;
									0 ,;
									/*lVisivel*/, .F./*lEnable*/, )
	self:oVPF:Enable(.F.)					

	//  Total do Desconto Linear:
	self:oVDescL	 := TJurPnlCampo():New( 26, 355, 40, 022,;
									self:oPSupL,;
									, "NX0_DESCON",;
									{ ||  },;
									{ ||  }, ;
									0 ,;
									/*lVisivel*/, .F./*lEnable*/, )
	self:oVDescL:Enable(.F.)


	//  Tipo de desconto Especial:
	self:oTpDesc := TJurPnlCampo():New( 26, 405, 40, 022,;
									self:oPSupL,;
									, "NX0_TPDESC",;
									{ ||  },;
									{ ||  }, ;
									0 ,;
									/*lVisivel*/, .T./*lEnable*/, )

	self:oTpDesc:oCampo:bLostFocus		:= { ||  self:LostFocus(oView, "oTpDesc")  }

	If self:nVlDesE > 0 .OR. self:nPcDesE > 0
		self:oTpDesc:Enable(.F.)
	Else
		self:oTpDesc:Enable(self:lRevisa)
	EndIf

	// Valoe Desconto Especial
	self:oVDescE := TJurPnlCampo():New( 26, 455, 40, 022,;
									self:oPSupL,;
									, "NX0_DESCH",;
									{ ||  },;
									{ ||  }, ;
									0 ,;
									/*lVisivel*/, .T./*lEnable*/, )
	self:oVDescE:oCampo:bLostFocus		:= { ||  self:LostFocus(oView, "oVDescE")  }
	If self:cTpDesc == "1"
		self:oVDescE:Enable(self:lRevisa)
	Else
		self:oVDescE:Enable(.F.)
	EndIf

	// Percentual Desconto Especial
	self:oPDescE := TJurPnlCampo():New( 26, 505, 40, 022,;
									self:oPSupL,;
									, "NX0_PDESCH",;
									{ ||  },;
									{ ||  }, ;
									0 ,;
									/*lVisivel*/, .T./*lEnable*/, )

	self:oPDescE:oCampo:bLostFocus		:= { ||  self:LostFocus(oView, "oPDescE")  }
	If self:cTpDesc == "2"
		self:oPDescE:Enable(self:lRevisa)
	Else
		self:oPDescE:Enable(.F.)
	EndIf

	// Casos - Botoes de navegacao
	Self:AddNavBar( self:oPSup, oView )

	self:oFolPDet := TFolder():New( 0,0,{},,self:oPDet,,,,.T.,,260,184 )	
	self:oFolPDet:Align := CONTROL_ALIGN_ALLCLIENT
	
	self:oFolPDet:AddItem( STR0004 )	// "Casos"
	self:oFolPDet:AddItem( STR0005 )	// "Timesheet"
	self:oFolPDet:AddItem( STR0006 )	// "Despesas"
	self:oFolPDet:AddItem( STR0007 )	// "Tabelados"
	self:oFolPDet:AddItem( STR0008 )	// "Inf.Adicionais"
	self:oFolPDet:AddItem( STR0009 )	// "Observações"

	//Define o folder default na abertura
	self:oFolPDet:nOption := 01
	
	//Aba de Casos
	self:oPDetCaso	:= 	self:GridCasos(self:oFolPDet:aDialogs[ 1 ], oView, .T. )
	//Abas de Lançamentos
	self:oPDetLcTs	:= 	self:CriaArea(self:oFolPDet:aDialogs[ 2 ], "TS", .T., oView )
	self:oPDetLcDp	:= 	self:CriaArea(self:oFolPDet:aDialogs[ 3 ], "DP", .T., oView )
	self:oPDetLcTb	:= 	self:CriaArea(self:oFolPDet:aDialogs[ 4 ], "TB", .T., oView )

	//Aba de Informações Adicionais
	self:oPInfsAdic	:=	self:CriaAdic ( oView, self:oFolPDet:aDialogs[ 5 ] )
	
	//Observações Revisor / Redator
	self:oPObserv	:=	self:CriaObs ( oView, self:oFolPDet:aDialogs[ 6 ] )


	self:oPDetLcTs:Resumo("TS")
	self:oPDetLcDp:Resumo("DP")
	self:oPDetLcTb:Resumo("TB")

Return self:oPanel

Method LostFocus(oView, cCampo) Class TJURREVPREFAT
Local lRet      := .T.
Local oModel    := FwModelActive()
Local oModelNX0 := oModel:GetModel("NX0MASTER")
Local cTpAjuste := ""
Local lRefresh  := .F.
Local cAltPer	:= ""
Local lReload	:= .F.
//Local oView  := FWViewActive()
   
   If self:lEnable
   
		If cCampo == "oVTS"
			If oModelNX0:GetValue("NX0_VTS") <> self:oVTS:valor
	            
				If oModelNX0:CanSetValue("NX0_ALTPER")
					cTpAjuste := JASelOpcao("NX0_ALTPER")
					lRet := !Empty(cTpAjuste) // Se for em branco, quer dizer que cancelou.
				Else
					cTpAjuste := ""
					lRet := .F.
					JurMsgErro(STR0032) //"Existem alterações de valor pendentes, para efetuar novas alterações confirme ou cancele as anteriores!"
				EndIf
				
				//NX0_ALTPER
				If !Empty(cTpAjuste)
					JurSetValue( oModelNX0, "NX0_ALTPER", ,cTpAjuste )
					Self:Observacao(.T., 2, cTpAjuste)
				EndIf
				
				If lRet .And. !(lRefresh := JurSetValue( oModelNX0, "NX0_VTS", , self:oVTS:valor ) )
					self:nVlTS := oModelNX0:GetValue("NX0_VTS")
					self:oVTS:valor := oModelNX0:GetValue("NX0_VTS")
				Else
					self:oVTS:SetValue(oModelNX0:GetValue("NX0_VTS"))
				EndIf
			
			EndIf
		EndIF
	
		If cCampo == "oVDesp"	
			If !(self:oVDesp:valor == oModelNX0:GetValue("NX0_VLFATD"))  
				If  ApMsgYesNo( STR0022 + CRLF + STR0023 )
					cAltPer := oModelNX0:GetValue("NX0_ALTPER")
					lRet := lRet .AND. oModelNX0:LoadValue("NX0_ALTPER", "2")
			
					lRet := lRet .AND. JurSetValue( oModelNX0, "NX0_VLFATD", ,self:oVDesp:valor )
					Self:Observacao(.T., 2, "2")
					lRefresh := lRet
					lReload	 := lRet
				Else
					self:oVDesp:valor := oModelNX0:GetValue("NX0_VLFATD")
				EndIf
			EndIf
		EndIF	
		If cCampo == "NX0_OBSREV"
			lRet := JurSetValue(oModelNX0,"NX0_OBSREV", , self:cObsRevis)  
			lRefresh := lRet
		EndIf
		If cCampo == "NX0_OBSRED"
			lRet := JurSetValue(oModelNX0,"NX0_OBSRED", , self:cObsRedat)
			lRefresh := lRet
		EndIf
		
		If cCampo == "oTpDesc"
			lRet := oModelNX0:SetValue("NX0_TPDESC", self:oTpDesc:Valor )
	
			If self:oTpDesc:Valor == "1"
				self:oVDescE:Enable(self:lRevisa)
			Else
				self:oVDescE:Enable(.F.)
			EndIf
	
			If self:oTpDesc:Valor == "2"
				self:oPDescE:Enable(self:lRevisa)
			Else
				self:oPDescE:Enable(.F.)
			EndIf
	
			lRefresh := lRet	
		EndIf
		If cCampo == "oVDescE"
			//omodel:Setvalue //normal..
		
			If oModelNX0:CanSetValue("NX0_DESCH")
				//Utilizado o valid field pois ao confirmar pela segunda vez exibia a msg "Formulário não alterado, não precisa ser salvo"
				lRet := oView:ValidField("NX0MASTER","NX0_DESCH",self:oVDescE:Valor,.T.)
			EndIf
			
			If self:oVDescE:Valor > 0
				self:oTpDesc:Enable(.F.)
			Else
				self:oTpDesc:Enable(self:lRevisa)
			EndIf
			lRefresh := lRet
		EndIf
		If cCampo == "oPDescE" 
			If oModelNX0:CanSetValue("NX0_PDESCH")
				//Utilizado o valid field pois ao confirmar pela segunda vez exibia a msg "Formulário não alterado, não precisa ser salvo"
				lRet := oView:ValidField("NX0MASTER","NX0_PDESCH",self:oPDescE:Valor,.T.)
			EndIf
	
			If self:oPDescE:Valor > 0
				self:oTpDesc:Enable(self:lRevisa)
			Else
				self:oTpDesc:Enable(.T.)
			EndIf
			
			lRefresh := lRet	
		EndIf
	
		If lRet .And. lRefresh 
			oView:Refresh()
			self:Refresh()
			IF lReload
				self:Reload(oView)
			EndIf
		Endif
	EndIf
	
Return nil

Method CriaArea( oParent, cTipo, lResumo, oView ) Class TJURREVPREFAT     
	Local oPnlLc
	Local dDtIni	:= ctod("  /  /    ")
	Local dDtFim	:= ctod("  /  /    ")

	oPnlLc := TJURREVLANCTO():new(cTipo, oParent, oView )
	oPnlLc:setListaCasos( self:GetListCasos(cTipo) )
	oPnlLc:AddLinesLanctos ( cTipo , lResumo )
	oPnlLc:LoadLines()

	Do Case
		Case cTipo == "TS"	
			dDtIni	:= JurGetDados("NX0",1,xFilial("NX0")+self:cPreFt,"NX0_DINITS")
			dDtFim	:= JurGetDados("NX0",1,xFilial("NX0")+self:cPreFt,"NX0_DFIMTS")
		Case cTipo == "DP"
			dDtIni	:= JurGetDados("NX0",1,xFilial("NX0")+self:cPreFt,"NX0_DINIDP")
			dDtFim	:= JurGetDados("NX0",1,xFilial("NX0")+self:cPreFt,"NX0_DFIMDP")
		Case cTipo == "TB"
			dDtIni	:= JurGetDados("NX0",1,xFilial("NX0")+self:cPreFt,"NX0_DINITB")
			dDtFim	:= JurGetDados("NX0",1,xFilial("NX0")+self:cPreFt,"NX0_DFIMTB")
	EndCase

	oPnlLc:SetDtIni(dDtIni)
	oPnlLc:SetDtFim(dDtFim)

Return oPnlLc

Method GetListCasos(cTipo) Class TJURREVPREFAT
Local aListCasos := {}
Local aTempCas   := {}
Local nI         := 0
Local nRevisado  := 3

Default cTipo := ""

	Do Case // Isto serve para pegar a posição 
		Case cTipo == "TS"
			nRevisado := 3
		Case cTipo == "DP"
			nRevisado := 4
		Case cTipo == "TB"
			nRevisado := 5
	End Case

	aTempCas	:= self:oPDetCaso:aCols
	For ni := 1 to len( aTempCas )
		aAdd( aListCasos, { aTempCas[nI][NPOSCLI],;
							aTempCas[nI][NPOSLOJA],;
							aTempCas[nI][NPOSCASO],;
							.F.,;
							.F.,;
							IIF(aTempCas[nI][nRevisado] == "LBOK", .T., .F.),; // Revisado TS
							.F.,;
							.F.;
							};
			)
	Next nI

Return aListCasos

Method CriaAdic ( oView, oParent ) Class TJURREVPREFAT     
Local oPnlAdic
Local aHeader		:= {}
Local nSinal 		:= 1 
Local aContratos	:= {}
Local aFixos		:= {}
Local uTemp 		:= "INFS"
Local aSays			:= {}
Local aInfo			:= {}

	aContratos 	:= self:ArrayContr()
	aFixos		:= self:ArrayFixos()
	
	self:aCompsInfs	:= {}
	
	oPnlAdic := tPanel():New( 00, 00, "", oParent, , , , , ,00, 50, .T., .T. )
	oPnlAdic:Align := CONTROL_ALIGN_ALLCLIENT
	
	self:oFolAdic := TFolder():New( 0,0,{},,oPnlAdic,,,,.T.,,260,184 )	
	self:oFolAdic:Align := CONTROL_ALIGN_ALLCLIENT

	self:oFolAdic:AddItem( STR0010 ) 	// "Contratos"
	self:oFolAdic:AddItem( STR0011 )     // "Fixos" 
	
	self:oFolAdic:nOption := 01
    // Aba de contratos
	self:oPnlContr := TJurPanel():New( 00, 00, 00, 00, self:oFolAdic:aDialogs[1], "", .F., .T., CONTROL_ALIGN_ALLCLIENT )
	&( uTemp +"_1") := self:oPnlContr:AddHorizontalPanel(40 )   //Contratos
	&( uTemp +"_2") := self:oPnlContr:AddHorizontalPanel(60 )	// Observaçoes

	&( uTemp +"_1_1") := self:oPnlContr:AddVerticalPanel( 100, &( uTemp +"_1")  , CLR_WHITE )  //Grid Contratos

	aadd(self:aCompsInfs, {"1", {  &( uTemp +"_1_1")  }} )

	&( uTemp +"_2_1")	:=	self:oPnlContr:AddVerticalPanel( 50,  &( uTemp +"_2") , CLR_WHITE ) // Obs do Contrato
	&( uTemp +"_2_2")	:=	self:oPnlContr:AddVerticalPanel( 50,  &( uTemp +"_2") , CLR_WHITE ) // Obs do Cliente

	aadd(self:aCompsInfs, {"2", {  &( uTemp +"_2_1"), &( uTemp +"_2_2")  }   } )
	
	aHeader	:= {}
	aAdd( aHeader , self:HeaderCampo(STR0012     	, "CONTR" ) )
	aAdd( aHeader , self:HeaderCampo("NX8_CCONTR"	, "CONTR" ) )
	aAdd( aHeader , self:HeaderCampo("NX8_DCONTR"	, "CONTR" ) )
	aAdd( aHeader , self:HeaderCampo("NX8_CCLIEN"	, "CONTR" ) )
	Iif(cLojaAuto == "1", ,aAdd( aHeader , self:HeaderCampo("NX8_CLOJA" 	, "CONTR" ) ))
	aAdd( aHeader , self:HeaderCampo("NX8_DCLIEN"	, "CONTR" ) )

	aAdd( aHeader , self:HeaderCampo("NT0_CTPHON"  	, "CONTR" ) )
	aAdd( aHeader , self:HeaderCampo("NRA_SIGLA"  	, "CONTR" ) )
	aAdd( aHeader , self:HeaderCampo("NRA_DESC"  	, "CONTR" ) )

	aAdd( aHeader , self:HeaderCampo("NX8_VHON"  	, "CONTR" ) )
	aAdd( aHeader , self:HeaderCampo("NX8_VDESP"    , "CONTR" ) )
	aAdd( aHeader , self:HeaderCampo("NX8_VTS"      , "CONTR" ) )
	aAdd( aHeader , self:HeaderCampo("NX8_VTAB"     , "CONTR" ) )
	aAdd( aHeader , self:HeaderCampo("NX8_VFIXO"	, "CONTR" ) )
	aAdd( aHeader , self:HeaderCampo("NX8_VDESCO"   , "CONTR" ) )
	aAdd( aHeader , self:HeaderCampo("NX8_VLDESC"   , "CONTR" ) )
	aAdd( aHeader , self:HeaderCampo("NX8_VDESCT"   , "CONTR" ) )

	aAdd( aHeader , self:HeaderCampo("NX8_VSLDPX", "CONTR" ) )


	self:oGridCt := self:CriaGrid( self:oPnlContr:GetPanel( self:aCompsInfs[1][2][1] ), aHeader, aContratos, nSinal, oView)  // Grid de contratos
    self:oGridCt:bChange	  := {|| self:ChangeCt(aContratos[self:oGridCt:nAt,02]) }
    //Obs Contrato
	&( uTemp +"_3_1")		:= tSay():New( 025, 280, { || JA207TitCamp("NT0_OBS")   }, self:oPnlContr:GetPanel( self:aCompsInfs[2][2][1] ), , , , , , .T., , , 300, 8 ) //"Observação do Contrato"
	&( uTemp +"_3_1"):Align	:=	CONTROL_ALIGN_TOP
	//Obs Cliente
	&( uTemp +"_3_2")		:= tSay():New( 025, 280, { || JA207TitCamp("NUH_OBSCAD") }, self:oPnlContr:GetPanel( self:aCompsInfs[2][2][2] ), , , , , , .T., , , 300, 8 ) // "Observação do Cliente" 
	&( uTemp +"_3_2"):Align	:= CONTROL_ALIGN_TOP

	aadd(self:aCompsInfs, {"3", {  &( uTemp +"_3_1"), &( uTemp +"_3_2")  }   } )
	
	self:oPnlObsCt := tMultiget():New( 	00, 00, { | | self:cObsCont },;
										self:oPnlContr:GetPanel( self:aCompsInfs[2][2][1] ),;
										10, 10, , , , ,  , .T., , , , , .T., , , , , , .T. )
	self:oPnlObsCt:Align := CONTROL_ALIGN_ALLCLIENT
	
	self:oPnlObsCl := tMultiget():New( 	00, 00, { | | self:cObsCli },;
										self:oPnlContr:GetPanel( self:aCompsInfs[2][2][2] ),;
										10, 10, , , , ,  , .T., , , , , .T., , , , , , .T. )
	self:oPnlObsCl:Align := CONTROL_ALIGN_ALLCLIENT

    // Aba de Fixos
   	self:oPnlFixos := TJurPanel():New( 00, 00, 00, 00, self:oFolAdic:aDialogs[2], "", .F., .T., CONTROL_ALIGN_ALLCLIENT )
	&( uTemp +"_4") := self:oPnlFixos:AddHorizontalPanel(100 )  //Fixos

	&( uTemp +"_4_1") := self:oPnlFixos:AddVerticalPanel( 100, &( uTemp +"_4")  , CLR_WHITE )  // Grid Fixos	

	aadd(self:aCompsInfs, {"4", {  &( uTemp +"_4_1")  }} )

	aHeader	:= {}
	aAdd( aHeader , self:HeaderCampo(STR0013      , "FIXO", 'cAcumular') )  // Acumular
	aAdd( aHeader , self:HeaderCampo("NT1_CCONTR" , "FIXO" ) )
	aAdd( aHeader , self:HeaderCampo("NT1_PARC"   , "FIXO" ) )
	aAdd( aHeader , self:HeaderCampo("NT1_CTPFTU" , "FIXO" ) )
	aAdd( aHeader , self:HeaderCampo("NT1_DTPFTU" , "FIXO" ) )
	aAdd( aHeader , self:HeaderCampo("NT1_DATAVE" , "FIXO" ) )
	aAdd( aHeader , self:HeaderCampo("NT1_CMOEDA" , "FIXO" ) )
	aAdd( aHeader , self:HeaderCampo("NT1_DMOEDA" , "FIXO" ) )
	aAdd( aHeader , self:HeaderCampo("NT1_VALORA" , "FIXO" ) )
	aAdd( aHeader , self:HeaderCampo("NT1_DESCRI" , "FIXO" ) )
	
	aHeader[1][3] := "@BMP"	// Acumular

	self:oGridFx := self:CriaGrid( self:oPnlFixos:GetPanel( self:aCompsInfs[4][2][1] ), aHeader, aFixos, 0, oView)  // Grid de Fixos
	
	self:oGridFx:oBrowse:bLDblClick     := {|| self:EditarCel(self:oGridFx:aCols, self:oGridFx:oBrowse, oView, self:oGridFx, "NT1" ) }
	self:oGridFx:oBrowse:bCustomEditCol := {|| self:EditarCel(self:oGridFx:aCols, self:oGridFx:oBrowse, oView, self:oGridFx, "NT1" ) }

Return oPnlAdic

Method CriaObs ( oView, oParent ) Class TJURREVPREFAT
Local oPnlObs

Local uTemp 		:= "OBS"

	oPnlObs := tPanel():New( 00, 00, "", oParent, , , , , ,00, 50, .T., .T. )
	oPnlObs:Align := CONTROL_ALIGN_ALLCLIENT

	self:oPnlObsFt := TJurPanel():New( 00, 00, 00, 00, oPnlObs, "", .F., .T., CONTROL_ALIGN_ALLCLIENT )
	&( uTemp +"_5") := self:oPnlObsFt:AddHorizontalPanel(100 )   //Observações
	
	&( uTemp +"_5_1") := self:oPnlObsFt:AddVerticalPanel( 50, &( uTemp +"_5")  , CLR_WHITE )  //Observação do Revisor
	&( uTemp +"_5_2") := self:oPnlObsFt:AddVerticalPanel( 50, &( uTemp +"_5")  , CLR_WHITE )  //Observação do Redador

	aadd(self:aCompsInfs, {"5", {  &( uTemp +"_5_1"), &( uTemp +"_5_2")  }   } )
	
	&( uTemp +"_6_1")		:= tSay():New( 025, 280, { || JA207TitCamp("NX0_OBSREV") }, self:oPnlObsFt:GetPanel( self:aCompsInfs[5][2][1] ), , , , , , .T., , , 300, 8 ) // "Observação do Revisor"
	&( uTemp +"_6_1"):Align	:=	CONTROL_ALIGN_TOP

	&( uTemp +"_6_2")		:= tSay():New( 025, 280, { || JA207TitCamp("NX0_OBSRED") }, self:oPnlObsFt:GetPanel( self:aCompsInfs[5][2][2] ), , , , , , .T., , , 300, 8 ) // "Observação do Redator"
	&( uTemp +"_6_2"):Align	:= CONTROL_ALIGN_TOP

	aadd(self:aCompsInfs, {"6", {  &( uTemp +"_6_1"), &( uTemp +"_6_2")  }   } )

	self:oObsRevis := tMultiget():New( 	00, 00, {|u| if(Pcount()>0,self:cObsRevis:=u,self:cObsRevis) },;
										self:oPnlObsFt:GetPanel( self:aCompsInfs[5][2][1] ),;
										10, 10, , , , ,  , .T., , , , , .T., , , , , , .T. )
    self:oObsRevis:bLostFocus	:= { || self:LostFocus(oView, "NX0_OBSREV" ) }
	self:oObsRevis:Align := CONTROL_ALIGN_ALLCLIENT

	self:oObsRedat := tMultiget():New( 	00, 00, {|u| if(Pcount()>0,self:cObsRedat:=u,self:cObsRedat) },;
										self:oPnlObsFt:GetPanel( self:aCompsInfs[5][2][2] ),;
										10, 10, , , , ,  , .T., , , , , .T., , , , , , .T. )
	self:oObsRedat:bLostFocus	:= { || self:LostFocus(oView, "NX0_OBSRED" ) }
	self:oObsRedat:Align := CONTROL_ALIGN_ALLCLIENT
	

Return oPnlObs


Method CriaGrid(oParent, aHeader, aItems, nSinal, oView) Class TJURREVPREFAT
Local oGrid

Default nSinal := 0

    // Cria Browse
	oGrid := MsNewGetDados():New(000,000,000,000,GD_UPDATE+GD_INSERT, , , , , , 999,,,,oParent,aHeader,{})
	oGrid:aCols	:= aItems
	
    oGrid:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
    IF Empty(aItems) .OR. Len(aItems) == 0
    	oGrid:disable()
    EndIf
    
    oGrid:lInsert := .F.
    oGrid:lDelete := .F.

Return oGrid

Method ArrayContr(  ) Class TJURREVPREFAT
Local aBrowse 		:= {}  
Local aArea			:= GetArea() 
Local aSaveLines 	:= FWSaveRows( )
Local oModel		:= FwModelActive()
Local oModelNX8		:= oModel:GetModel("NX8DETAIL")
Local oModelNX1		:= oModel:GetModel("NX1DETAIL")
Local nLinNX1		:= 0
Local nLinNX8		:= 0
Local lCasoContr	:= .F.

	For nLinNX8 := 1 to oModelNX8:GetQtdLine()
		oModelNX8:GoLine(nLinNX8)
		lCasoContr := .F.
		For nLinNX1 := 1 to oModelNX1:GetQtdLine()
			oModelNX1:GoLine(nLinNX1)
			If 	oModelNX1:GetValue( "NX1_CCLIEN" ) 	== self:cClien .AND. ;
				oModelNX1:GetValue( "NX1_CLOJA" )  	== self:cLoja .AND. ;
				oModelNX1:GetValue( "NX1_CCASO" ) 	== self:cCaso 
				
				lCasoContr := .T.
				exit
			EndIf
		Next nLinNX1
			cCTpHon 	:= JurGetDados("NT0",1,xFilial("NT0")+oModelNX8:GetValue( "NX8_CCONTR" ),"NT0_CTPHON")
			cSigTpHon 	:= JurGetDados("NRA",1,xFilial("NRA")+cCTpHon,"NRA_SIGLA")
			cDTpHon 	:= JurGetDados("NRA",1,xFilial("NRA")+cCTpHon,"NRA_DESC")
			If(cLojaAuto == "1")
				aAdd(aBrowse , { If(lCasoContr,"br_verde", "br_branco"), ;
								oModelNX8:GetValue( "NX8_CCONTR" ),;
								oModelNX8:GetValue( "NX8_DCONTR" ),;
								oModelNX8:GetValue( "NX8_CCLIEN" ),;
								oModelNX8:GetValue( "NX8_DCLIEN" ),;
								AllTrim(cCTpHon),;
								AllTrim(cSigTpHon),;
								AllTrim(cDTpHon),;
								oModelNX8:GetValue( "NX8_VHON"   ),;
								oModelNX8:GetValue( "NX8_VDESP"  ),;
								oModelNX8:GetValue( "NX8_VTS"    ),;
								oModelNX8:GetValue( "NX8_VTAB"   ),;
								oModelNX8:GetValue( "NX8_VFIXO"  ),;
								oModelNX8:GetValue( "NX8_VDESCO" ),;
								oModelNX8:GetValue( "NX8_VLDESC" ),;
								oModelNX8:GetValue( "NX8_VDESCT" ),;
								oModelNX8:GetValue( "NX8_VSLDPX" ),;
								.F.;
								})
			Else
				aAdd(aBrowse , { If(lCasoContr,"br_verde", "br_branco"), ;
								oModelNX8:GetValue( "NX8_CCONTR" ),;
								oModelNX8:GetValue( "NX8_DCONTR" ),;
								oModelNX8:GetValue( "NX8_CCLIEN" ),;
								oModelNX8:GetValue( "NX8_CLOJA"  ),; //Com a loja
								oModelNX8:GetValue( "NX8_DCLIEN" ),;
	                            AllTrim(cCTpHon),;
								AllTrim(cSigTpHon),;
								AllTrim(cDTpHon),;
								oModelNX8:GetValue( "NX8_VHON"   ),;
								oModelNX8:GetValue( "NX8_VDESP"  ),;
								oModelNX8:GetValue( "NX8_VTS"    ),;
								oModelNX8:GetValue( "NX8_VTAB"   ),;
								oModelNX8:GetValue( "NX8_VFIXO"  ),;
								oModelNX8:GetValue( "NX8_VDESCO" ),;
								oModelNX8:GetValue( "NX8_VLDESC" ),;
								oModelNX8:GetValue( "NX8_VDESCT" ),;
								oModelNX8:GetValue( "NX8_VSLDPX" ),;
								.F.;
								})
			EndIf

	Next nLinNX8

	FWRestRows( aSaveLines )
	RestArea( aArea )
	
Return aBrowse

Method ArrayFixos(  ) Class TJURREVPREFAT
Local aBrowse 		:= {}  
Local aArea			:= GetArea() 
Local aSaveLines 	:= FWSaveRows( )
Local oModel		:= FwModelActive()
Local oModelNX8		:= oModel:GetModel("NX8DETAIL")
Local oModelNT1		:= oModel:GetModel("NT1DETAIL")
Local nLinNT1		:= 0
Local nLinNX8		:= 0

	For nLinNX8 := 1 to oModelNX8:GetQtdLine()
		oModelNX8:GoLine(nLinNX8)
		For nLinNT1 := 1 to oModelNT1:GetQtdLine()
			oModelNT1:GoLine(nLinNT1)
			If !Empty( oModelNT1:GetValue( "NT1_PARC" ) )
				aAdd(aBrowse , {"LBNO",;
								oModelNT1:GetValue( "NT1_CCONTR" ),;
								oModelNT1:GetValue( "NT1_PARC"   ),;
								oModelNT1:GetValue( "NT1_CTPFTU" ),;
								oModelNT1:GetValue( "NT1_DTPFTU" ),;
								oModelNT1:GetValue( "NT1_DATAVE" ),;
								oModelNT1:GetValue( "NT1_CMOEDA" ),;
								oModelNT1:GetValue( "NT1_DMOEDA" ),;
								oModelNT1:GetValue( "NT1_VALORA" ),;
								oModelNT1:GetValue( "NT1_DESCRI" ),;
								.F.;
								})
			EndIf

		Next nLinNT1
	Next nLinNX8
	If Empty(aBrowse )
		aAdd(aBrowse , {"","","","","","","","",.F.} )
	EndIf
	
	FWRestRows( aSaveLines )
	RestArea( aArea )
	
Return aBrowse

Method ChangeCt( cContr )  Class TJURREVPREFAT     
Local cClien	:= ""
Local cLoja		:= ""

	
	cClien := JurGetDados("NT0",1,xFilial("NT0")+cContr, "NT0_CCLIEN")
	cLoja := JurGetDados("NT0",1,xFilial("NT0")+cContr, "NT0_CLOJA")
	
	
	self:cObsCli	:= JurGetDados("NUH",1,xFilial("NUH")+cClien+cLoja, "NUH_OBSCAD")
	self:cObsCont	:= JurGetDados("NT0",1,xFilial("NT0")+cContr, "NT0_OBS")
	
	self:oPnlObsCl:Refresh()
	self:oPnlObsCt:Refresh()

Return nil

Method GridCasos( oParent, oView ) Class TJURREVPREFAT     
Local oGtDados
Local aBrowse := {}  
Local aHeader := {}
Local bColor
Local nI	:= 0

	aAdd( aHeader , self:HeaderCampo(STR0021		, "CASO", 'cEditar'  ) )  // Editar
	aAdd( aHeader , self:HeaderCampo(STR0013		, "CASO", 'cAcumular') )  // Acumular
	aAdd( aHeader , self:HeaderCampo("NX1_TSREV"	, "CASO" ) )  
	aAdd( aHeader , self:HeaderCampo("NX1_DSPREV"	, "CASO" ) )  
	aAdd( aHeader , self:HeaderCampo("NX1_TABREV"	, "CASO" ) )  
	aAdd( aHeader , self:HeaderCampo("NX1_SIGLA"	, "CASO" ) )
	aAdd( aHeader , self:HeaderCampo("NX1_DPART"	, "CASO" ) )
	aAdd( aHeader , self:HeaderCampo("NX1_CCLIEN"	, "CASO" ) )
	Iif(cLojaAuto == "2", aAdd( aHeader , self:HeaderCampo("NX1_CLOJA"	, "CASO" ) ), )
	aAdd( aHeader , self:HeaderCampo("NX1_CCASO"	, "CASO" ) )
	aAdd( aHeader , self:HeaderCampo("NX1_VTS"		, "CASO" ) )
	aAdd( aHeader , self:HeaderCampo("NX1_VDESP"	, "CASO" ) )
	aAdd( aHeader , self:HeaderCampo("NX1_VTAB"		, "CASO" ) )
	aAdd( aHeader , self:HeaderCampo("NX1_VLDESC"	, "CASO" ) )
	aAdd( aHeader , self:HeaderCampo("NX1_DCLIEN"	, "CASO" ) )
	aAdd( aHeader , self:HeaderCampo("NX1_DCASO"	, "CASO" ) )

	//Ajusta as pictures
	aHeader[NPOSREVISA][3] 	:= "@BMP"	// Revisar?
	aHeader[NPOSRET]   [3] 	:= "@BMP"	// Acumular
	aHeader[NPOSTSREV] [3] 	:= "@BMP"	// TS REv
	aHeader[NPOSDPREV] [3] 	:= "@BMP"	// TS REv
	aHeader[NPOSTBREV] [3] 	:= "@BMP"	// TS REv
	//Ajusta o Tipo de Dados
	aHeader[NPOSTSREV]	[8] 	:= "L"	// TS REv
	aHeader[NPOSDPREV]	[8] 	:= "L"	// TS REv
	aHeader[NPOSTBREV]	[8] 	:= "L"	// TS REv
	
	aBrowse := self:LoadCasos()

	oGtDados := MsNewGetDados():New(000,000,000,000,GD_UPDATE+GD_INSERT, , , , , , 999,,,,oParent,aHeader,{})
	oGtDados:aCols	:= aBrowse

	oGtDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oGtDados:lInsert   := .F.
	oGtDados:lDelete   := .F.
	oGtDados:lEditLine := .F.


	oGtDados:oBrowse:bChange := {|| self:LineChange(aBrowse[oGtDados:oBrowse:nAt,NPOSCLI], aBrowse[oGtDados:oBrowse:nAt,NPOSLOJA], aBrowse[oGtDados:oBrowse:nAt,NPOSCASO]) }
	oGtDados:oBrowse:bLDblClick     := {|| self:EditarCel(oGtDados:aCols, oGtDados:oBrowse, oView, oGtDados, "NX1" ) }
	oGtDados:oBrowse:bCustomEditCol := {|| self:EditarCel(oGtDados:aCols, oGtDados:oBrowse, oView, oGtDados, "NX1" ) }

	//oGtDados:oBrowse:bEditCol := {|| self:GrdValid(oGtDados:oBrowse, oGtDados:aCols, oView ) }
	oGtDados:bFieldOk := {|| self:GrdValid(oGtDados:oBrowse, oGtDados:aCols, oView ) }

Return oGtDados

Method HeaderCampo(cCampo, cGrid, cVar) Class TJURREVPREFAT
Local aHeadCampo := {}
Local aInfCampo := {}
                                  
Default cVar  := cCampo

	If !Empty(cCampo)

		If cCampo == STR0013 .OR. cCampo == STR0021 .OR. cCampo == STR0012 //Acumular? / Editar? / Indicador
		
			aAdd(aHeadCampo,  cCampo  		) 	//	 1- Título
			aAdd(aHeadCampo,  cVar   		) 	//	 2- Campo
			aAdd(aHeadCampo,  "@BMP"		)	//	 3- Picture // "@BMP"
			aAdd(aHeadCampo,  1  			) 	//	 4- Tamanho
			aAdd(aHeadCampo,  0  			) 	//	 5- Decimal
			aAdd(aHeadCampo,  {||.T.}		)	//	 6- Validação
			aAdd(aHeadCampo,  .T.  			) 	//	 7- Usado
			aAdd(aHeadCampo,  "L"  			) 	//	 8- Tipo
			aAdd(aHeadCampo,  "" 			) 	//	 9- F3
			aAdd(aHeadCampo,  ""			) 	//	10- Contexto ( Real ou Virtual )
			aAdd(aHeadCampo,  ""			)	//	11- Opções
			aAdd(aHeadCampo,  ""			)	//	12-	Inicializador Padrão
			If cCampo == STR0013
				aAdd(aHeadCampo,  "TJREVPREED('" + cGrid + "',n, '" + cVar  + "', " + IF(self:lEnable,".T.", ".F.") + " ) "	)	//	13-	Modo de Edição
			Else
				aAdd(aHeadCampo, ".F." 	) // 13- Modo de Edição
			EndIf
		Else
			aInfCampo	:= AVSX3(cVar)
			
			aAdd(aHeadCampo,  aInfCampo[5]  ) 		//	 1- Título
			aAdd(aHeadCampo,  cVar	     	) 		//	 2- Campo
			aAdd(aHeadCampo,  If(aInfCampo[2] == "C" .AND. Empty(aInfCampo[6]), "@!" , aInfCampo[6])  )		//	 3- Picture
			aAdd(aHeadCampo,  aInfCampo[3]  ) 		// 	 4- Tamanho
			aAdd(aHeadCampo,  aInfCampo[4]  ) 		//	 5- Decimal
			aAdd(aHeadCampo,  ""			)		//	 6- Validação
			aAdd(aHeadCampo,  ""			) 		//	 7- Usado
			aAdd(aHeadCampo,  aInfCampo[2]  ) 		//	 8- Tipo
			aAdd(aHeadCampo,  ""			) 		//	 9- F3
			aAdd(aHeadCampo,  ""			) 		//	10- Contexto ( Real ou Virtual )
			aAdd(aHeadCampo,  ""			)		//	11- Opções
			aAdd(aHeadCampo,  ""			)		//	12-	Inicializador Padrão
			aAdd(aHeadCampo,  "TJREVPREED('"+ cGrid + "',n, '"+ cVar  +"', " + IF(self:lEnable,".T.", ".F.") + " ) "	)		//	13-	Modo de Edição

		EndIf
	EndIf

Return aHeadCampo

Method GrdValid( oBrowse, aBrowse, oView ) Class TJURREVPREFAT
Local lRet      := .T.
Local lAchou    := .F.
Local oModel    := FwModelActive()
Local oModelNX0 := oModel:GetModel("NX0MASTER")
Local oModelNX8 := oModel:GetModel("NX8DETAIL")
Local oModelNX1 := oModel:GetModel("NX1DETAIL")
Local nLinNX8	  := 0
Local nLinNX1	  := 0
Local xValueold := aBrowse[oBrowse:nAt][oBrowse:nColPos]
Local xValueNew := &(ReadVar())
Local lReload	:= .F.

	If !(xValueold == xValueNew)

		// Selecionar o caso alterado:
		For nLinNX8 := 1 to oModelNX8:GetQtdLine()
			oModelNX8:GoLine(nLinNX8)
			For nLinNX1 := 1 to oModelNX1:GetQtdLine()
				oModelNX1:GoLine(nLinNX1)
				
				If oModelNX1:GetValue("NX1_CCLIEN" ) == aBrowse[oBrowse:nAt][NPOSCLI] .AND. ;
					oModelNX1:GetValue("NX1_CLOJA" ) == aBrowse[oBrowse:nAt][NPOSLOJA] .AND. ;
					oModelNX1:GetValue("NX1_CCASO" ) == aBrowse[oBrowse:nAt][NPOSCASO]

					lAchou	:= .T.
					//NPOSVTS			8	//	Valor de Time-Sheets
					//NPOSVDESP			9	//	Valor de Despesas
	
					If oBrowse:nColPos == NPOSTSREV
						lRet := JurSetValue( oModelNX1, "NX1_TSREV",, If(xValueNew=="LBOK", "1","2")  )
					endIf
					If lRet .And. oBrowse:nColPos == NPOSDPREV
						lRet := JurSetValue( oModelNX1, "NX1_DSPREV",, If(xValueNew=="LBOK", "1","2")  )
					endIf
					If lRet .And. oBrowse:nColPos == NPOSTBREV
						lRet := JurSetValue( oModelNX1, "NX1_TABREV",, If(xValueNew=="LBOK", "1","2")  )
					endIf				
					
					If lRet .And. oBrowse:nColPos == NPOSVTS .AND. oModelNX1:GetValue("NX1_TS" ) == "1" //VL TS

						If oModelNX0:CanSetValue("NX0_ALTPER")
							cTpAjuste := JASelOpcao("NX0_ALTPER")
							lRet := !Empty(cTpAjuste) // Se for em branco, quer dizer que cancelou.
						Else
							cTpAjuste := ""
						EndIf

						//NX0_ALTPER
						If lRet

							If !Empty(cTpAjuste)
								Self:Observacao(.T., 2, cTpAjuste)
								JurSetValue( oModelNX0, "NX0_ALTPER", ,cTpAjuste )
							EndIf
							lRet := JurSetValue( oModelNX1, "NX1_VTS",, xValueNew )
							aBrowse[oBrowse:nAt][oBrowse:nColPos] := oModelNX1:GetValue("NX1_VTS" )

						EndIf

						Exit
						
					EndIF

					If lRet .And. oBrowse:nColPos == NPOSVDESP .AND. oModelNX1:GetValue("NX1_DESP" ) == "1" //  Tem Despesa?

						cAltPer := oModelNX0:GetValue("NX0_ALTPER")
						lRet := lRet .AND. oModelNX0:LoadValue("NX0_ALTPER", "2")
						Self:Observacao(.T., 2, "2")
						
						If lRet := (oModelNX0:GetValue("NX0_ALTPER") == "2" .Or. oModelNX0:CanSetValue("NX0_ALTPER") ) // Tempo

							//Msg "Esta operação executará o ajuste nas despesas utilizando o tipo 2 - retira as últimas despesas do caso.
							// Tem certeza que que deseja continuar?"
							If ApMsgYesNo( STR0022 + CRLF + STR0023 )
								cTpAjuste := "2"
								Self:Observacao(.T., 2, cTpAjuste)
								JurSetValue(oModelNX0, "NX0_ALTPER", ,cTpAjuste)
								lRet := JurSetValue(oModelNX1, "NX1_VDESP", , xValueNew)
								lReload := lRet
							Else
								lRet := .F.
							EndIf
							aBrowse[oBrowse:nAt][oBrowse:nColPos] := oModelNX1:GetValue("NX1_VDESP")
						Else
							MsgStop(STR0030) // "Esta operação necessita utilizar a alteração por periodo como 'Ultimo', favor confirmar as alterações para poder utiliza-la!"
						EndIf
                        
						
						JurLoadValue( oModelNX0, "NX0_ALTPER", ,cAltPer )
						Exit

					EndIF

					//NPOSCPART		 3	//	Cód Revisor
					//NPOSDPART		 4	//	Desc Revisor
					If lRet .And. oBrowse:nColPos == NPOSCPART
	
						IIF(lRet, lRet := JurLoadValue( oModelNX1, "NX1_CPART", JurGetDados("RD0",9, xFilial("RD0") + xValueNew  , "RD0_CODIGO" ) ), )
						IIF(lRet, lRet := JurLoadValue( oModelNX1, "NX1_DPART", JurGetDados("RD0",9, xFilial("RD0") + xValueNew  , "RD0_NOME" ) ), )
						IIF(lRet, lRet := JurLoadValue( oModelNX1, "NX1_SIGLA", JurGetDados("RD0",9, xFilial("RD0") + xValueNew  , "RD0_SIGLA" ) ), )
						//JurLoadValue( oModelNX1, "NX1_SIGLA",, xValueNew )
						If lRet
							aBrowse[oBrowse:nAt][NPOSCPART] := oModelNX1:GetValue("NX1_SIGLA")
							aBrowse[oBrowse:nAt][NPOSDPART] := oModelNX1:GetValue("NX1_DPART")
						EndIf
						
					EndIf

					If lRet .And. oBrowse:nColPos == NPOSVDESC
						If lRet := JurSetValue( oModelNX1, "NX1_VLDESC", xValueNew )
							aBrowse[oBrowse:nAt][oBrowse:nColPos] := oModelNX1:GetValue("NX1_VLDESC")
						EndIf
					EndIf

				EndIf

				If !lRet
					Exit
				EndIf

			Next nLinNX1

			If lAchou
				Exit
			EndIf
		Next nLinNX8
		oView:Refresh()
		IF lReload
			self:Reload(oView)
		EndIf
	EndIf

Return lRet

Method MontaGrid(oBrowse, aBrowse, nSinal ) Class TJURREVPREFAT   
Local aLine := {}
Local nI := 0

Default nSinal	:= 0

	for nI := 1 to len(aBrowse[1])
		Do Case
			Case valtype(aBrowse[oBrowse:nAt,nI]) == "N"
				aadd( aLine, transform( aBrowse[oBrowse:nAt,nI], "@E 99,999,999,999.99" ) )
			Case valtype(aBrowse[oBrowse:nAt,nI]) == "L"
				If nSinal > 0 .AND. nI == nSinal
					aadd( aLine, If(aBrowse[oBrowse:nAt,nI],self:oAtivo,self:oInAtivo ) )	
				Else
					aadd( aLine, If(aBrowse[oBrowse:nAt,nI],self:oOk,self:oNo ) )	
				EndIf
			OtherWise
				aadd( aLine, aBrowse[oBrowse:nAt,nI]  ) 
		EndCase
	Next nI

Return aLine

Method EditarCel(aBrowse, oBrowse, oView, oGtDados, cTipo) Class TJURREVPREFAT
//Function EditarCel(aBrowse, oBrowse, oView)
//Local xValueold := aBrowse[oBrowse:nAt][oBrowse:nColPos]
//Local xValueNew
Local lRet      := .T.
Local lCheck    := .F.
Local cContr    := ""
Local cParc     := ""
Local nLinNX8   := 0
Local nLinNT1   := 0
Local nColNT1   := 0
Local nAtNT1Ant := 0
Local oModelNX8
Local oModelNT1

If cTipo == "NX1"

	If  oBrowse:nColPos <> NPOSREVISA .AND. aBrowse[oBrowse:nAt,NPOSREVISA] == "LBOK"

		Do Case
			Case valtype(aBrowse[oBrowse:nAt,oBrowse:nColPos]) == "L" .OR. oBrowse:nColPos == NPOSTSREV .OR. oBrowse:nColPos == NPOSDPREV .OR. oBrowse:nColPos == NPOSTBREV .OR. oBrowse:nColPos == NPOSRET

				aBrowse[oBrowse:nAt][oBrowse:nColPos] := IF( aBrowse[oBrowse:nAt][oBrowse:nColPos]=="LBNO", "LBOK", "LBNO" ) 
				lCheck	:= aBrowse[oBrowse:nAt][oBrowse:nColPos] == "LBOK"

				If oBrowse:nColPos == NPOSRET // 1 - Retirar

					self:oPDetLcTs:oCkRet:lcheckjur	:= lCheck
					self:oPDetLcTs:MarcaChecks(Nil, "0", 18 ) // [18] NPOSRETIR - retirar

					self:oPDetLcDp:oCkRet:lcheckjur	:= lCheck
					self:oPDetLcDp:MarcaChecks(Nil, "0", 18 ) // [18] NPOSRETIR - retirar

					self:oPDetLcTb:oCkRet:lcheckjur	:= lCheck
					self:oPDetLcTb:MarcaChecks(Nil, "0", 18 ) // [18] NPOSRETIR - retirar
					
					nAtNT1Ant := self:oGridFx:oBrowse:nAt
					nColNT1   := self:oGridFx:oBrowse:nColPos
					For nLinNT1 := 1 To Len(self:oGridFx:aCols)
					
						self:oGridFx:oBrowse:nAt     := nLinNT1
						self:oGridFx:oBrowse:nColPos := 1
						self:EditarCel(self:oGridFx:aCols, self:oGridFx:oBrowse, oView, oGtDados, "NT1")
					
					Next					
					self:oGridFx:oBrowse:nAt     := nAtNT1Ant
					self:oGridFx:oBrowse:nColPos := nColNT1
					self:oGridFx:Refresh()

				EndIf

				If oBrowse:nColPos == NPOSTSREV // 2 - TS Revisado
					self:oPDetLcTs:oCkRev:lcheckjur := lCheck
					self:oPDetLcTs:MarcaChecks(Nil, "0", 17 ) // [17]	NPOSREVIS - Revisado
				EndIf
			OtherWise
				self:oPDetCaso:EditCell()
		EndCase

	EndIf
	
ElseIf cTipo == "NT1"

	Do Case
		Case oBrowse:nColPos == 1 //Acumular
		
			aBrowse[oBrowse:nAt][oBrowse:nColPos] := IF( aBrowse[oBrowse:nAt][oBrowse:nColPos]=="LBNO", "LBOK", "LBNO" ) 
			lCheck	:= aBrowse[oBrowse:nAt][oBrowse:nColPos] == "LBOK"
			
			cContr := aBrowse[oBrowse:nAt][2]
			cParc  := aBrowse[oBrowse:nAt][3]
			
			oModelNX8 := self:oModel:GetModel("NX8DETAIL")
			oModelNT1 := self:oModel:GetModel("NT1DETAIL")

			For nLinNX8 := 1 to oModelNX8:GetQtdLine()
				oModelNX8:GoLine(nLinNX8)
				
				If cContr == oModelNX8:GetValue("NX8_CCONTR")
				
					For nLinNT1 := 1 to oModelNT1:GetQtdLine()
						oModelNT1:GoLine(nLinNT1)
						
						If cParc == oModelNT1:GetValue( "NT1_PARC" )

							lRet := JurLoadValue( oModelNT1, "NT1_TKRET", Nil, lCheck )
							
							oView:Refresh("NT1DETAIL")
							
						EndIf

					Next nLinNT1
				
				EndIf
			Next nLinNX8

	EndCase

EndIf

Return lRet

Method LineChange(cClien, cLoja, cCaso) Class TJURREVPREFAT       
//Local bAcao
Local lRet := .F.

	self:oCliente:Valor := cClien
	self:oloja:Valor    := Iif(cLojaAuto == "1", JurGetLjAt(), cLoja)
	self:oCaso:Valor	:= cCaso
	
	self:SelectCaso()


Return lRet

Method SelectCaso() Class TJURREVPREFAT  
Local lRet := .F.
Local aItems	:= {}
Local cNumClien := SuperGetMV( 'MV_JCASO1',, '1' ) // Seqüência da numeração do caso (1 - Por cliente / 2 - Independente)

	If Empty(self:oCliente:Valor) .OR. Empty(self:oloja:Valor) .OR. Empty(self:oCaso:Valor) 

		self:cDscClien	:= ""
		self:cDscCaso	:= ""
		self:oDscCaso:Valor	:= ""
	
	Else
		If !Empty(self:oCliente:Valor) .AND. !Empty(self:oloja:Valor) .AND. !Empty(self:oCaso:Valor) 
		
			self:cClien	:= self:oCliente:Valor
			self:cLoja	:= self:oloja:Valor
			self:cCaso	:= self:oCaso:Valor

			If lRet := ExistCpo( "SA1", self:cClien + self:cLoja )

				If cNumClien == "1"
					lRet := ExistCpo( "NVE", self:cClien + self:cLoja + self:cCaso, 1)
				Else
					lRet := ExistCpo('NVE', self:cCaso , 3)
				EndIf

				If lRet
				
					self:LoadLancs()
					
					self:cDscClien			:= AllTrim(JurGetDados("SA1",1,xFilial("SA1")+self:cClien+self:cLoja,"A1_NOME"))
					self:cDscCaso			:= AllTrim(JurGetDados("NVE",1,xFilial("NVE")+self:cClien+self:cLoja+self:cCaso,"NVE_TITULO"))
					self:oDscCaso:Valor	:= self:cDscCaso

					self:oPDetLcTs:SelectLancs(self:cClien, self:cLoja, self:cCaso, "oPDetLcTs" )
					self:oPDetLcTs:RefreshResumo( )
					self:oPDetLcDp:SelectLancs(self:cClien, self:cLoja, self:cCaso, "oPDetLcDp" )
					self:oPDetLcDp:RefreshResumo( )
					self:oPDetLcTb:SelectLancs(self:cClien, self:cLoja, self:cCaso, "oPDetLcTb" )
					self:oPDetLcTb:RefreshResumo( )
					If  alltrim(self:oPDetCaso:acols[self:oPDetCaso:oBrowse:nAt][NPOSREVISA])  == "LBOK" .AND. self:lEnable
						self:oPDetLcTs:Enable()
						self:oPDetLcDp:Enable()
						self:oPDetLcTb:Enable()
					Else
						self:oPDetLcTs:Disable()
						self:oPDetLcDp:Disable()					
						self:oPDetLcTb:Disable()
					EndIf

				EndIf
					
			EndIf
	
		EndIf

		self:oPDetLcTs:Primeiro()
		self:oPDetLcDp:Primeiro()
		self:oPDetLcTb:Primeiro()

	EndIf

	If lRet
		aItems := self:oPDetCaso:aCols
		nPos := aScan( aItems , { |ax|  self:cClien == ax[ NPOSCLI ], self:cLoja  == ax[ NPOSLOJA ], self:cCaso == ax[ NPOSCASO ] }  )
		If nPos > 0
			self:oPDetCaso:oBrowse:nAt	:= nPos
		EndIf

	    // Monta a linha a ser exibina no Browse de contratos (para o relacionamento )
	    aItems	:= self:ArrayContr()
	    self:oGridCt:aCols := aItems
	
		self:Refresh()
	EndIf
	
Return lRet

Method Refresh() Class TJURREVPREFAT     

	self:oCliente:Refresh()
	self:oloja:Refresh()
	self:oCaso:Refresh()
	self:oDscCaso:Refresh()
	

	self:nVlTS		:= FwFldGet("NX0_VTS")
	self:vlDesp		:= FwFldGet("NX0_VLFATD")
	self:vlHon		:= FwFldGet("NX0_VLFATH") - FwFldGet("NX0_VTS")
	self:cTpDesc	:= FwFldGet("NX0_TPDESC")
	self:nPcDesE	:= FwFldGet("NX0_PDESCH")
	self:nVlDesE	:= FwFldGet("NX0_DESCH")
	self:nVlDesL	:= FwFldGet("NX0_DESCON")	

	self:cObsRevis	:= FwFldGet("NX0_OBSREV")
	self:cObsRedat	:= FwFldGet("NX0_OBSRED")

	self:VlPF		:= self:nVlTS + self:vlHon + self:vlDesp - self:nVlDesE - self:nVlDesL
	
	self:VlSldAdi	:= J203SLDAD( self:cClien, self:cLoja, FwFldGet("NX0_CESCR"), FwFldGet("NX0_CMOEDA"), FwFldGet("NX0_DTEMI"), FwFldGet("NX0_CCONTR") )
	
	self:cDscClien	:= AllTrim(JurGetDados("SA1",1,xFilial("SA1")+self:cClien+self:cLoja,"A1_NOME"))
	self:cDscCaso	:= AllTrim(JurGetDados("NVE",1,xFilial("NVE")+self:cClien+self:cLoja+self:cCaso,"NVE_TITULO"))

	self:cObsCli	:= JurGetDados("NUH",1,xFilial("NUH")+self:cClien+self:cLoja, "NUH_OBSCAD")
	self:cObsCont	:= JurGetDados("NT0",1,xFilial("NT0")+FwFldGet("NX0_CCONTR"), "NT0_OBS")

	self:oVTS:Valor		:= self:nVlTS
	self:oVHon:Valor	:= self:vlHon
	self:oVDesp:Valor	:= self:vlDesp
	self:oVAdi:Valor	:= self:VlSldAdi
	self:oVPF:Valor		:= self:VlPF
	self:oVDescL:Valor		:= self:nVlDesL

	self:oTpDesc:Valor		:= self:cTpDesc

	self:oVDescE:Valor		:= self:nVlDesE
	self:oPDescE:Valor		:= self:nPcDesE

	self:oTpDesc:Enable(self:lRevisa)
	If self:oTpDesc:Valor == "1"
		self:oVDescE:Enable(self:lRevisa)
	Else
		self:oVDescE:Enable(.F.)
	EndIf
	If self:oTpDesc:Valor == "2"
		self:oPDescE:Enable(self:lRevisa)
	Else
		self:oPDescE:Enable(.F.)
	EndIf

	self:oDscCaso:Valor		:= self:cDscCaso

	self:oMoeda:Valor := self:cDesMoed
	self:oCotac:Valor := self:nCotac
	self:oCotac:oCampo:Picture := "@E 999.9999"

	self:oIdioma:Valor := self:cDIdioma

	If self:lEnable
		self:Habilita()
	Else
		self:Desabilita()
	EndIf

	self:oVTS:Refresh()
	self:oVHon:Refresh()
	self:oVDesp:Refresh()
	self:oVPF:Refresh()
	self:oVAdi:Refresh()
	self:oMoeda:Refresh()
	self:oCotac:Refresh()
	self:oIdioma:Refresh()
    
	self:oPDetCaso:Refresh()
	self:oGridCt:Refresh()
	self:oGridFx:Refresh()
	self:oPDetLcTs:Refresh()
	self:oPDetLcDp:Refresh()
	self:oPDetLcTb:Refresh()
Return nil

Method Habilita()  Class TJURREVPREFAT
	self:oCliente:Enable(.T.)
	self:oLoja:Enable(.T.)
	self:oCaso:Enable(.T.)
	self:oDscCaso:Enable(.F.)
	self:oVTS:Enable(self:lRevisa)
	self:oVHon:Enable(.F.)
	self:oVDesp:Enable(self:lRevisa)
	self:oVAdi:Enable(.F.)
	self:oVPF:Enable(.F.)
	self:oMoeda:Enable(.F.)
	self:oCotac:Enable(.F.)
	self:oIdioma:Enable(.F.)
	self:oTpDesc:Enable(.T.)
	If self:cTpDesc == "1"
		self:oVDescE:Enable(self:lRevisa)
	Else
		self:oVDescE:Enable(.F.)
	EndIf
	If self:cTpDesc == "2"
		self:oPDescE:Enable(self:lRevisa)
	Else
		self:oPDescE:Enable(.F.)
	EndIf
	
Return nil

Method Desabilita()  Class TJURREVPREFAT

	self:oDscCaso:Enable(.F.)
	self:oVTS:Enable(.F.)
	self:oVHon:Enable(.F.)
	self:oVDesp:Enable(.F.)
	self:oVAdi:Enable(.F.)
	self:oVPF:Enable(.F.)
	self:oMoeda:Enable(.F.)
	self:oCotac:Enable(.F.)
	self:oIdioma:Enable(.F.)
	self:oTpDesc:Enable(.F.)
	self:oPDescE:Enable(.F.)
	self:oVDescE:Enable(.F.)
	
Return nil
                                                                        
Method Reload(oView) Class TJURREVPREFAT     
Local aCasos := self:LoadCasos()
Local nI := 0
	//Atualiza o grid de casos
	self:lRevisa	:= JA202RCaso(self:cPreFt, self:cCodUsr)

    // Seta vetor para a browse                            
	self:oPDetCaso:aCols := aCasos
	self:oPDetCaso:oBrowse:Refresh()
	
    self:oPDetCaso:oBrowse:bChange := {|| self:LineChange(aCasos[self:oPDetCaso:oBrowse:nAt,NPOSCLI], aCasos[self:oPDetCaso:oBrowse:nAt,NPOSLOJA], aCasos[self:oPDetCaso:oBrowse:nAt,NPOSCASO]) }

	self:SelectCaso()
	
	self:oPDetLcTs:setListaCasos( self:GetListCasos("TS") )
	self:oPDetLcDp:setListaCasos( self:GetListCasos("DP") )
	self:oPDetLcTb:setListaCasos( self:GetListCasos("TB") )
	self:oGridFx:aCols := self:ArrayFixos()
	
	self:refresh()
Return nil


Method ConfirmRev(oView, lComit) Class TJURREVPREFAT
Local lRet       := .T.
Local cFiltroFX  := 0
Local aPosiFX    := {}
Local aArea      := GetArea() 
Local aSaveLines := FWSaveRows()
Local oModel     := FwModelActive()
Local cMsgWO     := "" 
Local aLanctos   := {}
Local lTrasf     := .F.
Local lMarcAll   := .F.
Local aObsWO	   := {} 
Local nSaveSX8 	 := GetSx8Len()  // guarda a quantidade de registro não confirmados antes da emissão 

Default lComit := .T.

	/************************************************************************/
	// 1 - Retirar Lançamentos
	/************************************************************************/
	// Marca os Lançementos 
	// - Marca o TKRET para transferir
	// - Inclui no Array aLanctos para desvincular em todas as situações (Trans / Retirar e WO) no final
	// NPOSRETIR		15	//[15]	retirar
	//  ??
	
	aLanctos := self:MarcaLanc()      // { aLancs, aPosiTS, aPosiDS, aPosiTB}
	If !Empty(aLanctos)
		aPosiTS  := aLanctos[2]
		aPosiDS  := aLanctos[3]
		aPosiTB  := aLanctos[4]
		lTrasf   := aLanctos[5]
		lMarcAll := aLanctos[6]
		
		aLanctos := aLanctos[1]
	EndIf
/*
	If Empty(aLanctos) .and. !JA202Updt(oModel)
		lRet := .F.
	EndIf
*/
	/************************************************************************/
	// 2 - Transferir Lançamentos
	/************************************************************************/
	// Marca os Lançementos (__TKRET)
	// NPOSTRANS		16	//[16]	Transferir 
BEGIN TRANSACTION

	If lRet .And. lTrasf
	
		IF (lRet := JA202CKDSP(oModel)) // Verifica se há despesas e se pode manipular.
	
			lRet := JA202TRANS()
			
		EndIF
		//EndIf	
	EndIf

	/************************************************************************/
	// 3 - Enviar para WO.
	/************************************************************************/
	// NPOSWO			11	//[11]	WO
	If lRet .AND.	( !Empty( aPosiTS ) .OR. !Empty( aPosiDS ) .OR. !Empty( aPosiTB ) )

		aObsWO := JurMotWO('NUF_OBSEMI', , )
		If lRet := !Empty(aObsWO)
			cMsgWO := JA202ENVWO( aPosiTS, aPosiDS, aPosiTB, cFiltroFX, aPosiFX, aObsWO )
		EndIf

		If lRet .And. !Empty(cMsgWO)
			ApMsgInfo( cMsgWO )

		EndIf

	EndIf

	//Desvincula os lançamentos após a execução das rotinas.
	//aLanctos := TJREVOnlyRet(aLanctos) // trata somente os lançamentos que serão retirados
	If lRet .AND. !Empty(aLanctos)
	
		lRet := lRet .AND. JA202LFatu( aLanctos )

		If lRet .And. lMarcAll
			//Cancela a Pre-fatura no encerramento da JURA202
			J202SetCan(.T.)
		EndIf

		If lRet
			lRet := Self:MarkCasRev()
		EndIf
	
		If lRet
		
			If !Empty(aLanctos) .And. !oModel:IsFieldUpdated("NX0MASTER","NX0_SITUAC")
				JurloadValue(oModel:GetModel("NX0MASTER"), "NX0_SITUAC", , "3")
				JurloadValue(oModel:GetModel("NX0MASTER"), "NX0_USRALT", , JurUsuario(__CUSERID))
				JurloadValue(oModel:GetModel("NX0MASTER"), "NX0_DTALT", , date())
			EndIf
	
			If lComit
	
				If oModel:VldData() // Alterada
					lRet := oModel:CommitData()
					oModel:Deactivate()
					oModel:Activate()
					
					If lRet
						ApMsgInfo( STR0014 ) // "Operação concluída!"
					EndIf
				
				Else
					JurShowErro( oModel:GetModel():GetErrormessage() )
					lRet := .F.
				EndIf
	
				oView:Refresh()
	
			EndIf
	
		EndIf

	EndIf

If lRet
	
	While GetSX8Len() > nSaveSX8 
		ConfirmSX8()
	EndDo	
		
Else
	
	While (GetSx8Len() > nSaveSX8)  //Libera os registros usados na transação 
		RollBackSX8()
	EndDo 
	DisarmTransaction()
	
 	JurMsgErro(STR0031) //"Operação(ões) cancelada(s)!"
	lRet := .F.
EndIf

END TRANSACTION	

FWRestRows(aSaveLines)
RestArea(aArea)
	
Return lRet

Method MarcaLanc() Class TJURREVPREFAT
Local nPos       := 0
Local aArea      := GetArea() 
Local aSaveLines := FWSaveRows( )
Local oModel     := FwModelActive()
Local oModelNT1  := oModel:GetModel("NT1DETAIL")
Local oModelNX8  := oModel:GetModel("NX8DETAIL")
Local oModelNX1  := oModel:GetModel("NX1DETAIL")
Local oModelNUE  := oModel:GetModel("NUEDETAIL")
Local oModelNVY  := oModel:GetModel("NVYDETAIL")
Local oModelNV4  := oModel:GetModel("NV4DETAIL")
Local nLinNT1    := 0
Local nLinNUE    := 0
Local nLinNVY    := 0
Local nLinNV4    := 0
Local nLinNX1    := 0
Local nLinNX8    := 0
Local nQtdNT1    := 0
Local nQtdNUE    := 0
Local nQtdNVY    := 0
Local nQtdNV4    := 0
Local nQtdNX1    := 0
Local nQtdNX8    := 0
Local aLancs     := {}
Local nPosCodlan := 7 // posição do array para o código do lançamento
Local nPosWO     := 14
Local nPosCob    := 16
Local nPosRet    := 18
Local nPosTrans  := 19
Local aCasos     := self:oPDetCaso:aCols
Local aPosTemp   := {}
Local aPosiTS    := {}
Local aPosiDS    := {}
Local aPosiTB    := {}

Local aRecnTS   := {}
Local aRecnDS   := {}
Local aRecnTB   := {}

Local lRet       := .F.
Local lTransf    := .F.
Local lParcFX    := .F.
Local lMarcAll   := .F.
Local lRev		:= .F.

For nLinNX8 := 1 to oModelNX8:GetQtdLine()
	oModelNX8:GoLine(nLinNX8)
	nQtdNX1 := 0	
	
	For nLinNX1 := 1 to oModelNX1:GetQtdLine()
		oModelNX1:GoLine(nLinNX1)

		lRev := JA202When(oModel)

		aRecnTS   := {}
		aRecnDS   := {}
		aRecnTB   := {}

		//Marca os Time-Sheets
		nQtdNUE := 0
		nQtdNVY := 0
		nQtdNV4 := 0

		For nLinNUE := 1 to oModelNUE:GetQtdLine()
			oModelNUE:GoLine(nLinNUE)
			If JMdlNewLine(oModelNUE)
				nQtdNUE++
			EndIf
			
			nPos := aScan(self:oPDetLcTs:aItems, {|x| x[nPosCodlan] == oModelNUE:GetValue( "NUE_COD" ) }  )
			If nPos > 0 

				If self:oPDetLcTs:aItems[nPos][nPosWO] .OR. self:oPDetLcTs:aItems[nPos][nPosRet] .OR. self:oPDetLcTs:aItems[nPos][nPosTrans]
					Aadd( aLancs, { "NUE", ;
									1, ;
									oModelNUE:GetValue( "NUE_COD" ), ;
									oModel, ;
									{nLinNX8, nLinNX1, nLinNUE},  ;
									"NW0", ;
									1, ;
									xFilial("NW0")+oModelNUE:GetValue( "NUE_COD" )+"1"+self:cPreFt,;
									self:oPDetLcTs:aItems[nPos][nPosWO],;
									self:oPDetLcTs:aItems[nPos][nPosRet];
									};
						)
					nQtdNUE++

				EndIf

				If lRev
					If self:oPDetLcTs:aItems[nPos][nPosRet] .OR. self:oPDetLcTs:aItems[nPos][nPosTrans] 
						lRet := JurSetValue( oModelNUE, "NUE_TKRET",, .T. )
					Else
						lRet := JurSetValue( oModelNUE, "NUE_TKRET",, .F. )
					EndIf
				EndIf
				If self:oPDetLcTs:aItems[nPos][nPosTrans]
					lTransf := .T.
				EndIf
				If self:oPDetLcTs:aItems[nPos][nPosWO]
					Aadd(aRecnTS , oModelNUE:GetDataID(nLinNUE))
				EndIf
			EndIf

		Next nLinNUE

		//Marca as Despesas
		For nLinNVY := 1 to oModelNVY:GetQtdLine()
			oModelNVY:GoLine(nLinNVY)
			
			If JMdlNewLine(oModelNVY)
				nQtdNVY++
			EndIf

			nPos := aScan(self:oPDetLcDp:aItems, {|x| x[nPosCodlan] == oModelNVY:GetValue( "NVY_COD" ) } )
			If nPos > 0 
				If self:oPDetLcDp:aItems[nPos][nPosWO] .OR. self:oPDetLcDp:aItems[nPos][nPosRet] .OR. self:oPDetLcDp:aItems[nPos][nPosTrans];  //Para transferir pela 202 precisa marcar o lançamento
					.OR. !self:oPDetLcDp:aItems[nPos][nPosCob]
					Aadd( aLancs, { "NVY", ;
									1, ;
									oModelNVY:GetValue( "NVY_COD" ), ;
									oModel, ;
									{nLinNX8, nLinNX1, nLinNVY},  ;
									"NVZ", ;
									1, ;
									xFilial("NVZ")+oModelNVY:GetValue( "NVY_COD" )+"1"+self:cPreFt,;
									self:oPDetLcDp:aItems[nPos][nPosWO],;
									self:oPDetLcDp:aItems[nPos][nPosRet] .Or. !self:oPDetLcDp:aItems[nPos][nPosCob];
									};
						)
					nQtdNVY++
				EndIF

				If  lRev
					If self:oPDetLcDp:aItems[nPos][nPosRet] .OR. self:oPDetLcDp:aItems[nPos][nPosTrans] 
						lRet := JurSetValue( oModelNVY, "NVY_TKRET",, .T. )
					Else
						lRet := JurSetValue( oModelNVY, "NVY_TKRET",, .F. )
					EndIf
				EndIf
				If self:oPDetLcDp:aItems[nPos][nPosTrans]
					lTransf := .T.
				EndIf
				If self:oPDetLcDp:aItems[nPos][nPosWO]
					Aadd(aRecnDS , oModelNVY:GetDataID(nLinNVY) )
				EndIf
			EndIf
		Next nLinNVY

		//Marca os Tabelados
		For nLinNV4 := 1 to oModelNV4:GetQtdLine()
			oModelNV4:GoLine(nLinNV4)
			
			If JMdlNewLine(oModelNV4)
				nQtdNV4++
			EndIf
			
			nPos := aScan(self:oPDetLcTb:aItems, {|x| x[nPosCodlan] == oModelNV4:GetValue( "NV4_COD" ) } )
			If nPos > 0 
				If self:oPDetLcTb:aItems[nPos][nPosWO] .OR. self:oPDetLcTb:aItems[nPos][nPosRet] .OR. self:oPDetLcTb:aItems[nPos][nPosTrans]; //Para transferir pela 202 precisa marcar o lançamento
					.OR. !self:oPDetLcTb:aItems[nPos][nPosCob] 

					Aadd( aLancs, { "NV4", ;
									1, ;
									oModelNV4:GetValue( "NV4_COD" ), ;
									oModel, ;
									{nLinNX8, nLinNX1, nLinNV4},  ;
									"NW4", ;
									4, ;
									xFilial("NW4")+oModelNV4:GetValue( "NV4_COD" )+"1"+self:cPreFt,;
									self:oPDetLcTb:aItems[nPos][nPosWO],;
									self:oPDetLcTb:aItems[nPos][nPosRet] .OR. !self:oPDetLcTb:aItems[nPos][nPosCob];
									};
						)
					nQtdNV4++
				EndIf
				If  lRev
					If self:oPDetLcTb:aItems[nPos][nPosRet] .OR. self:oPDetLcTb:aItems[nPos][nPosTrans] 
						lRet := JurSetValue( oModelNV4, "NV4_TKRET",, .T. )
					Else
						lRet := JurSetValue( oModelNV4, "NV4_TKRET",, .F. )
					EndIf
				EndIf
				If self:oPDetLcTb:aItems[nPos][nPosTrans]
					lTransf := .T.
				EndIf
				If self:oPDetLcTb:aItems[nPos][nPosWO]
					Aadd(aRecnTB , oModelNV4:GetDataID(nLinNV4))
				EndIf
			EndIf
		Next nLinNV4

		If nQtdNUE == oModelNUE:GetQtdLine() .And. nQtdNVY == oModelNVY:GetQtdLine() .And. nQtdNV4 == oModelNV4:GetQtdLine()
			nQtdNX1++
			nRecnoNX1 := oModelNX1:GetDataID()
		Else
			nRecnoNX1 := 0
		EndIf

		If !Empty(aRecnTS)
			AAdd(aPosiTS, {0, nRecnoNX1, aRecnTS})
		EndIf

		If !Empty(aRecnDS)
			AAdd(aPosiDS, {0, nRecnoNX1, aRecnDS})
		EndIf			

		If !Empty(aRecnTB)
			AAdd(aPosiTB, {0, nRecnoNX1, aRecnTB})
		EndIf	

	Next nLinNX1

	/*
	//Marca os Fixos - ??
	*/
	For nLinNT1 := 1 to oModelNT1:GetQtdLine()
		oModelNT1:GoLine(nLinNT1)

		If !JMdlNewLine(oModelNT1)
			//lParcFX := .T.
			
			nPos := aScan(self:oGridFx:aCols, {|x| x[2] == oModelNT1:GetValue( "NT1_CCONTR" ) .And. x[3] == oModelNT1:GetValue( "NT1_PARC" ) } )
			
			If nPos > 0
			
				If self:oGridFx:aCols[nPos][1] == "LBOK" //Retirar
				
					Aadd( aLancs, { "NT1", ;
									1, ;
									oModelNT1:GetValue( "NT1_SEQUEN" ), ;
									oModel, ;
									{nLinNX8, 1, nLinNT1},  ;
									"NWE", ;
									1, ;
									xFilial("NWE")+oModelNT1:GetValue( "NT1_SEQUEN" )+"1"+self:cPreFt,;
									.F.,;
									(self:oGridFx:aCols[nPos][1] == "LBOK");
									};
						)
						
					nQtdNT1++
					
					lRet := JurSetValue( oModelNT1, "NT1_TKRET",, .T. )
				
				EndIf
			
			EndIf
			
		EndIf
		
	Next nLinNT1
	
	If nQtdNX1 == oModelNX1:GetQtdLine() .And. !lParcFX
		nQtdNX8++
	EndIf

Next nLinNX8

lMarcAll := ( nQtdNX8 == oModelNX8:GetQtdLine() )

If !lRet
	aLancs := {}
EndIf

Return { aLancs, aPosiTS, aPosiDS, aPosiTB, lTransf, lMarcAll}


Method RetiraLanc( nPosCodlan, nPosCodItem ) Class TJURREVPREFAT
Local lRet 			:= .F.
Local oModel		:= FwModelActive()
Local oModelNX8		:= oModel:GetModel("NX8DETAIL")
Local oModelNX1		:= oModel:GetModel("NX1DETAIL")
Local oModelNUE		:= oModel:GetModel("NUEDETAIL")
Local oModelNVY		:= oModel:GetModel("NVYDETAIL")
Local oModelNV4		:= oModel:GetModel("NV4DETAIL")
Local nLinNUE		:= 0
Local nLinNVY		:= 0
Local nLinNV4		:= 0
Local nLinNX1		:= 0
Local nLinNX8		:= 0
Local aLancs		:= {}

	If 	nPosCodItem == 11 .OR. ;  //WO 
		nPosCodItem == 15			// Retirar

		For nLinNX8 := 1 to oModelNX8:GetQtdLine()
			oModelNX8:GoLine(nLinNX8)
			For nLinNX1 := 1 to oModelNX1:GetQtdLine()
				oModelNX1:GoLine(nLinNX1)
	
	            //Remove os Time-Sheets da pré
				For nLinNUE := 1 to oModelNUE:GetQtdLine()
					oModelNUE:GoLine(nLinNUE)
					nPos := aScan(self:oPDetLcTs:aItems, {|x| x[nPosCodlan] == oModelNUE:GetValue( "NUE_COD" ) }  )
					If nPos > 0 
						If self:oPDetLcTs:aItems[nPos][nPosCodItem]
							lRet := JurLoadValue( oModelNUE, "NUE_CPREFT",, "" )
						EndIf
					EndIf
				Next nLinNUE
				
	
	            //Remove as Despesas da pré
				For nLinNVY := 1 to oModelNVY:GetQtdLine()
					oModelNVY:GoLine(nLinNVY)
					nPos := aScan(self:oPDetLcDp:aItems, {|x| x[nPosCodlan] == oModelNVY:GetValue( "NVY_COD" ) } )
					If nPos > 0 
					    If self:oPDetLcDp:aItems[nPos][nPosCodItem]
							lRet := JurLoadValue( oModelNVY, "NVY_CPREFT",, "" )
						EndIf
					EndIf
				Next nLinNVY
	
	            //Remove os Tabelados da pré
				For nLinNV4 := 1 to oModelNV4:GetQtdLine()
					oModelNV4:GoLine(nLinNV4)
					nPos := aScan(self:oPDetLcTb:aItems, {|x| x[nPosCodlan] == oModelNV4:GetValue( "NV4_COD" ) } )
					If nPos > 0 
					    If self:oPDetLcTb:aItems[nPos][nPosCodItem]
						    lRet := JurLoadValue( oModelNV4, "NV4_CPREFT",, "" )
						EndIf
					EndIf
				Next nLinNV4
				
			Next nLinNX1
			
			//
			//Marca os Fixos - ??
			//
	
		Next nLinNX8 
		
		lRet := JA202LFatu( aLancs )
		
	Else
		lRet := .F.
	EndIf

Return lRet

Method LoadCasos() Class TJURREVPREFAT
Local aCasos      := {}
Local aArea			  := GetArea() 
Local aSaveLines 	:= FWSaveRows( )
Local oModel		   := FwModelActive()
Local oModelNX8	 := oModel:GetModel("NX8DETAIL")
Local oModelNX1	 := oModel:GetModel("NX1DETAIL")
Local nLinNX1		 := 0
Local nLinNX8		 := 0
Local lRev			   := .F.
Local cNumCaso   := SuperGetMV( 'MV_JCASO1' ,, 2   )  //Seqüencia da numeracao do caso: por cliente (1) ou independente o cliente (2)
Local nAjs   := 0

	For nLinNX8 := 1 to oModelNX8:GetQtdLine()
		oModelNX8:GoLine(nLinNX8)
		For nLinNX1 := 1 to oModelNX1:GetQtdLine()
			oModelNX1:GoLine(nLinNX1)
             
			lRev	:= JA202When(oModel)
			If(cLojaAuto == "1")
				aAdd(aCasos , { If(lRev, "LBOK" ,  "LBNO"),;
								"LBNO",;
								If(oModelNX1:GetValue( "NX1_TSREV"  )=="1","LBOK","LBNO"), ;
								If(oModelNX1:GetValue( "NX1_DSPREV" )=="1","LBOK","LBNO"), ;
								If(oModelNX1:GetValue( "NX1_TABREV" )=="1","LBOK","LBNO"), ;
								oModelNX1:GetValue( "NX1_SIGLA" ),;
								oModelNX1:GetValue( "NX1_DPART" ),;
								oModelNX1:GetValue( "NX1_CCLIEN" ),;
								oModelNX1:GetValue( "NX1_CCASO" ),;
								oModelNX1:GetValue( "NX1_VTS" ),;
								oModelNX1:GetValue( "NX1_VDESP" ),;
								oModelNX1:GetValue( "NX1_VTAB" ),;
								oModelNX1:GetValue( "NX1_VLDESC" ),;
								oModelNX1:GetValue( "NX1_DCLIEN" ),;
								oModelNX1:GetValue( "NX1_DCASO" ),;
								.F.   /* //Indica se está deletado (msnewgetdados)*/  ;
								})
				nAjs := 1
			Else
				aAdd(aCasos , { If(lRev, "LBOK" ,  "LBNO"),;
								"LBNO",;
								If(oModelNX1:GetValue( "NX1_TSREV"  )=="1","LBOK","LBNO"), ; 
								If(oModelNX1:GetValue( "NX1_DSPREV" )=="1","LBOK","LBNO"), ; 
								If(oModelNX1:GetValue( "NX1_TABREV" )=="1","LBOK","LBNO"), ; 
								oModelNX1:GetValue( "NX1_SIGLA" ),;
								oModelNX1:GetValue( "NX1_DPART" ),;
								oModelNX1:GetValue( "NX1_CCLIEN" ),;
								oModelNX1:GetValue( "NX1_CLOJA" ),;
								oModelNX1:GetValue( "NX1_CCASO" ),;
								oModelNX1:GetValue( "NX1_VTS" ),;
								oModelNX1:GetValue( "NX1_VDESP" ),;
								oModelNX1:GetValue( "NX1_VTAB" ),;
								oModelNX1:GetValue( "NX1_VLDESC" ),;
								oModelNX1:GetValue( "NX1_DCLIEN" ),;
								oModelNX1:GetValue( "NX1_DCASO" ),;
								.F.   /* //Indica se está deletado (msnewgetdados)*/  ;
								})
			EndIf
		Next nLinNX1
	Next nLinNX8
	
	If cNumCaso $ '1'
		aSort( aCasos,,, { |aX,aY|  aX[8-nAjs] + aX[9-nAjs] + aX[10-nAjs]  <  aY[8-nAjs] + aY[9-nAjs] + aY[10-nAjs]  } )
	Else
		aSort( aCasos,,, { |aX,aY|  aX[10-nAjs]  <  aY[10-nAjs]  } )
	EndIf

	FWRestRows( aSaveLines )
	RestArea( aArea )
		
Return aCasos

Method LoadLancs() Class TJURREVPREFAT
Local aTSheets 	 := {} 
Local aDesps     := {}
Local aServicos  := {}
Local aArea			 := GetArea()
Local oModel		 := FwModelActive()
Local aSaveLines := FWSaveRows(oModel)
Local oModelNX8  := oModel:GetModel("NX8DETAIL")
Local oModelNX1  := oModel:GetModel("NX1DETAIL")
Local oModelNUE	 := oModel:GetModel("NUEDETAIL")
Local oModelNVY	 := oModel:GetModel("NVYDETAIL")
Local oModelNV4	 := oModel:GetModel("NV4DETAIL")
Local nLinNUE		 := 0
Local nLinNVY		 := 0
Local nLinNV4		 := 0
Local nLinNX1		 := 0
Local nLinNX8		 := 0

	For nLinNX8 := 1 to oModelNX8:GetQtdLine()
		oModelNX8:GoLine(nLinNX8)
		For nLinNX1 := 1 to oModelNX1:GetQtdLine()
			oModelNX1:GoLine(nLinNX1)

			For nLinNUE := 1 to oModelNUE:GetQtdLine()
				oModelNUE:GoLine(nLinNUE)

				If !Empty( oModelNUE:GetValue( "NUE_CCLIEN" ) ) .AND. !Empty( oModelNUE:GetValue( "NUE_CLOJA" ) ) .AND. !Empty( oModelNUE:GetValue( "NUE_CCASO" ) )				
					aAdd(aTSheets, { nLinNX8, ;
					                 nLinNX1, ;
					                 nLinNUE, ;
					                 oModelNUE:GetValue("NUE_CCLIEN"),;
                           oModelNUE:GetValue( "NUE_CLOJA" ),;
                           oModelNUE:GetValue( "NUE_CCASO" ),;
                           oModelNUE:GetValue( "NUE_COD" ),;
                           oModelNUE:GetValue( "NUE_DATATS" ),;
                           oModelNUE:GetValue( "NUE_SIGLA2" ),;
                           oModelNUE:GetValue( "NUE_CATIVI" ),;
                           oModelNUE:GetValue( "NUE_DESC" ),;
                           oModelNUE:GetValue( self:cCpoLanc ),;
                           oModelNUE:GetValue( self:cCpoRev ),;
                           .F./*WO*/,;
                           .F./*DE*/,;
                           If(oModelNUE:GetValue( "NUE_COBRAR" ) == "1",.T.,.F.) /*COBRAR*/,;
                           If(oModelNUE:GetValue( "NUE_REVISA" ) == "1",.T.,.F.)/*REVISA*/,;
                           .F./*Acumular*/,;
                           .F./*Transferir*/,;
                           oModelNUE:GetValue( "NUE_VALORH" ) * ( oModelNUE:GetValue( "NUE_COTAC1" ) / oModelNUE:GetValue( "NUE_COTAC2" )  )/*TS - VLH*/,;
                           oModelNUE:GetValue( "NUE_VALOR1" )/*TS VL1*/,;
                           oModelNUE:GetValue( "NUE_CPART2" );
                         };
              )
				 	EndIf
			Next nLinNUE

			For nLinNVY := 1 to oModelNVY:GetQtdLine()
				oModelNVY:GoLine(nLinNVY)
				
				
				If !Empty( oModelNVY:GetValue( "NVY_CCLIEN" ) ) .AND. !Empty( oModelNVY:GetValue( "NVY_CLOJA" ) ) .AND. !Empty( oModelNVY:GetValue( "NVY_CCASO" ) )
				
					aAdd(aDesps, { nLinNX8, ;
					               nLinNX1, ;
					               nLinNVY, ;
                         oModelNVY:GetValue( "NVY_CCLIEN" ),;
                         oModelNVY:GetValue( "NVY_CLOJA" ),;
                         oModelNVY:GetValue( "NVY_CCASO" ),;
                         oModelNVY:GetValue( "NVY_COD" ),;
                         oModelNVY:GetValue( "NVY_DATA" ),;
                         oModelNVY:GetValue( "NVY_SIGLA" ),;
                         oModelNVY:GetValue( "NVY_CTPDSP" ),;
                         oModelNVY:GetValue( "NVY_DESCRI" ),;
                         AllTrim(JurGetDados("CTO",1,xFilial("CTO")+oModelNVY:GetValue( "NVY_CMOEDA" ),"CTO_SIMB")),;
                         oModelNVY:GetValue( "NVY_VALOR" ),;
                         .F./*WO*/,;
                         "" /*DE*/,;
                         If(oModelNVY:GetValue( "NVY_COBRAR" ) == "1",.T.,.F.) /*COBRAR*/,;
                         "" /*REVIS*/,;
                         .F./*Acumular*/,;
                         .F./*Transferir*/,;
                         ""/*TS - VL H*/,;
                         "" /*TS - Vl 1*/,;
                         oModelNVY:GetValue( "NVY_CPART" );
                       };
					 	)
      				EndIf
			Next nLinNVY

			For nLinNV4 := 1 to oModelNV4:GetQtdLine()
				oModelNV4:GoLine(nLinNV4)
				
				If !Empty( oModelNV4:GetValue( "NV4_CCLIEN" ) ) .AND. !Empty( oModelNV4:GetValue( "NV4_CLOJA" ) ) .AND. !Empty( oModelNV4:GetValue( "NV4_CCASO" ) )				
				
					aAdd(aServicos, { nLinNX8, ;
					                  nLinNX1, ;
					                  nLinNV4, ;
                            oModelNV4:GetValue( "NV4_CCLIEN" ),;
                            oModelNV4:GetValue( "NV4_CLOJA" ),;
                            oModelNV4:GetValue( "NV4_CCASO" ),;
                            oModelNV4:GetValue( "NV4_COD" ),;
                            oModelNV4:GetValue( "NV4_DTLANC" ),;
                            oModelNV4:GetValue( "NV4_SIGLA" ),;
                            oModelNV4:GetValue( "NV4_CTPSRV" ),;
                            oModelNV4:GetValue( "NV4_DESCRI" ),;
                            AllTrim(JurGetDados("CTO",1,xFilial("CTO")+oModelNV4:GetValue( "NV4_CMOEH" ),"CTO_SIMB")),;
                            oModelNV4:GetValue( "NV4_VLHFAT" ),;
                            .F./*WO*/,;
                            .F./*DE*/,;
                            If(oModelNV4:GetValue( "NV4_COBRAR" ) =="1",.T.,.F.)/*COBRAR*/,;
                            ""/*REVIS*/,;
                            .F./*Acumular*/,;
                            .F./*Transferir*/,;
                            ""/*TS - VL H*/,;
                            "" /*TS - Vl 1*/,;
                            oModelNV4:GetValue( "NV4_CPART" );
                          };
					 	)
				 	EndIf

			Next nLinNV4

		Next nLinNX1
	Next nLinNX8

	self:oPDetLcTs:SetArrayLanc( aTSheets )
	self:oPDetLcTs:SelectLancs(self:cClien, self:cLoja, self:cCaso, "self:oPDetLcTs" )

	self:oPDetLcDp:SetArrayLanc( aDesps )
	self:oPDetLcDp:SelectLancs(self:cClien, self:cLoja, self:cCaso, "self:oPDetLcDp" )

	self:oPDetLcTb:SetArrayLanc( aServicos )
	self:oPDetLcTb:SelectLancs(self:cClien, self:cLoja, self:cCaso, "self:oPDetLcTb" )

	FWRestRows( aSaveLines )
	RestArea( aArea )

Return nil

Method LoadTS(oGridLanc) Class TJURREVPREFAT
Local aTSheets 		:= {} 
Local aArea			:= GetArea()
Local aSaveLines 	:= FWSaveRows( )
Local oModel		:= FwModelActive()
Local oModelNX8		:= oModel:GetModel("NX8DETAIL")
Local oModelNX1		:= oModel:GetModel("NX1DETAIL")
Local oModelNUE		:= oModel:GetModel("NUEDETAIL")
Local nLinNUE		:= 0
Local nLinNX1		:= 0
Local nLinNX8		:= 0

	For nLinNX8 := 1 to oModelNX8:GetQtdLine()
		oModelNX8:GoLine(nLinNX8)
		For nLinNX1 := 1 to oModelNX1:GetQtdLine()
			oModelNX1:GoLine(nLinNX1)
			For nLinNUE := 1 to oModelNUE:GetQtdLine()
				oModelNUE:GoLine(nLinNUE)

				If !Empty( oModelNUE:GetValue( "NUE_CPREFT" ) ) .AND. !Empty( oModelNUE:GetValue( "NUE_CCLIEN" ) ) .AND. !Empty( oModelNUE:GetValue( "NUE_CLOJA" ) ) .AND. !Empty( oModelNUE:GetValue( "NUE_CCASO" ) )				

					aAdd(aTSheets, { nLinNX8, ;
					                 nLinNX1, ;
					                 nLinNUE, ;
					                 oModelNUE:GetValue("NUE_CCLIEN"),;
                           oModelNUE:GetValue( "NUE_CLOJA" ),;
                           oModelNUE:GetValue( "NUE_CCASO" ),;
                           oModelNUE:GetValue( "NUE_COD" ),;
                           oModelNUE:GetValue( "NUE_DATATS" ),;
                           oModelNUE:GetValue( "NUE_SIGLA2" ),;
                           oModelNUE:GetValue( "NUE_CATIVI" ),;
                           oModelNUE:GetValue( "NUE_DESC" ),;
                           oModelNUE:GetValue( self:cCpoLanc ),;
                           oModelNUE:GetValue( self:cCpoRev ),;
                           .F./*WO*/,;
                           .F./*DE*/,;
                           If(oModelNUE:GetValue( "NUE_COBRAR" ) == "1",.T.,.F.) /*COBRAR*/,;
                           If(oModelNUE:GetValue( "NUE_REVISA" ) == "1",.T.,.F.)/*REVISA*/,;
                           .F./*Acumular*/,;
                           .F./*Transferir*/,;
                           oModelNUE:GetValue( "NUE_VALORH" ) * ( oModelNUE:GetValue( "NUE_COTAC1" ) / oModelNUE:GetValue( "NUE_COTAC2" )  )/*TS - VLH*/,;
                           oModelNUE:GetValue( "NUE_VALOR1" )/*TS VL1*/;
                         };
              )
				 	EndIf

			Next nLinNUE
		Next nLinNX1
	Next nLinNX8

	oGridLanc:SetArrayLanc( aTSheets )
	oGridLanc:SelectLancs(self:cClien, self:cLoja, self:cCaso, "oGridLanc" )

	FWRestRows( aSaveLines )
	RestArea( aArea )

Return nil

Method LoadDP(oGridLanc) Class TJURREVPREFAT     
Local aDesps := {} 
Local aArea			:= GetArea()
Local aSaveLines 	:= FWSaveRows( )
Local oModel		:= FwModelActive()
Local oModelNX8		:= oModel:GetModel("NX8DETAIL")
Local oModelNX1		:= oModel:GetModel("NX1DETAIL")
Local oModelNVY		:= oModel:GetModel("NVYDETAIL")
Local nLinNVY		:= 0
Local nLinNX1		:= 0
Local nLinNX8		:= 0



	For nLinNX8 := 1 to oModelNX8:GetQtdLine()
		oModelNX8:GoLine(nLinNX8)
		For nLinNX1 := 1 to oModelNX1:GetQtdLine()
			oModelNX1:GoLine(nLinNX1)
			For nLinNVY := 1 to oModelNVY:GetQtdLine()
				oModelNVY:GoLine(nLinNVY)
				
				
				If  !Empty( oModelNVY:GetValue( "NVY_CPREFT" ) ) .AND. !Empty( oModelNVY:GetValue( "NVY_CCLIEN" ) ) .AND. !Empty( oModelNVY:GetValue( "NVY_CLOJA" ) ) .AND. !Empty( oModelNVY:GetValue( "NVY_CCASO" ) )
				
					aAdd(aDesps, { nLinNX8, ;
					               nLinNX1, ;
					               nLinNVY, ;
                         oModelNVY:GetValue( "NVY_CCLIEN" ),;
                         oModelNVY:GetValue( "NVY_CLOJA" ),;
                         oModelNVY:GetValue( "NVY_CCASO" ),;
                         oModelNVY:GetValue( "NVY_COD" ),;
                         oModelNVY:GetValue( "NVY_DATA" ),;
                         oModelNVY:GetValue( "NVY_SIGLA" ),;
                         oModelNVY:GetValue( "NVY_CTPDSP" ),;
                         oModelNVY:GetValue( "NVY_DESCRI" ),;
                         AllTrim(JurGetDados("CTO",1,xFilial("CTO")+oModelNVY:GetValue( "NVY_CMOEDA" ),"CTO_SIMB")),;
                         oModelNVY:GetValue( "NVY_VALOR" ),;
                         .F./*WO*/,;
                         "" /*DE*/,;
                         If(oModelNVY:GetValue( "NVY_COBRAR" ) == "1",.T.,.F.) /*COBRAR*/,;
                         "" /*REVIS*/,;
                         .F./*Acumular*/,;
                         .F./*Transferir*/,;
                         ""/*TS - VL H*/,;
                         "" /*TS - Vl 1*/;
                       };
					 	)
				EndIf
			Next nLinNVY
		Next nLinNX1
	Next nLinNX8
	
	oGridLanc:SetArrayLanc( aDesps )
	oGridLanc:SelectLancs(self:cClien, self:cLoja, self:cCaso, "oGridLanc" )

	FWRestRows( aSaveLines )
	RestArea( aArea )

Return nil

Method LoadTB(oGridLanc) Class TJURREVPREFAT     
Local aServicos := {} 
Local aArea			:= GetArea()
Local aSaveLines 	:= FWSaveRows( )
Local oModel		:= FwModelActive()
Local oModelNX8		:= oModel:GetModel("NX8DETAIL")
Local oModelNX1		:= oModel:GetModel("NX1DETAIL")
Local oModelNV4		:= oModel:GetModel("NV4DETAIL")
Local nLinNV4		:= 0
Local nLinNX1		:= 0
Local nLinNX8		:= 0

	For nLinNX8 := 1 to oModelNX8:GetQtdLine()
		oModelNX8:GoLine(nLinNX8)
		For nLinNX1 := 1 to oModelNX1:GetQtdLine()
			oModelNX1:GoLine(nLinNX1)
			For nLinNV4 := 1 to oModelNV4:GetQtdLine()
				oModelNV4:GoLine(nLinNV4)
				
				If !Empty( oModelNV4:GetValue( "NV4_CPREFT" ) ) .AND. !Empty( oModelNV4:GetValue( "NV4_CCLIEN" ) ) .AND. !Empty( oModelNV4:GetValue( "NV4_CLOJA" ) ) .AND. !Empty( oModelNV4:GetValue( "NV4_CCASO" ) )				
				
					aAdd(aServicos, { nLinNX8, ;
					                  nLinNX1, ;
					                  nLinNV4, ;
                            oModelNV4:GetValue( "NV4_CCLIEN" ),;
                            oModelNV4:GetValue( "NV4_CLOJA" ),;
                            oModelNV4:GetValue( "NV4_CCASO" ),;
                            oModelNV4:GetValue( "NV4_COD" ),;
                            oModelNV4:GetValue( "NV4_DTLANC" ),;
                            oModelNV4:GetValue( "NV4_SIGLA" ),;
                            oModelNV4:GetValue( "NV4_CTPSRV" ),;
                            oModelNV4:GetValue( "NV4_DESCRI" ),;
                            AllTrim(JurGetDados("CTO",1,xFilial("CTO")+oModelNV4:GetValue( "NV4_CMOEH" ),"CTO_SIMB")),;
                            oModelNV4:GetValue( "NV4_VLHFAT" ),;
                            .F./*WO*/,;
                            .F./*DE*/,;
                            If(oModelNV4:GetValue( "NV4_COBRAR" ) == "1",.T.,.F.)/*COBRAR*/,;
                            ""/*REVIS*/,;
                            .F./*Acumular*/,;
                            .F./*Transferir*/,;
                            ""/*TS - VL H*/,;
                            "" /*TS - Vl 1*/;
                          };
					 	)

				 	EndIf

			Next nLinNV4
		Next nLinNX1
	Next nLinNX8

	oGridLanc:SetArrayLanc( aServicos )
	oGridLanc:SelectLancs(self:cClien, self:cLoja, self:cCaso, "oGridLanc" )

	FWRestRows( aSaveLines )
	RestArea( aArea )

Return nil


Method AddNavBar(oParent, oView) Class TJURREVPREFAT

	//Verifica se o objeto ja foi criado                             
	if valtype( self:oPNav ) == "O"
		self:oPNav:Free()
	endif
	                                              
	//Painel esquerdo de Navegacao dos CASOS
	self:oPNav		:= tPanel():New( 00, 00, "", oParent, , , , , ,16, 00, .T., .T. )
	self:oPNav:Align := CONTROL_ALIGN_RIGHT

	self:oBCasPri	:= TBtnBmp2():New( 000, 05, 22, 25, "VCTOP",		, , , { | | self:Primeiro() }, self:oPNav, STR0015, , .T. ) 	// "Primeiro"
	self:oBCasAnt	:= TBtnBmp2():New( 025, 05, 22, 25, "VCPGUP",		, , , { | | self:Anterior() }, self:oPNav, STR0016, , .T. )		// "Anterior"
	self:oBCasPro	:= TBtnBmp2():New( 050, 05, 22, 25, "VCPGDOWN",		, , , { | | self:Proximo()  }, self:oPNav, STR0017, , .T. )	// "Próximo"
	self:oBCasUlt	:= TBtnBmp2():New( 075, 05, 22, 25, "VCBOTTOM", 	, , , { | | self:Ultimo()   }, self:oPNav, STR0018, , .T. )	// "Último"

	self:oPAct		:= tPanel():New( 00, 00, "", oParent, , , , , ,55, 00, .F., .F. )
	self:oPAct:Align := CONTROL_ALIGN_RIGHT

	//Painel esquerdo de Navegacao dos CASOS
	self:oPBotoes		:= tPanel():New( 00, 00, "", self:oPAct, , , , , ,00, 20, .F., .F. )
	self:oPBotoes:Align := CONTROL_ALIGN_TOP

	self:oBotAtual	:= TButton():New( 06, 002, STR0020, self:oPBotoes, { || self:Reload(oView)   }, 50, 12, , , , .T., , STR0020 )	// "Atualizar"

	//Observações
	Self:AddPObservacoes(self:oPAct)
	
Return nil

Method AddPObservacoes(oParent) Class TJURREVPREFAT

self:oPObs       := tPanel():New( 00, 00, "", oParent, , , , , ,00, 70, .F., .F. )
self:oPObs:Align := CONTROL_ALIGN_ALLCLIENT

Self:oGetObs       := tMultiget():New(0,0,{|| STR0009+":"},Self:oPObs,,,,,,,,.T.,,,,,/*ReadOnly*/.F.)
Self:oGetObs:Align := CONTROL_ALIGN_ALLCLIENT
Self:oGetObs:hide()

Return Nil

Method Primeiro() Class TJURREVPREFAT
Local aArray := {}

	aArray := self:oPDetCaso:aCols
	self:oPDetCaso:oBrowse:nAt := 1
  self:LineChange(aArray[self:oPDetCaso:oBrowse:nAt,NPOSCLI], aArray[self:oPDetCaso:oBrowse:nAt,NPOSLOJA], aArray[self:oPDetCaso:oBrowse:nAt,NPOSCASO])
	self:oPDetCaso:Refresh()

Return Nil

Method Ultimo()  Class TJURREVPREFAT
Local aArray := {}

	aArray := self:oPDetCaso:aCols
	self:oPDetCaso:oBrowse:nAt := self:oPDetCaso:oBrowse:nLen
	self:LineChange(aArray[self:oPDetCaso:oBrowse:nAt,NPOSCLI], aArray[self:oPDetCaso:oBrowse:nAt,NPOSLOJA], aArray[self:oPDetCaso:oBrowse:nAt,NPOSCASO])
	self:oPDetCaso:Refresh()

Return Nil

Method Anterior()  Class TJURREVPREFAT    
Local aArray := {}
                  
	aArray := self:oPDetCaso:aCols
	If self:oPDetCaso:oBrowse:nAt > 1
		self:oPDetCaso:oBrowse:nAt 			:= self:oPDetCaso:oBrowse:nAt - 1
	    self:LineChange(aArray[self:oPDetCaso:oBrowse:nAt,NPOSCLI], aArray[self:oPDetCaso:oBrowse:nAt,NPOSLOJA], aArray[self:oPDetCaso:oBrowse:nAt,NPOSCASO])
		self:oPDetCaso:Refresh()
	EndIf
Return Nil

Method Proximo()  Class TJURREVPREFAT    
Local aArray := {}

	aArray := self:oPDetCaso:aCols
    If self:oPDetCaso:oBrowse:nAt < self:oPDetCaso:oBrowse:nLen
		self:oPDetCaso:oBrowse:nAt := self:oPDetCaso:oBrowse:nAt + 1
	    self:LineChange(aArray[self:oPDetCaso:oBrowse:nAt,NPOSCLI], aArray[self:oPDetCaso:oBrowse:nAt,NPOSLOJA], aArray[self:oPDetCaso:oBrowse:nAt,NPOSCASO] )
		self:oPDetCaso:Refresh()
	EndIf
Return Nil


Method Destroy() Class TJURREVPREFAT

	/*lf:oPreFt:Destroy()
	self:oAcrHon:Destroy()
	self:oDescHon:Destroy()
	self:oBCasPri:Destroy()
	self:oBCasAnt:Destroy()
	self:oBCasPro:Destroy()
	self:oBCasUlt:Destroy()
	self:oTBitmap:Destroy()
	self:oCliente:Destroy()
	self:oLoja:Destroy()
	self:oCaso:Destroy()
	self:oDscCaso:Destroy()

	self:oPDetLcTs:LimpaRef()
	self:oPDetLcDp:LimpaRef()
	self:oPDetLcTb:LimpaRef()*/

	if (self:oPSup !=Nil)
		FreeObj( self:oPSup )
	Endif
	
	if (self:oPDetCaso !=Nil)
		FreeObj( self:oPDetCaso )
	Endif
	
	if (self:oPDetCaso !=Nil)
		FreeObj( self:oFolPDet )
	Endif	
	
	if (self:oPInfsAdic !=Nil)
		FreeObj( self:oPInfsAdic )
	Endif	

	if (self:oPDet !=Nil)
		FreeObj( self:oPDet )
	Endif	
	
Return nil

 // lAcao = .T. - Insere / lAcao = .F. - Retira  /  nID - Id da menssagem
Method Observacao(lAcao, nID, cTxt) Class TJURREVPREFAT
Local lRet := .T.

Default cTxt := ""

	Do Case
		Case nID == 2 // Observação da alteração por periodo!
			Do Case
				Case cTxt == "1"
					cTxt := STR0026 // "Tempo"
				Case cTxt == "2"
					cTxt := STR0027 // "Ultimo"
				Case cTxt == "3"
					cTxt := STR0028 // "Todos"
				OtherWise
					cTxt := ""
			EndCase

		Case nID == 3 // A Implementar
			//
		Case nID == 4 // A Implementar
			//
		OtherWise
			//
	EndCase

	If lAcao
		Self:oGetObs:AppendText( CRLF + STR0029 + cTxt )
		Self:oGetObs:Align	:= CONTROL_ALIGN_TOP
		Self:oGetObs:Show()
	EndIf

Return lRet

Method MarkCasRev() Class TJURREVPREFAT
Local lRet       := .T.
Local aArea      := GetArea() 
Local aSaveLines := FWSaveRows()
Local oModel     := FwModelActive()
Local oModelNX8  := oModel:GetModel("NX8DETAIL")
Local oModelNX1  := oModel:GetModel("NX1DETAIL")
Local oModelNUE  := oModel:GetModel("NUEDETAIL")
Local nLinNX1    := 0
Local nLinNX8    := 0
Local nLinNUE    := 0
Local nQtdNUETot := 0
Local nCount     := 0

	For nLinNX8 := 1 to oModelNX8:GetQtdLine()
		oModelNX8:GoLine(nLinNX8)

		For nLinNX1 := 1 to oModelNX1:GetQtdLine()
			oModelNX1:GoLine(nLinNX1)
	
			nCount     := 0
			nQtdNUETot := oModelNUE:getQtdLine()
			For nLinNUE := 1 to nQtdNUETot
				oModelNUE:GoLine(nLinNUE)
				If oModelNUE:GetValue("NUE_REVISA") == "1"
					nCount++
				EndIf
			Next nLinNUE

			IIF( lRet, lRet := JurLoadValue(oModelNX1, "NX1_TSREV", , IIF(nCount == nQtdNUETot, "1", "2") ), )

  		Next nLinNX1

		If !lRet
			Exit
		EndIf

  Next nLinNX8

	FWRestRows(aSaveLines)
	RestArea(aArea)

Return lRet

/*
Static Function JRevKillObj(oOBj)
Local lRet := .T.

	If lRet := (ValType(oOBj) == "O")
		oOBj:FreeChildren()
		FreeObj(oOBj)
	EndIf

Return lRet
*/
Function TJREVPREED(cGrid, nlinha, cCampo, lEnable) 
Local lRet		:= .F.

	If cGrid == "CASO" .AND. lEnable
		//IF 	alltrim(acols[n][NPOSREVISA])  == "LBOK" .AND. ( cCampo $ " NX1_TSREV | NX1_DSPREV | NX1_TABREV | NX1_SIGLA | NX1_VTS | NX1_VDESP | NX1_VLDESC | " + STR0021 + " | " + STR0013 )
		IF 	alltrim(acols[n][NPOSREVISA])  == "LBOK"
		Do Case
			Case cCampo $ " NX1_SIGLA | NX1_VTS | NX1_VDESP | " + STR0021 + " | " + STR0013
				lRet := .T.
			Case cCampo $ " NX1_VLDESC "
		    lRet := FwFldGet("NX0_TPDESC") == '1'
		 End Case
		Else
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf

Return lRet

//-------------------------------------------------------------------
/*/ { Protheus.doc } TJREVOnlyRet()
Rotina para filtrar os lançamentos que serão retirados da prefatura 

@Params		aLanctos array com lançamentos segundo modelo da rotina JA202LFatu()

@Return		aRet array com  lançamentos filtrados

@author Luciano Pereira dos Santos
@since 03/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
/*Static function TJREVOnlyRet(aLanctos)
Local aRet	:= {}
Local nI	:= 0

For nI := 1 to Len(aLanctos)
	If aLanctos[nI][09] .Or. aLanctos[nI][10] // lançamentos em WO ou retirados
		aAdd(aRet,aLanctos[nI])
	EndIf
Next nI

Return aRet*/