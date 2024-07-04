#include "protheus.ch"
#include "report.ch"
#include "OGR720.ch"

Function OGR720()
 	Local aAreaAtu 	:= GetArea() 
	Local oReport	:= Nil
	
	Private cPergunta	:= "OGR7200001"
	Private _nDesc		:= 0
	    
	If FindFunction("TRepInUse") .And. TRepInUse()
		Pergunte( cPergunta, .f. )
		oReport:= ReportDef()
		oReport:PrintDialog()		
	EndIf
	
	RestArea( aAreaAtu )
Return( Nil )

Static Function ReportDef()
	Local oReport		:= Nil
	Local oSection1		:= Nil
	Local oSection2		:= Nil
	Local oSection3		:= Nil
		
	oReport := TReport():New("OGR720", STR0001 /*"Embarques da IE/Contrato"*/, cPergunta, {| oReport | PrintReport( oReport ) }, STR0001 /*"Embarques da IE/Contrato"*/)
		
	oReport:oPage:SetPageNumber(1)
	oReport:lBold 		   := .F.
	oReport:lUnderLine     := .F.
	oReport:lHeaderVisible := .T.
	oReport:lFooterVisible := .T.
	oReport:lParamPage     := .F.
	
	//Seção 1 - Relatório
	oSection1 := TRSection():New( oReport, STR0001 /*"Embarques da IE/Contrato"*/, {"N7Q","N7S"} ) //"Embarques da IE/Contrato"
	oSection1:lLineStyle := .T. 
	
	TRCell():New( oSection1, STR0002 /*"Entidade/Loja Entrega"*/, , STR0002 /*"Entidade/Loja Entrega"*/, /*Mask*/, 45, .T., {|| getEntEnt(QryIE->N7Q_ENTENT, QryIE->N7Q_LOJENT) }, , , "LEFT", .T.)
	TRCell():New( oSection1, "N7Q_CODPRO", "N7Q", STR0003 /*"Produto"*/, "@!", 45 , .F., {|| getDesPrd(QryIE->N7Q_CODPRO) }, , , "LEFT", .T.)
	TRCell():New( oSection1, "N7S_CODCTR","N7S", STR0004 /*"Contrato"*/, "@!", 45 , .T.,/*Block*/ , , , "LEFT", .T. )
	TRCell():New( oSection1, "N7S_CTREXT","N7S", STR0005 /*"Contrato Externo"*/, "@!", 45 , .T.,/*Block*/ , , , "LEFT", .T. )	
	TRCell():New( oSection1, STR0006 /*"IE"*/, , STR0006 /*"IE"*/, "@!", 45 , .T.,{|| getIE(QryIE->N7Q_CODINE, QryIE->N7Q_DESINE) } , , , "RIGHT", .T. )
	TRCell():New( oSection1, STR0007, "N7Q", STR0007 /*"Cliente IE"*/, /*Mask*/, 45, .T.,{|| getCliIE(QryIE->N7Q_IMPORT, QryIE->N7Q_IMLOJA) }  , , , "LEFT" , .T.)
	TRCell():New( oSection1, "N7S_QTDVIN", "N7S", STR0008 /*"Peso IE"*/, /*Mask*/, 45, .T., , , , "LEFT" , .T.)
	TRCell():New( oSection1, "N7S_SALNEG", "N7S" , STR0009 /*"Saldo IE"*/, /*Mask*/, 45, .T., , , , "RIGHT" , .T.)
	TRCell():New( oSection1, STR0010 /*"Filial"*/, , STR0010 /*"Filial"*/, /*Mask*/, 45, .T., {|| getDescFil(QryIE->N7S_FILORG) }, , , "LEFT" , .T.)
	TRCell():New( oSection1, STR0011 /*"Estado"*/, , STR0011 /*"Estado"*/, /*Mask*/, 45, .T., {|| getEstdFil(QryIE->N7S_FILORG) }, , , "LEFT" , .T.)
	TRCell():New( oSection1, STR0012 /*"Transportadora"*/, , STR0012 /*"Transportadora"*/, /*Mask*/, 45, .T.,{|| getDescTrans(QryIE->N7Q_CODINE) } , , , "LEFT" , .T.)
	
		
	//Seção 2 - Relatório
	oSection2 := TRSection():New( oReport, "Listagem dados", {"NJM", "NJJ"} ) //"Listagem dados"
	oSection2:lAutoSize := .T.
	TRCell():New( oSection2, "NJM_DOCEMI", "NJM", STR0013 /*"Data Expedição"*/)
	TRCell():New( oSection2, "NJM_DOCNUM", "NJM", STR0014 /*"NF"*/)
	TRCell():New( oSection2, "NJJ_PLACA", "NJJ", STR0015 /*"Placa"*/) 
	TRCell():New( oSection2, "NJJ_PSSUBT", "NJJ", STR0016 /*"P. Bruto (Kg)"*/)
	TRCell():New( oSection2, "NJJ_PSBASE", "NJJ", STR0017 /*"P. Liq. (Kg)"*/)
	TRCell():New( oSection2, "NJM_QTDFIS", "NJM", STR0018 /*"Peso NF (Kg)"*/)
	TRCell():New( oSection2, "NJM_VLRTOT", "NJM", STR0019 /*"Valor NF em R$"*/)	
	TRCell():New( oSection2, STR0020 /*"% Desc."*/, , STR0020 /*"% Desc."*/, PesqPict( "NJK", "NJK_PERDES" ) , , , {|| getDescont(QryNJM->NJM_FILIAL, QryNJM->NJM_CODROM) })		
	TRCell():New( oSection2, STR0021 /*"P. Liq. (Kg) Desc"*/, "", STR0021 /*"P. Liq. (Kg) Desc"*/, PesqPict( "NJJ", "NJJ_PSSUBT" ) , , , {|| (QryNJM->NJJ_PSSUBT - (QryNJM->NJJ_PSSUBT * _nDesc/100) ) })
	
	
	//Seção 3 - Classificação
	oSection3 := TRSection():New( oReport, "Listagem dados", {"NJJ", "NJK"} ) //"Listagem dados classificação"
	oSection3:lAutoSize := .T.
	TRCell():New( oSection3, "NJK_CODDES", "NJK", STR0026 /*"Exame"*/)
	TRCell():New( oSection3, STR0023 /*"Descrição"*/, , STR0023 /*"Descrição"*/, , , , {|| getDescDes(QryNJM->NJJ_TABELA, QryNJK->NJK_CODDES) })
	TRCell():New( oSection3, "NJK_PERDES", "NJK", STR0024 /*"% Desconto"*/)
	TRCell():New( oSection3, "NJK_QTDDES" , "NJK", STR0025 /*"Qtd. Desc."*/)
				
	oBreak1 := TRBreak():New( oSection2, "", STR0022 /*"Total"*/, .F. )//"Total -->"
	TRFunction():New(oSection2:aCell[4], Nil, "SUM", oBreak1, "", , , .F., .F., )	
	TRFunction():New(oSection2:aCell[5], Nil, "SUM", oBreak1, "" , , , .F., .F., )
	TRFunction():New(oSection2:aCell[6], Nil, "SUM", oBreak1, "" , , , .F., .F., )
	TRFunction():New(oSection2:aCell[7], Nil, "SUM", oBreak1, "" , , , .F., .F., )
Return (oReport)

Static Function PrintReport(oReport)
	Local aAreaAtu	:= GetArea()
	Local oS1		:= oReport:Section(1)
	Local oS2		:= oReport:Section(2)
	Local oS3		:= oReport:Section(3)
	Local cFiltro 	:= ""

	If oReport:Cancel()
		Return( Nil )
	EndIf

	If .NOT. Empty(MV_PAR01)
		cFiltro += " AND N7Q.N7Q_CODSAF = '" + MV_PAR01 + "'"
	EndIf	

	If .NOT. Empty(MV_PAR02)
		cFiltro += " AND N7S.N7S_CODCTR >= '" + MV_PAR02 + "'"
	EndIf
	
	If .NOT. Empty(MV_PAR03)
		cFiltro += " AND N7S.N7S_CODCTR <= '" + MV_PAR03 + "'"
	EndIf	
	
	If .NOT. Empty(MV_PAR04)
		cFiltro += " AND N7Q.N7Q_ENTENT >= '" + MV_PAR04 + "'"
	EndIf		
	
	If .NOT. Empty(MV_PAR05)
		cFiltro += " AND N7Q.N7Q_LOJENT >= '" + MV_PAR05 + "'"
	EndIf		
	
	If .NOT. Empty(MV_PAR06)
		cFiltro += " AND N7Q.N7Q_ENTENT <= '" + MV_PAR06 + "'"
	EndIf
	
	If .NOT. Empty(MV_PAR07)
		cFiltro += " AND N7Q.N7Q_LOJENT <= '" + MV_PAR07 + "'"
	EndIf

	If .NOT. Empty(MV_PAR08)
		cFiltro += " AND N7Q.N7Q_CODINE >= '" + MV_PAR08 + "'"
	EndIf
	
	If .NOT. Empty(MV_PAR09)
		cFiltro += " AND N7Q.N7Q_CODINE <= '" + MV_PAR09 + "'"
	EndIf
		
	cFiltro := "%" + cFiltro + "%"

	oS1:BeginQuery()
	oS1:Init()
	
	BeginSql Alias "QryIE"
	  SELECT N7S_FILIAL, N7Q_IMPORT, N7Q_IMLOJA, N7Q_CODPRO, N7S_CODCTR, N7S_CTREXT, N7Q_CODINE, N7Q_DESINE,
	         N7Q_ENTENT, N7Q_LOJENT, N7S_ITEM, N7S_SEQPRI, N7S_FILORG, N7S_QTDVIN
	    FROM %Table:N7S% N7S 
	   INNER JOIN %Table:N7Q% N7Q
  		  ON N7S_FILIAL = N7Q_FILIAL 
  		 AND N7S_CODINE = N7Q_CODINE
	   WHERE N7S.%NotDel% 
		 AND N7Q.%NotDel%
	     %Exp:cFiltro% 
	EndSql
	oS1:EndQuery()
	
	If .Not. QryIE->(Eof())
	
		QryIE->(dbGoTop())
		    
		oS1:Init()
	
		While .Not. QryIE->(Eof())
							
			oS1:PrintLine()
	
			oS2:BeginQuery()
			oS2:Init()

			BeginSql Alias "QryNJM"
			  Select NJM_DOCNUM, NJJ_PLACA, NJJ_PSSUBT, NJJ_PSBASE, NJM_QTDFIS, NJM_VLRTOT, NJM_DOCEMI,
				     NJM_FILIAL, NJM_CODROM, NJJ_TABELA
				FROM %Table:NJM% NJM
			   INNER JOIN %Table:NJJ% NJJ
			      ON NJM.NJM_FILIAL = NJJ.NJJ_FILIAL
			     AND NJM.NJM_CODROM = NJJ.NJJ_CODROM
				WHERE NJM.%NotDel%
				  AND NJJ.%NotDel%
				  AND NJM.NJM_CODINE 	= %exp:QryIE->N7Q_CODINE%					  
				  AND NJM.NJM_CODCTR 	= %exp:QryIE->N7S_CODCTR%
				  AND NJM.NJM_ITEM 		= %exp:QryIE->N7S_ITEM%
				  AND NJM.NJM_SEQPRI 	= %exp:QryIE->N7S_SEQPRI%
				  AND NJM.NJM_DOCNUM   <> ' '	
			EndSQL
			oS2:EndQuery()
			
			QryNJM->(dbGoTop())
			
			oS2:Init()
			While .Not. QryNJM->(Eof())

				oS2:PrintLine()
								
				If MV_PAR10 = 1 //Detalhar os descontos
					oS3:BeginQuery()
					oS3:Init()
		
					BeginSql Alias "QryNJK"
					  Select NJK_CODDES, NJK_PERDES, NJK_QTDDES
						FROM %Table:NJK% NJK
					   WHERE NJK.%NotDel%
						 AND NJK.NJK_FILIAL	= %exp:QryNJM->NJM_FILIAL%
						 AND NJK.NJK_CODROM	= %exp:QryNJM->NJM_CODROM%	
						 AND NJK.NJK_PERDES > 0
					EndSQL
					oS3:EndQuery()
					
					QryNJK->(dbGoTop())
					
					oS3:Init()
					While .Not. QryNJK->(Eof())
		
						oS3:PrintLine()
						QryNJK->( dbSkip() )
					EndDo
					
					QryNJK->( dbCloseArea() )
					oS3:Finish()
				EndIf
				
				QryNJM->( dbSkip() )
			EndDo
			QryNJM->( dbCloseArea() )
			oS2:Finish()			
			
			oReport:SkipLine(1)
			
			QryIE->( dbSkip() )
		EndDo
		QryIE->( dbCloseArea() )
	
		If MV_PAR10 = 1 //Detalhar os descontos
			oS3:Finish()
		EndIf
		
		//fecha listagem dos dados
		oS2:Finish()
		
		//fecha cabeçalho
		oS1:Finish()	
	EndIf

	RestArea(aAreaAtu)		
Return .t.

/*/{Protheus.doc} getEntidade
Formata a informação de entidade junto com loja
@author silvana.torres
@since 20/09/2018
@version undefined
@param cEntidade, characters, descricao
@param cLoja, characters, descricao
@type function
/*/
Static Function getEntEnt(cEnt, cLoja)
	Local cRet 	:= ""
	Local cDesc	:= ""
	
	If !Empty(cEnt)
		NJ0->(DbSelectArea("NJ0"))
		NJ0->(dbSetOrder(1)) //Filial + Código + Loja	
	
		if NJ0->(MsSeek(FwXFilial('NJ0')+cEnt+cLoja)) 
			cDesc := NJ0->NJ0_NOME			
		endIf
		NJ0->(dbCloseArea())
	
		cRet := cEnt + "/" + cLoja + " - " + cDesc
	Endif
	
Return cRet

/*/{Protheus.doc} getIE
Formata a informação de IE junto com a descrição
@author silvana.torres
@since 20/09/2018
@version undefined
@param cIE, characters, descricao
@param cDesc, characters, descricao
@type function
/*/
Static Function getIE(cIE, cDesc)
	Local cRet := ""
	
	If !Empty(cIE)
		cRet := cIE + "/" + cDesc
	Endif
Return cRet

/*/{Protheus.doc} getDescTrans
//TODO Descrição auto-gerada.
@author silvana.torres
@since 21/09/2018
@version undefined

@type function
/*/
Static Function getDescTrans(cCodIne)

	Local cRet := ""
	
	N9R->(DbSelectArea("N9R"))
	N9R->(dbSetOrder(2)) //Filial + IE	

	If N9R->(MsSeek(FWxFilial('N9R')+cCodIne)) 
				
		GXS->(DbSelectArea("GXS"))
		GXS->(dbSetOrder(1)) //Filial + Id. requisição + Sequência	
	
		If GXS->(MsSeek(FWxFilial('GXS')+N9R->N9R_IDREQ)) 
			While GXS->(!Eof()) .AND. GXS->GXS_IDREQ = N9R->N9R_IDREQ
			       
			    If GXS->GXS_MRKBR = .T.
			      	cRet := GXS->GXS_CDTRP + " - " + POSICIONE("GU3",1,FWxFilial("GU3")+GXS->GXS_CDTRP,"GU3_NMEMIT")
			    EndIf
				GXS->(dbSkip())
			EndDo		
		EndIf
		
		N9R->(dbCloseArea())
	EndIf
	
	N9R->(dbCloseArea())
	
Return cRet


/*/{Protheus.doc} getDescFil
Formata a informação da Filial junto com o nome
@author silvana.torres
@since 24/09/2018
@version undefined
@param cFil, characters, descricao
@type function
/*/
Static Function getDescFil(cFil)
	Local cRet := ""
	
	If !Empty(cFil)
		cRet := AllTrim(cFil) + " - " + FWFilialName(,cFil,2)
	EndIf 
	
Return cRet


/*/{Protheus.doc} getDesPrd
Formata a informação do produto junto com a descrição
@author silvana.torres
@since 24/09/2018
@version undefined
@param cPrd, characters, descricao
@type function
/*/
Static Function getDesPrd(cPrd)
	Local cRet := ""
	
	If !Empty(cPrd)
		cRet := AllTrim(cPrd) + " - " + Posicione("SB1", 1, FwxFilial("SB1") + cPrd, "B1_DESC")
	EndIf 
	
Return cRet


/*/{Protheus.doc} getDescont
Totaliza os percentuais de desconto 
@author silvana.torres
@since 24/09/2018
@version undefined
@param cFil, characters, descricao
@param cCodRoom, characters, descricao
@type function
/*/
Static Function getDescont(cFil, cCodRom)
	Local nRet := 0
	
	If !Empty(cCodRom)
		
		BeginSql Alias "QryNJK"
		  Select SUM(NJK_PERDES) as SomaDes
			FROM %Table:NJK% NJK
		   WHERE NJK.%NotDel%
			 AND NJK.NJK_FILIAL	= %exp:cFil%
			 AND NJK.NJK_CODROM	= %exp:cCodRom%	
		EndSQL
		
		QryNJK->(dbGoTop())
		
		If .Not. QryNJK->(Eof())
			nRet := QryNJK->SomaDes			
		EndIf
		
		QryNJK->( dbCloseArea() )
		
	EndIf 
	
	_nDesc := nRet
	
Return nRet


/*/{Protheus.doc} getEstdFil
Retorna a UF da filial
@author silvana.torres
@since 25/09/2018
@version undefined
@param cFil, characters, descricao
@type function
/*/
Static Function getEstdFil(cFil)
	
	Local cRet := ""
	
	NJ0->(DbSelectArea("NJ0"))
	NJ0->(dbSetOrder(5)) 


	if NJ0->(MsSeek(FwXFilial('NJ0')+cFil))  //Filial + CODCRP
	
		SA1->(DbSelectArea("SA1"))
		SA1->(dbSetOrder(3)) //Filial + CGC

		If (SA1->(MsSeek(FWxFilial("SA1")+NJ0->NJ0_CGC)))
			cRet := SA1->A1_EST
		EndIf
		
		SA1->(dbCloseArea())
		
	endIf
	NJ0->(dbCloseArea())

Return cRet


/*/{Protheus.doc} getCliIE
Retorna o cliente da IE, loja e nome 
@author silvana.torres
@since 25/09/2018
@version undefined
@param cCli, characters, descricao
@param cLoja, characters, descricao
@type function
/*/
Static Function getCliIE(cCli, cLoja)
	
	Local cRet := ""
	
	SA1->(DbSelectArea("SA1"))
	SA1->(dbSetOrder(1)) //Filial + Código + Loja

	If (SA1->(MsSeek(FWxFilial("SA1")+cCli+cLoja)))
		cRet := cCli + "/" + cLoja + " - " + SA1->A1_NOME
	EndIf
	
	SA1->(dbCloseArea())

Return cRet

/*/{Protheus.doc} getDescDes
Retorna a descrição do desconto
@author silvana.torres
@since 25/09/2018
@version undefined
@param cTabela, characters, descricao
@param cCodDes, characters, descricao
@type function
/*/
Static Function getDescDes(cTabela, cCodDes)
	
	Local cRet := ""
	
	NNJ->(dbSelectArea('NNJ'))
	NNJ->(dbSetOrder(1)) //Filial + Tabela + Cod. Desconto
	
	If NNJ->(MsSeek(FWxFilial('NNJ')+cTabela+cCodDes))
		cRet := NNJ->NNJ_DESDES
	EndIf 
	
	NNJ->(dbCloseArea())
	
Return cRet