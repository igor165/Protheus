#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"  


#DEFINE	 IMP_PDF 6 
#DEFINE PLSMONEY "@E 99,999,999,999.99"
#DEFINE __RELIMP PLSMUDSIS(getWebDir() + getSkinPls() + "\relatorios\")

//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSRCPRT
Relatorio capa de lote PEG
@since 21/11/2012
@author Totvs
@version P12 
/*/
//-------------------------------------------------------------------
Function PLSRCPRT(cChave,cPathDest,lWeb,nRecno,oObj,cProt,lFmrTxt)
LOCAL nPixLin		:= 40
LOCAL nLargLogo		:= 140
LOCAL nIniBox		:= 90
LOCAL nPixCol		:= 40
LOCAL nPixFin		:= 450
LOCAL cDesLoc 		:= ""
LOCAL cEndNum 		:= ""
LOCAL cBaMuEs 		:= ""
LOCAL cEndCep 		:= ""
LOCAL cOpeNom 		:= ""
LOCAL cOpeEnd 		:= ""
LOCAL cEstLoc		:= ""
LOCAL cOpeBCE 		:= ""
LOCAL cOpeCep 		:= ""
LOCAL cBarra		:= ""
LOCAL cTipGui 		:= "NÃO IDENTIFICADA"
LOCAL cRelName		:= "capapeg"+CriaTrab(NIL,.F.)   
LOCAL oRel			:= nil    
LOCAL lFound		:= .f.
LOCAL lEntrou		:= .F.
LOCAL nPosI			:=  0
LOCAL nPosII		:=  0
LOCAL nPosIII		:=  0
LOCAL nPosIIII		:=  0
LOCAL nPosSequen 	:=  0
LOCAL nValApBA0		:=  0

LOCAL cCodInt		:= PLSINTPAD()
LOCAL cCodRda		:= ""
LOCAL cSequen		:= ""
LOCAL cCodPeg		:= ""
LOCAL cStatus		:= ""
LOCAL ni			:= 0
Local nfor			:= 1
Local limpr			:= .T.
lOCAL lMarc			:= .T.                                
Local lAbrSetup 	:= Empty(GetNewPar("MV_PLRLSET","")) .Or. !('PLSR974' $ Upper(GetNewPar("MV_PLRLSET","")))//Se o parametro nao foi informado, ou na lista de informacao nao tem o PLSR974, deixa abrir o setup
LOCAL lTipVlAp		:= .F.
local aDadosIte		:= {}
local aDadosExt		:= {}
local aDadosCap		:= {}
local lVlrRel		:= .f.
local cBkpTpGui		:= ""
Local objCENFUNLGP := CENFUNLGP():New() 

DEFAULT cChave		:= ""
DEFAULT cPathDest	:= lower(GETMV("MV_RELT")) 
DEFAULT nRecno		:= 0
DEFAULT lWeb		:= .F.
DEFAULT oObj		:= nil
DEFAULT lFmrTxt     := .F.

//-- LGPD ----------
If !(FunName() == "RPC")
	if !objCENFUNLGP:getPermPessoais()
		objCENFUNLGP:msgNoPermissions()
		Return
	Endif	
endIf
//------------------

//Ponto de Entrada para que seja possivel criar o Relatorio 
//pelo o usuario
If valType(nRecno) == "C"
	nRecno := VAL(nRecno)
EndIf

If ExistBlock("PLR974CL")

	cRelName := ExecBlock("PLR974CL",.F.,.F.,{cChave,cPathDest,lWeb,nRecno,oObj})
	
	IF ! Empty(cRelName)
		return{cRelName+".pdf",""}
	Else	
		return()
	EndIf
	
Endif
	
if valType(oObj) == 'O'

	nPosI		:= aScan(oObj:aHeader,{|x|AllTrim(x[2])=="BXX_CODRDA"})
	nPosII		:= aScan(oObj:aHeader,{|x|AllTrim(x[2])=="BXX_CODPEG"})
	nPosIII		:= aScan(oObj:aHeader,{|x|AllTrim(x[2])=="BXX_STATUS"})
	nPosIIII	:= aScan(oObj:aHeader,{|x|AllTrim(x[2])=="BXX_CHKBOX"} )
	nPosSequen 	:= aScan(oObj:aHeader,{|x|AllTrim(x[2])=="BXX_SEQUEN"} )
	nfor 		:= len(oObj:aCols)
	
Endif

If lWeb
	cPathDest	:= __RELIMP
Else	 
	cPathDest	:= PswRet()[2,3]//GETMV("MV_RELT") 	
Endif	

//Posiciona BA0 para verificar o valor do campo se Exibe Valor apresentado pelo usuário ou não - campo BA0_VLRAPR
if BA0->(fieldPos("BA0_VLRAPR")) > 0
	
	BA0->(DbSetOrder(1))
	If BA0->( DbSeek(xFilial("BA0") + cCodInt ) )
		If ValType(BA0->BA0_VLRAPR) == "C" //Quando as alterações de dicionário que mudaram o tipo deste campo apra caractere forem oficializadas, retirar essa proteção.
			lTipVlAp := ( BA0->BA0_VLRAPR == '1' )
		else
			lTipVlAp := BA0->BA0_VLRAPR
		EndIf
	EndIf
	
endIf

//³ Posiciona no PEG
BXX->( dbSetOrder(2) )
BCI->( dbSetOrder(1) ) //BCI_FILIAL + BCI_CODOPE + BCI_CODLDP + BCI_CODPEG + BCI_FASE + BCI_SITUAC

If !lFmrTxt
	oRel := FWMSPrinter():New(cRelName,6,.F.,nil,.T.,nil,@oRel,nil,nil,.F.,.F.)	
	oRel:cPathPDF := cPathDest
Endif

For ni := 1 to nfor
	
	if valType(oObj) == 'O'
		limpr := oObj:aCols[nI,nPosIIII] == "LBOK"
		
		IF lImpr
			cCodRda := oObj:aCols[ni,nPosI]
			cCodPeg := oObj:aCols[ni,nPosII]
			cStatus	:= oObj:aCols[ni,nPosIII]
			cSequen	:= oObj:aCols[ni,nPosSequen]

			BXX->( msSeek( xFilial("BXX")+cCodInt+cCodRda+cCodPeg ) )
			cChave := BXX->BXX_CHVPEG
		Endif
		
	Endif
		
	IF lImpr
	
		If lWeb
	
		 	If nRecno > 0 //SE INFORMOU O RECNO EH PORQUE ELE ESTA BUSCANDO PELA BCI VIA PORTAL
		 		BCI->(DbGoTo(nRecno))
		 		lFound := .T.
		 		lWeb   := .F.                       
		 		lVlrRel	:= .t.                    
		 	Else
							
		 		lFound := BXX->( MsSeek( xFilial("BXX") + lower(cChave))) .or. BXX->( MsSeek( xFilial("BXX") + upper(cChave) ) )
		 		
			Endif
		Else
		 	lFound := BCI->( msSeek(xFilial("BCI")+cChave))
		Endif                                  

		If lFound
			
		    If lWeb                            
				cCodRda := BXX->BXX_CODRDA
				cCodInt := BXX->BXX_CODINT                      
				dDatMov := BXX->BXX_DATMOV                
				cCodPeg := BXX->BXX_CODPEG
				cArqIn	 := BXX->BXX_ARQIN
				cTipGui := PLTipGuiBXX(BXX->BXX_TIPGUI)
				nQtdGui := BXX->BXX_QTDGUI  
				nVlrApr := BXX->BXX_VLRTOT
				nValApBA0 := BXX->BXX_VLRTOT //Quando é do XML tem que ser esse campo
		
			Else
			
				cCodRda := BCI->BCI_CODRDA
				cCodInt := BCI->BCI_CODOPE                      
				dDatMov := BCI->BCI_DTDIGI
				cCodPeg := BCI->BCI_CODPEG
				cArqIn	 := BCI->BCI_ARQUIV        
				cTipGui := PLTipGuiBXX(BCI->BCI_TIPGUI, "BCI_TIPGUI")              								
				nQtdGui 	:= BCI->BCI_QTDDIG  
				nVlrApr 	:= BCI->BCI_VLRGUI
				nValApBA0 	:= iif(lVlrRel .or. BCI->BCI_VALORI <> 0, BCI->BCI_VALORI, BCI->BCI_VLRAPR) //BCI_VALORI só tem valor após a mudança de fase da guia importada
		
			Endif
			cBkpTpGui := strzero(val(cTipGui),2)

			//posiciona na bau
			BAU->( dbSetOrder(1) ) //BAU_FILIAL + BAU_CODIGO
			BAU->( msSeek(xFilial("BAU")+cCodRda) ) 

			//local de atendimento para pegar o endereco
			BB8->( dbSetOrder(1) )//BB8_FILIAL + BB8_CODIGO + BB8_CODINT + BB8_CODLOC + BB8_LOCAL
			if BB8->( msSeek(xFilial("BB8")+cCodRda+cCodInt ) )
			
				while !BB8->( Eof() ) .and. BB8->(BB8_FILIAL+BB8_CODIGO+BB8_CODINT) == xFilial("BB8")+cCodRda+cCodInt

					if PLSDADRDA(cCodInt,cCodRda,"1",dDatMov,BB8->BB8_CODLOC)[1]
						exit
					endIf
					   
				BB8->( DbSkip() )
				endDo
				
				cDesLoc := BB8->BB8_DESLOC
				cEndNum := allTrim(BB8->BB8_END) + ", " + BB8->BB8_NR_END +  iif(!empty(BB8->BB8_COMEND), " - " + alltrim(BB8->BB8_COMEND), "")
				cBaMuEs := allTrim(BB8->BB8_BAIRRO)+" - "+allTrim(BB8->BB8_MUN)+" - "+BB8->BB8_EST
				cEstLoc	:= allTrim(BB8->BB8_EST)
				cEndCep := BB8->BB8_CEP   
			endIf
			
			//pegar endereco da operadora
			BA0->( dbSetOrder(1) )//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
			if BA0->( msSeek(xFilial("BA0")+cCodInt ) )
				
				If Empty(GetNewPar("MV_PNOMXML",""))
			   		cOpeNom := allTrim(BA0->BA0_NOMINT)
				Else
					cOpeNom := GetNewPar("MV_PNOMXML","")
				Endif
				
				If Empty(GetNewPar("MV_PENDXML",""))
					cOpeEnd := allTrim(BA0->BA0_END) + ', ' + allTrim(BA0->BA0_NUMEND) + ' - ' + allTrim(BA0->BA0_COMPEN)
				Else
					cOpeEnd := GetNewPar("MV_PENDXML","")
				Endif
				
				If Empty(GetNewPar("MV_POPEXML",""))
					cOpeBCE := allTrim(BA0->BA0_BAIRRO)+"/"+allTrim(BA0->BA0_CIDADE)+"/"+BA0->BA0_EST
				Else
					cOpeBCE := GetNewPar("MV_POPEXML","") 
				Endif
				
				If Empty(GetNewPar("MV_PCEPXML",""))
					cOpeCep := allTrim(BA0->BA0_CEP)
				Else
					cOpeCep := GetNewPar("MV_PCEPXML","")
				Endif
				
			endIf
			
			if lFmrTxt
			
				cBarra 		:= If(BAU->BAU_TIPPE=='F','01','02') + cCodPeg + strZero(val(BAU->BAU_CPFCGC),14)
				aDadosIte	:= {}
				aDadosExt	:= {}
				aDadosCap	:= { alltrim(BAU->BAU_CODIGO) + " - " + alltrim(BAU->BAU_NOME) + " - " + iIf(BAU->BAU_TIPPE == 'F',"cpf: ","cnpj: ") + BAU->BAU_CPFCGC,;
								 cEndNum,;
								 cBaMuEs,;
								 cEndCep,;
								 allTrim(BXX->BXX_ARQIN),;
								 cOpeNom,;
								 cOpeEnd,;
								 cOpeBCE,;
								 cOpeCep,;
								 cBarra,;
								 cValToChar(nQtdGui),;
								 iif( ! lTipVlAp, allTrim( transForm(nVlrApr,PLSMONEY) ), allTrim( transForm(nValApBA0,PLSMONEY) ) ),;
								 cCodPeg,;
								 cArqIn,;
								 cEstLoc,;
								 dToc(dDatMov),;
								 cTipGui }
				
				cContCAPA 	:= PLCRPROT(aDadosIte, aDadosCap, aDadosExt, .T., , iif(nRecno > 0, .t., .f.), lTipVlAp)
				
				If nRecno > 0
					
					cCont := PLSR754Imp(nil,.T.,nil,cCodPeg, { cCodRda, cCodRda, nil, ctod(''), ctod(''), Iif(cBkpTpGui <> "05",1,3), 0, 3 }, IIF((!lEntrou),.F.,.T.),cContCAPA,.T., cBkpTpGui, lTipVlAp)
					
					Return(cCont)
					
				Else

					cContCAPA += "</body> </html>" 
					cContCAPA := Encode64(alltrim(cContCAPA))
					
					Return(cContCAPA)
					
				EndIf
									
			EndIf
			
			// Instancia os objetos de fonte antes da pintura do relatorio    
			oFont12  := TFont():New( "Arial",, 12,,.F.)
			oFont12N := TFont():New( "Arial",, 12,,.T.)
			oFont18	 := TFont():New( "Arial",, 18,,.F.)
			oFont18N := TFont():New( "Arial",, 18,,.T.)
			
			//Obj
			oRel:setResolution(72)                                                            
			//se esta habilitado para mostrar, e foi chamado a partir da 'CONSULTA DE PROTOCOLO' gerado pelo Portal (nRecno > 0)
			If GetnewPar("MV_IMPPROP",.T.) .and. nRecno > 0 
				oRel:setLandscape()
				nLargLogo+=110
				nIniBox  +=160
				nPixFin	 +=100
			Else
				oRel:setPortrait()
			Endif
			oRel:setPaperSize(DMPAPER_A4)                                                 	
	
			//nEsquerda, nSuperior, nDireita, nInferior 
			oRel:setMargin(05,05,05,05)
		
			//setup da impressora
			If !lWeb .AND. lMarc .And. lAbrSetup
				oRel:Setup()
				lMarc:=.F.

				If oRel:nModalResult == 2 //Verifica se foi Cancelada a Impressão
					Return{"",""}
				EndIf
			EndIf
			
			//Inicializa uma pagina
			oRel:StartPage()	
			
			aBMP			:= {"lgrlpr.bmp"}
			If File("lgrlpr" + FWGrpCompany() + FWCodFil() + ".bmp")
				aBMP := { "lgrlpr" + FWGrpCompany() + FWCodFil() + ".bmp" }
			ElseIf File("lgrlpr" + FWGrpCompany() + ".bmp")
				aBMP := { "lgrlpr" + FWGrpCompany() + ".bmp" }
			EndIf
			If !Empty(aBMP[1])
				oRel:SayBitmap(15,20, aBMP[1],130,75) 		//-- Tem que estar abaixo do RootPath 
			Endif      
			nPixLin += 25

			//Imprime "mini" cabeçalho
			oRel:say(nPixLin,nPixCol+nLargLogo,"REDE DE ATENDIMENTO:",oFont18)
			nPixLin += 15
			oRel:say(nPixLin,nPixCol+nLargLogo,alltrim(BAU->BAU_CODIGO) + " - " + alltrim(BAU->BAU_NOME)+" - "+iIf(BAU->BAU_TIPPE=='F',"cpf: ","cnpj: ") + BAU->BAU_CPFCGC,oFont12)
			nPixLin += 15
			oRel:say(nPixLin,nPixCol+nLargLogo,cEndNum,oFont12)
			nPixLin += 15
			oRel:say(nPixLin,nPixCol+nLargLogo,cBaMuEs,oFont12)
			nPixLin += 15
			oRel:say(nPixLin,nPixCol+nLargLogo,cEndCep,oFont12)
			nPixLin += 160
			oRel:say(nPixLin,nPixCol+nLargLogo,"PROTOCOLO ELETRÔNICO DE GUIAS",oFont18)	
			nPixLin := nPixLin+50
			If !Empty(cProt)
				oRel:say(nPixLin,nPixCol+nLargLogo,"Numero: " + cProt,oFont18)
				nPixLin := nPixLin+20
			EndIf 

			//Imprime o Box principal
			oRel:Box(nPixLin,nPixCol+nIniBox,nPixLin+80,nPixCol+nPixFin)
			nPixLin += 20

			//Imprime uma linha dentro do box
			oRel:say(nPixLin,nPixCol+nIniBox+5,"A(o)",oFont12)
			nPixLin += 15
			oRel:say(nPixLin,nPixCol+nIniBox+8,cOpeNom,oFont12)
			nPixLin += 10
			oRel:say(nPixLin,nPixCol+nIniBox+8,cOpeEnd,oFont12)
			nPixLin += 10
			oRel:say(nPixLin,nPixCol+nIniBox+8,cOpeBCE,oFont12)
			nPixLin += 10
			oRel:say(nPixLin,nPixCol+nIniBox+8,cOpeCep,oFont12)
			nPixLin += 30
			nPixLin += 20
			nPixLin += 30

			//Imprime o PEG em codigo de barras
			If GetNewPar('MV_PSHCODB','0') == '1'
				cBarra := If(BAU->BAU_TIPPE=='F','01','02')+cCodPeg+strzero(val(BAU->BAU_CPFCGC),14)
				oRel:Code128C(nPixLin,nPixCol+nIniBox+35,cBarra,70)
			Endif
			nPixLin += 90

			//PEG quatidade de guias
			oRel:say(nPixLin,nPixCol,"PROTOCOLO: "+cCodPeg,oFont12)
			nPixLin += 10
			If !Empty(cArqIn)
				oRel:say(nPixLin,nPixCol,"ARQUIVO: "+cArqIn,oFont12)
				nPixLin += 10      
			Endif
			oRel:say(nPixLin,nPixCol,"QUANTIDADE DE GUIAS: "+cValToChar(nQtdGui),oFont12)
			nPixLin += 10
			
			//Verifico se deve ser o total de guias ou Valor Apresentado pelo Prestador
			If !lTipVlAp
				oRel:say(nPixLin,nPixCol,"VALOR: R$ "+allTrim(transForm(nVlrApr,PLSMONEY)),oFont12)
			Else
				oRel:say(nPixLin,nPixCol,"VALOR: R$ "+allTrim(transForm(nValApBA0,PLSMONEY)),oFont12)
			EndIf	

			//dados finais
			oRel:say(nPixLin,nPixCol+nIniBox+300,cEstLoc+" - "+dToc(dDatMov),oFont12)
			nPixLin += 10         

			//01=Consulta;02=SP_SADT;05=GRI;06=GHI;07=Odonto;08=Não identificada
			oRel:say(nPixLin,nPixCol+nIniBox+300,cTipGui,oFont12)

			//Quebra de Paginas
			If nPixLin > 700
				lEntrou 	:= .T.
				nPixLin 	:= 40
				oRel:EndPage()
				oRel:StartPage()	
			EndIf

			//Finaliza a pagina                                                         
			//se esta habilitado para mostrar, e foi chamado a partir da 'CONSULTA DE PROTOCOLO' gerado pelo Portal (nRecno > 0)
			If GetnewPar("MV_IMPPROP",.T.) .and. nRecno > 0 
				nTweb		:= 2.9
				nLweb		:= 10                
				cTitulo 	:= "Guias/Eventos contidos no Protocolo"
				nLeft		:= 40  
				nRight		:= 4000
				nCol0  		:= nLeft 
				nTop		:= 100
				nTopInt		:= nTop
				nPag		:= 1
				aParW2 		:= {cCodRda,cCodRda,nil,ctod(''),ctod(''),Iif(cBkpTpGui <> "05",1,3),1,3}
				
				If ! lEntrou
					oRel:EndPage()
					oRel:StartPage()	
				Endif
				
				PLSR754Imp(oRel, .T., NIL, cCodPeg, aParW2, IIF((!lEntrou),.F.,.T.), , /*lFmrTxt*/, cBkpTpGui)
				
			Endif   		
				lEntrou 	:= .T.
				nPixLin := 40
			oRel:EndPage()
		
		else
			if !lWeb
				msgAlert("Protocolo não encontrado!")
				Return()
			else
				Return {cRelName+".pdf",""}
			Endif
		
		Endif
	Endif
	
Next

oRel:Preview()

return{cRelName+".pdf",""}
 

//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSRCPRO
Relatorio capa de lote processo
@since 29/11/2012
@author Totvs
@version P12 
/*/
//-------------------------------------------------------------------
function PLSRCPRO(cChave,cPathDest,lWeb)
LOCAL nPixLin		:= 40
LOCAL nLargLogo		:= 140
LOCAL nIniBox		:= 90
LOCAL nPixCol		:= 40
LOCAL cDesLoc 		:= ""
LOCAL cEndNum 		:= ""
LOCAL cBaMuEs 		:= ""
LOCAL cEndCep 		:= ""
LOCAL cOpeNom 		:= ""
LOCAL cOpeEnd 		:= ""
LOCAL cEstLoc		:= ""
LOCAL cOpeBCE 		:= ""
LOCAL cOpeCep 		:= ""
LOCAL cRelName		:= "CAPAPROCESSO"+CriaTrab(NIL,.F.)   
//LOCAL lView			:= .t.
LOCAL oRel			:= nil
DEFAULT cPathDest	:= lower(GETMV("MV_RELT")) 
DEFAULT lWeb		:= .f.

//Posiciona no processo
BRI->( dbSetOrder(1) ) //BRI_FILIAL + BRI_CODOPE + BRI_CODIGO + BRI_CODRDA
if BRI->( msSeek(xFilial("BRI")+cChave) ) 

	//posiciona na bau
	BAU->( dbSetOrder(1) ) //BAU_FILIAL + BAU_CODIGO
	BAU->( msSeek(xFilial("BAU")+BRI->BRI_CODRDA) ) 

	//local de atendimento para pegar o endereco
	BB8->( dbSetOrder(1) )//BB8_FILIAL + BB8_CODIGO + BB8_CODINT + BB8_CODLOC + BB8_LOCAL
	if BB8->( msSeek(xFilial("BB8")+BRI->(BRI_CODRDA+BRI_CODOPE) ) )
		while !BB8->( Eof() ) .and. BB8->(BB8_FILIAL+BB8_CODIGO+BB8_CODINT) == xFilial("BB8")+BRI->(BRI_CODRDA+BRI_CODOPE)

			//Valida a Rda																			 
			if PLSDADRDA(BRI->BRI_CODOPE,BRI->BRI_CODRDA,"1",BRI->BRI_DATMOV,BB8->BB8_CODLOC)[1]
				exit
			endIf   
			BB8->( DbSkip() )
		endDo
		cDesLoc := BB8->BB8_DESLOC
		cEndNum := allTrim(BB8->BB8_END) + ", " + BB8->BB8_NR_END + iif(!empty(BB8->BB8_COMEND), " - " + alltrim(BB8->BB8_COMEND), "")
		cBaMuEs := allTrim(BB8->BB8_BAIRRO)+" - "+allTrim(BB8->BB8_MUN)+" - "+BB8->BB8_EST
		cEstLoc	:= allTrim(BB8->BB8_EST)
		cEndCep := BB8->BB8_CEP   
	endIf

	//pegar endereco da operadora
	BA0->( dbSetOrder(1) )//BA0_FILIAL+BA0_CODIDE+BA0_CODINT
	if BA0->( msSeek(xFilial("BA0")+BRI->BRI_CODOPE ) )
		cOpeNom := allTrim(BA0->BA0_NOMINT)
		cOpeEnd := allTrim(BA0->BA0_END)
		cOpeBCE := allTrim(BA0->BA0_BAIRRO)+"/"+allTrim(BA0->BA0_CIDADE)+"/"+BA0->BA0_EST
		cOpeCep := allTrim(BA0->BA0_CEP)
	endIf

	//Instancia os objetos de fonte antes da pintura do relatorio    
	oFont12  := TFont():New( "Arial",, 12,,.F.)
	oFont12N := TFont():New( "Arial",, 12,,.T.)
	oFont18	 := TFont():New( "Arial",, 18,,.F.)
	oFont18N := TFont():New( "Arial",, 18,,.T.)

	//Obj
	oRel := FWMSPrinter():New(cRelName,6	  ,.F.,nil,.T.,nil,@oRel,nil,nil,.F.,.F.)	
	oRel:setResolution(72)
	oRel:setPortrait()
	oRel:setPaperSize(DMPAPER_A4)                                                 	

	//nEsquerda, nSuperior, nDireita, nInferior 
	oRel:setMargin(05,05,05,05)
	oRel:cPathPDF := cPathDest

	//setup da impressora
	If !lWeb
		oRel:Setup()

		If oRel:nModalResult == 2 //Verifica se foi Cancelada a Impressão
			Return{"",""}
		EndIf
	EndIf

	//Inicializa uma pagina
	oRel:StartPage()	

	//Imprime "mini" cabeçalho
	oRel:say(nPixLin,nPixCol,"REDE DE ATENDIMENTO:",oFont18)
	nPixLin += 15
	oRel:say(nPixLin,nPixCol,iIf(BAU->BAU_TIPPE=='F',"CPF: ","CNPJ: ") + BAU->BAU_CPFCGC,oFont12)
	nPixLin += 15
	oRel:say(nPixLin,nPixCol,cDesLoc,oFont12)
	nPixLin += 15
	oRel:say(nPixLin,nPixCol,cEndNum,oFont12)
	nPixLin += 15
	oRel:say(nPixLin,nPixCol,cBaMuEs,oFont12)
	nPixLin += 15
	oRel:say(nPixLin,nPixCol,cEndCep,oFont12)
	nPixLin += 60
	oRel:say(nPixLin,nPixCol+nLargLogo,"PROCESSO DE ENTREGA DE GUIAS",oFont18)
	nPixLin := nPixLin+50 

	//Imprime o Box principal
	oRel:Box(nPixLin,nPixCol+nIniBox,nPixLin+80,nPixCol+450)
	nPixLin += 20

	//Imprime uma linha dentro do box
	oRel:say(nPixLin,nPixCol+nIniBox+5,"À",oFont12)
	nPixLin += 15
	oRel:say(nPixLin,nPixCol+nIniBox+8,cOpeNom,oFont12)
	nPixLin += 10
	oRel:say(nPixLin,nPixCol+nIniBox+8,cOpeEnd,oFont12)
	nPixLin += 10
	oRel:say(nPixLin,nPixCol+nIniBox+8,cOpeBCE,oFont12)
	nPixLin += 10
	oRel:say(nPixLin,nPixCol+nIniBox+8,cOpeCep,oFont12)
	nPixLin += 30
	oRel:say(nPixLin,nPixCol+nIniBox+130,allTrim(BAU->BAU_TIPPE)+"-"+allTrim(BRI->BRI_CODIGO)+"-"+allTrim(BAU->BAU_CPFCGC),oFont12)
	nPixLin += 70

	//Imprime o processo em codigo de barras
	//cBarra := BAU->BAU_TIPPE+BRI->BRI_CODIGO+BAU->BAU_CPFCGC
	//oRel:Code128C(nPixLin,nPixCol+nIniBox+30,cBarra,70)
	nPixLin += 50

	//processo quatidade de guias
	oRel:say(nPixLin,nPixCol,"PROCESSO: "+BRI->BRI_CODIGO,oFont12)
	nPixLin += 10
	oRel:say(nPixLin,nPixCol,"QUANTIDADE DE PROTOCOLOS: "+cValToChar(BRI->BRI_QTDPEG),oFont12)
	nPixLin += 10
	oRel:say(nPixLin,nPixCol,"VALOR: R$ "+allTrim(transForm(BRI->BRI_VLRAPR,PLSMONEY)),oFont12)
	nPixLin += 40

	//dados finais
	oRel:say(nPixLin,nPixCol+nIniBox+300,cEstLoc+" - "+dToc(BRI->BRI_DATMOV),oFont12)
	nPixLin += 10         

	//Quebra de Paginas
	If nPixLin > 700
		nPixLin 	:= 40
		oRel:EndPage()
		oRel:StartPage()	
	EndIf

	//Finaliza a pagina
	oRel:EndPage()   		
	oRel:Preview()
else
	if !lWeb
		msgAlert("PROCESSO não encontrado!")
	endIf	
endIf

//fim da rotina
return(cRelName)


//-------------------------------------------------------------------
/*/ {Protheus.doc} PLSRCRIT
Relatorio de criticas do processamento do arquivo
@since 29/11/2012
@author Totvs
@version P12 
/*/
//-------------------------------------------------------------------
function PLSRCRIT(cChave,cPathDest,lWeb,cTexto,cInfo)
//LOCAL lView			:= .t.
LOCAL nPixLin		:= 40
LOCAL nPixCol		:= 40
LOCAL oRel			:= nil
LOCAL cRelName		:= LOWER("criticaslote"+CriaTrab(NIL,.F.))   
LOCAL nLargLogo		:= 140  
LOCAL cDesLoc 		:= ""
LOCAL cEndNum 		:= ""
LOCAL cBaMuEs 		:= ""
LOCAL cEndCep 		:= ""
LOCAL cEstLoc		:= ""
LOCAL nLinTotal:=0
LOCAL nCont:=0
LOCAL nCont1:=0
Local cRelArq:=""
Local cRelArq1:=""

Local lFmrTxt		:= .T. //No futuro, será trocado para parâmetro decidir, mas a melhoria agora será sempre TXT.
Local cRetTxt			:= ""

DEFAULT cPathDest	:= lower(GETMV("MV_RELT")) 
DEFAULT lWeb		:= .f.
DEFAULT cTexto 		:= "CRITICAS REFERENTE A VALIDACAO DO XML"
DEFAULT cInfo		:= "Criticas"

//Posiciona no PEG  
If lWeb 
	cTexto := "ARQUIVO NAO IMPORTADO DEVIDO A INCONSISTENCIAS DETECTADAS"
Endif
	BXX->( dbSetOrder(7) )              
//z
if BXX->( MsSeek( xFilial("BXX") + lower(cChave) ) ) .or. BXX->( MsSeek( xFilial("BXX") + upper(cChave) ) )


	//posiciona na bau
	BAU->( dbSetOrder(1) ) //BAU_FILIAL + BAU_CODIGO
	BAU->( msSeek(xFilial("BAU")+BXX->BXX_CODRDA) )     
	
	BB8->( dbSetOrder(1) )//BB8_FILIAL + BB8_CODIGO + BB8_CODINT + BB8_CODLOC + BB8_LOCAL
	if BB8->( msSeek(xFilial("BB8")+BXX->(BXX_CODRDA+BXX_CODINT) ) )
		while !BB8->( Eof() ) .and. BB8->(BB8_FILIAL+BB8_CODIGO+BB8_CODINT) == xFilial("BB8")+BXX->(BXX_CODRDA+BXX_CODINT)

			//Valida a Rda																			 
			if PLSDADRDA(BXX->BXX_CODINT,BXX->BXX_CODRDA,"1",BXX->BXX_DATMOV,BB8->BB8_CODLOC)[1]
				exit
			endIf   
			BB8->( DbSkip() )
		endDo
		cDesLoc := BB8->BB8_DESLOC
		cEndNum := allTrim(BB8->BB8_END) + ", " + BB8->BB8_NR_END + iif(!empty(BB8->BB8_COMEND), " - " + alltrim(BB8->BB8_COMEND), "")
		cBaMuEs := allTrim(BB8->BB8_BAIRRO)+" - "+allTrim(BB8->BB8_MUN)+" - "+BB8->BB8_EST
		cEstLoc	:= allTrim(BB8->BB8_EST)
		cEndCep := BB8->BB8_CEP   
	endIf
	
	if lWeb .AND. lFmrTxt //Gera em html para o portal
		cRetTxt := PLSRETCRTXT(BAU->BAU_NOME, iIf(BAU->BAU_TIPPE=='F'," CPF: "," CNPJ: "), Alltrim(BAU->BAU_CPFCGC), cEndNum, cBaMuEs, cEndCep, BXX->BXX_ARQIN, BXX->BXX_DATMOV)
		Return (cRetTxt)
	EndIf
	
	//Instancia os objetos de fonte antes da pintura do relatorio    
	oFont8  := TFont():New( "Lucida Console",, 8,,.F.)
	oFont9  := TFont():New( "Arial",, 9,,.F.)
	oFont10  := TFont():New( "Arial",, 10,,.F.)
	oFont12  := TFont():New( "Arial",, 12,,.F.)
	oFont12N := TFont():New( "Arial",, 12,,.T.)
	oFont18	 := TFont():New( "Arial",, 18,,.F.)
	oFont18N := TFont():New( "Arial",, 18,,.T.)

	//Obj
	oRel := FWMSPrinter():New(cRelName,6	  ,.F.,nil,.T.,nil,@oRel,nil,nil,.F.,.F.)	
	oRel:setResolution(72)
	oRel:setPortrait()
	oRel:setPaperSize(DMPAPER_A4)                                                 	

	//nEsquerda, nSuperior, nDireita, nInferior 
	oRel:setMargin(05,05,05,05)
	oRel:cPathPDF := cPathDest

	//setup da impressora
	If !lWeb
		oRel:Setup()

		If oRel:nModalResult == 2 //Verifica se foi Cancelada a Impressão
			Return{"",""}
		EndIf
	EndIf

	//Inicializa uma pagina
	oRel:StartPage() 
	aBMP			:= {"lgrlpr.bmp"}
	If File("lgrlpr" + FWGrpCompany() + FWCodFil() + ".bmp")
		aBMP := { "lgrlpr" + FWGrpCompany() + FWCodFil() + ".bmp" }
	ElseIf File("lgrlpr" + FWGrpCompany() + ".bmp")
		aBMP := { "lgrlpr" + FWGrpCompany() + ".bmp" }
	EndIf
	If !Empty(aBMP[1])
		oRel:SayBitmap(15,20, aBMP[1],130,75) 		//-- Tem que estar abaixo do RootPath 
	Endif	

	//Imprime "mini" cabeçalho
	oRel:say(nPixLin,nPixCol+nLargLogo,"REDE DE ATENDIMENTO:",oFont18)
	nPixLin += 15
	oRel:say(nPixLin,nPixCol+nLargLogo,alltrim(BAU->BAU_NOME)+" - "+iIf(BAU->BAU_TIPPE=='F',"cpf: ","cnpj: ") + BAU->BAU_CPFCGC,oFont12)
	nPixLin += 15
	oRel:say(nPixLin,nPixCol+nLargLogo,cEndNum,oFont12)
	nPixLin += 15
	oRel:say(nPixLin,nPixCol+nLargLogo,cBaMuEs,oFont12)
	nPixLin += 15
	oRel:say(nPixLin,nPixCol+nLargLogo,cEndCep,oFont12)
	nPixLin += 15
	oRel:say(nPixLin,nPixCol+nLargLogo,"ARQUIVO: ",oFont9)
	nPixLin += 10
	cRelArq:=allTrim(BXX->BXX_ARQIN)
	nLinTotal := MlCount(cRelArq)  
	For nCont1 := 1 To nLinTotal
		cRelArq1:= MemoLine(cRelArq,90, nCont1)
		oRel:say(nPixLin,nPixCol+nLargLogo," "+allTrim(cRelArq1),oFont9)
		nPixLin += 10
	Next nCont1
	nPixLin += 10
	//oRel:say(nPixLin,nPixCol+nLargLogo,"DATA MOVIMENTAÇÃO: "+dToc(BXX->BXX_DATMOV),oFont12)
	oRel:say(nPixLin,nPixCol+nLargLogo,cEstLoc+" - "+dToc(BXX->BXX_DATMOV) +" - " + PLTipGuiBXX(BXX->BXX_TIPGUI),oFont10)
	nPixLin += 45
	oRel:say(nPixLin,nPixCol+nLargLogo-50,cTexto,oFont12N)
	nPixLin += 25

	//Criticas
	oRel:say(nPixLin, nPixCol, cInfo, oFont10)
	nPixLin += 5
	oRel:line(nPixLin,nPixCol,nPixLin,nPixCol+520)
	nPixLin += 25                  
	cTextOri := MSMM(BXX->BXX_CODREG,999)
	
	If (nHdlLog := FCreate(cRelName,0)) == -1
		Return {cRelName+".pdf",""}
   EndIf
   FSeek(nHdlLog,0,2)
   FWrite(nHdlLog,cTextOri+Chr(13)+Chr(10))
   FClose(nHdlLog)
  
	FT_FUse( cRelName )
	FT_FGotop()
	While ( !FT_FEof() )       
	    cRelato := FT_FREADLN()
		nLinTotal := MlCount(cRelato)  //Imprime o campo .
		For nCont := 1 To nLinTotal
			oRel:say(nPixLin,nPixCol,MemoLine(cRelato, 90, nCont),oFont8)
			nPixLin+= 10

			If nPixLin > 700
				nPixLin := 40
				oRel:EndPage()
				oRel:StartPage()	
			Endif
		Next nCont
		FT_FSkip()
	EndDo
	FT_FUse(  )
	FErase ( cRelName )  

	//Quebra de Paginas
	If nPixLin > 700
		nPixLin := 40
		oRel:EndPage()
		oRel:StartPage()	
	EndIf

	//Finaliza a pagina
	oRel:EndPage()   		
	oRel:Preview()
else
	if !lWeb
		msgAlert("PEG não encontrado!")
	endIf	
endIf

//fim da rotina
return{cRelName+".pdf",""}



/*/{Protheus.doc} PLSRETCRTXT
Montagem das críticas do XML não acatado em HTML
@author Renan Martins
@since 06/2017
/*/
Function PLSRETCRTXT (cNome, cTipCpfJ, cCpfJ, cEndereco, cMunic, cCep, cArq, cDatArq )

Local cMemo := ""
Local cMemoCod:= ""
Local cTemp := ""

cMemo := fwcutoff(MSMM(BXX->BXX_CODREG,999))

cMemoCod := "<html> " 
cMemoCod += " <head>"

cMemoCod += "<link href='PRTSKINS/componentes/jquery-ui/jquery-ui.css' rel='stylesheet' type='text/css'>"
cMemoCod += "	<script type='text/javascript' src='PRTSKINS/componentes/jquery/jquery.js'></script>"
cMemoCod += "	<script type='text/javascript' src='PRTSKINS/jquery-1.7.1.min.js'></script>"

cMemoCod += "  <script type='text/javascript'> "
cMemoCod += "  $(window).load(function(){ "
cMemoCod += "  var offset = $('#Imprimir').offset().top;"
cMemoCod += "  var $Imprimir = $('#Imprimir');"
cMemoCod += "  $(document).on('scroll', function () {	"
cMemoCod += "  if (offset <= $(window).scrollTop()) { "
cMemoCod += "     $Imprimir.addClass('fixar'); "
cMemoCod += "   } else { "
cMemoCod += "     $Imprimir.removeClass('fixar');	 "
cMemoCod += "  } "
cMemoCod += "  }); "
cMemoCod += " }); "
cMemoCod += " </script>"

cMemoCod += " <style type='text/css'> #Imprimir { background:#00A9C7;  width:100%; margin-top: 0px; padding: 2px; }  .fixar {  position:fixed; top: 0px; }  " 
cMemoCod += " .cab  { font-weight:bold; text-align:center;}  p.titulo { font-weight:bold; font-size:20px; text-align:center; }	"
cMemoCod += " .subtitulo {font-weight:bold; text-align:left; font-size:15px; padding: 10px;} body {font-family:Arial, Verdana;} .txt {background:#f7fcfc; width:100%; word-wrap: break-word; } "
cMemoCod += " @media print {#Imprimir { display:none; } }	"
cMemoCod += " .btnImp {background-color: #fff; color: #333; border-color: #ccc; outline: none; border-radius: 10px; padding: 5px 10px; text-align: center; margin-left: 10px}  </style>" 

cMemoCod += " </head> "

cMemoCod += "<body> "
 			 	 
cMemoCod += " <div id='Imprimir'><input type='button' class='btnImp' name='Imprimir' value='Imprimir' onclick='window.print();'></div> "
cMemoCod += "<div class='txt'>"

cMemoCod += "<p> <span class='cab'> Rede de Atendimento: </span>" + Alltrim(cNome) + "<span class='cab'> - " + Alltrim(cTipCpfJ) + "</span>" + Alltrim(cCpfJ) + "</p>"
cMemoCod += "<p> <span class='cab'> Endereço: </span>" + Alltrim(cEndereco) + " <span class='cab'> - Município/UF: </span>" + Alltrim(cMunic) + " <span class='cab'> - CEP: </span>" + Alltrim(cCep) + "</p>"
cMemoCod += "<p> <span class='cab'> Arquivo XML: </span>" + Alltrim(cArq) + " <span class='cab'>- Data Arquivo: </span>" + Alltrim(dToc(cDatArq)) + " <span class='cab'> - Tipo: </span>" + Alltrim(PLTipGuiBXX(BXX->BXX_TIPGUI)) + "</p>"
cMemoCod += "<p class='titulo'> Arquivo não Importado devido a Inconsistências detectadas </p> "
cMemoCod += "<p class='subtitulo'> Críticas encontradas: <br> </p> "

cTemp := StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(cMemo, "** ERRO [", "</p><hr><p>** ERRO ["), "] **", "] **<br>"), "Tag XML:", "<br>Tag XML:"), "Tag :", "<br>Tag :"),;
          "Beneficiario:", "<br>Beneficiario:"), "Numero ", "<br>Numero ")
          
cTemp := StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(cTemp, "Valor no", "<br>Valor no" ), "** [ E", "</p><hr><p>** [ E"),;
          "Data ", "<br>Data "), "Nome do Profissional:", "<br>Nome do Profissional:"), "*** ERRO [", "</p><hr><p>*** ERRO ["), "] ***", "] ***<br>")
          
cTemp := StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(cTemp, "Nome do arquivo:", "<br>Nome do arquivo:"), "Numero sequencial", "<br>Numero sequencial"), "Nome do arquivo:", "<br>Nome do arquivo:"),;
			 "Hash informado:", "<br>Hash informado:"), "Versao do arquivo", "<br>Versao do arquivo"), "Versao aceite pela", "<br>Versao aceite pela")
			 
cTemp := StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(cTemp, "Hash informado", "<br>Hash informado"), "Hash do conteudo", "<br>Hash do conteudo"), "Procedimento Nao", "<br>Procedimento Nao"),;
			 "Codigo", "<br>Codigo"), "Tipo de", "<br>Tipo de"), "Prestador que", "<br>Prestador que")

cTemp := StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(cTemp, "Matricula", "<br>Matricula"), "Registro", "<br>Registro"), "Operadora", "<br>Operadora"), "Dado", "<br>Dado"),;
		  "Tabela", "<br>Tabela"), "Local", "<br>Local")  		
		 
cTemp := StrTran(StrTran(StrTran(StrTran(StrTran(StrTran(cTemp, "Para ", "<br>Para "), "Quantidade", "<br>Quantidade"), "Membro", "<br>Membro"), "CBOS", "<br>CBOS"),;
		  "Nao", "<br>Nao"), "Tipo", "<br>Tipo")            

cTemp := StrTran(StrTran(StrTran(cTemp, "Descricao", "<br>Descricao"), "RDA Submissao", "<br>RDA Submissao",), "RDA Origem", "<br>RDA Origem")

cMemoCod += Alltrim(cTemp)
           
cMemoCod += "</p> </div> </body> </html>"
cMemoCod := Encode64(alltrim(cMemoCod)) 

Return (cMemoCod)


/*/{Protheus.doc} PLCRPROT
Monta o HTML de Protocolo
aDadosIte = Dados que compõem a tabela.
aDadosCap = Dados que compõem a capa.
aDadosExt = Dados complementares(Rodapé)
lCapa     = Indica se é para montar a capa.
cTextCabc = Dados da capa para concatenar com o conteúdo.
@author André Dini
@since 07/2017
/*/
Function PLCRPROT(aDadosIte, aDadosCap, aDadosExt, lCapa, cTextCabc, lUpXML, lVlrApr)
local aBmp			:= {}
LOCAL ni 		:= 1
LOCAL cMemoCod	:= ""
LOCAL nTotalReg  := 0
LOCAL nTotalAprs := 0
local nTotalPag	:= 0
local lTextImg	:= .f.

DEFAULT aDadosIte	:= {}
DEFAULT aDadosCap	:= {}
DEFAULT aDadosExt	:= {}
DEFAULT lCapa := .F.
DEFAULT cTextCabc := "" 
Default lUpXML 	:= .f.
Default lVlrApr	:= .f.

If lCapa
	
	if File(PLSMUDSIS(getWebDir() + getSkinPls() + "\logo_capa.bmp"))
		aBMP := { "logo_capa.bmp" }
	elseif File(PLSMUDSIS(getWebDir() + getSkinPls() + "\logo_capa.png"))
		aBMP := { "logo_capa.png" }
	EndIf
	
	if Empty(aBMP)
		lTextImg := .t.
	Endif  


	cTextCabc := "<html> " 
	cTextCabc += "<head>"
	cTextCabc += "<link href='PRTSKINS/componentes/jquery-ui/jquery-ui.css' rel='stylesheet' type='text/css'>"
	cTextCabc += "	<script type='text/javascript' src='PRTSKINS/componentes/jquery/jquery.js'></script>"
	cTextCabc += "	<script type='text/javascript' src='PRTSKINS/jquery-1.7.1.min.js'></script>"
	cTextCabc += "	<script type='text/javascript' src='PRTSKINS/JsBarcode.all.min.js.js'></script>"  
	
	cTextCabc += "  <script type='text/javascript'> "
	
	cTextCabc += "  $(window).load(function(){ "
	cTextCabc += "  var offset = $('#Imprimir').offset().top;"
	cTextCabc += "  var $Imprimir = $('#Imprimir');"
	cTextCabc += "  $(document).on('scroll', function () {	"
	cTextCabc += "  if (offset <= $(window).scrollTop()) { "
	cTextCabc += "     $Imprimir.addClass('fixar'); "
	cTextCabc += "   } else { "
	cTextCabc += "     $Imprimir.removeClass('fixar');	 "
	cTextCabc += "  } "
	cTextCabc += " });JsBarcode('#barcode','" + alltrim(aDadosCap[10]) + "'); "
	cTextCabc += " });"
	cTextCabc += " </script>"
	
	
	cTextCabc += " <style type='text/css'> #Imprimir { background:#00A9C7;  width:100%; margin-top: 0px; padding: 2px; }  .fixar {  position:fixed; top: 0px; }  " 
	cTextCabc += " .cab  { font-weight:bold; text-align:center; font-size:8px}  p.titulo { font-weight:bold; font-size:17px; text-align:center; }	"
	cTextCabc += " .subtitulo {font-weight:bold; text-align:left; font-size:15px; padding: 10px;} body {font-family:Arial, Verdana;} .txt {background:#f7fcfc; width:100%; word-wrap: break-word; } "
	cTextCabc += " @media print {#Imprimir { display:none; } } @page {margin-top: 20mm;margin-bottom: 20mm;}	"
	cTextCabc += " .btnImp {background-color: #fff; color: #333; border-color: #ccc; outline: none; border-radius: 10px; padding: 5px 10px; text-align: center; margin-left: 10px}
	cTextCabc += " table { font-family: arial, sans-serif; border-collapse: collapse; width: 100%; page-break-inside:auto }
	cTextCabc += " td, th { border: 1px solid #017d93; text-align: left; padding: 8px;font-size: 8px}
	cTextCabc += " tr:nth-child(even) {background-color: #00A9C7; page-break-inside:avoid; page-break-after:auto}"
	cTextCabc += "div.footer{ margin-top: 90px;border-bottom: solid}"
	
	//Habilitando ou não a impressão do código de barras
	If GetNewPar('MV_PSHCODB','0') == '1'
		cTextCabc += "div.codBar{ text-align:center;}"	
	Else
		cTextCabc += "div.codBar{ margin-left:650px; visibility:hidden}"
	EndIf	
	cTextCabc += "div.destinatario{width: 350px; margin:0 auto ; margin-top:45px; border: 1px solid;}"
	cTextCabc += "h2.titulo{text-align: center; margin-top: 20px; margin-bottom: 45px; font-size: 10px }"
	cTextCabc += "div.cabe{margin:0 auto; text-align: center; padding-right:100px}"
	cTextCabc += "div.imagem{float: left;}</style>"
	
	cTextCabc += "</head><body>"
	
	//IMPRIMIR
	cTextCabc += " <div id='Imprimir'><input type='button' class='btnImp' name='Imprimir' value='Imprimir' onclick='window.print();'></div> "
	
	//LOGO
	
	if lTextImg
		cTextCabc += "<small> Insira o logo no diretório Web, na pasta <strong>imagens-pls</strong>: <br> logo_capa.bmp (100 x 150) </small>"	
	else
	cTextCabc += "<div class='capa'><div class='imagem'>"
		cTextCabc += "<img src='PRTSKINS/" + aBmp[1] + "' alt='Coloque o Logo no RoothPath' height='100' width='150'>"
	cTextCabc += "</div>"
	endif

	
	//CABEÇALHO    
	cTextCabc += "<div class='cabe'><strong>REDE DE ATENDIMENTO: </strong><br>"
	cTextCabc +=  alltrim(aDadosCap[1]) + "<br>"
	cTextCabc +=  alltrim(aDadosCap[2]) + "<br>" 
	cTextCabc +=  alltrim(aDadosCap[3]) + "<br>"
	cTextCabc +=  alltrim(aDadosCap[4]) + "<br>"
	cTextCabc += "</div>"
	
	//TITULO
	cTextCabc += "<h2 class='titulo'>PROTOCOLO ELETRÔNICO DE GUIAS</h2>"
	
	//CODIGO DE BARRAS
	cTextCabc += "<div class='codBar'><svg id='barcode'></svg></div>"
	
	
	//DESTINATARIO
	cTextCabc += "<div class='destinatario'><small>A(o)<br>"
	cTextCabc += alltrim(aDadosCap[6]) + "<br>"
	cTextCabc += alltrim(aDadosCap[7]) + "<br>"
	cTextCabc += alltrim(aDadosCap[8]) + "<br>"
	cTextCabc += alltrim(aDadosCap[9]) + "<br></small>"		 
	cTextCabc += "</div>"
	
	//RODAPE DA CAPA
	cTextCabc += "<div style='page-break-after: always' class='footer'>"
	cTextCabc += "<small>PROTOCOLO: " + alltrim(aDadosCap[13]) + "<br></small>"
	If !Empty(aDadosCap[14])
		cTextCabc += "<small>ARQUIVO: " + alltrim(aDadosCap[14]) + "<br></small>"
	EndIf	
	cTextCabc += "<small>QUANTIDADE DE GUIAS: " + alltrim(aDadosCap[11]) + "<br></small>"
	cTextCabc += "<small>VALOR" + iif(lVlrApr, " APRESENTADO:", ":") + " R$ " + alltrim(aDadosCap[12]) + "<br></small>"
	if (!lUpXML)
		cTextCabc += "<small>" + alltrim(aDadosCap[15]) + ' - ' + alltrim(aDadosCap[16]) + "<br></small>"
		cTextCabc += "<small>" + alltrim(aDadosCap[17]) + "<br></small>"
	endif
	cTextCabc += iif(lVlrApr, "<small> O valor de pagamento deste protocolo deve ser consultado no Demonstrativo de Pagamento. <br></small>", "")
	
	cTextCabc += "</div></div>"	
	return(cTextCabc)

else

	cMemoCod += alltrim(cTextCabc)
	
	cMemoCod += "<div class='txt'>"
	
	cMemoCod += "<p class='titulo'> Guias/Eventos contidos no Protocolo </p>"
	
	cMemoCod += "<p><span class='cab'> Data: </span>" + alltrim(Substr(Dtos(Date()),7,2)) + "/" + alltrim(Substr(Dtos(Date()),5,2)) + "/" + alltrim(Substr(Dtos(Date()),1,4)) + "    "
	cMemoCod += "<span class='cab'> Hora: </span>" + alltrim(Time()) + "<br></p>"
	cMemoCod += "<p><span class='cab'> Prestador: </span>" + alltrim(aDadosExt[1]) + "</p>"
	
	if lVlrApr  //valor apresentado, mostro unitário e total
	cMemoCod += "<table><thead><tr><th>Data</th><th>Tp. Guia</th><th>Num Guia</th><th>Matricula</th><th>Nome do Beneficiário</th><th>Código</th><th>QTD</th><th>Neg</th><th>Exe/Lib</th><th>Vlr unitário apresentado</th><th>Vlr apresentado Total</th></tr></thead><tbody>"
	else
		cMemoCod += "<table><thead><tr><th>Data</th><th>Tp. Guia</th><th>Num Guia</th><th>Matricula</th><th>Nome do Beneficiário</th><th>Código</th><th>QTD</th><th>Neg</th><th>Exe/Lib</th><th>Vlr Pagamento</th></tr></thead><tbody>"
	endif
	
	For ni :=1 to  Len(aDadosIte)
		if lVlrApr
			cMemoCod += "<tr><td>" + alltrim(aDadosIte[ni][1]) + "</td><td>" + alltrim(aDadosIte[ni][2]) + "</td><td>" + alltrim(aDadosIte[ni][3]) + "</td><td  width='20%'>" + alltrim(aDadosIte[ni][4]) + "</td><td>" + alltrim(aDadosIte[ni][5]) + "</td><td>" + alltrim(aDadosIte[ni][6]) + "</td><td>" + alltrim(aDadosIte[ni][7]) + "</td><td>" + alltrim(aDadosIte[ni][8]) + "</td><td>" + alltrim(aDadosIte[ni][9]) + "</td><td>R$" + ALLTRIM(TRANSFORM(aDadosIte[ni][10], "@E 99,999,999,999.99")) + "</td><td>R$" + ALLTRIM(TRANSFORM(aDadosIte[ni][11], "@E 99,999,999,999.99")) + "</td>"		
		else
			cMemoCod += "<tr><td>" + alltrim(aDadosIte[ni][1]) + "</td><td>" + alltrim(aDadosIte[ni][2]) + "</td><td>" + alltrim(aDadosIte[ni][3]) + "</td><td  width='20%'>" + alltrim(aDadosIte[ni][4]) + "</td><td>" + alltrim(aDadosIte[ni][5]) + "</td><td>" + alltrim(aDadosIte[ni][6]) + "</td><td>" + alltrim(aDadosIte[ni][7]) + "</td><td>" + alltrim(aDadosIte[ni][8]) + "</td><td>" + alltrim(aDadosIte[ni][9]) + "</td><td>R$" + ALLTRIM(TRANSFORM(aDadosIte[ni][12], "@E 99,999,999,999.99")) + "</td>"
		endif
		
		If Len(aDadosIte) = 1
			nTotalReg  += (aDadosIte[ni][11])
			nTotalAprs += (aDadosIte[ni][10])  
			nTotalPag  += (aDadosIte[ni][12]) 
			if lVlrApr
			cMemoCod += "<tr><td colspan='9'></td> <td> <strong>R$ " + ALLTRIM(TRANSFORM(nTotalAprs, "@E 99,999,999,999.99")) + "</strong></td><td><strong>R$"+ ALLTRIM(TRANSFORM(nTotalReg, "@E 99,999,999,999.99")) + "</strong></td>"
			else
				cMemoCod += "<tr><td colspan='9'></td> <td> <strong>R$ " + ALLTRIM(TRANSFORM(nTotalPag, "@E 99,999,999,999.99")) + "</strong></td>
			endif	
			nTotalReg  := 0
			nTotalAprs := 0
			nTotalPag  := 0
			
		ElseIf ni == Len(aDadosIte)
			If aDadosIte[ni][3] == aDadosIte[ni-1][3]
				nTotalReg  += (aDadosIte[ni][11])
				nTotalAprs += (aDadosIte[ni][10])
				nTotalPag  += (aDadosIte[ni][12]) 
			Else
				nTotalReg  := (aDadosIte[ni][11])
				nTotalAprs := (aDadosIte[ni][10])
				nTotalPag  += (aDadosIte[ni][12]) 
			EndIf
			if lVlrApr
			cMemoCod += "<tr><td colspan='9'></td><td><strong> R$" + ALLTRIM(TRANSFORM(nTotalAprs, "@E 99,999,999,999.99")) + "</strong></td><td><strong> R$"+ ALLTRIM(TRANSFORM(nTotalReg, "@E 99,999,999,999.99")) + "</strong></td>"
			else
				cMemoCod += "<tr><td colspan='9'></td> <td> <strong>R$ " + ALLTRIM(TRANSFORM(nTotalPag, "@E 99,999,999,999.99")) + "</strong></td>
			endif
			nTotalReg  := 0
			nTotalAprs := 0
			nTotalPag  := 0
			
		ElseIf aDadosIte[ni][3] != aDadosIte[ni+1][3]
			nTotalReg  += (aDadosIte[ni][11])
			nTotalAprs += (aDadosIte[ni][10])
			nTotalPag  += (aDadosIte[ni][12]) 
			if lVlrApr
			cMemoCod += "<tr><td colspan='9'></td><td><strong> R$" + ALLTRIM(TRANSFORM(nTotalAprs, "@E 99,999,999,999.99")) + "</strong></td><td><strong> R$"+ ALLTRIM(TRANSFORM(nTotalReg, "@E 99,999,999,999.99")) + "</strong></td>"
			else
				cMemoCod += "<tr><td colspan='9'></td> <td> <strong>R$ " + ALLTRIM(TRANSFORM(nTotalPag, "@E 99,999,999,999.99")) + "</strong></td>
			endif
			nTotalReg  := 0
			nTotalAprs := 0
			nTotalPag  := 0
		
		Else
			nTotalReg  += (aDadosIte[ni][11])
			nTotalAprs += (aDadosIte[ni][10])
			nTotalPag  += (aDadosIte[ni][12]) 
		EndIf
	Next
	
	cMemoCod += "</tbody></table>"
	
	cMemoCod += "<p style='font-size:100%;'>Qtd. Iten(s): " + alltrim(aDadosExt[2]) + "<br>
	cMemoCod += "Qtd. Consulta(s) Aut.: " + alltrim(aDadosExt[3]) + space(1) + "Neg.:" + alltrim(aDadosExt[4]) + "<br>
	cMemoCod += "Qtd. Exame(s) Aut.: " + alltrim(aDadosExt[5]) + space(1) + "Neg.:" + alltrim(aDadosExt[6]) + "</p>
	           
	cMemoCod += "</div></body> </html>"
	
	cMemoCod := Encode64(alltrim(cMemoCod))

EndIf

Return (cMemoCod)



/*/{Protheus.doc} PLTipGuiBXX
Retorna o tipo de guia e texto, caso a função X3COMBO não retorne nada. Foi baseado no campo BXX_TIPGUI.
@author Renan Martins
@since 01/2019
/*/
Static Function PLTipGuiBXX(cTipGui, cCampoBsc)
local aTextTpG	:= {{"01", "Consulta"},{"02", "SADT"}, {"05", "GRI"}, {"06", "Honorário"}, {"07", "Odonto"}}
local nI			:= 0
local cResult		:= ""
default cCampoBsc	:= "BXX_TIPGUI"

cResult := X3COMBO(cCampoBsc,cTipGui)

if empty(cResult)
	
	for nI := 1 to len(aTextTpG)
		if ( val(cTipGui) == val(aTextTpG[nI,1]) )
			cResult := aTextTpG[nI,1] + " - " + aTextTpG[nI,2]
			exit
		endif				
	next
	
	//se não foi encontrado, ou seja, algum tipo não esperado, retorna o próprio código
	if (empty(cResult))
		cResult := cTipGui
	endif
else
	cResult := cTipGui + " - " + cResult	
endif

return cResult
