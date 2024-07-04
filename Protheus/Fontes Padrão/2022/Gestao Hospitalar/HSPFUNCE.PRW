#INCLUDE "PROTHEUS.CH"
#INCLUDE "HSPFUNCE.CH"
#INCLUDE "TopConn.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณhs_LogoSusบAutor  ณDarcio R. Sporl     บ Data ณ  24/09/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao criada para carregar o logotipo da empresa.          บฑฑ
ฑฑบ          ณAtualizado e renomeado de static function para function em  บฑฑ
ฑฑบ          ณ18/03/2011 (constava anteriormente somente no arquivo       บฑฑ
ฑฑบ          ณHSPRH88                                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function hs_logoSus(cLogoSUS)

Local cStartPath	:= GetSrvProfString("STARTPATH","")

// Logotipo do SUS
cLogoSUS := cStartPath + "LogoSUS.bmp"


Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณhs_formCPFบAutor  ณ                    บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao exibir o CPF formatado e com espacos                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function hs_formCpf(cCpf)

if Alltrim(cCpf)==""
	return ""
endif

return SubStr(cCpf,1,1)+" "+ SubStr(cCpf,2,1)+" "+SubStr(cCpf,3,1)+;
		" . " +;
		SubStr(cCpf,4,1)+" "+SubStr(cCpf,5,1)+" "+SubStr(cCpf,6,1)+;
		" . " +;
		SubStr(cCpf,7,1)+" "+SubStr(cCpf,8,1)+" "+SubStr(cCpf,9,1)+;
		" - " +;
		SubStr(cCpf,10,1)+" "+SubStr(cCpf,11,1)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณhs_formCnsบAutor  ณ                    บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao exibir o CNS com espacos                             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function hs_formCNS(cCns)

Local cRetorno:=""
Local nI

if Alltrim(cCNS)==""
	return ""
endif

for nI=1 to Len(cCNS)
	cRetorno+=Substr(cCns,nI,1)+" "
next nI

return cRetorno

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณhs_formTelบAutor  ณ                    บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao exibir o telefone com espa็os e formatado no padrao  บฑฑ
ฑฑบ          ณ0 X X - X X X X - X X X X                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function hs_formTel(cTel)


if Alltrim(cTel)==""
	return ""
endif

return ;
	"0 " + SubStr(cTel,1,1) + "  " + SubStr(cTel,2,1)+ "  -  " + ;
	SubStr(cTel,3,1) + "  " + SubStr(cTel,4,1) + "  " + SubStr(cTel,5,1) + "  " +;
	SubStr(cTel,6,1) + "  -  " + SubStr(cTel,7,1) + "  " + SubStr(cTel,8,1) + "  " +;
	SubStr(cTel,9,1) + "  " + SubStr(cTel,10,1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณhs_formCnpบAutor  ณ                    บ Data ณ  18/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao exibir o CNPJ com espacos e formatado no padrao      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function hs_formCnp(cCnpj)


if Alltrim(cCnpj)==""
	return ""
endif

return ;
	SubStr(cCnpj,1,1) + " " + SubStr(cCnpj,2,1) + " . " + SubStr(cCnpj,3,1) + " " +;
	SubStr(cCnpj,4,1) + " " + SubStr(cCnpj,5,1) + " . " + SubStr(cCnpj,6,1) + " " +;
	SubStr(cCnpj,7,1) + " " + SubStr(cCnpj,8,1) + " / " + SubStr(cCnpj,9,1) + " " +;
	SubStr(cCnpj,10,1) + " " + SubStr(cCnpj,11,1) + " " + SubStr(cCnpj,12,1) + " - " +;
	SubStr(cCnpj,13,1) + " " + SubStr(cCnpj,14,1)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณhs_formCepบAutor  ณ                    บ Data ณ  18/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao exibir o CEP com espacos e formatado no padrao       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function hs_formCep(cCep)


if Alltrim(cCep)==""
	return ""
endif

return ;
	SubStr(cCep,1,1) + " " + SubStr(cCep,2,1) + " " + SubStr(cCep,3,1) + " " +;
	SubStr(cCep,4,1) + " " + SubStr(cCep,5,1) + " - " + SubStr(cCep,6,1)+ " " +;
	SubStr(cCep,7,1) + " " + SubStr(cCep,8,1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณhs_boxProcบAutor  ณ                    บ Data ณ  16/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao exibir um box (|_|) para procedimento sem a borda    บฑฑ
ฑฑบ          ณsuperior e com cada celula ja preenchida                    บฑฑ
ฑฑบ          ณSIGAHSP                                                     บฑฑ
ฑฑบ          ณParametros:												  บฑฑ
ฑฑบ          ณnLinha    = linha inicial do box                            บฑฑ
ฑฑบ          ณnColunaIni= coluna inicial do box                           บฑฑ
ฑฑบ          ณoTmsPrint = objeto do tipo oTmsPrint que esta sendo utilizadบฑฑ
ฑฑบ          ณnCelulas  = qtde de celulas do box                          บฑฑ
ฑฑบ          ณnAltura   = altura do box                                   บฑฑ
ฑฑบ          ณnLargCel  = largura das celulas                             บฑฑ
ฑฑบ          ณcCodProc  = codigo do Procedimento                          บฑฑ
ฑฑบ          ณoFont     = objeto do tipo oFont que estah sendo utilizado  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function hs_boxProc(nLinha, nColunaIni,oTmsPrint,nCelulas,nAlturaBox,nLargCel,cCodProc,oFont)
/*
Parametros:
nLinha    = linha inicial do box
nColunaIni= coluna inicial do box
oTmsPrint = objeto do tipo oTmsPrint que estah sendo utilizado
nCelulas  = qtde de celulas bo box
nAltura   = altura do box
nLargCel  = largura das celulas
cCodProc  = codigo do Procedimento
oFont     = objeto do tipo oFont que estah sendo utilizado
*/


Local oPrintLoc:=oTmsPrint
Local oFontLoc:=oFont
Local oBrush1 := TBrush():New( , CLR_WHITE )
Local i

for i=1 to nCelulas
	//Desenha o Box
	oPrintLoc:Box(nLinha,nColunaIni,nLinha+nAlturaBox,nColunaIni+nLargCel,,,,2)
	//Insere o digito do procedimento
	oPrintLoc:Say(nLinha+15,nColunaIni+(int(nLargCel/3)), substr(cCodProc,i,1), oFontLoc)
	//Apaga a borda superior
	oPrintLoc:fillRect( { nlinha-5, nColunaIni, nlinha+5, nColunaIni+NLargCel }, oBrush1 )
	nColunaIni+=nLargCel
next i
//Destroi os TBrush
oBrush1:End()

return (nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณhs_getMes บAutor  ณ                    บ Data ณ  17/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao exibir o mes atual (mes do database) por extenso     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
function hs_getMes()
Local nMes   := Month(dDataBase)
Local aMeses := {	{1,STR0001}, {2,STR0002}, {3,STR0003}, {4,STR0004}, {5,STR0005},;
						{6,STR0006}, {7,STR0007}, {8,STR0008}, {9,STR0009}, {10,STR0010},;
						{11,STR0011}, {12,STR0012}}
Local nI:=1

For nI = 1 to len(aMeses)
	if nMes == aMeses[nI,1]
		return aMeses[nI,2]
	EndIf
Next nI

return aMeses[1,1]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณhs_qtProAgบAutor  ณ Saude              บ Data ณ  27/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que verifica a quantidade de procedimentos agendados บฑฑ
ฑฑบ          ณpara uma determinada solicitacao de APAC                    บฑฑ
ฑฑบ          ณParametros:                                                 บฑฑ
ฑฑบ          ณcCodSolici = Codigo da Solicitacao  - GK7_SOLICI            บฑฑ
ฑฑบ          ณcCodProc   = Codigo do Procedimento - GK7_CODPRO            บฑฑ
ฑฑบ          ณcTipSol    = Tipo de solicitacao - "A" APAC / "S" Sessao    บฑฑ
ฑฑบ          ณ(Convenio)                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ GH                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
function hs_qtProAg(cCodSolici, cCodProc, cTipSol)
Local cArea     := getArea()
Local cSql      := ""
Local nQtdeAge  := 0
Default cTipSol := "A"


//Verificando quantos procedimentos ja foram agendados para a mesma solicitacao de APAC
cSql := " SELECT COUNT (*) AS QTDE "
cSql += " FROM "+RetSqlName("GM8") "
cSql += " WHERE GM8_FILIAL = '"+xFilial("GM8")+"' AND D_E_L_E_T_ <> '*'  "
if cTipSol == "A" //Solicitacao de APAC (HSPAHM12)
	cSql += " AND GM8_SOLICI= '"+ cCodSolici+"' "
elseif cTipSol == "S" //Solicitacao de Sessoes (HSPAHM13)
	cSql += " AND GM8_SOLGKB= '"+ cCodSolici+"' "
endif
cSql += " AND GM8_CODPRO = '"+cCodProc+"'"
TCQuery cSql New Alias "TMPGM8"
DbSelectArea("TMPGM8")
nQtdeAge := TMPGM8->QTDE
DbCloseArea()

restArea(cArea)
return nQtdeAge

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณhs_formCepบAutor  ณ                    บ Data ณ  18/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao exibir o enderecoCEP com espacos e formatado no padrao       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
function hs_formEnd(cEnd,cNum,cCompl,cBairro)

Local cEndereco:=""
if !(empty(cEnd))
	cEndereco+=Alltrim(cEnd)
endif
if !(empty(cNum))
	cEndereco+=", "+Alltrim(cNum)
endif
if !(empty(cCompl))
	cEndereco+=", "+Alltrim(cCompl)
endif
if !(empty(cBairro))
	cEndereco+=", "+Alltrim(cBairro)
endif

return cEndereco

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GATEAGEบAutor  ณ                    บ Data ณ  19/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera atendimento automatico a partir de um agendamento      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_GATEAGE(cRegGer, cCodCrm, cCodCon, cCodPla, cTipAte , cCodLoc, cMatric, dDatAte, cCodTpg, cCodAge, lAtuGm8, lGrvProAgd)
Local aArea 	:= GetArea()
Local cRegAte	:= ""
Local cSeqDes	:= ""
Local aRValDes	:= {}
Local aProced	:= {}
Local lExDicOrc	:= .T.		//Hs_ExisDic({{"C","GD7_NUMORC"}},.F.)
Local nContPro	:= 0
Local cGcyCdPrev := "1"

Default cTipAte 	:= "1" //Ambulatorio
Default dDatAte		:= dDataBase
Default lAtuGm8		:= .F.
Default lGrvProAgd		:= .F.
Default cCodAge		:= "0"


DbSelectArea("GBH")
DbSetOrder(1)
DbSeek(xFilial("GBH") + cRegGer)

DbSelectArea("GA9")
DbSetOrder(1)
DbSeek(xFilial("GA9") + cCodCon)

Default cCodTpg		:= GA9->GA9_CDGPLA


dbSelectArea("SX3")
dbSetOrder(2)
if dbSeek("GCY_CDPREV")
	if !empty(X3_RELACAO)
		cGcyCdPrev := Posicione("SX3", 2, "GCY_CDPREV", X3_RELACAO)
	endif
endif

GCY->(RecLock("GCY", .T.))
	GCY->GCY_FILIAL	:= xFilial("GCY")
	GCY->GCY_REGATE :=  getSx8Num("GCY","GCY_REGATE")//HS_VSxeNum("GCY", "GCY->GCY_REGATE", 1)
	GCY->GCY_DTNASC := GBH->GBH_DTNASC
	GCY->GCY_DATATE := dDatAte
	GCY->GCY_IDADE 	:= HS_A58AGE(GBH->GBH_DTNASC, GCY->GCY_DATATE)
	GCY->GCY_SEXO   := GBH->GBH_SEXO
	GCY->GCY_REGGER := cRegGer
	GCY->GCY_NOME   := GBH->GBH_NOME
	GCY->GCY_CODCRM	:= cCodCrm
	GCY->GCY_CODCLI	:= GA9->GA9_CLIPAD
	GCY->GCY_ORIPAC	:= GA9->GA9_ORIPAD
	GCY->GCY_CARATE	:= GA9->GA9_CARPAD
	GCY->GCY_REGIME	:= "1"
	GCY->GCY_ATENDI	:= cTipAte
	GCY->GCY_HORATE	:= TIME()
	GCY->GCY_CODLOC :=	cCodLoc
	GCY->GCY_ATENDE := cUserName
	GCY->GCY_LOCATE	:=	cCodLoc
	GCY->GCY_STATUS := "0"
	GCY->GCY_MATRIC	:= cMatric
	GCY->GCY_ACITRA	:= "0"
	GCY->GCY_CDPREV	:= cGcyCdPrev
	GCY->(ConfirmSX8())
GCY->(MsUnlock())  

cRegAte :=GCY->GCY_REGATE
GCZ->(RecLock("GCZ", .T.))
	GCZ->GCZ_FILIAL	:= xFilial("GCZ")
	GCZ->GCZ_REGATE := cRegAte
	GCZ->GCZ_DATATE := dDatAte
	GCZ->GCZ_REGGER := GCY->GCY_REGGER
	GCZ->GCZ_NOME   := GCY->GCY_NOME
	GCZ->GCZ_CODTPG := cCodTpg
	GCZ->GCZ_CODCON := cCodCon
	GCZ->GCZ_CODPLA := cCodPla
	GCZ->GCZ_FILFAT := xFilial("GCZ")
	GCZ->GCZ_FILATE := xFilial("GCZ")
	GCZ->GCZ_STATUS := "0"
	GCZ->GCZ_NRSEQG := cNrSeqG := getSx8Num("GCZ","GCZ_NRSEQG")//HS_VSxeNum("GCZ", "GCZ->GCZ_NRSEQG", 1)
	GCZ->GCZ_LOGARQ := HS_LOGARQ()
	GCZ->GCZ_ATENDI := cTipAte
	GCZ->GCZ_LOCATE := cCodLoc
	GCZ->GCZ_DCPARI := dDatAte
	GCZ->GCZ_DCPARF := dDatAte
	GCZ->(ConfirmSX8())	
GCZ->(MsUnlock())

DbSelectArea("GCY") //retirado pois nใo estava localizando o atendimento apos a grava็ใo
DbSetOrder(1)
GCY->(DbSeek(xFilial("GCY") + cRegAte))

If lAtuGm8
	DbSelectArea("GM8")
	DbSetOrder(1)
	If DbSeek(xFilial("GM8") + cCodAge)
		aProced := Hs_RtPrAgd(cCodAge, GM8->GM8_CODPRO, GM8->GM8_NUMORC, GM8->GM8_ITEORC)
		For nContPro := 1 to len(aProced)
			cSeqDes := GetSxENum("GD7","GD7_SEQDES",,1)
			ConfirmSx8()
			cProcAtu := IIf(ValType(aProced[nContPro]) == "A",aProced[nContPro][1],aProced[nContPro])
			aRValDes := HS_RValPr(cProcAtu, HS_INIPADR("GD4",1, GCY->GCY_REGGER, "GD4_CODPLA",,.T.), GM8->GM8_CODLOC,;
			Time(), "2", GM8->GM8_CODCRM, "", {GCY->GCY_ATENDI, GCY->GCY_ATORIG, GCY->GCY_IDADE, GCY->GCY_SEXO, GCY->GCY_CARATE},;
			.T., GM8->GM8_DATAGE)

			If aRValDes[1] <> 0
				Loop
			EndIf

			DbSelectArea("GD7")
			RecLock("GD7", .T.)
			GD7->GD7_FILIAL := xFilial("GD7")
			GD7->GD7_SEQDES := cSeqDes
			GD7->GD7_NRSEQG := cNrSeqG
			GD7->GD7_REGATE := GCY->GCY_REGATE
			GD7->GD7_CODLOC := GM8->GM8_CODLOC
			GD7->GD7_CODDES := cProcAtu

			GD7->GD7_HORDES := HS_DATPAT(.F.)
			GD7->GD7_DATDES := GM8->GM8_DATAGE//HS_DATPAT(.T.)

			GD7->GD7_CODCRM := GM8->GM8_CODCRM

			GD7->GD7_SLAUDO :=  "0"
			If HS_IsLaudo(GM8->GM8_CODLOC, cProcAtu)[1]
				GD7->GD7_SLAUDO :=  "1"
				GD7->GD7_CRMLAU := GM8->GM8_CODCRM
			EndIf

			GD7->GD7_QTDDES := 1
			GD7->GD7_LOGARQ := HS_LOGARQ()

			If lExDicOrc  .AND. ValType(aProced[nContPro]) == "A"
				GD7->GD7_NUMORC := aProced[nContPro,2]
				GD7->GD7_ITEORC := aProced[nContPro,3]
			EndIf

			GD7->GD7_CODPRE := aRValDes[14]
			GD7->GD7_COEFAM := aRValDes[2][1][2]
			GD7->GD7_COEDES := aRValDes[16][02]
			GD7->GD7_CODESP := aRValDes[07]

			GD7->GD7_URGDES := aRValDes[2][14]
			//GD7->GD7_URGDES := IIF(GBY->GBY_URGDES $ "0/1",GBY->GBY_URGDES,aRValDes[2][14])
			GD7->GD7_COECHP := aRValDes[2][10]
			GD7->GD7_QTDCHP := aRValDes[2][11]
			GD7->GD7_VLRCOS := aRValDes[2][24]
			GD7->GD7_PGTMED := aRValDes[9][1]
			GD7->GD7_COECHM := aRValDes[9][aRValDes[11]]
			GD7->GD7_REPAMB := aRValDes[9][aRValDes[10]]

			GD7->GD7_VALDES := aRValDes[02][01][01]
			GD7->GD7_PCUDES := aRValDes[03]
			GD7->GD7_GLODES := IIf(aRValDes[04][01], "2", "0")
			GD7->GD7_CODPRT := aRValDes[02][15]
			GD7->GD7_DESPRT := aRValDes[02][18]
			GD7->GD7_DOPLER := "0"

			GD7->GD7_ORIDES := "0"

			GD7->GD7_FATPAR := aRValDes[04][02]

				GD7->GD7_VALREB := GD7->GD7_QTDDES * aRValDes[9][14]
				GD7->GD7_VALREP := GD7->GD7_QTDDES * aRValDes[9][14]
				GD7->GD7_VLREPF := GD7->GD7_QTDDES * aRValDes[9][17]

			GD7->GD7_VCUSOP := aRValDes[02][02]
			GD7->GD7_VFILME := aRValDes[02][03]
			GD7->GD7_VLRCOS := aRValDes[2][24]
			GD7->GD7_CODPRE := aRValDes[14]

				GD7->GD7_TABELA := aRValDes[02][20]

			MsUnLock()

		Next
		DbSelectArea("GM8")
		DbGoTop()
		DbSetOrder(1)
		DbSeek(xFilial("GM8") + cCodAge)
		While !Eof() .AND. (GM8->GM8_CODAGE == cCodAge .OR. GM8->GM8_AGDPRC == cCodAge)
			RecLock("GM8", .F.)
				GM8->GM8_REGATE := cRegAte
				GM8->GM8_STATUS := '3' //Atendido
				GM8->GM8_REGGER := cRegGer
			MsUnlock()
			DbSkip()
		EndDo
	EndIf
EndIf

RestArea(aArea)
Return(cRegAte)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_SOMAHORบ Autor ณDaniel Peixoto      บ Data ณ  07/21/05   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Soma duas horas no formato 99:99                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_SUBAHOR(cHora1, cHora2)

 Local cRet  	:= ""
 Local nHora1 := Val(StrTran(cHora1, ":", "."))
 Local nHora2 := Val(StrTran(cHora2, ":", "."))
 Local nHoras := 0
 Local cHoras :=""
 Local cMin	  :=""

 nHoras	:= subhoras(nHora1, nHora2)
 cHoras	:= StrZero(int(nHoras), 2)
 cMin	  := PADR(STUFF(ALLTRIM(STR(nHoras-int(nHoras))), 1, 2, ""), 2, "0")
 cRet	  := cHoras + ":" + cMin

Return(cRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VLDPFINบ Autor ณSaude               บ Data ณ  22/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica pendencias no financeiro                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_VLDPFIN(cCodCli, cLoja, dDataVld)
Local aArea		  := GetArea()
Local cSql 		  := ""
Local nQtdTit  := 0
Local dUltVcto := CToD(" ")
Local cNotIn	:= "'NCC','NCE','NCF','NCI','NCP','RA'"

If ExistBlock("HSPNTIN")
	cNotIn := ExecBlock("HSPNTIN",.F.,.F.,{cNotIn})
EndIf

Default dDataVld := dDataBase

cSql := "SELECT MAX(SE1.E1_VENCREA) ULTVENCTO, COUNT(*) TITULOS FROM " + RetSqlName("SE1") + " SE1 "
cSql += "WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "' AND SE1.E1_CLIENTE = '" + cCodCli + "' AND "
cSql += "SE1.E1_LOJA = '" + cLoja + "' AND SE1.E1_VENCREA < '" + DToS(dDataVld) + "' AND "
cSql += "SE1.E1_SALDO > 0 AND SE1.E1_TIPO NOT IN (" + cNotIn + ") AND SE1.D_E_L_E_T_ <> '*' "
//E1_Tipo = tipos de credito ao cliente/fornecedor/etc - Tabela 05 (TIPOS DE TITULOS)

cSql := ChangeQuery(cSql)
TCQuery cSql New Alias "GBHTMP"

nQtdTit  := GBHTMP->TITULOS
dUltVcto := GBHTMP->ULTVENCTO

DbSelectArea("GBHTMP")
DbCloseArea()

RestArea(aArea)
Return({nQtdTit, dUltVcto})

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_VLDPFINบ Autor ณSaude               บ Data ณ  22/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Chama Tela Para Digita็ใo de Senha do Superior             บฑฑ
ฑฑบRetorna Confirma็ใo de Digita็ใo e Nome do Superior imediato			  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function HS_RetSup()
Local  lRetSup	:=.F.
Local  cNomeSup	:=""
Local  cIdSup 	:=""

lRetSup:=FWAuthSuper() // Tela de Digita็ใo
cIdSup:=PswId () // Id do Superior
cNomeSup:=FWGetUserName(cIdSup)// Nome do Superior caso Aprovado

Return({lRetSup,cNomeSup})


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_Justifบ Autor ณSaude               บ Data ณ  06/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Chama Tela Para Digita็ใo de justificativa                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_Justif()
Local cCoJust := Space(TamSx3("GT7_CODMTV")[1])
Local oCodJus,oSol
Local cComent :=Space(TamSx3("GT7_DESMTV")[1])
Local oDlgJust

aSize := MsAdvSize(.T.)
aObjects := {}
AAdd( aObjects, { 100, 100, .T., .T. } )

aInfo  := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 0, 0 }
aPObjs := MsObjSize( aInfo, aObjects, .T. )


DEFINE MSDIALOG oDlgJust TITLE STR0020 From 120, 000 To 244 , 550 Of oMainWnd Pixel   //"Justificativa"


	@ 010, 010 Say STR0026 Of oDlgJust Pixel COLOR CLR_BLUE // "Cod. Justificativa"
	@ 010, 070 MSGet oCodjus Var cCoJust F3 "GT7   " Valid  Hs_vldJust(cCoJust) Picture "@!" Size 50, 010 Of oDlgJust Pixel Color CLR_BLACK

	@ 030, 010 Say STR0025  Of oDlgJust Pixel COLOR CLR_BLUE    // "Descri็ใo "
	@ 030, 070 MsGet oSol VAR cComent:=HS_IniPadr("GT7", 1, cCoJust, "GT7_DESMTV",, .F.) WHEN .F. Size 140, 009 OF oDlgJust Pixel COLOR CLR_BLACK

oBtnOk := tButton():New(@ 45, 115, STR0024, oDlgJust, {|| oDlgJust:End()}, 050, 012,,,, .T.)    //"Confirma"


ACTIVATE MSDIALOG oDlgJust CENTERED

Return(cCoJust)



Function HS_VERCRIT(aProcs, aEsp, aPac, dDataAge, cRegGer)
Local aArea		     := GetArea()
Local aRetCri          := {}
Local cSql 			 := ""
Local nI			     := 0
Local nCountTb         := 0
Local nQtd			     := 0
Local nDias			 := 0
Local dDatAux	         := ""
Local dDatIni,dDatFim := "" //Data Inicial e final para agendamento
local lCritDRF         := .T.		//Hs_ExisDic({{"C","GTL_CODDEN"}},.F.) .and. Hs_ExisDic({{"C","GTL_DESDEN"}},.F.) .and. ;
									//Hs_ExisDic({{"C","GTL_CODFAC"}},.F.) .and. Hs_ExisDic({{"C","GTL_DESFAC"}},.F.)
local cCodDen          := ""
local cCodFac          := ""
local cSqlDrf          := ""

Default dDataAge := dDataBase

For nI := 1 To Len(aProcs)
	dDatAux	:= dDataAge
	dDatIni := dDatAux
	dDatFim := dDatAux

	if lCritDRF
		cCodDen := aProcs[nI,6]
		cCodFac := aProcs[nI,7]
	endif

	If aProcs[nI,3] == "1"
		nQtd := aProcs[nI,5]
		nDias := 6
	ElseIf aProcs[nI, 3] == "2"
		nQtd := aProcs[nI,5]
		nDias := 29
	Else
		nQtd := 0
		nDias := aProcs[nI,4] - 1
	EndIf

	While nDias > 0
		dDatIni --
	    dDatFim ++
    	nDias --
    End
	cCondicao := " GM8_CODPRO = '" + aProcs[nI,1] + "'  AND GM8_REGGER = '" + cRegGer + "' AND GM8_STATUS IN('1', '3', '4', '5', '6') AND GM8.D_E_L_E_T_ <> '*' "
	If aProcs[nI,3] == "3"
		cCondicao += " AND GM8_DATAGE BETWEEN '" + DTOS(dDatIni) + "' AND '" + DTOS(dDatFim) + "'"
	Else
		cCondicao += " AND GM8_DATAGE BETWEEN '" + DTOS(dDatIni) + "' AND '" + DTOS(dDatFim) + "'"
	EndIf

	//Se nao ha cadastro de criticas de procedimentos por dente/regiao/face OU se ha o cadastro, mas dente e face estao vazios,
	//valida somente o procedimento
	if !lCritDRF .or. (lCritDRF .and. (empty(cCodDen) .and. empty(cCodFac)))
		nCountTb := HS_CountTB("GM8", cCondicao )

		If nCountTb >= nQtd .and. nCountTb > 0
			AADD(aRetCri, {aProcs[nI,1], STR0030 + Posicione("GA7",1,xFilial("GA7")+aProcs[nI,1] ,"GA7_DESC") , aProcs[nI,2] , Posicione("GTK",1,xFilial("GTK")+aProcs[nI,2] ,"GTK_DESCR")  })//"Critica x Procedimento: "
		EndIf
	else
			cSqlDrf := "SELECT GM8.GM8_NUMORC, GM8.GM8_ITEORC FROM " + retSqlName("GM8") + " GM8 WHERE " + cCondicao

			cSqlDrf := ChangeQuery(cSqlDrf)
			TCQuery cSqlDrf New Alias "TMPDRF"

			DbSelectArea("TMPDRF")
			If !TMPDRF->(Eof())
				dbGoTop()
				while !TMPDRF->(Eof())
					DbSelectArea("GTJ")
					dbSetOrder(1)
					if Dbseek(xFilial("GTJ") + TMPDRF->GM8_NUMORC + TMPDRF->GM8_ITEORC)
						//Se dente E face estao preenchidos
						if  !empty(cCodDen) .and. !empty(cCodFac)
							if (GTJ->GTJ_DENREG == cCodDenPln .and. GTJ->GTJ_DENREG == cCodDen) .and. ((GTJ->GTJ_FADENT == cCodFacPln .and. GTJ->GTJ_FADENT == cCodFac))
							   AADD(aRetCri, {aProcs[nI,1], "Crํtica x Procedimento x Dente/Regiใo/Face: " + Posicione("GA7",1,xFilial("GA7")+aProcs[nI,1] ,"GA7_DESC") , aProcs[nI,2] , alltrim(Posicione("GTK",1,xFilial("GTK")+aProcs[nI,2] ,"GTK_DESCR")) + " - Dente/Regiใo: " + cCodDen + " / Face: " + cCodFac   })//"Critica x Procedimento: "
							endif
 						endif
					endif
					DbSelectArea("TMPDRF")
					TMPDRF->(DbSkip())
				end
			EndIf
			DbSelectArea("TMPDRF")
			DbCloseArea()

	endif
Next nI


For nI := 1 To Len(aEsp)
	If Select("TMPVLD") > 0
		TMPVLD->(DbCloseArea())
	EndIf
	dDatAux	:= dDataAge
	dDatIni := dDatAux
	dDatFim := dDatAux
	If aEsp[nI,3] == "1"
		nQtd := aEsp[nI,5]
		nDias := 6
	ElseIf aEsp[nI,3] == "2"
		nQtd := aEsp[nI,5]
		nDias := 29
	Else
		nQtd := 0
		nDias := aEsp[nI,4] - 1
	EndIf

    While nDias > 0
		dDatIni --
	    dDatFim ++
    	nDias --
    End

    cSql := " SELECT COUNT(*) QTD FROM " + RetSqlName("GM8") + " GM8 "
    cSql += " JOIN " + RetSqlName("GA7") + " GA7 ON GM8_CODPRO = GA7_CODPRO "
    cSql += " AND GA7.D_E_L_E_T_ <> '*' AND GA7_FILIAL = '" + xFilial("GA7") + "'"
    cSql += " JOIN " + RetSqlName("GFR") + " GFR ON GFR_CDESPE = GA7_CODESP AND GFR_CDESPE = '" + aEsp[nI,1] + "'"
	cSql += " AND GFR.D_E_L_E_T_ <> '*' AND GFR_FILIAL = '" + xFilial("GFR") + "'"


	cCondicao := " WHERE GM8_REGGER = '" + cRegGer + "' AND GM8_STATUS IN('1', '3', '4', '5', '6') AND GM8.D_E_L_E_T_ <> '*' "
	If aEsp[nI,3] == "3"
		cCondicao += " AND GM8_DATAGE BETWEEN '" + DTOS(dDatIni) + "' AND '" + DTOS(dDatFim) + "'"
	Else
		cCondicao += " AND GM8_DATAGE BETWEEN '" + DTOS(dDatIni) + "' AND '" + DTOS(dDatFim) + "'"
	EndIf
	cSql := cSql + cCondicao

	cSql := ChangeQuery(cSql)
	TCQuery cSql New Alias "TMPVLD"

	DbSelectArea("TMPVLD")
	If !TMPVLD->(Eof())
		If TMPVLD->QTD >= nQtd .and. TMPVLD->QTD > 0
			AADD(aRetCri, {aEsp[nI,1], STR0029 + Posicione("GFR",1,xFilial("GFR")+aEsp[nI,1] ,"GFR_DSESPE") , aEsp[nI,2] , Posicione("GTK",1,xFilial("GTK")+aEsp[nI,2] ,"GTK_DESCR")  })//"Critica x Especialidade: "
		EndIf
	EndIf
Next nI


For nI := 1 To Len(aPac)
	dDatAux	:= dDataAge //Data selecionada para agendamento
	dDatIni := dDatAux
	dDatFim := dDatAux
	If aPac[nI,3] == "1"
		nQtd := aPac[nI,5]
		nDias := 6
	ElseIf aPac[nI, 3] == "2"
		nQtd := aPac[nI,5]
		nDias := 29
	Else
		nQtd := 0
		nDias := aPac[nI,4] - 1
	EndIf

    While nDias > 0
		dDatIni --
	    dDatFim ++
    	nDias --
    End


	cCondicao := " GM8_REGGER = '" + cRegGer + "' AND GM8_STATUS IN('1', '3', '4', '5', '6') AND GM8.D_E_L_E_T_ <> '*' "
	If aPac[nI,3] == "3"
		cCondicao += " AND GM8_DATAGE BETWEEN '" + DTOS(dDatIni) + "' AND '" + DTOS(dDatFim) + "'"
	Else
		cCondicao += " AND GM8_DATAGE BETWEEN '" + DTOS(dDatIni) + "' AND '" + DTOS(dDatFim) + "'"
	EndIf
	nCountTb := HS_CountTB("GM8", cCondicao )
	If nCountTb >= nQtd .and. nCountTb > 0
		AADD(aRetCri, {aPac[nI,1], STR0023 + Posicione("GBH",1,xFilial("GBH") + M->GM8_REGGER ,"GBH_NOME") , aPac[nI,2] , Posicione("GTK",1,xFilial("GTK")+aPac[nI,2] ,"GTK_DESCR")  }) //"Critica x Paciente: "
	EndIf
Next nI
//0=liberado;1=Ocupado;2=Bloqueado;3=Atendido;4=Ocupado/Bloqueado;5=Confirmado;6=Retorno
//HS_CountTB("GAI", "GAI_REGATE = '" + GCY->GCY_REGATE + "' AND GAI_FLGATE IN ('0', '1')") > 0
// 1 = semananal 2 = mensal 3 = intervalo	   [1] procedimento   [2] cod critica   [3]
//C๓d. Proced.","C๓d. Crํtica","C๓d. Controle","Qtd Dias","Qtd. Mแx"

RestArea(aArea)
Return(aRetCri)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_RCRIESPบ Autor ณSaude               บ Data ณ  06/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna criticas da Especialidade		                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function HS_RCRIESP(cCodProc, cCodEsp)
Local aArea := GetArea()
Local aRetCri 		:= {} //GTK
Local aCriGTK		:= {}

Default cCodProc := ""
Default cCodEsp  := ""

If Empty(cCodEsp)
	DbSelectArea("GA7")
	DbSetOrder(1)
	If Dbseek(xFilial("GA7") + cCodProc)
		cCodEsp := GA7->GA7_CODESP
	Else
		Return(aRetCri)
	EndIf
EndIf
DbSelectArea("GTM")
DbSetOrder(1)
//If DbSeek(xFilial("GTM") + PADR(cCodEsp, 3))
If DbSeek( xFilial("GTM") + cCodEsp )
	//While !GTM->(Eof()) .AND. GTM->GTM_CODESP == PADR(cCodEsp, 3)
	While !GTM->(Eof()) .AND. GTM->GTM_CODESP == cCodEsp
		aCriGTK := FS_RETGTK(GTM->GTM_CODCRI)
		If Len(aCriGTK ) > 0
			//AADD(aRetCri, {PADR(cCodEsp, 3), GTM->GTM_CODCRI, aCriGTK[1], aCriGTK[2], aCriGTK[3]})
			AADD(aRetCri, {cCodEsp, GTM->GTM_CODCRI, aCriGTK[1], aCriGTK[2], aCriGTK[3]})
		EndIf
		GTM->(DbSkip())
	End
EndIf
RestArea(aArea)
Return(aRetCri)







Static Function FS_RETGTK(cCodCri)
Local aArea 	:= GetArea()

DbSelectArea("GTK")
DbSetOrder(1)
If !DbSeek(xFilial("GTK") + cCodCri)
	Return{}
EndIf
RestArea(aArea)
Return({GTK->GTK_CTRL,GTK->GTK_DIAS, GTK->GTK_QTDMAX })


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_RCRIPACบ Autor ณSaude               บ Data ณ  19/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna criticas do Paciente      		                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

function HS_RCRIPAC(cCodPac, cCodProc)
local aArea    := getArea()
local aCrit    := {}
local cCodCri

//Verifica se o paciente possui critica cadastrada
DbSelectArea("GTN")
DbSetOrder(1)
if DbSeek(xFilial("GTN") + cCodPac )
	While GTN->GTN_CODPAC == cCodPac
		cCodCri := GTN->GTN_CODCRI
		DbSelectArea("GTK")
		DbSetOrder(1)
		if DbSeek(xFilial("GTK") + cCodCri )
			aAdd(aCrit,{cCodProc,GTK->GTK_CODIGO,GTK->GTK_CTRL,GTK->GTK_DIAS, GTK->GTK_QTDMAX})
		endif
		GTN->(dbSkip())
	end
endif

restArea(aArea)
return aCrit

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_RCRIPROบ Autor ณSaude               บ Data ณ  09/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Retorna criticas do Procedimento  		                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ*/

function HS_RCRIPRO(cCodProced)
local aArea    := getArea()
local aCrit    := {}
local cCodProc := allTrim(cCodProced)
local cCodCri
local cCritica
local nDias
local nQtdMax
local lCritDRF := .T.			//Hs_ExisDic({{"C","GTL_CODDEN"}},.F.) .and. Hs_ExisDic({{"C","GTL_DESDEN"}},.F.) .and. ;
								//Hs_ExisDic({{"C","GTL_CODFAC"}},.F.) .and. Hs_ExisDic({{"C","GTL_DESFAC"}},.F.)
local cCodDen := ""
local cCodFac := ""


DbSelectArea("GTL")
DbSetOrder(1)
if DbSeek(xFilial("GTL") + cCodProc )
	While  Alltrim(GTL->GTL_CODPRO) == Alltrim(cCodProc)
		cCodCri := GTL->GTL_CODCRI

		if lCritDRF
			cCodDen := GTL->GTL_CODDEN
			cCodFac := GTL->GTL_CODFAC
		endif

		//Localiza a critica
		dbSelectArea("GTK")
		dbSetOrder(1)
		if dbSeek(xFilial("GTK") + cCodCri)
			cCritica := GTK->GTK_DESCR
			nDias    := GTK->GTK_DIAS
			nQtdMax  := GTK->GTK_QTDMAX

			aAdd(aCrit,{cCodProc,GTK->GTK_CODIGO,GTK->GTK_CTRL,nDias, nQtdMax, cCodDen, cCodFac})

		endif
		dbSelectArea("GTL")
		GTL->(DbSkip())
	end
endif

restArea(aArea)
return aCrit


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณhs_vldJust       ณAutorณSaude                 ณDataณ09/05/11ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Verifica o preenchimento correto do campo cod justificativaณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ fs_vldJust(cCodJust)                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ logico                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ HSPAHM54                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function Hs_vldJust(cCodJust)

local aArea := getArea()
local lRet := .T.

dbSelectArea("GT7")
dbSetOrder(1)
if !(dbSeek(xFilial("GT7")+cCodJust))
	HS_MsgInf(STR0020 + " (" + cCodJust + ") " + STR0021,STR0014,STR0022) //"Justificativa" ### "nใo encontrada!" ### "Aten็ใo" ### "Autoriza็ใo de agendamento"
	lRet := .F.
endif

restArea(aArea)
return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณhs_gDPacRe       ณAutorณSaude                 ณDataณ10/05/11ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Retorna os dados do paciente ou de seu responsavel a partirณฑฑ
ฑฑณ          ณ do codigo do paciente                                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ hs_getDRes(cCodPac, aCampo, lRetDados, cRetAlt, lRetPac)   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณArgumentosณ cCodPac - GBH->GBH_CODPAC - Cod. Paciente                  ณฑฑ
ฑฑณ          ณ aCampo  - array com os nomes do campo que deve ser         ณฑฑ
ฑฑณ          ณ           aCampo[1] GBH (Paciente) aCampo[2] GFD (Respons.)ณฑฑ
ฑฑณ          ณ lRetResp- Indica se, qdo houver responsavel, retornara     ณฑฑ
ฑฑณ          ณ           os dados do responsavel                          ณฑฑ
ฑฑณ          ณ cRetAlt - Caso nao queira exibir os dados do responsavel,  ณฑฑ
ฑฑณ          ณ           retorna o conteudo definido neste parametro      ณฑฑ
ฑฑณ          ณ           se estiver vazio, retorna ""                     ณฑฑ
ฑฑณ          ณ lRetPac - Indica se devera retornar os dados do paciente,  ณฑฑ
ฑฑณ          ณ           quando nao exibir os dados do responsavel        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ campo definido em aCampo                                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ HSPAHM54                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function hs_gDPacRe(cCodPac, aCampo, lRetResp, cRetAlt, lRetPac)

local aArea      := getArea()
local cRet       := " "
local lResp      := .F.

Default cRetAlt  := " "
Default lRetPac  := .F.



dbSelectArea("GBH")
dbSetOrder(1)
if dbSeek(xFilial("GBH") + cCodPac )
	dbSelectArea("GFD")
	dbSetOrder(3)
	if dbSeek(xFilial("GFD") + cCodPac + "1") //"1" - Responsavel padrao
		//Se o campo em GFD foi informado
		if !empty(aCampo[2])
			cRet  := &("GFD->"+allTrim(aCampo[2]))
			lResp := .T.
		else
			cRet:= cRetAlt
		endif
	else //se nao ha responsavel
		//Se o campo em GBH foi informado
		if !empty(aCampo[1])
			cRet  := &("GBH->"+allTrim(aCampo[1]))
		else
			cRet := cRetAlt
		endif
	endif
endif

//Se paciente possui responsavel
if lResp
	//Se nao deseja exibir os dados do responsavel
	if !lRetResp
		//se deseja exibir os dados do paciente
		if !lRetPac
			cRet := cRetAlt
		endif
	endif
//Se nao possui responsavel e se nao quiser exibir os dados do paciente retorna cRetAlt
elseif !lRetPac
	cRet := cRetAlt
endif

restArea(aArea)
return Alltrim(cRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณhs_gDesSex       ณAutorณSaude                 ณDataณ10/05/11ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Retorna a descricao do sexo                                ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ hs_gDesSex(cSexo)                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณArgumentosณ cSexo   - (Pode receber "0",0,"1",1,"M","F")               ณฑฑ
ฑฑณ          ณ           0,"0","M" - Masculino   / 1,"1","F" - Feminino   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ cDesc - "Masculino" ou "Feminino"                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ HSPAHM54                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function hs_gDesSex(cSexo)
local cDesSexo := ""

if valType(cSexo) =="N"
	if cSexo == 0
		cDesSexo := STR0027 //"Masculino"
	elseif cSexo == 1
		cDesSexo := STR0028 //"Feminino"
	endif
else
	if cSexo == "0" .or. cSexo == "M"
		cDesSexo := STR0027 //"Masculino"
	elseif cSexo == "1" .or. cSexo == "F"
		cDesSexo := STR0028 //"Feminino"
	endif

endif
return cDesSexo



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณhs_gDesCbx       ณAutorณSaude                 ณDataณ10/05/11ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Retorna a descricao contida em SX3->X3_CBOX par ao codigo  ณฑฑ
ฑฑณ          ณ informado                                                  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ hs_gDesCbo(cCampo,cCodigo)                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณArgumentosณ cCampo  - Nome do campo - X3_CAMPO                         ณฑฑ
ฑฑณ          ณ cCodigo - Codigo contido em X3_CBOX                        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ cDesc - Descricao                                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function hs_gDesCbx(cCampo,cCodigo)
local aArea := getArea()
local cRet  := ""
local cTemp := " "
local nI

dbSelectArea("SX3")
dbSetOrder(2)
if dbSeek(cCampo)
	cTemp := X3_CBOX
	for nI:=1 to len(cTemp)
		if substr(cTemp, nI, 1) == allTrim(cCodigo)
			while substr(cTemp, nI, 1)<> ";" .and. nI <= len(cTemp)
				cRet += substr(cTemp, nI, 1)
				nI++
			end
			return Substr(cRet,3,len(cRet)-2)
		endif
	next nI
endif

restArea(aArea)
return cRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณHS_gIteOrc       ณAutorณSaude                 ณDataณ10/05/11ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Retorna um array com os itens de detalhe dos orcamentos a  ณฑฑ
ฑฑณ          ณ partir do codigo do cliente informado. Esse array possui   ณฑฑ
ฑฑณ          ณ apenas uma coluna com os dados da colunas concatenados,poisณฑฑ
ฑฑณ          ณ eh utilizado nas rotinas de impressao de arquivos Txt pre  ณฑฑ
ฑฑณ          ณ configurados, que utilizam arrays de 1 dimensao            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ HS_gIteOrc(cCodCli,aCpoSck,aStatus,cCondicao,aOrdBy,aLenCpos)ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณArgumentosณ cCodCli - Codigo do Cliente - A1_COD                       ณฑฑ
ฑฑณ          ณ aCpoSck - Array com os campos que se deseja visualizar     ณฑฑ
ฑฑณ          ณ aStatus - Status do(s) or็amentos que se deseja visualizar ณฑฑ
ฑฑณ          ณ aCondicao - Condicao adicional na clausula WHERE [opcional]ณฑฑ
ฑฑณ          ณ aOrdBy  - Campos utilizados na clausula ORDER BY [opcional]ณฑฑ
ฑฑณ          ณ aLenCpos - Tamanho para exibicao dos Campos (seguir ordem  ณฑฑ
ฑฑณ          ณ            definida em aCpoSck)                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ aRetorno - Resultado da query (array 1 coluna/n linhas)    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Arquivos Txt utilizado nas rotinas de impressao            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
function HS_gIteOrc( cCodCli, aCpoSck, aStatus, cCondicao, aOrdBy, aLenCpos )

local aArea    := getArea()
local cSql     := ""
local aRetorno := {}
local cStatus  := ""
local nI
local cLinhaSql:= ""
local cTemp    := ""
local nLenCpo  := 0

Default cCondicao := ""
Default aOrdBy    := ""

//Montando campos definidos na selecao
cSql := " SELECT "
for nI:=1 to len(aCpoSck)
	cSql += "SCK." + aCpoSck[nI]
	if nI< len(aCpoSck)
		cSql += ","
	endif
next nI

cSql += " FROM  " + RetSqlName("SCK") + " SCK

//Montando condicao para status selecionados
for nI:=1 to len(aStatus)
	cStatus += "'" + aStatus[nI] + "'"
	if nI< len(aStatus)
		cStatus += ","
	endif
next nI

cSql += " WHERE SCK.CK_CLIENTE='" + alltrim(cCodCli) + "' AND"
cSQL += " SCK.CK_NUM IN (SELECT GT9.GT9_NUMFAT FROM GT9990 GT9 WHERE GT9_STATUS IN (" + cStatus + ") AND GT9.GT9_CLIENT='" + alltrim(cCodCli) + "'"
cSql += " AND GT9.D_E_L_E_T_ <> '*' AND GT9.GT9_FILIAL = '" + xFilial("GT9") + "')"
cSql += " AND SCK.D_E_L_E_T_ <> '*' AND SCK.CK_FILIAL = '" + xFilial("SCK") + "'"
//se houver alguma condicao adicional
if !empty(cCondicao)
	cSql += " AND " + cCondicao
endif

//Se houver ORDER BY
if !empty(aOrdBy)
	//Montando itens do order by
	for nI:=1 to len(aOrdBy)
		cTemp += aOrdB[nI]
		if nI < len(aOrdBy)
			cTemp := + ","
		endif
	next nI
	cSql += " ORDER BY " +	cTemp
endif

TCQuery cSql New Alias "TMPSCK"
dbGoTop()

cTemp := ""
DbSelectArea("TMPSCK")

while !TMPSCK->(Eof())
	for nI:=1 to len(aCpoSck)
		nLenCpo := aLenCpos[nI]
		if valType(&("TMPSCK->"+aCpoSck[nI])) == "N"
			cTemp := ALLTRIM(TRAN(&("TMPSCK->"+aCpoSck[nI]),"@E 999999,999,999.99"))
		elseif valType(&("TMPSCK->"+aCpoSck[nI])) == "D"
			cTemp := dToC(&("TMPSCK->"+aCpoSck[nI]))
		elseif valType(&("TMPSCK->"+aCpoSck[nI])) == "C"
			cTemp := &("TMPSCK->"+aCpoSck[nI])
		endif
		//Se eh o campo Produto
		if aCpoSck[nI] == "CK_PRODUTO"
			//B1_DESC - Tamanho=30
			cTemp = Alltrim(cTemp)+ " - " + Posicione("SB1",1,xFilial("SB1") + Alltrim(cTemp) ,"B1_DESC")
		endif

		if len(cTemp) < nLenCpo
			cTemp += Repl(" ", nLenCpo - len(cTemp) )
		else
			cTemp := substr(cTemp,1,nLenCpo)
		endif
		cLinhaSql += cTemp
	next nI
	aAdd(aRetorno, cLinhaSql)
	cLinhaSql := ""
	TMPSCK->(DbSkip())
End
DbSelectArea("TMPSCK")
DbCloseArea()

RestArea(aArea)
return aRetorno

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFunao    ณHS_ORCTotal      ณAutorณSaude                 ณDataณ12/05/11ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Retorna um array com valor bruto, valor total de desconto eณฑฑ
ฑฑณ          ณ valor liquido do orcamento                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ HS_ORCTotal(cCodPac, aCampo, lRetDados, cRetAlt, lRetPac)  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณArgumentosณ cCodCli - Codigo do Cliente - A1_COD                       ณฑฑ
ฑฑณ          ณ aStatus - Status do(s) or็amentos que se deseja visualizar ณฑฑ
ฑฑณ          ณ aLenCpos - Tamanho para exibicao dos Campos (Total Bruto,  ณฑฑ
ฑฑณ          ณ            Total de Descontos , Total Liquido              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ aRetorno - Total, Total de Desconto, Total+Desconto        ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Arquivos Txt utilizado nas rotinas de impressao            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_ORCTotal(cCodCli, aStatus, aLenCpos)
Local aArea   	:= GetArea()
Local nTotVal 	:= 0
Local nTotDesc	:= 0
Local nPerDesc  := 0
//Local nX  		:= 0
//Local aControl
//Local nL		:= 0
Local cSql      := ""
Local nI
local cRetorno  := ""
local cStatus   := ""
local cTemp     := ""



//aControl := oDlgPE:aControls



//Montando condicao para status selecionados
for nI:=1 to len(aStatus)
	cStatus += "'" + aStatus[nI] + "'"
	if nI< len(aStatus)
		cStatus += ","
	endif
next nI


//Verificando qtde de orcamentos existentes
cSql := "SELECT DISTINCT SCK.CK_NUM FROM " + RetSqlName("GT9") + " GT9," + RetSqlName("SCJ") + " SCJ, " + RetSqlName("SCK") + " SCK"
cSql += " WHERE GT9.GT9_NUMFAT = SCJ.CJ_NUM AND GT9.GT9_CLIENT = SCJ.CJ_CLIENT"
cSql += " AND SCJ.CJ_NUM = SCK.CK_NUM  AND SCJ.CJ_CLIENT = SCK.CK_CLIENTE"
cSql += " AND GT9.GT9_STATUS IN (" + cStatus + ") AND SCK.D_E_L_E_T_ <> '*' AND SCK.CK_FILIAL = '" + xFilial("SCK") +"'"
cSql += " AND GT9.GT9_CLIENT = '" + Alltrim(cCodCli) + "'"

TCQuery cSql New Alias "TMPSCJ"
DbSelectArea("TMPSCJ")
dbGoTop()
while !TMPSCJ->(Eof())
	cNOrc := TMPSCJ->CK_NUM

	//Montando itens do orcamento atual
	cSql := "SELECT SCK.* FROM " + RetSqlName("GT9") + " GT9," + RetSqlName("SCJ") + " SCJ, " + RetSqlName("SCK") + " SCK"
	cSql += " WHERE GT9.GT9_NUMFAT = SCJ.CJ_NUM AND GT9.GT9_CLIENT = SCJ.CJ_CLIENT"
	cSql += " AND SCJ.CJ_NUM = SCK.CK_NUM  AND SCJ.CJ_CLIENT = SCK.CK_CLIENTE"
	cSql += " AND GT9.GT9_STATUS IN (" + cStatus + ") AND SCK.D_E_L_E_T_ <> '*' AND SCK.CK_FILIAL = '" + xFilial("SCK") +"'"
	cSql += " AND GT9.GT9_CLIENT = '" + Alltrim(cCodCli) + "' AND SCK.CK_NUM = '" + allTrim(cNOrc) + "'"
	TCQuery cSql New Alias "TMPSCK"
	dbSelectArea("TMPSCK")

	DbSelectArea("SCJ")
	DbSetOrder(1)
	If Empty(cNOrc) .OR. !DbSeek(xFilial("SCJ") + cNOrc)
		Return()
	EndIf
	RegToMemory("SCJ", .F.)

	nPerDesc  := M->CJ_DESC4
	//=======================================================ฟ
	//ณSoma o os valores e os descontos, mostrando-os na telaณ
	//=======================================================ู
	//For nL := 1 To Len(nItens)
	dbSelectArea("TMPSCK")
	dbGoTop()
	while !TMPSCK->(Eof())
	//	nTotVal  += oGetOrcIte:aCols[nL,nCKVALOR]
		nTotVal  += TMPSCK->CK_VALOR
	//	If (oGetOrcIte:aCols[nL,nCKPRUNIT] > oGetOrcIte:aCols[nL,nCKPRCVEN] )
		If TMPSCK->CK_PRUNIT > TMPSCK->CK_PRCVEN
	//		nTotDesc += A410Arred((oGetOrcIte:aCols[nL,nCKPRUNIT] * oGetOrcIte:aCols[nL,nCKQTDVEN]),"CK_VALOR") - A410Arred((oGetOrcIte:aCols[nL,nCKPRCVEN] * oGetOrcIte:aCols[nL,nCKQTDVEN]),"CK_VALOR")
			nTotDesc += A410Arred((TMPSCK->CK_PRUNIT * TMPSCK->CK_QTDVEN),"CK_VALOR") - A410Arred((TMPSCK->CK_PRCVEN * TMPSCK->CK_QTDVEN),"CK_VALOR")
		Else
	//		nTotDesc += oGetOrcIte:aCols[nL,nCKVALDESC]
			nTotDesc += TMPSCK->CK_VALDESC
		EndIf
		TMPSCK->(DbSkip())
	//Next nL
	end
	nTotDesc += M->CJ_DESCONT
	nTotVal  -= M->CJ_DESCONT
	nTotDesc += A410Arred(nTotVal*M->CJ_PDESCAB/100,"C6_VALOR")
	nTotVal  -= A410Arred(nTotVal*M->CJ_PDESCAB/100,"C6_VALOR")
	//=======================================================ฟ
	//ณCalcula o Desconto por Total                          ณ
	//=======================================================ู
	If nTotVal > 0 .And. FtRegraDesc(4,nTotVal+nTotDesc,M->CJ_DESC4) <> nPerDesc
		//=======================================================ฟ
		//ณSoma o os valores e os descontos, mostrando-os na telaณ
		//=======================================================?
		nTotVal := 0
		nTotDesc:= 0
	//	For nL := 1 To Len(oGetOrcIte:aCols)
		dbSelectArea("TMPSCK")
		goTop()
		while !TMPSCK->(Eof())
	//		nTotVal  += oGetOrcIte:aCols[nL,nCKVALOR]
			nTotVal  += TMPSCK->CK_VALOR
	//		If (oGetOrcIte:aCols[nL,nCKPRUNIT] > oGetOrcIte:aCols[nL,nCKPRCVEN] )
			If (TMPSCK->CK_PRUNIT > TMPSCK->CK_PRCVEN )
	//			nTotDesc += A410Arred((oGetOrcIte:aCols[nL,nCKPRUNIT] * oGetOrcIte:aCols[nL,nCKQTDVEN]),"CK_VALOR") - A410Arred((oGetOrcIte:aCols[nL,nCKPRCVEN] * oGetOrcIte:aCols[nL,nCKQTDVEN]),"CK_VALOR")
				nTotDesc += A410Arred((TMPSCK->CK_PRUNIT * TMPSCK->CK_QTDVEN),"CK_VALOR") - A410Arred((TMPSCK->CK_PRCVEN * TMPSCK->CK_QTDVEN),"CK_VALOR")
			Else
	//			nTotDesc += oGetOrcIte:aCols[nL,nCKVALDESC]
				nTotDesc += TMPSCK->CK_VALDESC
			EndIf
		//Next nL
		TMPSCK->(DbSkip())
		end
	EndIf

	//================================================================ฟ
	//ณSoma as variaveis da Enchoice                                  ณ
	//================================================================?
	nTotVal += M->CJ_FRETE
	nTotVal += M->CJ_SEGURO
	nTotVal += M->CJ_DESPESA
	nTotVal += M->CJ_FRETAUT

		dbSelectArea("TMPSCK")
		dbCloseArea()
		TMPSCJ->(DbSkip())
end
dbSelectArea("TMPSCJ")
dbCloseArea()

RestArea(aArea)

//Valor Bruto
cTemp := ALLTRIM(TRAN(nTotVal+nTotDesc,"@E 999999,999,999.99"))
if len(cTemp) < aLenCpos[1]
	cTemp += Repl(" ", aLenCpos[1] - len(cTemp) )
else
	cTemp := substr(cTemp,1,aLenCpos[1])
endif
cRetorno +=cTemp

//Valor Descontos
cTemp := ALLTRIM(TRAN(nTotDesc,"@E 999999,999,999.99"))
if len(cTemp) < aLenCpos[2]
	cTemp += Repl(" ", aLenCpos[2] - len(cTemp) )
else
	cTemp := substr(cTemp,1,aLenCpos[2])
endif
cRetorno +=cTemp

//Valor Liquido
cTemp := ALLTRIM(TRAN(nTotVal,"@E 999999,999,999.99"))
if len(cTemp) < aLenCpos[3]
	cTemp += Repl(" ", aLenCpos[3] - len(cTemp) )
else
	cTemp := substr(cTemp,1,aLenCpos[3])
endif
cRetorno +=cTemp

return cRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfs_getContบAutor  ณ                    บ Data ณ  03/05/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para retornar o codigo do Contrato do cliente        บฑฑ
ฑฑบ          ณSA1->A1_CODCLI/GBH->GBH_CODCLI a partir do codigo do        บฑฑ
ฑฑบ          ณpaciente GBH_CODPAC                                         บฑฑ
ฑฑบ          ณParametros:												  บฑฑ
ฑฑบ          ณcGbhCodPac  = codigo do paciente                            บฑฑ
ฑฑบ          ณRetorno:	     											  บฑฑ
ฑฑบ          ณGBH->GBH_CODCLI : Caracter                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGAHSP                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

function hs_getCont(cCodPac)
Local cArea   := getArea()
Local cCodCli := "______"
local cCodCon := "______"

DbSelectArea("GBH")
DbSetOrder(1)
If DbSeek(xFilial("GBH")  + cCodPac)
	cCodCli := GBH->GBH_CODCLI
	DbSelectArea("GT9")
	DbSetOrder(2)
	If DbSeek(xFilial("GT9")  + cCodCli)
		cCodCon := GT9->GT9_NRCONT
	Endif
Endif

restArea(cArea)
return alltrim(cCodCon)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GerTitPgบ Autor ณCibele Peria        บ Data ณ  09/06/05  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณGera o titulo no contas a pagar                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Gestao Hospitalar                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_GerTitPg(cHist, cPref, cPagHsp, cForn, cLoja, nValor, cNatura,cNumOrc, nItem)
Local cTipoTit  := "DP "
Local cE2_Num   := ""
Local aTitulo   := {}
Local aParcelas := {}//Condicao(aLbTit[11], cCondPag, 0, dVctoTit)
Local nPar      := 0
Local lRet      := .T.
Local cValTit   := 0
Local cMultNat  := "2" //Nao
Local cMV_HSPF12 := ALLTRIM(UPPER(GetMv("MV_HSPF12",, "N")))

Default cNumOrc := ""
Default nItem := 0

Private lMSHelpAuto := .T. // para nao mostrar os erro na tela
Private lMSErroAuto := .F. // inicializa como falso, se voltar verdadeiro e' que deu erro
Private lLoja		:= .F.

Private cBancoAdt	  	:=CriaVar("A6_COD")
Private cAgenciaAdt		:= CriaVar("A6_AGENCIA")
Private cNumCon	 	  	:= CriaVar("A6_NUMCON")
Private cChequeAdt	 	:= CriaVar("EF_NUM")
Private cHistor		   	:= CriaVar("EF_HIST")
Private cBenef		    := CriaVar("EF_BENEF")
Private cPictHist

If nValor == 0
	MsgStop(STR0019, STR0014)//"Tํtulo Gerado: "###" Prefixo "###"Aten็ใo"
	return("")
EndIf
aParcelas := Condicao(nValor, cPagHsp,0)

cE2_Num      := FS_E2Num(cPref)
For nPar := 1 to len(aParcelas)

	aTitulo      :={{"E2_FILIAL" , xFilial("SE2")                        , Nil}, ;
					{"E2_PREFIXO" , cPref                                  , Nil}, ;
					{"E2_NUM"    , cE2_Num                                , Nil}, ;
					{"E2_PARCELA" , StrZero(nPar, TAMSX3("E2_PARCELA")[1]), Nil}, ;
					{"E2_TIPO"   , cTipoTit                               , Nil}, ;
					{"E2_NATUREZ" , cNatura                              , Nil}, ;
					{"E2_FORNECE" , cForn                              , Nil}, ;
					{"E2_LOJA"   , cLoja                              , Nil}, ;
					{"E2_EMISSAO" , dDataBase            	                 , Nil}, ;
					{"E2_VENCTO" , aParcelas[nPar, 1]                    , Nil}, ;
					{"E2_VENCREA" , DataValida(aParcelas[nPar, 1])        , Nil}, ;
					{"E2_VALOR"  , aParcelas[nPar, 2]                    , Nil}, ;
					{"E2_VLCRUZ" , aParcelas[nPar, 2]                    , Nil}, ;
					{"E2_ORIGEM" , FunName()                            , Nil}, ;
					{"E2_HIST"   , cHist                                 , Nil}}

					//{"E2_BASECOF" , 0		                            , Nil}, ;


	MSExecAuto({|t,u,v| FINA050(t,u,v)}, aTitulo,, 3)
	If lMSErroAuto
		MostraErro()
		Return()
	EndIf


Next nPar
MsgStop(STR0017 + cE2_Num + STR0018 + cPref, STR0014)//"Tํtulo Gerado: "###" Prefixo "###"Aten็ใo"

If ExistBlock("HSPADCSE2")
	cE2_Num := ExecBlock("HSPADCSE2",.F.,.F.,{cNumOrc,nItem,aTitulo})
EndIf

Return(cE2_Num)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_E2Num  บ Autor ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera o codigo do Titulo                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function FS_E2Num(cMV_PrefCPH)
Local cE2_Num := Space(Len(SE2->E2_NUM)), cAliasOld := Alias(), aArea :=HS_SavArea({{"SE2", 0, 0}})
Local cSql    := ""

 cSql := "SELECT MAX(SE2.E2_NUM) MAXNUM FROM " + RetSqlName("SE2") + " SE2"
 cSQL += " WHERE"
 cSQL += " SE2.E2_FILIAL = '" + xFilial("SE2") + "' AND SE2.D_E_L_E_T_ <> '*' "
 cSQL += " AND SE2.E2_PREFIXO = '" + cMV_PrefCPH + "' "

 cSQL :=  ChangeQuery(cSQL)
 TCQUERY cSQL NEW ALIAS "QRYSE2"

 cE2_Num := Soma1(QRYSE2->MAXNUM , TAMSX3("E2_NUM")[1])

 DbCloseArea()
 HS_ResArea(aArea)
 DbSelectArea(cAliasOld)
Return(cE2_Num)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_GeraForบ Autor ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera o fornecedor                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_GFornPac(cRegGer, cCodCli)
Local aFornec 	:= {}, cAliasOld := Alias(), nOpc := 3
Local cCodFor 	:= "", cLoja := ""
Local aArea 	:= getArea()

Private lMSHelpAuto := .T. // para nao mostrar os erro na tela
Private lMSErroAuto := .f. // inicializa como falso, se voltar verdadeiro e'que deu erro

Default cCodCli := ""


/* *****************************************************************************
				BUSCA CODIGO DO CLIENTE DO CADASTRO DE PACIENTE
********************************************************************************/
If Empty(cCodCli) .AND. !Empty(cRegGer)
	DbSelectArea("GBH")
	DbSetOrder(1)
	If DbSeek(xFilial("GBH") + cRegGer)
		If !Empty(GBH->GBH_CODCLI)
			cCodCli := GBH->GBH_CODCLI
		Else
			HS_MSGINF(STR0016,STR0014, STR0015)//"Cliente nใo encontrado!","Aten็ใo", "Valida็ใo Atualiza็ใo Or็amento"
			Return()
		EndIf
	Else
		HS_MSGINF(STR0013,STR0014, STR0015)//"Paciente nใo encontrado!","Aten็ใo", "Valida็ใo Atualiza็ใo Or็amento"
		Return()
	EndIf
EndIf

DbSelectArea("GBH")
DbSetOrder(1)
DbSeek(xFilial("GBH") + cRegGer)

DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1") + cCodCli)

nOpc 		:= 3
cCodFor  	:= GetSxeNum("SA2", "A2_COD",, 1)

aFornec :=	{	{"A2_FILIAL" , xFilial("SA2")     , Nil}, ;
				{"A2_COD"    , cCodFor            , Nil}, ;
				{"A2_LOJA"   , SA1->A1_LOJA       , Nil}, ;
				{"A2_NOME"   , SA1->A1_NOME       , Nil}, ;
				{"A2_NREDUZ" , SA1->A1_NREDUZ     , Nil}, ;
				{"A2_END"    , SA1->A1_END        , Nil}, ;
				{"A2_EST"    , SA1->A1_EST        , Nil}, ;
				{"A2_MUN"    , SA1->A1_MUN        , Nil}, ;
				{"A2_BAIRRO" , SA1->A1_BAIRRO     , Nil}, ;
				{"A2_CEP"    , SA1->A1_CEP        , Nil}, ;
				{"A2_TIPO"   , SA1->A1_TIPO       , Nil}, ;
				{"A2_CGC"    , SA1->A1_CGC        , Nil}, ;
				{"A2_NATUREZ", SA1->A1_NATUREZ    , Nil}, ;
				{"A2_ID_REPR", "2"                , Nil}}

If ExistBlock("HSPFORN")
	aFornec := ExecBlock("HSPFORN",.F.,.F.,{aFornec})
	If ValType(aCampos) <> "A"
		ALERT(STR0035)
		Return()
	Endif
EndIf

MSExecAuto({|x, y| Mata020(x, y)}, aFornec, nOpc)
If lMSErroAuto
	MostraErro()
	DbSelectArea("SA2")
	RollBackSx8()
	Return()
Endif

DbSelectArea("GBH")
DbSetOrder(1)
If DbSeek(xFilial("GBH") + cRegGer)
	RecLock("GBH", .F.)
		GBH->GBH_CODFOR := cCodFor
	MsUnLock()
EndIf

ConfirmSx8()
RestArea(aArea)

Return(cCodFor)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GORCAUTบ Autor ณ                    บ Data ณ             บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera o or็amento automatico                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function HS_GORCAUT(aProdutos, cOrcamento, cCodCli, cLojCli, cNomeEn, dDatEmis, cProsp , cLojProsp, cCndPag, cTabela, cMoeda, cProposta, cOportunida, cRevisao)

Local aCabOrc 	:= {}
Local aRegs 	:= {}
Local aAux	 	:= {}
Local cItem 	:= "00"
Local cItePai	:= ""
Local nI		:= 0
Local nJ        := 0
Local nLinVet   := 0
Local nC		:= 0
Local nStack    := GetSX8Len()

Local aProdBlock := {}
Local aCpoBloOk  := {}
Local aCpoVlr    := {}
Local cNomCpoBlo := ""
Local aCposSCK   := {}
Local cMVTesNfs  := GetMv("MV_TESNFS",, "501")
Local lHspGerOrc := ExistBlock("HSPGERORC") 

Default cOrcamento := GetSxeNum("SCJ", "CJ_NUM",, 1)
Default dDatEmis := dDataBase
Default cProsp := ""
Default cLojProsp := ""
Default cCndPag	:= PadR(GetMV("MV_CPAGHSP"), TamSx3("E4_CODIGO")[1])
Default cTabela := Space(Len(SCJ->CJ_TABELA))
Default cMoeda	:= "1"
Default cProposta := Space(Len(SCJ->CJ_PROPOST))
Default cOportunida := Space(Len(SCJ->CJ_NROPOR))
Default cRevisao := Space(Len(SCJ->CJ_REVISA))

If ExistBlock("HSPGERORC")
	aProdBlock := ExecBlock("HSPGERORC", .F., .F., {aProdBlock}) //Recebe o array {cCodProd, cItemOrc, {cCampo, uValor}}
 	if !empty(aProdBlock)
 		//Validando Campos definidos pelo usuario
		for nI := 1 to len(aProdBlock)
			//Compara Codigo do produto e item do orcamento - Somente procedimentos pai/unitarios serao incluidos na SCK
			if (aScan(aProdutos,{|aVet|  aProdBlock[nI,1] == aVet[1] .and. aProdBlock[nI,2] == aVet[11] })) > 0
				aCpoVlr := aProdBlock[nI,3] //Vetor de Campos/Valores definidos para o item do or็amento encontrado
				//Validando campos no dicionario
				for nJ := 1 to len(aCpoVlr)
					dbSelectArea("SX3")
					dbSetOrder(2)
					If SX3->(dbSeek(aCpoVlr[nJ,1])) //Nome do campo
						aAdd(aCpoBloOk, {aCpoVlr[nJ,1], aCpoVlr[nJ,2]}) // Nome do campo / Valor
					Endif
				next nH
				aProdBlock[nI,3] := aCpoBloOk
				aCpoBloOk := {}
			endif
		next nI
	endif
endif

Begin Transaction

RecLock("SCJ", .T.)
	SCJ->CJ_FILIAL := xFilial("SCJ")
	SCJ->CJ_NUM := cOrcamento
	SCJ->CJ_EMISSAO:=	dDatEmis
	SCJ->CJ_CLIENTE:=	cCodCli
	SCJ->CJ_LOJA:=		cLojCli
	SCJ->CJ_PROSPE:=	cProsp
	SCJ->CJ_LOJPRO :=	cLojProsp
	SCJ->CJ_CLIENT:=	cCodCli
	SCJ->CJ_LOJAENT:=	cLojCli
	SCJ->CJ_CONDPAG:=	cCndPag
	SCJ->CJ_TABELA :=	cTabela
	SCJ->CJ_DESC1 :=	0
	SCJ->CJ_DESC2 :=	0
	SCJ->CJ_DESC3 :=    0
	SCJ->CJ_DESC4 :=    0
	SCJ->CJ_STATUS :=   "A"
	SCJ->CJ_FRETE :=	0
	SCJ->CJ_SEGURO :=	0
	SCJ->CJ_DESPESA :=	0
	SCJ->CJ_FRETAUT :=	0
	SCJ->CJ_MOEDA :=    Val(cMoeda)
	SCJ->CJ_TIPLIB :=   "1"
	SCJ->CJ_TPCARGA :=  "2"
	SCJ->CJ_DESCONT :=  0
	SCJ->CJ_PDESCAB :=  0
	SCJ->CJ_PROPOST :=  cProposta
	SCJ->CJ_TXMOEDA :=  1
	SCJ->CJ_NROPOR :=  cOportunida
	SCJ->CJ_REVISA :=  cRevisao
MsUnlock()

For nI := 1 To Len(aProdutos)
	cItem := Soma1(cItem)
	If !aProdutos[nI, 17]
		aProdutos[nI, 10] := cItem
		aProdutos[nI, 18] := IIf(Empty(cItePai), cItem, cItePai)
		Loop
	Else
		cItePai := cItem
	EndIf
	RecLock("SCK", .T.)
		SCK->CK_ITEM := cItem
		//aProdutos[nI, 11] := cItem
		SCK->CK_FILIAL := xFilial("SCK")
		SCK->CK_FILVEN := xFilial("SCK")
		SCK->CK_PRODUTO := aProdutos[nI,1]
		SCK->CK_VALOR := aProdutos[nI,2]
		SCK->CK_PRCVEN := aProdutos[nI,3]
		SCK->CK_UM := aProdutos[nI,4]
		SCK->CK_DT1VEN := dDatEmis
		SCK->CK_LOCAL :=  "01"
		SCK->CK_CLIENTE := cCodCli
		SCK->CK_LOJA := cLojCli
		SCK->CK_NUM := cOrcamento
		SCK->CK_DESCRI := aProdutos[nI,5]
		SCK->CK_ENTREG := dDatEmis
		SCK->CK_PRUNIT := aProdutos[nI,6]
		SCK->CK_DESCONT := aProdutos[nI,7]
		SCK->CK_VALDESC := aProdutos[nI,8]
		SCK->CK_QTDVEN := aProdutos[nI,9]
		SCK->CK_TES := cMVTesNfs

		If lHspGerOrc .and. !empty(aProdBlock)
			//Campos que nใo poderใo ser alterados pelo ponto de entrada
			aCposSCK   := {"CK_ITEM   ",;
							"CK_FILIAL ",;
							"CK_FILVEN ",;
							"CK_PRODUTO",;
							"CK_VALOR  ",;
							"CK_PRCVEN ",;
							"CK_UM     ",;
							"CK_DT1VEN ",;
							"CK_LOCAL  ",;
							"CK_CLIENTE",;
							"CK_LOJA   ",;
							"CK_NUM    ",;
							"CK_DESCRI ",;
							"CK_ENTREG ",;
							"CK_PRUNIT ",;
							"CK_DESCONT",;
							"CK_VALDESC",;
							"CK_QTDVEN ",;
							"CK_TES    "}
			//Verifica se a linha atual de aprodutos ้ igual a um dos iten s do orcamento recebido no PE
			if (nLinVet := aScan(aProdBlock,{|aVet|  aProdutos[nI,1] == aVet[1] .and. aProdutos[nI,11] == aVet[2] })) > 0
				aCpoVlr := aProdBlock[nLinVet,3]
				for nJ := 1 to len(aCpoVlr)
					cNomCpoBlo    := "SCK->" + aCpoVlr[nJ,1] //Nome do campo
					//Verifica se o campo informado nใo ้ igual aos campos pre definidos para gravacao
					if (aScan(aCposSCK,{|aVet|  allTrim(aVet) == alltrim(aCpoVlr[nJ,1])}) ) == 0
						&(cNomCpoBlo) := aCpoVlr[nJ,2] //Valor
					endif
				next nH
			endif
		endif

	MsUnlock()
	aProdutos[nI, 10] := cItem
Next nI

End transaction

While GetSX8Len() > nStack
	ConfirmSX8()
EndDo


/*aCabOrc := {			{"CJ_NUM",      cOrcamento	  					,nil},;
						{"CJ_EMISSAO",	dDatEmis	  					,nil},;
						{"CJ_CLIENTE",	cCodCli		  					,nil},;
						{"CJ_LOJA",		cLojCli		  					,nil},;
						{"CJ_PROSPE",	cProsp		  					,nil},;
						{"CJ_LOJPRO",	cLojProsp		  				,nil},;
						{"CJ_CLIENT",	cCodCli		  					,nil},;
						{"CJ_LOJAENT",	cLojCli		  					,nil},;
						{"CJ_CONDPAG",	cCndPag							,nil},;
						{"CJ_TABELA",	cTabela		  					,nil},;
						{"CJ_DESC1",	0			  					,nil},;
						{"CJ_DESC2",	0			   					,nil},;
						{"CJ_DESC3",    0			  					,nil},;
						{"CJ_DESC4",    0			  					,nil},;
						{"CJ_STATUS",   "A"			  					,nil},;
						{"CJ_FRETE",	0			  			  		,nil},;
						{"CJ_SEGURO",	0			  			  		,nil},;
						{"CJ_DESPESA",	0			   			   		,nil},;
						{"CJ_FRETAUT",	0			   			  		,nil},;
						{"CJ_MOEDA",    Val(cMoeda)						,nil},;
						{"CJ_TIPLIB",   "1"			   					,nil},;
						{"CJ_TPCARGA",  "2"			  					,nil},;
						{"CJ_DESCONT",  0			   					,nil},;
						{"CJ_PDESCAB",  0			   					,nil},;
						{"CJ_PROPOST",  cProposta	   					,nil},;
						{"CJ_TXMOEDA",  1			   					,nil},;
						{"CJ_NROPOR" ,  cOportunida	   					,nil},;
						{"CJ_REVISA" ,  cRevisao	   					,nil}}

For nI := 1 To Len(aProdutos)
	cItem := Soma1(cItem)
	aAux := {		{"CK_ITEM"    	,cItem										,Nil},;
					{"CK_FILVEN"	,xFilial("SCK")							 	    ,NIL},;
					{"CK_PRODUTO"  	,aProdutos[nI,1]				  				,NIL},;
					{"CK_VALOR"		,aProdutos[nI,2]							 	,NIL},;
					{"CK_PRCVEN"	,aProdutos[nI,3]							 	,NIL},;
					{"CK_UM"	 	,aProdutos[nI,4]							   	,NIL},;
					{"CK_DT1VEN"	,dDatEmis							  		,NIL},;
					{"CK_LOCAL"    	,"01"          							 	,NIL},;
					{"CK_CLIENTE"  	,cCodCli        						 	,NIL},;
					{"CK_LOJA"     	,cLojCli           						 	,NIL},;
					{"CK_NUM"   	,cOrcamento									,NIL},;
					{"CK_DESCRI"   	,aProdutos[nI,5]							 	,NIL},;
					{"CK_ENTREG"  	,dDatEmis     							  	,NIL},;
					{"CK_PRUNIT"  	,aProdutos[nI,6]							 	,NIL},;
					{"CK_DESCONT"	,aProdutos[nI,7]							 	,NIL},;
					{"CK_VALDESC"	,aProdutos[nI,8]							 	,NIL},;
					{"CK_TES"	,"501"							 	,NIL},;
					{"CK_QTDVEN"  	,aProdutos[nI,9]							   	,NIL}}

	AADD(aRegs, aClone(aAux))
	For nC := 1 To Len(aAux)
		AADD(aRegs, aAux[nC])
	Next nC
Next nI


MSExecAuto({|x,y,z|Mata415(x,y,z)},aCabOrc,aRegs,3)
    */
/*If	lMsErroAuto
	cOrcamento := ""
	DisarmTransaction()
	Mostraerro()
EndIf  */

Return(cOrcamento)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณHS_GTXTORCบ Autor ณ Saude              บ Data ณ  11/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Gera TXT com a observa็ใo impressa no relatorio de Orcamentoบฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Function HS_GTXTORC()
Local cEnvServ  := GetEnvServer()
Local cDirRaiz 	:= Upper(GetPvProfString(cEnvServ, "RootPath", "C:\MP811\Protheus_Data", GetADV97()))
Local cNomArq	:= ""
Local cArqNf    := ""

Private cTxtLab := ""

If SubString (cDirRaiz,Len(cDirRaiz),Len(cDirRaiz)) == "\"
	cNomArq := cDirRaiz + "OBSIMPRORCA.txt"
Else
	cNomArq := cDirRaiz + "\OBSIMPRORCA.txt"
EndIf

cTxtLab := MemoRead(cNomArq)

FErase(cNomArq)

cArqNf:=fCreate(cNomArq)

FS_OrcMemo(STR0031,.T.,@cTxtLab) //"Condi็๕es Pagamento"

FWrite(cArqNf,cTxtLab)

FClose(cArqNf)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FS_OrcMemo บ Autor ณ                  บ Data ณ  10/10/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Abre campo memo                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_OrcMemo( cLabel, lEdit, cTexto)

Local oDlgM, oTexto
Local nPos := 0, nPosCtrl := 0

Default cTexto := ""

lEdit  := IIf(lEdit  == Nil,           .T., lEdit)
cLabel := IIf(cLabel == Nil,            "", cLabel)

DEFINE MSDIALOG oDlgM FROM	62,100 TO 280,510 TITLE STR0031 PIXEL //"Condi็oes Pagamento"

  @ 015, 004 TO 085, 200 Label cLabel OF oDlgM PIXEL
  @ 025, 010 GET oTexto VAR cTexto MEMO When lEdit  Valid fs_vldObsCond(cTexto) SIZE 178.64, 051 OF oDlgM PIXEL

DEFINE SBUTTON FROM 90,170 TYPE 1 ACTION (oDlgM:End()) ENABLE OF oDlgM

ACTIVATE MSDIALOG oDlgM CENTERED


Return(Nil)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออหอออออออัออออออออออออออออออออหออออออัออออออออออปฑฑ
ฑฑบPrograma  ณfs_vldObsCond บ Autor ณ                    บ Data ณ27/12/2011บฑฑ
ฑฑฬออออออออออุออออออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออนฑฑ
ฑฑบDescricao ณ Valida conteudo do campo memo                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Administracao Hospitalar                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function fs_vldObsCond(cTxtCondPag)
local nLinhas   := 0
local lRet      := .T.

nLinhas := nLines := MLCount(cTxtCondPag)

if nLinhas > 5
	HS_MSGINF(STR0032 + ; //"A observa็ใo informada excede o n๚mero mแximo de linhas que podem ser exibidas no relat๓rio (5)."
	chr(13) + chr(10) + chr(13) + chr(10) + STR0033  ; //"Ajuste o texto a ser impresso."
	,STR0014, STR0034)// "Aten็ใo", "Valida็ใo Obs. Cond. Pagam."
	lRet := .F.
endif

return lRet

/*
###################################################################################
###################################################################################
### Programa  # hs_gerRepAuto ### Autor #  Saude       ### Data #   28/05/2012  ###
###################################################################################
### Descricao # Gera item de repasse automatico                                 ###
###################################################################################
### Parametro #                                                                 ###
###           # cGcyRegAte   : Codigo de atendimento ao paciente                ###
###################################################################################
### Retorno   #                                                                 ###
###           #                                                                 ###
###################################################################################
### Uso       # GH                                                              ###
###################################################################################
*/

function hs_gerRepAuto(cGcyRegAte, cCodProc, cNumOrc, cIteOrc, cCodCrm, cDenReg, cFadent, lItemRep, cCrmAnt)
local aArea      := getArea()
local lGD7Reg    := .F.
local cSeqDes    := ""
local cNrSeqG    := ""
local cRegGer    := ""
local cCodLoc    := ""
local cAtendi    := ""
local cAtOrig    := ""
local cIdade     := ""
local cSexo      := ""
local cCarate    := ""
local cLocate    := ""
local cCodPla    := ""
local bFnGerGui  := ""
local aRValDes   := {}
local cGe7SeqDes := ""
local nFieldGb   := 0
local cFatGer    := ""
local nRecGd7    := ""
local cGczCodTpg := ""
local cGatNumLot := ""
local lPlanPar   := GetNewPar("MV_PLANPAR", "")
local nField     := 0
Local cCrmRep	 := ""

Private cLocCont  := GetNewPar("MV_LOCCONT", "0")
Private __cCodBPA := GetNewPar("MV_PSUSBPA", "")
Private __cCodPAC := GetNewPar("MV_PSUSPAC", "")
Private __cCodAIH := GetNewPar("MV_PSUSAIH", "")

Default cDenReg := ""
Default cFadent := ""
Default lItemRep:= .F.
Default cCrmAnt := ""

//################# INCLUI PROCEDIMENTO NAS DESPESAS DA GUIA - INICIO
//Verifica se o procedimento ja foi registrado na GD7
DbSelectArea("GD7")
DbSetOrder(3)
if DbSeek(xFilial("GD7") + cGcyRegAte)
	While !GD7->(Eof()) .and. GD7->GD7_REGATE ==  cGcyRegAte  
		if GD7->GD7_NUMORC == cNumOrc .and. GD7->GD7_ITEORC ==  cIteOrc
			lGD7Reg := .T.
			cNrSeqG := GD7->GD7_NRSEQG
			nRecGd7 := GD7->(RECNO())
			exit
		endif
		GD7->(dbSkip())
	end
endif

//Dados do atendimento
DbSelectArea("GCY")
DbSetOrder(1)
if DbSeek(xFilial("GD7") + cGcyRegAte)
	cRegGer  := GCY->GCY_REGGER
	cCodLoc  := GCY->GCY_CODLOC
	cAtendi  := GCY->GCY_ATENDI
	cAtOrig  := GCY->GCY_ATORIG
	cIdade   := GCY->GCY_IDADE
	cSexo    := GCY->GCY_SEXO
	cCarate  := GCY->GCY_CARATE
	cLocate  := GCY->GCY_LOCATE
endif

DbSelectArea("GCZ")
DbSetOrder(2)
if DbSeek(xFilial("GCZ") + cGcyRegAte)
	if !lGD7Reg
		cNrSeqG := GCZ->GCZ_NRSEQG
	endif
	if empty(GCZ->GCZ_CODDES)
		RecLock("GCZ", .F.)
		GCZ->GCZ_CODDES := cCodProc
		MsUnlock()
	endif
	cCodPla := GCZ->GCZ_CODPLA
Else
	//Dados Paciente
	cCodPla := HS_INIPADR("GD4",1, cRegGer, "GD4_CODPLA",,.T.)
endif

//dados do procedimento
aRValDes := HS_RValPr(cCodProc, cCodPla, cCodLoc,;
Time(), "1", cCodCrm, "", {cAtendi, cAtOrig, cIdade, cSexo, cCarate},;
.F., date())
cSeqDes := GetSxENum("GD7","GD7_SEQDES",,1)

//Se o registro nao foi encontrado na GD7, ้ incluido
if !lGD7Reg
	DbSelectArea("GD7")
	RecLock("GD7", .T.)
	GD7->GD7_FILIAL := xFilial("GD7")
	GD7->GD7_CODLOC := cCodLoc
	GD7->GD7_DATDES := dDatabase//HS_DATPAT(.T.)
	GD7->GD7_HORDES := HS_DATPAT(.F.)
	GD7->GD7_QTDDES := 1
	GD7->GD7_CODDES := cCodProc
	GD7->GD7_CODCRM := cCodCrm
	//GD7->GD7_CODATO :=
	//GD7->GD7_CODVIA :=
	GD7->GD7_COEDES := aRValDes[16][02]
	GD7->GD7_COEFAM := aRValDes[2][1][2]
	GD7->GD7_VALDES := aRValDes[02][01][01]
	//GD7->GD7_DESPER :=
	//GD7->GD7_DESVAL :=
	//GD7->GD7_VALTOT :=
	//GD7->GD7_TOTDSC
	//GD7->GD7_DESOBS :=
	GD7->GD7_VFILME := aRValDes[02][03]
	GD7->GD7_VCUSOP := aRValDes[02][02]
	GD7->GD7_PCUDES := aRValDes[03]
	GD7->GD7_URGDES := aRValDes[2][14]
	GD7->GD7_GLODES := IIf(aRValDes[04][01], "2", "0")
	GD7->GD7_COECHP := aRValDes[2][10]
	GD7->GD7_QTDCHP := aRValDes[2][11]
	GD7->GD7_CODESP := aRValDes[07]
	GD7->GD7_PGTMED := aRValDes[9][1]
	GD7->GD7_COECHM := aRValDes[9][aRValDes[11]]
	GD7->GD7_REPAMB := aRValDes[9][aRValDes[10]]
		GD7->GD7_VALREP := GD7->GD7_QTDDES * aRValDes[9][14]
		GD7->GD7_VALREP := GD7->GD7_QTDDES * aRValDes[9][14]
	//GD7->GD7_CODPCT :=
	//GD7->GD7_CODKIT :=
	GD7->GD7_SEQDES := cSeqDes
	//GD7->GD7_SPRINC :=
	GD7->GD7_NRSEQG := cNrSeqG
	GD7->GD7_REGATE := cGcyRegAte
	//GD7->GD7_IDMARC :=
	GD7->GD7_FATPAR := aRValDes[04][02]
	//GD7->GD7_INCIDE :=
	GD7->GD7_SLAUDO :=  "0"
	If HS_IsLaudo(cCodLoc, cCodProc)[1]
		GD7->GD7_SLAUDO :=  "1"
		GD7->GD7_CRMLAU := cCodCrm
	EndIf
	GD7->GD7_CODPRE := aRValDes[14]
	//GD7->GD7_SEQGE7 :=
	GD7->GD7_ORIDES := "0"
	//GD7->GD7_CODPCO :=
	GD7->GD7_CODPRT := aRValDes[02][15]
	//GD7->GD7_TPAPAC :=
	//GD7->GD7_CDGATE :=
	//GD7->GD7_CMCPAC :=
	//GD7->GD7_CGCFOR :=
	//GD7->GD7_CDTATE :=
	//GD7->GD7_NNFFOR
	GD7->GD7_DOPLER := "0"
	GD7->GD7_LOGARQ := HS_LOGARQ()
	GD7->GD7_VLRCOS := aRValDes[2][24]
	//GD7->GD7_DOCCIR :=
	//GD7->GD7_DATFIM :=
	//GD7->GD7_HORFIM :=
	//GD7->GD7_TPANES :=
	//GD7->GD7_DESANE :=
		GD7->GD7_TABELA := aRValDes[02][20]
		GD7->GD7_VLREPF := GD7->GD7_QTDDES * aRValDes[9][17]
	//GD7->GD7_TECUTI :=
	//GD7->GD7_CNPJFO :=
	//GD7->GD7_NFOPM  :=
	//GD7->GD7_LOTOPM :=
	//GD7->GD7_SEROPM :=
	//GD7->GD7_CNPJFA :=
	//GD7->GD7_ANVOPM :=
	//GD7->GD7_COMPD  :=
	//GD7->GD7_QTFILH :=
	//GD7->GD7_CIDIND :=
	//GD7->GD7_GRINST :=
	//GD7->GD7_MCONT1 :=
	//GD7->GD7_MCONT2 :=
	//GD7->GD7_GESTR  :=
	//GD7->GD7_TDEAIH :=
	//GD7->GD7_DDEAIH :=
	//GD7->GD7_REPPAR :=
	GD7->GD7_DENREG := cDenReg
	GD7->GD7_FADENT := cFadent
	//GD7->GD7_STAPLS :=
	GD7->GD7_NUMORC := cNumOrc
	GD7->GD7_ITEORC := cIteOrc
	MsUnLock()
	nRecGd7 := RECNO()
endif

//################# INCLUI PROCEDIMENTO NAS DESPESAS DA GUIA - FIM

if lPlanPar == cCodPla
	//Atualiza o status da guia
	DbSelectArea("GCZ")
	DbSetOrder(2) //GCZ_REGATE + GCZ_STATUS
	if DbSeek(xFilial("GCZ") + cGcyRegAte)
		RecLock("GCZ", .F.)
		GCZ->GCZ_STATUS  := "1"
		GCZ->GCZ_LOGARQ  := HS_LOGARQ()
		MsUnLock()
		cGczCodTpg := GCZ->GCZ_CODTPG
		cFatGer := HS_HP12Fat(GCZ->GCZ_NRSEQG, .T.)

		if !empty(cFatGer)
			HS_MsgInf(cFatGer, "Aten็ใo", "Finaliza็ใo de procedimento - Gera Guia")
		else
			DbSelectArea("GD7")
			DbGoto(nRecGd7)
			RecLock("GD7", .F.)
			GD7->GD7_ITEFAT := .T.
			MsUnlock()
			//Se o item ja foi repetido, gera um registro na GE7 com valor negativo de repasse para o profissional que executou anteriormente
			if lItemRep
				/*RecLock("GE7",.T.)
				For nField := 1 To GD7->(FCount())
					If Type("GE7->GE7" + SubStr(GD7->(FieldName(nField)), 4)) # "U"
						if GD7->(FieldName(nField)) == "GD7_VALREP"
							&("GE7->GE7" + SubStr(GD7->(FieldName(nField)), 4)) := GD7->(&(FieldName(nField))) * (-1)
						elseif GD7->(FieldName(nField)) == "GD7_CODCRM" .and. !empty(cCrmAnt)
							&("GE7->GE7" + SubStr(GD7->(FieldName(nField)), 4)) := cCrmAnt
						else
							&("GE7->GE7" + SubStr(GD7->(FieldName(nField)), 4)) := GD7->(&(FieldName(nField)))
						endif
					EndIf
				Next nField
				MsUnlock()*/
                // Lanca despesa avulsa de debito para o profissional
                cCrmRep := IIf(!empty(cCrmAnt), cCrmAnt, GD7->GD7_CODCRM)
				RecLock("GDX", .T.)
				GDX->GDX_FILIAL := xFilial("GDX")
				GDX->GDX_NREXTM := HS_VSxeNum("GDX", "M->GDX_NREXTM", 1)
				GDX->GDX_CODLOC := GD7->GD7_CODLOC
				GDX->GDX_CODCRM := cCrmRep
				GDX->GDX_CODPRE := HS_RPreMed(cCrmRep, GD7->GD7_CODLOC)
				GDX->GDX_DATLAN := GD7->GD7_DATDES
				GDX->GDX_TIPLAN := "0"
				GDX->GDX_TIPMOV := "1" //"Avulso"
				GDX->GDX_VALLAN := GD7->GD7_VALREP
				GDX->GDX_VALLAO := GD7->GD7_VALREP
				GDX->GDX_HISLAN := "Proc.Repet[" + GD7->GD7_CODDES + "]Orc:" + cNumOrc + "-Item:" + cIteOrc + ""
				GDX->GDX_LOGARQ := Hs_LogArq()
				MsUnlock()
				ConfirmSXE()

			endif

			RecLock("GCZ", .F.)
			GCZ->GCZ_STATUS  := "9"
			GCZ->GCZ_LOGARQ  := HS_LOGARQ()
			MsUnLock()
		endif
	endif
endif



restArea(aArea)
return
