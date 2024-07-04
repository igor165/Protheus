#include "protheus.ch"
#include "agrar630a.ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#Define _BL 25
#Define __NTAM1  10
#Define __NTAM2  10
#Define __NTAM3  20
#Define __NTAM4  25

#DEFINE IMP_SPOOL 2
#define DMPAPER_A4 9

Static oFnt10C  := TFont():New("Arial",10,10,,.F., , , , .T., .F.)
Static oFnt10N  := TFont():New("Arial",10,10,,.T., , , , .T., .F.)
Static oFnt14N  := TFont():New("Arial",18,18,,.T., , , , .T., .F.)


/** {Protheus.doc} AGRAR630A
@param: 	Nil
@author: 	carlos.augusto
@since: 	02/03/2017
@Uso: 		SIGAAGR - Relatorio de Classificacao com Codigo de Barras
 */
Function AGRAR630A( )
	Local oReport			:= Nil
	Local cDirPrint			:= GetTempPath() // Dirétorio Temporário
	Local lRet 				:= .T.
	Local lAdjustToLegacy 	:= .F.
	Private cFileName 		:= "AGRAR630A"
	Private aRet            := {"",""}
	Private nLweb   		:= 10

    oReport := FWMSPrinter():New(cFileName, IMP_SPOOL, lAdjustToLegacy, cDirPrint, .T.,,,,.T.)// Ordem obrigátoria de configuração do relatório
	oReport:cPathPDF := cDirPrint  // Diretório para o arquivo PDF
	oReport:SetMargin(50,50,0,0) // Seta as margens
	oReport:lServer := .F. 
	oReport:nDevice := IMP_SPOOL // Tipo de impressão
	oReport:Setup() // Abre a tela de setup para o usuário
	 
	oReport:SetPortrait() // Seta modo retrato como padrão
	oReport:SetPaperSize(DMPAPER_A4)
	
	If oReport:nModalResult == PD_OK
		lRet := GeraRelat(oReport)
    Else 
    	oReport:Cancel()
    	lRet := .F.
    EndIf
    
    if lRet
        aRet := {cFileName+".pdf",""}
    else
        aRet := {"",""}
    endif
    
    if lRet
        oReport:EndPage()
        oReport:Print()
                
    endIf
    
    FreeObj(oReport)
        
    MS_FLUSH()
    
Return aRet


/*/{Protheus.doc} GeraRelat
//Função responsável pela geração do relatório
@author carlos.augusto
@since 18/04/2017
@version undefined
@param oReport, object, descricao
@type function
/*/
Static Function GeraRelat(oReport)
	Local lRet     		:= .T.
	Local cUN        	:= ""  
	Local cWhere     	:= ""
	Local nLinhaBar		:= 0
	Local nColBar		:= 0
	Local nQuantFard 	:= 0
	Local dPesoTotal 	:= 0
	
	Private nColAux    	:= 0
	Private nPag  		:= 1
	Private nLeft       := 40
	Private nRight     	:= 1730
	Private nCol0      	:= nLeft
	Private nTop        := 130
	Private nTopInt    	:= nTop
	Private nLinOri    	:= 46
	Private nTweb    	:= 3
	Private nLweb    	:= 10
	
	if oReport:GetOrientation() == 2 //se o usuário informou paisagem 
	    nLeft  	:= 40
	    nRight  := 2390
	    nCol0   := nLeft
	    nTop    := 130
	    nTopInt := nTop
	    nLinOri := 30
	endIf
	  
	cUN := A655GETUNB( )  
	
	If !Funname() = "AGRA630"	
	
		cWhere += "  DXJ.DXJ_FILIAL >= '" + MV_PAR01 + "'"
		cWhere += " AND DXJ.DXJ_FILIAL <= '" + MV_PAR02 + "'"
		cWhere += " AND DXJ.DXJ_PRDTOR >= '" + MV_PAR03 + "'"
		cWhere += " AND DXJ.DXJ_PRDTOR <= '" + MV_PAR05 + "'"
		cWhere += " AND DXJ.DXJ_LJPRD  >= '" + MV_PAR04 + "'"
		cWhere += " AND DXJ.DXJ_LJPRD  <= '" + MV_PAR06 + "'"
		cWhere += " AND DXJ.DXJ_SAFRA  >= '" + MV_PAR07 + "'"
		cWhere += " AND DXJ.DXJ_SAFRA  <= '" + MV_PAR08 + "'"
		
		If !Empty(cUN)
			cWhere += " AND DXJ.DXJ_CODUNB = '" + cUN + "' "
		Endif
	Else
		
		cWhere += "  DXJ.DXJ_FILIAL = '" + FWxFilial('DXJ') + "'"
		cWhere += " AND DXJ.DXJ_CODIGO = '" + DXJ->DXJ_CODIGO + "'"
		cWhere += " AND DXJ.DXJ_TIPO   = '" + DXJ->DXJ_TIPO + "'"
		
		If !Empty(cUN)
			cWhere += " AND DXJ.DXJ_CODUNB = '" + cUN + "' "
		Endif 
	Endif
		
	cWhere := "%"+cWhere+"%"
	
	BeginSql Alias "QryDXJ"
		Select DXJ.*
		FROM %Table:DXJ% DXJ
		WHERE
			DXJ.%NotDel% AND
			%exp:cWhere%
	EndSql
	
	QryDXJ->(dbGoTop())
	
	
	oReport:StartPage()
	
	While .Not. QryDXJ->(Eof())
	            
		If oReport:GetOrientation() == 1 //se é retrato
		    CabPagRet(oReport)
		Else
		    //Paisagem
		EndIf
		
		If DXK->(ColumnPos('DXK_TIPO'))
			BeginSql Alias "QryDXK"
				Select *
				FROM %Table:DXK% DXK
				WHERE DXK.%NotDel%
				  AND DXK.DXK_FILIAL = %exp:QryDXJ->DXJ_FILIAL%	
				  AND DXK.DXK_CODROM = %exp:QryDXJ->DXJ_CODIGO%
				  AND DXK.DXK_TIPO   = %exp:QryDXJ->DXJ_TIPO%	
		     EndSQL
		Else
			BeginSql Alias "QryDXK"
				Select *
				FROM %Table:DXK% DXK
				WHERE DXK.%NotDel%
				  AND DXK.DXK_FILIAL = %exp:QryDXJ->DXJ_FILIAL%	
				  AND DXK.DXK_CODROM = %exp:QryDXJ->DXJ_CODIGO%
		     EndSQL
		EndIf     
	        
		QryDXK->(dbGoTop())
		
		nTop 		+= 45
		nLinhaBar 	:= 210
		
		nTop 		+= 10
			
		While .Not. QryDXK->(Eof())
			nColBar 	:= 45
			If nQuantFard != 0 .And. Mod(nQuantFard,20) == 0 //Resto da divisao
				oReport:EndPage()
				oReport:Line(nTop/nTweb, 30, (nTop/nTweb), (nRight/nTweb) - 20)
				oReport:StartPage()
				nTop := 130
				nColAux := 0
				nLinhaBar := 205
				nPag++
				CabPagRet(oReport)
				nTop += 45
			EndIf
			
			
			nColAux := __NTAM1*3 
			
			
			If Mod(nQuantFard,2) != 0
				nColAux += 340
				nTop 	-= 185
				nColBar := 390
				nLinhaBar -= 61.5
			EndIf
			nTop 	+= 125
			nColAux += 30
			oReport:Say(nTop/nTweb,nColAux , QryDXK->DXK_ETIQ , oFnt10c)
			nTop 	-= 125
			nColAux -= 30
			
			oReport:Say(nTop/nTweb,nColAux , STR0001, oFnt10N) //#Fardo:
			nColAux += __NTAM1*3
	        oReport:Say(nTop/nTweb,nColAux , QryDXK->DXK_FARDO, oFnt10c)
	
			nColAux += __NTAM3*3 
			oReport:Say(nTop/nTweb,nColAux , STR0002, oFnt10N) //#Peso:
			nColAux += __NTAM4
	        oReport:Say(nTop/nTweb, nColAux, Transform(QryDXK->DXK_PSLIQU,"@E 9,999.99"), oFnt10c)
	        dPesoTotal += QryDXK->DXK_PSLIQU
	
			oReport:Code128C(nLinhaBar, nColBar, Alltrim(QryDXK->DXK_ETIQ), 30)
			
			nLinhaBar	+= 61.6
			nTop 		+= 185
			
			QryDXK->( dbSkip() )
			
			nQuantFard++
			
		EndDo
		
		QryDXK->( dbCloseArea() )
		
		nTop += 10
		nColAux := __NTAM1*3
		oReport:Say(nTop/nTweb,nColAux , STR0003, oFnt10N) //#Total
		
		nTop += 10
		
		nColAux := __NTAM1*3
		oReport:Line(nTop/nTweb, nColAux, (nTop/nTweb), (nRight/nTweb) - 20)
	
		nTop += 25
		nColAux := __NTAM1*3
		oReport:Say(nTop/nTweb,nColAux , STR0004, oFnt10N) //#"Total de Fardos: "
		nColAux += 65
		oReport:Say(nTop/nTweb,nColAux , cValToChar(nQuantFard), oFnt10c)
		
		nColAux += 300
		nColAux += __NTAM3*3 
		oReport:Say(nTop/nTweb,nColAux , STR0005, oFnt10N) //#"Peso Total: "
		nColAux += 45
		oReport:Say(nTop/nTweb,nColAux , Transform(dPesoTotal,"@E 999,999.99"), oFnt10c)
		
		nTop += 90
	            
		QryDXJ->( dbSkip() )
	    
	EndDo
	
	if(nQuantFard == 0)
	     Help("",1,STR0019,, STR0006,1,0) //#Mala vazia
	     lRet := .F.
	EndIf
	
	QryDXJ->( dbCloseArea() )

Return lRet

Static Function CabPagRet(oReport)
	Local cFileLogo    := ''
	Local cNmEmp
	Local cNmFilial

    //Carrega e Imprime Logotipo da Empresa
    fLogoEmp(@cFileLogo)

	if file(cFilelogo)
		nColAux += 30
		oReport:SayBitmap(nTop/nTweb, nColAux, cFileLogo, (180)/nTweb, (050)/nTweb)
		nColAux := 0
	EndIf
	
	nColAux += 30
	oReport:Line(nTop/nTweb, nColAux, (nTop/nTweb), (nRight/nTweb) - 20)
	    	
	nTop += 45
	    
	nColAux += 170
	oReport:Say(nTop/nTweb, nColAux, STR0007, oFnt14N) //#"Romaneio de Classificação"
	
	nTop -= 40
	nColAux += 320
	oReport:Say(((nTop)/nTweb)+nLweb, nColAux, STR0008 +AllTrim(Str(nPag)), oFnt10c) //#"Página: "
	    
	nColAux := 0
	nTop += 85
	
	If SM0->(Eof())
		SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
	EndIf
	
	cNmEmp	 := AllTrim( SM0->M0_NOME )
	cNmFilial:= AllTrim( SM0->M0_FILIAL )
	   
	nColAux += 30
	oReport:Say(nTop/nTweb, nColAux, "SIGA/" + cFileName + "/v." + cVersao, oFnt10N)
	oReport:Say(nTop/nTweb, (nRight/nTweb) - 105, STR0009 + Dtoc(dDataBase), oFnt10N) //#"Emissão...: "
	  
	nTop += 28
	  
	oReport:Say(nTop/nTweb, nColAux, STR0010 + cNmEmp + " / " + cNmFilial, oFnt10N) //#"Empresa...: "
	oReport:Say(nTop/nTweb, (nRight/nTweb) - 83, RptHora + Time(), oFnt10N)
	
	nTop += 20
	nColAux := 0
	
	nColAux := 30
	  	
	oReport:Line(nTop/nTweb, nColAux, (nTop/nTweb), (nRight/nTweb) - 20)  	
	  	
	nTop += 90
	nColAux := 0
	
	nColAux += 30 //Safra
	oReport:Say(nTop/nTweb, nColAux, STR0011, oFnt10N) //#"Safra: "
	nColAux += 25
	oReport:Say(nTop/nTweb, nColAux, QryDXJ->DXJ_SAFRA, oFnt10c)
	
	nColAux += 220 //Codigo + Tipo
	oReport:Say(nTop/nTweb, nColAux, STR0012, oFnt10N) //#"Código: "
	nColAux += 35
	oReport:Say(nTop/nTweb, nColAux, QryDXJ->DXJ_CODIGO + "-" + NGRETSX3BOX("DXJ_TIPO",QryDXJ->DXJ_TIPO), oFnt10c)
	
	nColAux += 160 //Data
	oReport:Say(nTop/nTweb, nColAux, STR0013 , oFnt10N) //#"Data: "
	nColAux += 25
	oReport:Say(nTop/nTweb, nColAux, CValToChar(STOD(QryDXJ->DXJ_DATA)), oFnt10c)
	
	nTop 	+= 45
	nColAux := 0
	
	nColAux += 30  //Codigo+Loja+Nome
	oReport:Say(nTop/nTweb, nColAux, STR0014, oFnt10N) //#"Entidade: "
	nColAux += 40
	oReport:Say(nTop/nTweb, nColAux, QryDXJ->DXJ_PRDTOR + "/" + QryDXJ->DXJ_LJPRO +;
	" - " + Posicione("NJ0",1,FWxFilial("NJ0")+QryDXJ->(DXJ_PRDTOR+DXJ_LJPRO),"NJ0_NOME"), oFnt10c)
	
	nColAux += 205 //Fazenda+Nome
	oReport:Say(nTop/nTweb, nColAux, STR0015, oFnt10N) //#"Fazenda: "
	nColAux += 38
	oReport:Say(nTop/nTweb, nColAux, QryDXJ->DXJ_FAZ + " - " + Posicione("NN2",2,FWxFilial("NN2")+QryDXJ->DXJ_FAZ,"NN2_NOME"), oFnt10c)
	
	nTop 	+= 45
	nColAux := 0 
	
	nColAux += 30
	oReport:Say(nTop/nTweb, nColAux, STR0016, oFnt10N) //#"Variedade: "
	nColAux += 45
	oReport:Say(nTop/nTweb, nColAux, A630BRWVAR(DXJ->DXJ_SAFRA, DXJ->DXJ_CODVAR), oFnt10c)
	
	nColAux += 200  //Fardo Inicial
	oReport:Say(nTop/nTweb, nColAux, STR0017, oFnt10N) //#"Fardo Inicial: "
	nColAux +=  54
	oReport:Say(nTop/nTweb, nColAux, QryDXJ->DXJ_FRDINI, oFnt10c)
	    
	nColAux += 55
	oReport:Say(nTop/nTweb, nColAux, STR0018, oFnt10N) //#"Fardo Final: "
	nColAux +=  48
	oReport:Say(nTop/nTweb, nColAux, QryDXJ->DXJ_FRDFIM, oFnt10c)         
	
	nTop += 25
	nColAux := 0
	
	nColAux := 30
	  	
	oReport:Line(nTop/nTweb, nColAux, (nTop/nTweb), (nRight/nTweb) - 20)

Return 

