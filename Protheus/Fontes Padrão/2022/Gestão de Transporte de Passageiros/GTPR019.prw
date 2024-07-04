#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'GTPR019.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR019
Impressão DAPE após confirmação.
@type function
@author crisf
@since 21/12/2017
@version 1.0
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------
Function GTPR019()

	Local lProcessa := .T.
	Private oReport
	
		If !TRepInUse()
			
			Alert(STR0032)//"A impressão em TREPORT deverá estar habilitada. Favor verificar o parâmetro MV_TREPORT."
			lProcessa := .F.
	
		EndIf
	
		If lProcessa
	
			oReport:= ReportDef()
			
			if oReport <> Nil
			
				oReport:PrintDialog()
	
			EndIf
			
		EndIf
		
Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
(long_description)
@type function
@author crisf
@since 21/12/2017
@version 1.0
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------
Static Function ReportDef()

	Local cTitulo	:= STR0001//"DAPE - Demonstrativo de Passagens Estrada"
		
	oReport:= TReport():New("GTPR019_"+StrTran(Time(),":",""), cTitulo, "", {|oReport| ReportPrint( oReport )}, "" )
	oReport:SetLandscape()
	oReport:HideParamPage()
	
	Return(oReport)
//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
(long_description)
@type function
@author crisf
@since 21/12/2017
@version 1.0
@param oReport, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
/*///-------------------------------------------------------------------
Static Function ReportPrint( oReport )

	Local oView		:= FwViewActive()
	Local oModAtu   := oView:GetModel()
	Local oModGrid	:= Nil
	Local oArial10N	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)	// Negrito	
	Local oArial07	:= TFont():New("Arial",07,07,,.F.,,,,.T.,.F.)	// Normal	
	Local nLnIni	:= 200
	Local nColIni	:= 050
	Local nLnFim	:= 200
	Local nColFim	:= 2400
	Local nColBox	:= 15
	Local nColAtu	:= 0
	Local nCols		:= nColFim/(nColBox+1)// descrição contar com espaço de 2 colunas
	Local nBilh		:= 0
	Local nTtLins	:= 35
	
		if valtype(oModAtu) <> 'U'
			
			oModGrid	:= oModAtu:GetModel("GICDETAIL")
				
			oReport:StartPage()
				
				oReport:Box( C(nLnIni), C(nColIni), C(nLnFim	:= nLnFim+150), C(nColFim) )
				oReport:Say( C(nLnIni	:= nLnIni+50)	, C(nColIni+0050), STR0002+GY3->GY3_CODAG+'-'+(Posicione("GI6",1,xFilial("GI6")+GY3->GY3_CODAG,"GI6_DESCRI")), oArial10N )//"Agência "
				oReport:Say( C(nLnIni)					, C(nColIni+1400), STR0003+Dtoc(GY3->GY3_DTENTR), oArial10N )//"Data da Entrega "
				oReport:Say( C(nLnIni)					, C(nColIni+1800), STR0004+Dtoc(GY3->GY3_DTFECH), oArial10N )//"Data Fechamento "
				oReport:Say( C(nLnIni	:= nLnIni+50)	, C(nColIni+0050), STR0005+GY3->GY3_CODEMI+'-'+Posicione("GYG",1,xFilial("GYG")+GY3->GY3_CODEMI,"GYG_NOME"), oArial10N )//"Emitente "
				
				nLnIni	:= nLnFim
				oReport:Box( C(nLnIni), C(nColIni), C(nLnFim	:= nLnFim+300), C(nColFim) )
				oReport:Say( C(nLnIni	:= nLnIni+50)	, C((nColFim/2)-100), STR0006 , oArial10N )//"Totalizadores "
				nLnIni	:= nLnIni+50
				oReport:Say( C(nLnIni)		, C(nColIni+2)	, STR0007													, oArial10N )//"Total Bilhetes "
				oReport:Say( C(nLnIni+050)	, C(nColIni+2)	, STR0008													, oArial10N )//"Valor total"
				oReport:Say( C(nLnIni+100)	, C(nColIni+2)	, STR0009													, oArial10N )//"Valor Acerto"
				oReport:Say( C(nLnIni)		, C(nColIni+200), Transform( oModGrid:Length(), "@E 999,999,999" )			, oArial07 )
				oReport:Say( C(nLnIni+050)	, C(nColIni+200), Transform( GY3->GY3_VALTOT, PesqPict("GY3","GY3_VALTOT") ), oArial07 )
				oReport:Say( C(nLnIni+102)	, C(nColIni+200), Transform( GY3->GY3_TOTACE, PesqPict("GY3","GY3_TOTACE") ), oArial07 )
				
				oReport:Say( C(nLnIni)		, C(((nColFim/4)*1)+2)	, STR0010													, oArial10N )//"Tot.tarifa"
				oReport:Say( C(nLnIni+050)	, C(((nColFim/4)*1)+2)	, STR0011													, oArial10N )//"Tot.tar Tb."
				oReport:Say( C(nLnIni+100)	, C(((nColFim/4)*1)+2)	, STR0012													, oArial10N )//"Tot.tx.emb."
				oReport:Say( C(nLnIni)		, C(((nColFim/4)*1)+200), Transform( GY3->GY3_TOTTAR, PesqPict("GY3","GY3_TOTTAR" ) ), oArial07 )
				oReport:Say( C(nLnIni+050)	, C(((nColFim/4)*1)+200), Transform( GY3->GY3_TTARTB, PesqPict("GY3","GY3_TTARTB" ) ), oArial07 )
				oReport:Say( C(nLnIni+102)	, C(((nColFim/4)*1)+200), Transform( GY3->GY3_TTXEMB, PesqPict("GY3","GY3_TTXEMB" ) ), oArial07 )
								
				oReport:Say( C(nLnIni)		, C(((nColFim/4)*2)+2), STR0013														, oArial10N )//"Tot.tx.Eb.Tb."
				oReport:Say( C(nLnIni+050)	, C(((nColFim/4)*2)+2), STR0014														, oArial10N )//"Tot.Ped."
				oReport:Say( C(nLnIni+100)	, C(((nColFim/4)*2)+2), STR0015														, oArial10N )//"Tot.Ped.Tb."
				oReport:Say( C(nLnIni)		, C(((nColFim/4)*2)+200), Transform( GY3->GY3_TTXEBT, PesqPict("GY3","GY3_TTXEBT" ) ), oArial07 )
				oReport:Say( C(nLnIni+050)	, C(((nColFim/4)*2)+200), Transform( GY3->GY3_TOTPED, PesqPict("GY3","GY3_TOTPED" ) ), oArial07 )
				oReport:Say( C(nLnIni+102)	, C(((nColFim/4)*2)+200), Transform( GY3->GY3_TPEDTB, PesqPict("GY3","GY3_TPEDTB" ) ), oArial07 )
								
				oReport:Say( C(nLnIni)		, C(((nColFim/4)*3)+2)	, STR0016													 , oArial10N )//"Tot.Sg.Fac."
				oReport:Say( C(nLnIni+050)	, C(((nColFim/4)*3)+2)	, STR0017													 , oArial10N )//"Tot.Sg.F.Tb."
				oReport:Say( C(nLnIni+100)	, C(((nColFim/4)*3)+2)	, STR0018													 , oArial10N )//"Outros Val."
				oReport:Say( C(nLnIni)		, C(((nColFim/4)*3)+200), Transform( GY3->GY3_TSGFAC, PesqPict("GY3","GY3_TSGFAC" ) ), oArial07 )
				oReport:Say( C(nLnIni+050)	, C(((nColFim/4)*3)+200), Transform( GY3->GY3_TSGFCT, PesqPict("GY3","GY3_TSGFCT" ) ), oArial07 )
				oReport:Say( C(nLnIni+102)	, C(((nColFim/4)*3)+200), Transform( GY3->GY3_OTVL, PesqPict("GY3","GY3_OTVL" ) )	 , oArial07 )
								
				nLnIni	:= nLnFim
				oReport:Box( C(nLnIni), C(nColIni), C(nLnFim	:= nLnFim+040), C(nColFim) )
							
				oReport:Say( C(nLnIni	:= nLnIni+2) , C(nColAtu:= nColIni+2)		, STR0019, oArial10N )//"Bilhete"
				oReport:Say( C(nLnIni)				 , C(nColAtu	:= nColAtu+100)	, STR0020, oArial10N )//"Linha"
				oReport:Say( C(nLnIni)				 , C(nColAtu	:= nColAtu+100)	, STR0021, oArial10N )//"Descrição"
				oReport:Say( C(nLnIni)				 , C(nColAtu	:= nColAtu+400)	, STR0022, oArial10N )//"Sentido"
				oReport:Say( C(nLnIni)				 , C(nColAtu	:= nColAtu+100)	, STR0023, oArial10N )//"Origem"
				oReport:Say( C(nLnIni)				 , C(nColAtu	:= nColAtu+100)	, STR0024, oArial10N )///"Descrição"
				oReport:Say( C(nLnIni)				 , C(nColAtu	:= nColAtu+200)	, STR0025, oArial10N )//"Destino"
				oReport:Say( C(nLnIni)				 , C(nColAtu	:= nColAtu+100)	, STR0026, oArial10N )//"Descrição"
				oReport:Say( C(nLnIni)				 , C(nColAtu	:= nColAtu+200)	, STR0027, oArial10N )//"Dt.Venda"
				oReport:Say( C(nLnIni)				 , C(nColAtu	:= nColAtu+200)	, STR0028, oArial10N )//"Dt.Viagem"
				oReport:Say( C(nLnIni)				 , C(nColAtu	:= nColAtu+200)	, STR0029, oArial10N )//"Tarifa"
				oReport:Say( C(nLnIni)				 , C(nColAtu	:= nColAtu+200)	, STR0030, oArial10N )//"Vl. Req."
				oReport:Say( C(nLnIni)				 , C(nColAtu	:= nColAtu+200)	, STR0031, oArial10N )//"Vl. Acerto"
				
				For nBilh	:= 1 to oModGrid:Length()
					
					nColAtu:= nColIni+2
					nLnIni	:= nLnFim
					oReport:Box( C(nLnIni), C(nColIni), C(nLnFim	:= nLnFim+040), C(nColFim) )
				
					nLnIni	:= nLnIni+2
					oReport:Say( C(nLnIni) 	, C(nColAtu), oModGrid:GetValue('GIC_BILHET',nBilh ), oArial07 )
					oReport:Say( C(nLnIni)	, C(nColAtu	:= nColAtu+100), oModGrid:GetValue('GIC_LINHA',nBilh ), oArial07 )
					oReport:Say( C(nLnIni)	, C(nColAtu	:= nColAtu+100), Posicione('GI2',1,xFilial('GI2')+oModGrid:GetValue('GIC_LINHA', nBilh ),'GI2_PREFIX'), oArial07 )
					oReport:Say( C(nLnIni)	, C(nColAtu	:= nColAtu+400), iif(oModGrid:GetValue('GIC_SENTID', nBilh )=='1','Ida','Volta'), oArial07 )
					oReport:Say( C(nLnIni)	, C(nColAtu	:= nColAtu+100), oModGrid:GetValue('GIC_LOCORI', nBilh ), oArial07 )
					oReport:Say( C(nLnIni)	, C(nColAtu	:= nColAtu+100), Posicione('GI1',1,xFilial('GI1')+oModGrid:GetValue('GIC_LOCORI', nBilh ),'GI1_DESCRI'), oArial07 )
					oReport:Say( C(nLnIni)	, C(nColAtu	:= nColAtu+200), oModGrid:GetValue('GIC_LOCDES', nBilh ), oArial07 )
					oReport:Say( C(nLnIni)	, C(nColAtu	:= nColAtu+100), Posicione('GI1',1,xFilial('GI1')+oModGrid:GetValue('GIC_LOCDES', nBilh ),'GI1_DESCRI'), oArial07 )
					oReport:Say( C(nLnIni)	, C(nColAtu	:= nColAtu+200), Dtoc( oModGrid:GetValue('GIC_DTVEND', nBilh )), oArial07 )
					oReport:Say( C(nLnIni)	, C(nColAtu	:= nColAtu+200), Dtoc( oModGrid:GetValue('GIC_DTVIAG', nBilh )), oArial07 )
					oReport:Say( C(nLnIni)	, C(nColAtu	:= nColAtu+200), Transform( oModGrid:GetValue('GIC_VALTOT', nBilh ),PesqPict("GIC","GIC_VALTOT") ), oArial07 )
					oReport:Say( C(nLnIni)	, C(nColAtu	:= nColAtu+200), Transform( oModGrid:GetValue('GIC_REQTOT', nBilh ),PesqPict("GIC","GIC_REQTOT") ), oArial07 )
					oReport:Say( C(nLnIni)	, C(nColAtu	:= nColAtu+200), Transform( oModGrid:GetValue('GIC_VLACER', nBilh ),PesqPict("GIC","GIC_VLACER") ), oArial07 )
					
					if 	nBilh == nTtLins
					
						oReport:EndPage()
						nTtLins	:= nBilh+35
						nLnIni	:= 200
						nLnFim	:= 200
						
					EndIf
									
				Next nBilh
					
			oReport:Finish()
		
		EndIf
		
Return 