#Include 'Protheus.ch'
#INCLUDE 'FINA870A.CH'

//-------------------------------------------------------------------
/*{Protheus.doc} FINA870A()
Impressão da guia GPS
@author Simone Mie Sato Kakinoana
   
@version P12
@since   04/07/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function FINA870A()

Local cDataDe	:= ""
Local cDataAte	:= ""
Local cSelFil	:= ""
Local cFil		:=  " = '" + FWXFilial("CTE") + "' "
Local aSelFil	:= "" 
Local cQry 		:= ""

Local cAlias 	:= GetNextAlias()

Private oPrint 	:= Nil
Private nQtdGps	:= 0 

If GetHlpLGPD({"E2_NOMFOR","E2_CNPJRET"})
	Return .F.
Endif

//VERIFICA AS PERGUNTAS SELECIONADAS
If Pergunte("FINR870A",.T.)

	cDataDe		:= DTOS(MV_PAR01)
	cDataAte	:= DTOS(MV_PAR02)
	cSelFil		:= MV_PAR03

	If cSelFil == 1
		AdmSelecFil("FINR870A",3,.F.,@aSelFil,"SE2",.T.)

		cFil := GetRngFil( aSelFil, 'SE2', .T., @cFil)
	EndIf

	cQry :=" SELECT E2_FILIAL, E2_FILORIG, E2_FORNECE, E2_LOJA, E2_EMISSAO, E2_VALOR, E2_CNPJRET, A2_NOME, A2_END,A2_BAIRRO, A2_EST, "+ CRLF
	cQry +=" A2_MUN, A2_TEL, A2_CEP, A2_TIPO, A2_CGC, E2_TITPAI, E2_CNPJRET, E2_RETINS, E2_MULTA, E2_JUROS " 
	cQry +=" FROM " + RetSqlName("SE2") + " SE2 " + CRLF
	cQry +=" INNER JOIN " + RetSqlName("SA2") + " SA2 ON " + CRLF 
	cQry += "A2_FILIAL = '" + FWXFilial("SA2") + "' "+CRLF
	cQry +=" AND A2_COD = E2_FORNECE "+ CRLF
	cQry +=" AND A2_LOJA = E2_LOJA "+ CRLF
	cQry += "AND SA2.D_E_L_E_T_ = ''" + CRLF
	cQry +=" WHERE E2_FILIAL " + cFil + CRLF
	cQry +=" AND E2_EMISSAO BETWEEN '" + cDataDe + "'  AND '" + cDataAte + "' "+ CRLF
	cQry +=" AND E2_ORIGEM = 'FINA870'" + CRLF
	cQry +=" AND SE2.D_E_L_E_T_ = ''" + CRLF
	cQry +=" ORDER BY E2_FILIAL, E2_EMISSAO "	

	cQry := ChangeQuery( cQry )

	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQry) , cAlias , .T. , .F.)

	dbSelectArea(cAlias)
	
	If (cAlias)->(!Eof())
		oPrint 	:= TMSPrinter():New("GPS - Guia da Previdência Social") // "GPS - Guia da Previdência Social"
		oPrint	:SetPortrait()
	Else
		HELP(' ',1,"F870NOGPS",,STR0027,2,0,,,,,,{})//"Nenhuma guia foi encontrada para emissão no periodo selecionado." 
	Endif

	While (cAlias)->(!Eof()) 

		oPrint	:StartPage()
		nLin 	:= 030	

		CarImpGPS(cAlias)
	
		(cAlias)-> (dbSkip())
		
		If (cAlias)->(Eof())
			oPrint:Preview()
		Endif 
	EndDo
	
EndIf 

Return

//-------------------------------------------------------------------
/*{Protheus.doc} CarImpGPS
Impressão da guia GPS
@author Simone Mie Sato Kakinoana
   
@version P12
@since   04/07/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function CarImpGPS(cAlias)
Local nQtdvias  := 1

Private nLin	:= 0 
oPrint:StartPage()
nLin 	:= 030

For nQtdvias := 1 TO 2	
		
	ImpGuia(cAlias)
	
Next 

nQtdGPS := 0

Return()

//-------------------------------------------------------------------
/*{Protheus.doc} ImpGuia()
Impressão da guia GPS
@author Simone Mie Sato Kakinoana
   
@version P12
@since   04/07/2015
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function ImpGuia(cAlias)

Local aFone			:= {}
Local aRestSM0		:= {}

Local cStartPath 	:= GetSrvProfString("StartPath","")

Local nTam			:= 0 

Local oFont07 		:= TFont():New("Arial",07,10,,.F.,,,,.T.,.F.)
Local oFont09    	:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)  
Local oFont10    	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)
Local oFont10n   	:= TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)
Local oFont11    	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
Local oFont12n   	:= TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)

Local cRazao	:= "" 
Local cEndereco	:= ""
Local cFone		:= ""
Local cBairro	:= ""
Local cCep		:= ""
Local cMunicipio:= ""
Local cUf		:= ""
Local cCnpj		:= ""
Local cCodPag	:= "" 
Local cCompet	:= ""
Local cEmissao	:= ""

Local nValInss	:= 0 
Local nMulta   	:= 0 
Local nJuros	:= 0 
Local nOutros	:= 0 

cBmp 	:= cStartPath + "GPS.BMP" //LOGO DA RECEITA FEDERAL

SA2->(dbSetorder(3))
If SA2->(dbSeek(xFilial("SA2")+(cAlias)->E2_CNPJRET))
	cCnpj		:= (cAlias)->E2_CNPJRET
	cRazao		:= SA2->A2_NOME
	cEndereco	:= SA2->A2_END
	cBairro		:= SA2->A2_BAIRRO
	cCep		:= SA2->A2_CEP
	cMunicipio	:= SA2->A2_MUN
	cUf			:= SA2->A2_EST
	aFone		:= FisGetTel(SA2->A2_TEL)
Else
	aRestSM0	:= SM0->(GetArea())
	SM0->(dbSetOrder(1))
	If SM0->(dbSeek(cEmpant+(cAlias)->E2_FILORIG))
		cCnpj		:= SM0->M0_CGC  
		cRazao		:= SM0->M0_NOMECOM
		cEndereco	:= SM0->M0_ENDCOB
		cBairro		:= SM0->M0_BAIRCOB
		cCep		:= SM0->M0_CEPCOB
		cMunicipio	:= SM0->M0_CIDCOB
		cUf			:= SM0->M0_ESTCOB
		aFone		:= FisGetTel(SM0->M0_TEL)
	EndIf
	RestARea(aRestSM0)
EndIf

If Len(aFone) > 0 
	nTam 	:= LEN(ALLTRIM(STR(aFone[03]))) 
	cFone	:= PadR("(" + Str(aFone[02],2) +") "+ Str(aFone[03], nTam), 14)
EndIf

cCnpj		:= PadR(Transform(cCnpj,"@R ##.###.###/####-##"),18) // CGC
cCodPag	:= (cAlias)->E2_RETINS
cEmissao:= (cAlias)->E2_EMISSAO
nValInss:= (cAlias)->E2_VALOR
nMulta  := (cAlias)->E2_MULTA
nJuros	:= (cAlias)->E2_JUROS
nOutros	:= 0 

//DATA DE COMPETENCIA
cCompet	:= Subs(cEmissao,5,2)+"/"+Subs(cEmissao,1,4)

//DEFINICAO DO BOX PRINCIPAL
oPrint:Box(nLin,0030,nLin+1100,2350)

//INCLUSAO DO LOGOTIPO DO MINISTERIO DA FAZENDA
If File(cBmp)
	oPrint:SayBitmap(nLin+10,040,cBmp,200,180)
EndIf
oPrint:Say(nLin+020,240,STR0001,oFont07) //"MINISTERIO DA PREVIDENCIA E ASSISTENCIA SOCIAL-MPAS"
oPrint:Say(nLin+070,240,STR0002,oFont07) //"SECRETARIA DA RECEITA PREVIDENCIÁRIA - SRP"
oPrint:Say(nLin+120,240,STR0003,oFont07) //"INSTITUTO NACIONAL DO SEGURO SOCIAL-INSS"
oPrint:Say(nLin+170,240,STR0004,oFont12n) //"GUIA DA PREVIDENCIA SOCIAL - GPS"

oPrint:Line(nLin,1300,nLin+850,1300)
oPrint:Line(nLin,1800,nLin+850,1800)

//DEFINICAO DO QUADRO 01
oPrint:Line(nLin+270,030,nLin+270,1300) 
oPrint:Say(nLin+280,040,"1 - ",oFont10)
oPrint:Say(nLin+280,110,STR0005,oFont09) //"NOME OU RAZÃO SOCIAL / ENDEREÇO / TELEFONE"
oPrint:Say(nLin+345,110,cRazao + " / " + cFone,oFont09)               
oPrint:Say(nLin+380,110,cEndereco + " - " + cBairro,oFont09)
oPrint:Say(nLin+415,110,cCep + " - " + cMunicipio + " - " + cUf,oFont09)

oPrint:Line(nLin+540,030,nLin+540,1300)
oPrint:Say(nLin+552,040,STR0006,oFont09) //"2 - VENCIMENTO"
oPrint:Say(nLin+582,040,STR0007,oFont09) //"(USO EXCLUSIVO DO INSS)"
oPrint:Line(nLin+540,450,nLin+630,450)
oPrint:Line(nLin+630,030,nLin+630,1300)

//DEFINICAO DO QUADRO 03                                                  
oPrint:Say(nLin+020,1305,STR0008,oFont09)//"3 - CÓDIGO DE PAGAMENTO"
oPrint:Say(nLin+030,2010, cCodPag,oFont10)
//DEFINICAO DO QUADRO 04
oPrint:Line(nLin+090,1300,nLin+90,2350)
oPrint:Say(nLin+120,1305,STR0009,oFont09) //"4 - COMPETÊNCIA"

oPrint:Say(nLin+130,2010,cCompet,oFont10)

//DEFINICAO DO QUADRO 05
oPrint:Line(nLin+180,1300,nLin+180,2350)
oPrint:Say(nLin+200,1305,STR0010,oFont09) //"5 - IDENTIFICADOR"
oPrint:Say(nLin+210,2010,cCnpj,oFont10)

//DEFINICAO DO QUADRO 06
oPrint:Line(nLin+270,1300,nLin+270,2350)
oPrint:Say(nLin+290,1305,STR0011,oFont09) //"6 - VALOR DO INSS"
oPrint:Say(nLin+300,1900,Transform(nValInss,"@E 999,999,999,999.99"),oFont11)

//DEFINICAO DO QUADRO 07
oPrint:Line(nLin+360,1300,nLin+360,2350)
oPrint:Say(nLin+380,1305,"7 -",oFont09)

//DEFINICAO DO QUADRO 08
oPrint:Line(nLin+450,1300,nLin+450,2350)
oPrint:Say(nLin+470,1305,"8 - ",oFont09)

//DEFINICAO DO QUADRO 09
oPrint:Line(nLin+ 540,1300,nLin+540,2350)
oPrint:Say(nLin+552,1303,STR0012,oFont09) //"9 - VALOR DE OUTRAS"
oPrint:Say(nLin+582,1350,STR0013,oFont09) //"ENTIDADES"
oPrint:Say(nLin+582,1900,Transform(nOutros,"@E 999,999,999,999.99"),oFont11)

//DEFINICAO DO QUADRO 10
oPrint:Line(nLin+630,1300,nLin+630,2350)
oPrint:Say(nLin+650,1305,STR0014,oFont09) //"10 - ATM/MULTA E JUROS"
oPrint:Say(nLin+670,1900,Transform(nMulta+nJuros,"@E 999,999,999,999.99"),oFont11)

//DEFINICAO DO QUADRO 11
oPrint:Line(nLin+720,1300,nLin+720,2350)
oPrint:Say(nLin+760,1305,STR0015,oFont10) //"11 - TOTAL"
oPrint:Say(nLin+770,1900,Transform(nValInss+nMulta+nJuros,"@E 999,999,999,999.99"),oFont11)

//DEFINICAO DO QUADRO DE AVISO
oPrint:Say(nLin+0650,040,STR0016,oFont10n) //"ATENÇÃO:"
oPrint:Say(nLin+0650,270,STR0017,oFont07) //"É vedada a utilização de GPS para recolhimento de receita de"
oPrint:Say(nLin+0690,040,STR0018,oFont07) //"inferior ao estipulado em Resolução publicada pelo INSS. A receita que resultar valor"
oPrint:Say(nLin+0730,040,STR0019,oFont07) //"inferior deverá ser adicionada a contribuição ou importância correspondente nos meses "
oPrint:Say(nLin+0770,040,STR0020,oFont07) //"subsequentes, até que o tal seja  igual ou superior ao valor mínimo fixado."
oPrint:Say(nLin+0810,040,STR0021,oFont07) //"subsequentes, até que o tal seja  igual ou superior ao valor mínimo fixado."

//DEFINICAO DO QUADRO 12
oPrint:Line(nLin+850,030,nLin+850,2350)
oPrint:Say(nLin+870,1305,"12-",oFont10)
oPrint:Say(nLin+870,1370,STR0022,oFont10n) //"12 - AUTENTICAÇÃO BANCÁRIA "

//oPrint:Say(nLin+0870,0040,substr(cTexto1+cTexto2+cTexto3+cTexto4,1,76),oFont07)
//oPrint:Say(nLin+0910,0040,substr(cTexto1+cTexto2+cTexto3+cTexto4,77),oFont07)


nQtdGps ++

If nQtdGps == 1
	oPrint:Say(nLin+1110,040,STR0023,oFont09)	//"1a. VIA - INSS"
	//DEFINICAO DO PICOTE
	oPrint:Say(nLin+1250,000,Replicate("-",132),oFont11)
	//SEGUNDA VIA
	nLin := 1480
EndIf

//FINALIZA A PAGINA
If nQtdGps == 2
	oPrint:Say(nLin+1120,040,STR0024,oFont09) //"2a. VIA - CONTRIBUINTE"
	oPrint:EndPage()
EndIf

Return .T.