#Include "PROTHEUS.Ch"
#Include "FINR85LI.Ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ FINR85LIR	³ Autor ³ TOTVS			    ³ Data ³ 21.01.11³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Livro de retenção de IR - Peru			   		  	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function FINR85LI()


Local oReport
PRIVATE cPerg := "F085LI"                            

oReport	:= ReportDef()
oReport:PrintDialog()

Return          
 

Static Function ReportDef()
Local oReport,oSection1,oSection2,oSection3
Local cReport		:= "FINR85LI"
Local cTitulo		:= STR0017	
Local cDesc			:= STR0001


	


oReport := TReport():New(cReport, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDesc) 
Pergunte(cPerg,.F.)	
	
oReport:SetLandscape(.T.)


// Define o tamanho da fonte a ser impressa no relatorio
oReport:nFontBody := 11 
oReport:lBold:=.T.   
                             
oSection1 := TRSection():New(oReport,STR0014,{"SFE","SA2"},,,,,,,,,,,,,,,0 ) 

TRCell():New( oSection1, "DTRETENC", , STR0007 + CRLF + STR0018 ,,17/*aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"CENTER",.T.,"CENTER",,,.F.,,,.T.)
TRCell():New( oSection1, "TIPODOC", , STR0008 + CRLF + STR0019 ,/*Picture*/,40/*aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"CENTER",.T.,"CENTER",,,.F.,,,.T.)
TRCell():New( oSection1, "NUMDOC", , STR0009 + CRLF + STR0020 ,/*Picture*/,25/*aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"CENTER",.T.,"CENTER",,,.F.,,,.T.)
TRCell():New( oSection1, "NOME", , STR0010 ,/*Picture*/,55/*aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"CENTER",.T.,"CENTER",,,.F.,,,.T.)
TRCell():New( oSection1, "VALBRUTO", , STR0011,PesqPict("SFE","FE_RETENC"),20/*aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"CENTER",.T.,"CENTER",,,.F.,,,.T.)
TRCell():New( oSection1, "RETENC", , STR0012,PesqPict("SFE","FE_RETENC"),20/*aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"CENTER",.T.,"CENTER",,,.F.,,,.T.)
TRCell():New( oSection1, "VALNETO", , STR0013 ,PesqPict("SFE","FE_RETENC"),20/*aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"CENTER",.T.,"CENTER",,,.F.,,,.T.)

oSection2 := TRSection():New( oReport,STR0015 , {"SFE"},,,,,,,,,,,,,,,0 ) //"Titulos a pagar"  
TRCell():New( oSection2, "TOTALES", , "" ,,140/*aTamDesc[1]  /*Tamanho*/,/*lPixel*/,,"RIGHT",.T.,,,,.F.,,,.T.)
TRCell():New( oSection2, "VALBRUTO", , "" ,PesqPict("SFE","FE_RETENC"),20/*aTamDesc[1]  /*Tamanho*/,/*lPixel*/,,"CENTER",.T.,,,,.F.,,,.T.)
TRCell():New( oSection2, "RETENC", , "" ,PesqPict("SFE","FE_RETENC"),20/*aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"CENTER",.F.,,,,.F.,,,.T.)
TRCell():New( oSection2, "VALNETO", , "" ,PesqPict("SFE","FE_RETENC"),20/*aTamDesc[1]  /*Tamanho*/,/*lPixel*/,/*CodeBlock*/,"CENTER",.F.,,,,.F.,,,.T.)

oSection3 := TRSection():New( oReport,STR0016 ,,,,,,,,,,,,,,,,0 ) //"Titulos a pagar"  
TRCell():New( oSection3, "COLUNA1", , "" ,,16/*aTamDesc[1]  /*Tamanho*/,/*lPixel*/,,"RIGHT",.T.,"CENTER",,,.F.,,,.T.)
TRCell():New( oSection3, "COLUNA2", , "" ,,122/*aTamDesc[1]  /*Tamanho*/,/*lPixel*/,,"CENTER",.T.,"CENTER",,,.F.,,,.T.)
TRCell():New( oSection3, "COLUNA3", , "" ,,80/*aTamDesc[1]  /*Tamanho*/,/*lPixel*/,,"CENTER",.T.,"CENTER",,,.F.,,,.T.)

oSection1:Cell("DTRETENC"):lHeaderSize:=.F.
oSection1:Cell("TIPODOC"):lHeaderSize:=.F.
oSection1:Cell("NUMDOC"):lHeaderSize:=.F.
oSection1:Cell("NOME"):lHeaderSize:=.F.
oSection1:Cell("VALBRUTO"):lHeaderSize:=.F.
oSection1:Cell("RETENC"):lHeaderSize:=.F.
oSection1:Cell("VALNETO"):lHeaderSize:=.F.

oSection2:Cell("TOTALES"):lHeaderSize:=.F.
oSection2:Cell("VALBRUTO"):lHeaderSize:=.F.
oSection2:Cell("RETENC"):lHeaderSize:=.F.
oSection2:Cell("VALNETO"):lHeaderSize:=.F.   

oSection3:Cell("COLUNA1"):lHeaderSize:=.F.
oSection3:Cell("COLUNA2"):lHeaderSize:=.F.
oSection3:Cell("COLUNA3"):lHeaderSize:=.F.






Return(oReport)

Static Function ReportPrint(oReport)
Local oSection1 := oReport:Section(1)    
Local oSection2  := oReport:Section(2)    
Local oSection3  := oReport:Section(3)  
Local nTotBruto:= 0
Local nTotRetenc:= 0
Local nTotNeto:= 0

nMesDe:= val(mv_par01)
nMesAte:= val(mv_par02)

nAnoDe:= val(mv_par03)


cDescri:="LIBRO DE RETENCIONES INCISOS E) Y F) DEL ART. 34º DE LA LEY DEL IMPUESTO A LA RENTA"
cEmpresa:= Alltrim(SM0->M0_NOME)
cRuc:= Alltrim(SM0->M0_CGC)


#IFDEF TOP   

cAlias := GetNextAlias()
cQuery 	:= "SELECT FE_EMISSAO,FE_RETENC,FE_VALBASE, (FE_VALBASE-FE_RETENC) FE_VALNETO, A2_NOME, A2_TIPDOC,A2_PFISICA FROM "+RetSqlName("SFE")+" SFE, "+RetSqlName("SA2")+" SA2"
cQuery	+= " WHERE FE_FILIAL = '"+xFilial("SFE")+"' AND " 
cQuery	+= " A2_FILIAL = '"+xFilial("SA2")+"' AND "
cQuery  += " FE_FORNECE=A2_COD "+"AND"
cQuery  += " FE_LOJA=A2_LOJA "+"AND"
cQuery  += " FE_TIPO='R' "+"AND"

If cPaisLoc $ "ARG|COS|PAR"
	cQuery  += " FE_DTESTOR = '' "+"AND" 
EndIf

cQuery += " SUBSTRING(FE_EMISSAO,5,2) >= '" + Alltrim(mv_par01) + "' AND"  
cQuery += " SUBSTRING(FE_EMISSAO,5,2) <= '" + Alltrim(mv_par02) + "' AND"  
cQuery += " SUBSTRING(FE_EMISSAO,1,4) = '" + Alltrim(mv_par03) + "' AND"  
cQuery 	+= " SFE.D_E_L_E_T_ = ' ' AND"
cQuery 	+= " SA2.D_E_L_E_T_ = ' '" 
cQuery 	+= " ORDER BY FE_EMISSAO  " 

cQuery := ChangeQuery(cQuery)                                                                              
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAlias, .F., .T.)  


DbSelectArea(cAlias)
(cAlias)->(dbGoTop())    
                

oSection1:SetBorder(2,,,.F.) 
oSection1:SetCellBorder(5,,,.F.) 
oSection1:SetCellBorder(5,,,.T.) 


oSection2:SetBorder(2,,,.F.) 
oSection2:SetCellBorder(5)


oSection1:Cell("DTRETENC"):SetBlock( { || STOD((cAlias)->(FE_EMISSAO)) } )
oSection1:Cell("TIPODOC"):SetBlock( { || nTipoDoc } )
oSection1:Cell("NUMDOC"):SetBlock( { || (cAlias)->(A2_PFISICA) } )
oSection1:Cell("NOME"):SetBlock( { || (cAlias)->(A2_NOME) } )   
oSection1:Cell("VALBRUTO"):SetBlock( { || (cAlias)->(FE_VALBASE) } )   
oSection1:Cell("VALBRUTO"):SetBlock( { || (cAlias)->(FE_VALBASE) } )   
oSection1:Cell("RETENC"):SetBlock( { || (cAlias)->(FE_RETENC) } )      
oSection1:Cell("VALNETO"):SetBlock( { || (cAlias)->(FE_VALNETO) } ) 

oSection2:Cell("TOTALES"):SetBlock( { || STR0015 } )  	
oSection2:Cell("VALBRUTO"):SetBlock( { || nTotBruto } )   
oSection2:Cell("RETENC"):SetBlock( { || nTotRetenc } )      
oSection2:Cell("VALNETO"):SetBlock( { || nTotNeto } )   

oSection3:Cell("COLUNA2"):SetBlock( { || STR0005} )  	
oSection3:Cell("COLUNA3"):SetBlock( { || STR0006 } )  	

oReport:nFontBody := 6 
oReport:lBold:=.F.     

oReport:SetLineHeight(40)  

nMesIni:= SUBSTRING(FE_EMISSAO,5,2)
aCabec:=({cDescri,"",STR0002+ " " + nMesIni +"/" + MV_PAR03,STR0003 +" " + cRuc,STR0004+" "+cEmpresa,""})
oReport:SetCustomText({|| aCabec})
	
oSection3:Init()  
oSection3:PrintLine()
oSection3:Finish() 

oSection1:Init()
nMesAtu:= MV_PAR01  



oReport:OnPageBreak( { || Impr3(oReport)})

While !(cAlias)->(eof())   


  If nMesIni != SUBSTRING(FE_EMISSAO,5,2)
	oReport:nFontBody := 6 
	oReport:lBold:=.F.   
    oSection1:Finish()
  	oSection2:Init()
  	oSection2:PrintLine()
  	oSection2:Finish()
  	
  	oReport:EndPage()
  	


	oSection1:Init()

  	nMesIni := SUBSTRING(FE_EMISSAO,5,2)
	aCabec:=({cDescri,"",STR0002+ " " + nMesIni +"/" + MV_PAR03,STR0003 +" " + cRuc,STR0004+" "+cEmpresa,""})
  	oReport:SetCustomText({|| aCabec})
	nTotBruto  := 0
	nTotRetenc := 0
	nTotNeto   := 0
  	
  Endif              
  
	SX5->(DbSeek(xFilial()+"TB"+(cAlias)->(A2_TIPDOC) ))
	nTipoDoc:=Alltrim(X5Descri())     

	nTotBruto  += (cAlias)->(FE_VALBASE)
	nTotRetenc += (cAlias)->(FE_RETENC)
	nTotNeto   += (cAlias)->(FE_VALNETO) 

	oSection1:PrintLine()
	(cAlias)->(dbSkip())
EndDo       
oSection1:Finish() 
oSection2:Init()  
oSection2:PrintLine()
oSection2:Finish() 
#ENDIF

Return                     


Static Function Impr3(oReport)
Local oSection3  := oReport:Section(3)  


oSection3:Init()
oSection3:PrintLine()
oSection3:Finish()


Return
