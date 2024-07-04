#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINDEAMT   บAutor  ณMurilo Alves        บ Data ณ 09/10/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGeracao dos Arquivos de Importacao da INDEA/MT              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function INDEAMT(dDtInicial,dDtFinal)
	Local aTRBS 	:= INDEAMTTRB()
	INDEAMTProc(dDtInicial,dDtFinal) 	
Return(aTRBs)                    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINDEAMTTRBบAutor  ณMurilo Alves        บ Data ณ 09/10/2008  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCria tabelas temporarias para o INDEA/MT                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณINDEAMT                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function INDEAMTTRB()

Local aTabMuni		:= {}
Local aMovProd		:= {}
Local aEstIni		:= {}
Local aMovComp  	:= {}
Local aMovVend  	:= {}
Local aMovClie  	:= {}
Local aMovForn  	:= {}
Local aDevVda  		:= {}
Local aCanVda	  	:= {}
Local aTrbs			:= {}
Local cTabMuni		:= ""
Local cMovProd		:= ""
Local cEstIni		:= ""
Local cMovComp  	:= ""
Local cMovVend  	:= ""
Local cMovClie  	:= ""
Local cMovForn  	:= ""
Local cDevVda  		:= ""
Local cCanVda	  	:= ""

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Tabela Tab_Muni.txt - Unidade de Medida     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aTabMuni,{"TM_CODIGO","C",006,0})
AADD(aTabMuni,{"TM_NOME"  ,"C",035,0})
AADD(aTabMuni,{"TM_ESTADO","C",002,0})
//
cTabMuni := CriaTrab(aTabMuni)
dbUseArea(.T.,__LocalDriver,cTabMuni,"TMX")
IndRegua("TMX",cTabMuni,"TM_CODIGO")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Tabela Mov_Prod.txt - Revenda Produto       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aMovProd,{"MP_CODEMP" ,"C",018,0})
AADD(aMovProd,{"MP_NUMREG" ,"C",008,0})
AADD(aMovProd,{"MP_NOMECOM","C",035,0})
AADD(aMovProd,{"MP_SGEMB"  ,"C",002,0})
AADD(aMovProd,{"MP_TIPOEMB","C",003,0})
AADD(aMovProd,{"MP_VOLUME" ,"N",009,3})
AADD(aMovProd,{"MP_SGUNID" ,"C",003,0})
AADD(aMovProd,{"MP_REFREV" ,"C",029,0})
AADD(aMovProd,{"MP_DATA"   ,"C",010,0})
AADD(aMovProd,{"MP_SDINI"  ,"C",009,0})
AADD(aMovProd,{"MP_SDFIN"  ,"C",009,0})
//                         
cMovProd := CriaTrab(aMovProd)
dbUseArea(.T.,__LocalDriver,cMovProd,"MPX")
IndRegua("MPX",cMovProd,"MP_CODEMP+MP_NUMREG")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Tabela Est_Ini.txt - Estoque Inicial        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aEstIni,{"EI_CODEMP" ,"C",018,0})
AADD(aEstIni,{"EI_REFREV" ,"C",029,0})
AADD(aEstIni,{"EI_NOMECOM","C",035,0})
AADD(aEstIni,{"EI_SDINI"  ,"C",009,0})
AADD(aEstIni,{"EI_DATA"   ,"C",010,0})
//
cEstIni := CriaTrab(aEstIni)
dbUseArea(.T.,__LocalDriver,cEstIni,"EIX")
IndRegua("EIX",cEstIni,"EI_CODEMP")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Tabela Mov_Comp.txt - Movimento de Compras  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aMovComp,{"MC_CODEMP","C",018,0})
AADD(aMovComp,{"MC_CNPJ"  ,"C",018,0})
AADD(aMovComp,{"MC_NF"    ,"C",009,0})
AADD(aMovComp,{"MC_REFREV","C",029,0})
AADD(aMovComp,{"MC_DATA"  ,"C",010,0})
AADD(aMovComp,{"MC_QUANT" ,"N",006,0})
AADD(aMovComp,{"MC_MESANO","C",006,0})
//
cMovComp := CriaTrab(aMovComp)
dbUseArea(.T.,__LocalDriver,cMovComp,"MCX")
IndRegua("MCX",cMovComp,"MC_CODEMP+MC_CNPJ+MC_NF+MC_REFREV")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Tabela Mov_Vend.txt - Movimento de Vendas   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aMovVend,{"MV_CODEMP" ,"C",018,0})
AADD(aMovVend,{"MV_NF"     ,"C",009,0})
AADD(aMovVend,{"MV_REFREV" ,"C",029,0})
AADD(aMovVend,{"MV_DATA"   ,"C",010,0})
AADD(aMovVend,{"MV_QUANT"  ,"N",006,0})
AADD(aMovVend,{"MV_CULT"   ,"N",006,0})
AADD(aMovVend,{"MV_APLIC"  ,"N",006,0})
AADD(aMovVend,{"MV_CPFCNPJ","C",018,0})
AADD(aMovVend,{"MV_ART"    ,"C",011,0})
AADD(aMovVend,{"MV_RECEITA","C",012,0})
AADD(aMovVend,{"MV_CREA"   ,"C",014,0})
AADD(aMovVend,{"MV_DOSAGEM","C",013,0}) //AADD(aMovVend,{"MV_DOSAGEM","N",009,3})
AADD(aMovVend,{"MV_AREA"   ,"C",016,0}) //AADD(aMovVend,{"MV_AREA"   ,"N",012,3})
AADD(aMovVend,{"MV_MESANO" ,"C",006,0})
AADD(aMovVend,{"MV_CODCOLE","N",004,0})
AADD(aMovVend,{"MV_CODPRAG","N",004,0})
//
cMovVend := CriaTrab(aMovVend)
dbUseArea(.T.,__LocalDriver,cMovVend,"MVX")
IndRegua("MVX",cMovVend,"MV_CODEMP+MV_NF+MV_CPFCNPJ+MV_REFREV")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Tabela Mov_Clie.txt - Clientes da Revenda   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aMovClie,{"MC_TIPO"   ,"C",001,0}) //0-propriedade / 1-p.fisica / 2-p.juridica
AADD(aMovClie,{"MC_CPFCNPJ","C",018,0})
AADD(aMovClie,{"MC_NOMECLI","C",045,0})
AADD(aMovClie,{"MC_END"    ,"C",040,0})
AADD(aMovClie,{"MC_BAIRRO" ,"C",025,0})
AADD(aMovClie,{"MC_ESTADO" ,"C",002,0})
AADD(aMovClie,{"MC_CODMUNI","C",006,0})
AADD(aMovClie,{"MC_CEP"    ,"C",009,0})
AADD(aMovClie,{"MC_FONE"   ,"C",014,0})
AADD(aMovClie,{"MC_PROPR"  ,"C",045,0})
AADD(aMovClie,{"MC_EMAIL"  ,"C",040,0})
AADD(aMovClie,{"MC_PERFIL" ,"C",001,0}) //0-consumidor / 1-revenda
//
cMovClie := CriaTrab(aMovClie)
dbUseArea(.T.,__LocalDriver,cMovClie,"MCY")
IndRegua("MCY",cMovClie,"MC_CPFCNPJ")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Tabela Mov_Forn.txt - Fornecedor            ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aMovForn,{"MF_CNPJ"   ,"C",018,0})
AADD(aMovForn,{"MF_RAZSOC" ,"C",040,0})
AADD(aMovForn,{"MF_NOMEFAN","C",030,0})
AADD(aMovForn,{"MF_INSCR"  ,"C",016,0})
AADD(aMovForn,{"MF_END"    ,"C",040,0})
AADD(aMovForn,{"MF_BAIRRO" ,"C",025,0})
AADD(aMovForn,{"MF_ESTADO" ,"C",002,0})
AADD(aMovForn,{"MF_CODMUNI","C",006,0})
AADD(aMovForn,{"MF_CEP"    ,"C",009,0})
AADD(aMovForn,{"MF_FONE"   ,"C",014,0})
AADD(aMovForn,{"MF_FAX"    ,"C",014,0})
AADD(aMovForn,{"MF_EMAIL"  ,"C",040,0})
AADD(aMovForn,{"MF_PAGINA" ,"C",050,0})
AADD(aMovForn,{"MF_CONTATO","C",020,0})
//
cMovForn := CriaTrab(aMovForn)
dbUseArea(.T.,__LocalDriver,cMovForn,"MFX")
IndRegua("MFX",cMovForn,"MF_CNPJ")

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Tabela Emp_Ref.txt - Mes/Ano Referencia     ณ
//| *******     VAI DIRETO PELO INI      ******* |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Tabela Dev_Vda.txt - Devolucao de Vendas    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aDevVda,{"DV_CODEMP" ,"C",018,0})
AADD(aDevVda,{"DV_NF"     ,"C",009,0})
AADD(aDevVda,{"DV_REFREV" ,"C",029,0})
AADD(aDevVda,{"DV_QUANT"  ,"C",009,0})
AADD(aDevVda,{"DV_CPFCNJP","C",018,0})
AADD(aDevVda,{"DV_DATADEV","C",010,0})
AADD(aDevVda,{"DV_MESANO" ,"C",006,0})
//
cDevVda := CriaTrab(aDevVda)
dbUseArea(.T.,__LocalDriver,cDevVda,"DVX")
IndRegua("DVX",cDevVda,"DV_CODEMP")
dbClearIndex()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ  Tabela Can_Vda.txt - Vendas Canceladas      |
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
AADD(aCanVda,{"CV_CODEMP" ,"C",018,0})
AADD(aCanVda,{"CV_NF"     ,"C",009,0})
AADD(aCanVda,{"CV_DATACAN","C",010,0})
AADD(aCanVda,{"CV_MESANO" ,"C",006,0})
//
cCanVda := CriaTrab(aCanVda)
dbUseArea(.T.,__LocalDriver,cCanVda,"CVX")
IndRegua("CVX",cCanVda,"CV_CODEMP")

aTrbs := {{cMovProd,"MPX"};
		 ,{cEstIni ,"EIX"};
		 ,{cMovComp,"MCX"};
		 ,{cMovVend,"MVX"};
		 ,{cMovClie,"MCY"};
		 ,{cMovForn,"MFX"};
		 ,{cDevVda ,"DVX"};
		 ,{cTabMuni,"TMX"};
		 ,{cCanVda ,"CVX"}}

Return(aTrbs)
       
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINDEAMTProcบAutor  ณMurilo Alves        บ Data ณ 09/10/2008  บฑฑ
ฑฑฬออออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCarrega as tabelas temporarias do INDEA/MT                   บฑฑ
ฑฑบ          ณ                                                             บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณINDEAMT                                                      บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function INDEAMTProc(dDtInicial,dDtFinal)

Local 	nX 			:= 0
Local	cIndea		:= ""
Local	cCNPJ		:= Replicate(" ",18)
Local	cQuery		:= ""
Local	cChave		:= ""
Local	aStruSFT	:= {}
Local	cAliasSFT	:= "SFT"
Local	cRazSocial	:= ""
Local	cNomRed		:= ""
Local	cInscr		:= ""
Local	cEnd		:= ""
Local	cBairro		:= ""
Local	cEstado		:= ""
Local	cCodMun		:= ""
Local	cCEP		:= ""
Local	cFone		:= ""
Local	cFax		:= ""
Local	cEMail		:= ""
Local	cHP			:= ""
Local	cContato	:= ""
Local	cTipo		:= ""
Local	cMun		:= ""
Local	cPerfil		:= ""
Local	cDataEntr	:= ""
Local	cCrea		:= ""
Local	cColeta		:= ""
Local	cCodigo		:= ""
Local	aSdINI		:= {}
Local	aSdATU		:= {}
Local	cCGC        := ""
Local	cIndeaB5	:= ""
Local	cIndeaA7	:= ""
Local	cIndeaA1	:= ""
Local	aIndeaB5	:= {}	//recebe ARRAY com nome dos campos do SB5 a serem criados para o INDEA/MT
Local	aIndeaA7	:= {}	//recebe ARRAY com nome dos campos do SA7 a serem criados para o INDEA/MT
Local	aIndeaA1	:= {}	//recebe ARRAY com nome dos campos do SA1 a serem criados para o INDEA/MT
Local	cReferencia	:= ""
Local	cRef		:= ""
Local	cNumReg		:= ""
Local 	lReturn := .F.

cCGC = TRANSFORM(SM0->M0_CGC,"@R 99.999.999/9999-99")

cINDEAB5 = GetNewPar ("MV_INDEAB5",'{}')
cINDEAA7 = GetNewPar ("MV_INDEAA7",'{}')
cINDEAA1 = GetNewPar ("MV_INDEAA1",'{}')

aINDEAB5 := &(cINDEAB5)
aINDEAA7 := &(cINDEAA7)
aINDEAA1 := &(cINDEAA1)

If Len(aINDEAB5) == 0
	MsgAlert("O Parโmetro MV_INDEAB5 nใo foi preenchido corretamente" + CRLF + "Para o correto processamento desta rotina, preencher este parโmetro conforme boletim t้cnico") 
	lReturn := .T.
EndIf

If Len(cINDEAA7) == 0
	MsgAlert("O Parโmetro MV_INDEAA7 nใo foi preenchido corretamente" + CRLF + "Para o correto processamento desta rotina, preencher este parโmetro confome boletim t้cnico")
	lReturn := .T.
EndIf

If Len(aINDEAA1) == 0
	MsgAlert("O Parโmetro MV_INDEAA1 nใo foi preenchido corretamente" + CRLF + "Para o correto processamento desta rotina, preencher este parโmetro confome boletim t้cnico")
	lReturn := .T.
EndIf

If !lReturn
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ  Gerar consulta das Tabelas                  |
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSelectArea("SA2")
	dbSetOrder(1)
	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSelectArea("SB5")
	dbSetOrder(1)
	dbSelectArea("SFT")			
	dbSetOrder(1)
	
	#IFDEF TOP
		If TcSrvType()<>"AS/400"
		    lQuery := .T.
			cAliasSFT := "INDEA"
			aStruSFT  := SFT->(dbStruct())
	
			cQuery := "SELECT *"
			cQuery += "FROM "+RetSqlName("SFT")+" "
			cQuery += "WHERE "
			cQuery += "FT_FILIAL='"+xFilial("SFT")+"' AND "
			cQuery += "FT_ENTRADA>='"+Dtos(dDtInicial)+"' AND "
			cQuery += "FT_ENTRADA<='"+Dtos(dDtFinal)+"' AND "
			cQuery += "FT_TIPO <> 'B' AND "
			cQuery += "D_E_L_E_T_ = ' ' "
			cQuery += "ORDER BY "+SqlOrder(SFT->(IndexKey()))
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFT)
			
		    //Tratamento para tipo de Campos diferentes de 'Caracter'(C). Ex: tipo 'DATA'(D)
			For nX := 1 To len(aStruSFT)
				If aStruSFT[nX][2] <> "C" .And. FieldPos(aStruSFT[nX][1])<>0
					TcSetField(cAliasSFT,aStruSFT[nX][1],aStruSFT[nX][2],aStruSFT[nX][3],aStruSFT[nX][4])
				EndIf
			Next nX
			
			dbSelectArea(cAliasSFT)
			
		EndIf
	#ELSE  
			cIndex    := CriaTrab(NIL,.F.)
			cCondicao := 'FT_FILIAL=="'+xFilial("SFT")+'" '
			cCondicao += '.And. DTOS(FT_ENTRADA) >= "'+ DTOS(dDtInicial) +'" '
			cCondicao += '.And. DTOS(FT_ENTRADA) <= "'+ DTOS(dDtFinal) +'" '
			cCondicao += ".And. FT_TIPO <> 'B' "
		    IndRegua(cAliasSFT,cIndex,SFT->(IndexKey()),,cCondicao)
		    nIndex := RetIndex(cAliasSFT)
			dbSetIndex(cIndex+OrdBagExt())
		    dbSelectArea(cAliasSFT)
		    dbSetOrder(nIndex+1)
		    dbGoTop()
	#ENDIF
	          
	//INSERE INFORMACOES NAS TABELAS CRIADAS
	Do While (cAliasSFT)->(!Eof())
	    
	 	If ((cAliasSFT)->FT_TIPOMOV == "E" .And. (cAliasSFT)->FT_TIPO == "D") .Or.;
		 	((cAliasSFT)->FT_TIPOMOV == "S" .And. !(cAliasSFT)->FT_TIPO == "D")
	 		If SA1->(dbSeek(xFilial("SA1")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
		 		cCNPJ 		:= 	IIF(!EMPTY(SA1->A1_CGC),IIF(LEN(ALLTRIM(SA1->A1_CGC))<=9,TRANSFORM(ALLTRIM(SA1->A1_CGC),"@R 99.999.999-99"),IIF(LEN(ALLTRIM(SA1->A1_CGC))>11,TRANSFORM(SA1->A1_CGC,"@R 99.999.999/9999-99"),TRANSFORM(ALLTRIM(SA1->A1_CGC),"@R 999.999.999-99"))),"")
				cRazSocial	:= 	SA1->A1_NOME
				cNomRed		:= 	SA1->A1_NREDUZ
				cInscr		:= 	SA1->A1_INSCR
				cEnd		:= 	SA1->A1_END
				cBairro		:= 	SA1->A1_BAIRRO
				cEstado		:= 	SA1->A1_EST
				cCodMun		:= 	IIF(!Empty(SA1->A1_COD_MUN),RetCodUF(SA1->A1_EST)+SUBSTR(SA1->A1_COD_MUN,1,4),"")
				cCEP		:=  IIF(!EMPTY(SA1->A1_CEP),TRANSFORM(SA1->A1_CEP,"@R 99999-999"),"")
				cFone		:= 	IIF(!EMPTY(SA1->A1_TEL),TRANSFORM(SA1->A1_DDD,"@R (999)")+TRANSFORM(SA1->A1_TEL,"@R 9999-9999"),"")
				cFax		:= 	IIF(!EMPTY(SA1->A1_FAX),TRANSFORM(SA1->A1_DDD,"@R (999)")+TRANSFORM(SA1->A1_FAX,"@R 9999-9999"),"")			
				cEMail		:= 	SUBSTR(SA1->A1_EMAIL,1,40)
				cHP			:= 	SUBSTR(SA1->A1_HPAGE,1,50)
				cContato	:= 	SUBSTR(SA1->A1_CONTATO,1,20)
				cTipo		:=	IIF(SA1->A1_PESSOA$"F","1","2")
				cMun		:=	SA1->A1_MUN
				cPerfil		:=	IIF(SA1->A1_TIPO$"F","0",Iif(SA1->A1_TIPO$"R","1",""))
				cDataEntr	:=	STRZERO(DAY((cAliasSFT)->FT_ENTRADA),2) + "/" + STRZERO(MONTH((cAliasSFT)->FT_ENTRADA),2) + "/" + STR(YEAR((cAliasSFT)->FT_ENTRADA),4)
				cCrea		:=	IIF(SA1->(FieldPos(aINDEAA1[1]))>0,SA1->&(aINDEAA1[1]),"")
				cColeta		:=	IIF(SA1->(FieldPos(aINDEAA1[2]))>0,SA1->&(aINDEAA1[2]),"")
				cCodigo		:=	""
	 		EndIf
		EndIf
		
	 	If ((cAliasSFT)->FT_TIPOMOV == "E" .And. !(cAliasSFT)->FT_TIPO == "D") .Or.;
		 	((cAliasSFT)->FT_TIPOMOV == "S" .And. (cAliasSFT)->FT_TIPO == "D")
	 		If SA2->(dbSeek(xFilial("SA2")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA))
		 		cCNPJ 		:= 	IIF(!EMPTY(SA2->A2_CGC),IIF(LEN(ALLTRIM(SA2->A2_CGC))<=9,TRANSFORM(ALLTRIM(SA2->A2_CGC),"@R 99.999.999-99"),IIF(LEN(ALLTRIM(SA2->A2_CGC))>11,TRANSFORM(SA2->A2_CGC,"@R 99.999.999/9999-99"),TRANSFORM(ALLTRIM(SA2->A2_CGC),"@R 999.999.999-99"))),"")
				cRazSocial	:= 	SA2->A2_NOME
				cNomRed		:= 	SA2->A2_NREDUZ
				cInscr		:= 	SA2->A2_INSCR
				cEnd		:= 	SA2->A2_END
				cBairro		:= 	SA2->A2_BAIRRO
				cEstado		:= 	SA2->A2_EST
				cCodMun		:= 	IIF(!Empty(SA2->A2_COD_MUN),RetCodUF(SA2->A2_EST)+SUBSTR(SA2->A2_COD_MUN,1,4),"")
				cCEP		:=  IIF(!EMPTY(SA2->A2_CEP),TRANSFORM(SA2->A2_CEP,"@R 99999-999"),"")
				cFone		:= 	IIF(!EMPTY(SA2->A2_TEL),TRANSFORM(SA2->A2_DDD,"@R (999)")+TRANSFORM(SA2->A2_TEL,"@R 9999-9999"),"")
				cFax		:= 	IIF(!EMPTY(SA2->A2_FAX),TRANSFORM(SA2->A2_DDD,"@R (999)")+TRANSFORM(SA2->A2_FAX,"@R 9999-9999"),"")
				cEMail		:= 	SUBSTR(SA2->A2_EMAIL,1,40)
				cHP			:= 	SUBSTR(SA2->A2_HPAGE,1,50)
				cContato	:= 	SUBSTR(SA2->A2_CONTATO,1,20)
				cTipo		:= 	IIF(SA2->A2_TIPO$"F","1",IIF(SA2->A2_TIPO$"J","2","0"))
				cMun		:=	SA2->A2_MUN
				cPerfil		:=	""
				cDataEntr	:=	STRZERO(DAY((cAliasSFT)->FT_ENTRADA),2) + "/" + STRZERO(MONTH((cAliasSFT)->FT_ENTRADA),2) + "/" + STR(YEAR((cAliasSFT)->FT_ENTRADA),4)
				cCrea		:=	""
				cColeta		:=	0
				cCodigo		:=	(cAliasSFT)->FT_CLIEFOR
	 		EndIf
	 	EndIf
	 	
		If !TMX->(MsSeek(cCodMun))
			RecLock("TMX",.T.)
			TMX->TM_CODIGO	:=	IIF(!EMPTY(cCodMun),cCodMun,"000000")
			TMX->TM_NOME	:=	cMun
			TMX->TM_ESTADO	:=	cEstado
			MsUnLock()
		EndIf
	    						
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณTratamento Cabecalhos ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		IF (cAliasSFT)->FT_TIPO == "D"		
			If SB5->(dbSeek(xFilial("SB5")+(cAliasSFT)->FT_PRODUTO))
				SB1->(dbSeek(xFilial("SB1")+(cAliasSFT)->FT_PRODUTO))
				cReferencia := ""
				cReferencia :=	IIF(SB5->(FieldPos(aINDEAB5[1]))>0,ALLTRIM(SB5->&(aINDEAB5[1])),"") + "-"
				cReferencia +=	IIF(SB5->(FieldPos(aINDEAB5[2]))>0,SB5->&(aINDEAB5[2]),"") + "-"
				cReferencia +=	IIF(SB5->(FieldPos(aINDEAB5[3]))>0,ALLTRIM(REPLACE(TRANSFORM(SB5->&(aINDEAB5[3]),"@R 99999.999"),".",",")),"") + "-"
				cReferencia +=	ALLTRIM(SB1->B1_UM) + "-"
				cReferencia +=	IIF(SB5->(FieldPos(aINDEAB5[4]))>0,SB5->&(aINDEAB5[4]),"")
	 		EndIf
	
			//Dev_VDA.txt - Devolucao de Vendas
			RecLock("DVX",.T.)
			DVX->DV_CODEMP  := cCGC
			DVX->DV_NF      := (cAliasSFT)->FT_NFISCAL
			DVX->DV_REFREV  := cReferencia
			DVX->DV_QUANT   := STRZERO((cAliasSFT)->FT_QUANT,9)
			DVX->DV_CPFCNJP := cCNPJ
			
			IIF(!EMPTY(SA1->A1_CGC),IIF(LEN(ALLTRIM(SA1->A1_CGC))<=9,TRANSFORM(ALLTRIM(SA1->A1_CGC),"@R 99.999.999-99"),IIF(LEN(ALLTRIM(SA1->A1_CGC))>11,TRANSFORM(SA1->A1_CGC,"@R 99.999.999/9999-99"),TRANSFORM(ALLTRIM(SA1->A1_CGC),"@R 999.999.999-99"))),"")
			
			DVX->DV_DATADEV := cDataEntr
			DVX->DV_MESANO  := STRZERO(Month((cAliasSFT)->FT_ENTRADA),2) + STR(Year((cAliasSFT)->FT_ENTRADA),4)
			MsUnLock()
			
			(cAliasSFT)->(DbSkip ())
			Loop
		ElseIf !Empty((cAliasSFT)->FT_DTCANC)
	        //Can_Vda.txt - Vendas Canceladas
		 	RecLock("CVX",.T.)
			CVX->CV_CODEMP	 := cCGC
			CVX->CV_NF		 := (cAliasSFT)->FT_NFISCAL
			CVX->CV_DATACAN  := IIF(EMPTY((cAliasSFT)->FT_DTCANC),"",STRZERO(DAY((cAliasSFT)->FT_DTCANC),2) + "/" + STRZERO(MONTH((cAliasSFT)->FT_DTCANC),2) + "/" + STR(YEAR((cAliasSFT)->FT_DTCANC),4))
			CVX->CV_MESANO   := STRZERO(Month((cAliasSFT)->FT_ENTRADA),2) + STR(Year((cAliasSFT)->FT_ENTRADA),4)
		    MsUnLock()
		    
		    (cAliasSFT)->(DbSkip ())
		    Loop
		EndIf
		
		If	(((cAliasSFT)->FT_TIPOMOV == "E" .And. !(cAliasSFT)->FT_TIPO == "D") .Or.;
		 	((cAliasSFT)->FT_TIPOMOV == "S" .And. (cAliasSFT)->FT_TIPO == "D")) .And.;
		 	SA2->(dbSeek(xFilial("SA2")+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA)) .And.;
		 	!Empty(cCodigo)
		 	
			If	!MFX->(dbSeek(cCNPJ))
				//Mov_Forn.txt - Fornecedores da Revenda
				RecLock("MFX",.T.)
				MFX->MF_CNPJ     := cCNPJ
				MFX->MF_RAZSOC   := cRazSocial
				MFX->MF_NOMEFAN  := cNomRed
				MFX->MF_INSCR    := cInscr
				MFX->MF_END      := cEnd
				MFX->MF_BAIRRO   := cBairro
				MFX->MF_ESTADO   := cEstado
				MFX->MF_CODMUNI  := cCodMun
				MFX->MF_CEP      := cCEP
				MFX->MF_FONE     := cFone
				MFX->MF_FAX      := cFax
				MFX->MF_EMAIL    := cEMail
				MFX->MF_PAGINA   := cHP
				MFX->MF_CONTATO  := cContato
				MsUnLock()
			Endif
		Else
			If !MCY->(dbSeek(cCNPJ)) .And. cCodigo = ""
				If AllTrim(cCrea) <> "" .and. cColeta <> 0
					//Mov_Clie.txt - Clientes da Revenda	
					RecLock("MCY",.T.)
					MCY->MC_TIPO     	:= 	cTipo
					MCY->MC_CPFCNPJ 	:=	cCNPJ
					MCY->MC_NOMECLI 	:=	cRazSocial
					MCY->MC_END     	:=	cEnd
					MCY->MC_BAIRRO  	:=	cBairro
					MCY->MC_ESTADO  	:=	cEstado
					MCY->MC_CODMUNI 	:=	cCodMun
					MCY->MC_CEP	    	:=	cCEP
					MCY->MC_FONE		:=	cFone
					MCY->MC_PROPR   	:=	"" //?
					MCY->MC_EMAIL		:=	cEMail
					MCY->MC_PERFIL		:=	cPerfil
					MsUnLock()
				Endif
			EndIf
		EndIf 
		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณTratamento Item a Itemณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู         
		cChave	:=	(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
		Do While !(cAliasSFT)->(Eof ()) .And.;
			cChave==(cAliasSFT)->FT_FILIAL+(cAliasSFT)->FT_TIPOMOV+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA
			
	        If (cAliasSFT)->FT_TIPOMOV == "E"
				
	            If SB5->(dbSeek(xFilial("SB5")+(cAliasSFT)->FT_PRODUTO))
	            	SB1->(dbSeek(xFilial("SB1")+(cAliasSFT)->FT_PRODUTO))
	            	
	            	If !(cAliasSFT)->FT_QUANT == 0
	            	
						//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
						//ณApenas criar quando o produto tiver complementoณ
						//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
						cRef := ""
	       				cRef :=	IIF(SB5->(FieldPos(aINDEAB5[1]))>0,ALLTRIM(SB5->&(aINDEAB5[1])),"") + "-"
						cRef +=	IIF(SB5->(FieldPos(aINDEAB5[2]))>0,SB5->&(aINDEAB5[2]),"") + "-"
						cRef +=	IIF(SB5->(FieldPos(aINDEAB5[3]))>0,ALLTRIM(REPLACE(TRANSFORM(SB5->&(aINDEAB5[3]),"@R 99999.999"),".",",")),"") + "-"
						cRef +=	ALLTRIM(SB1->B1_UM) + "-"
						cRef +=	IIF(SB5->(FieldPos(aINDEAB5[4]))>0,SB5->&(aINDEAB5[4]),"")
					    
						If MCX->(MsSeek(cCGC+;
						    ALLTRIM(cCNPJ)+replicate(" ",18-len(ALLTRIM(cCNPJ)))+;
						    ALLTRIM((cAliasSFT)->FT_NFISCAL)+replicate(" ",9-Len(ALLTRIM((cAliasSFT)->FT_NFISCAL)))+;
						    ALLTRIM(cRef)+replicate(" ",29-len(ALLTRIM(cRef))))) 
						    
					 		RecLock("MCX",.F.)
			 			Else
			 				SB1->(dbSeek(xFilial("SB1")+(cAliasSFT)->FT_PRODUTO))
			 				
			 			    cReferencia := ""
		        			cReferencia :=	IIF(SB5->(FieldPos(aINDEAB5[1]))>0,ALLTRIM(SB5->&(aINDEAB5[1])),"") + "-"
							cReferencia +=	IIF(SB5->(FieldPos(aINDEAB5[2]))>0,SB5->&(aINDEAB5[2]),"") + "-"
							cReferencia +=	IIF(SB5->(FieldPos(aINDEAB5[3]))>0,ALLTRIM(REPLACE(TRANSFORM(SB5->&(aINDEAB5[3]),"@R 99999.999"),".",",")),"") + "-"
							cReferencia +=	ALLTRIM(SB1->B1_UM) + "-"
							cReferencia +=	IIF(SB5->(FieldPos(aINDEAB5[4]))>0,SB5->&(aINDEAB5[4]),"")
							
					 		RecLock("MCX",.T.)
							MCX->MC_CODEMP	:= alltrim(cCGC)
							MCX->MC_CNPJ	:= alltrim(cCNPJ)
							MCX->MC_NF		:= (cAliasSFT)->FT_NFISCAL
							MCX->MC_REFREV	:= alltrim(cReferencia)
							MCX->MC_DATA	:= cDataEntr
							MCX->MC_MESANO	:= STRZERO(Month((cAliasSFT)->FT_ENTRADA),2) + STR(Year((cAliasSFT)->FT_ENTRADA),4)			
						EndIf
					EndIf
					MCX->MC_QUANT	+= (cAliasSFT)->FT_QUANT / SB5->&(aINDEAB5[3])
					MsUnLock()
				EndIf
		 	Else
		 		//Mov_Vend.txt - Movimento de Vendas
		 		If SB5->(dbSeek(xFilial("SB5")+(cAliasSFT)->FT_PRODUTO))          
		 		    SB1->(dbSeek(xFilial("SB1")+(cAliasSFT)->FT_PRODUTO))
		 		    
		 		    If !(cAliasSFT)->FT_QUANT == 0
		 		        
						cRef := ""
						cRef :=	IIF(SB5->(FieldPos(aINDEAB5[1]))>0,ALLTRIM(SB5->&(aINDEAB5[1])),"") + "-"
						cRef +=	IIF(SB5->(FieldPos(aINDEAB5[2]))>0,SB5->&(aINDEAB5[2]),"") + "-"
						cRef +=	IIF(SB5->(FieldPos(aINDEAB5[3]))>0,ALLTRIM(REPLACE(TRANSFORM(SB5->&(aINDEAB5[3]),"@R 99999.999"),".",",")),"") + "-"
						cRef +=	ALLTRIM(SB1->B1_UM) + "-"
						cRef +=	IIF(SB5->(FieldPos(aINDEAB5[4]))>0,SB5->&(aINDEAB5[4]),"")
	     				
						If MVX->(MsSeek(cCGC+;
							ALLTRIM((cAliasSFT)->FT_NFISCAL)+replicate(" ",9-Len(ALLTRIM((cAliasSFT)->FT_NFISCAL)))+;
							ALLTRIM(cCNPJ)+replicate(" ",18-len(ALLTRIM(cCNPJ)))+;
							ALLTRIM(cRef)+replicate(" ",29-len(ALLTRIM(cRef)))))
							
							RecLock("MVX",.F.)
						Else
							SB1->(dbSeek(xFilial("SB1")+(cAliasSFT)->FT_PRODUTO))
							
							cReferencia := ""
							cReferencia :=	IIF(SB5->(FieldPos(aINDEAB5[1]))>0,ALLTRIM(SB5->&(aINDEAB5[1])),"") + "-"
							cReferencia +=	IIF(SB5->(FieldPos(aINDEAB5[2]))>0,SB5->&(aINDEAB5[2]),"") + "-"
							cReferencia +=	IIF(SB5->(FieldPos(aINDEAB5[3]))>0,ALLTRIM(REPLACE(TRANSFORM(SB5->&(aINDEAB5[3]),"@R 99999.999"),".",",")),"") + "-"
							cReferencia +=	ALLTRIM(SB1->B1_UM) + "-"
							cReferencia +=	IIF(SB5->(FieldPos(aINDEAB5[4]))>0,SB5->&(aINDEAB5[4]),"")
					 		
						 	RecLock("MVX",.T.)
							MVX->MV_CODEMP   := alltrim(cCGC)
							MVX->MV_NF       := (cAliasSFT)->FT_NFISCAL
							MVX->MV_REFREV   := alltrim(cReferencia)
							MVX->MV_DATA     := cDataEntr
							MVX->MV_CULT     := IIF(SB5->(FieldPos(aINDEAB5[5]))>0,SB5->&(aINDEAB5[5]),0)
							MVX->MV_APLIC    := IIF(SB5->(FieldPos(aINDEAB5[6]))>0,SB5->&(aINDEAB5[6]),0)
							MVX->MV_CPFCNPJ  := alltrim(cCNPJ)
							MVX->MV_ART      := "ART"
							MVX->MV_RECEITA  := "RECEITA"
							MVX->MV_CREA     := IIF(SA1->(FieldPos(aINDEAA1[1]))>0,SA1->&(aINDEAA1[1]),"CREA")
							MVX->MV_DOSAGEM  := ALLTRIM(REPLACE(STR(IIF(SA7->(FieldPos(aINDEAA7[1]))>0,SA7->&(aINDEAA7[1]),0)),'.',',')) //IIF(SA7->(FieldPos(aINDEAA7[1]))>0,SA7->&(aINDEAA7[1]),0)
							MVX->MV_AREA     := ALLTRIM(STR(IIF(SA7->(FieldPos(aINDEAA7[2]))>0,SA7->&(aINDEAA7[2]),0))) //IIF(SA7->(FieldPos(aINDEAA7[2]))>0,SA7->&(aINDEAA7[2]),0)
							MVX->MV_MESANO   := STRZERO(Month((cAliasSFT)->FT_ENTRADA),2) + STR(Year((cAliasSFT)->FT_ENTRADA),4)
							MVX->MV_CODCOLE  := IIF(SA1->(FieldPos(aINDEAA1[2]))>0,SA1->&(aINDEAA1[2]),9999)
							MVX->MV_CODPRAG  := IIF(SB5->(FieldPos(aINDEAB5[7]))>0,SB5->&(aINDEAB5[7]),9999)
						EndIf
					EndIf
					MVX->MV_QUANT += (cAliasSFT)->FT_QUANT / SB5->&(aINDEAB5[3])
					MsUnLock()
				EndIf
		 	EndIf
		 	
			SB5->(dbSeek(xFilial("SB5")+(cAliasSFT)->FT_PRODUTO))
			
			cNumReg := IIF(SB5->(FieldPos(aINDEAB5[1]))>0,SB5->&(aINDEAB5[1]),"")
			
			SB1->(DbGoTop())
			
			If SB5->(dbSeek(xFilial("SB5")+(cAliasSFT)->FT_PRODUTO))
			
				If !MPX->(dbSeek(cCGC+cNumReg))
				 	SB1->(dbSeek(xFilial("SB1")+(cAliasSFT)->FT_PRODUTO))
				 			 	
					If !MPX->(MsSeek(SM0->M0_CGC+cNumReg))
					
						aSdINI := CALCEST(SB1->B1_COD,SB1->B1_LOCPAD,_aTotal[01])
						aSdATU := CALCEST(SB1->B1_COD,SB1->B1_LOCPAD,_aTotal[02])
					 	
					 	cReferencia := ""
	        			cReferencia :=	IIF(SB5->(FieldPos(aINDEAB5[1]))>0,ALLTRIM(SB5->&(aINDEAB5[1])),"") + "-"
						cReferencia +=	IIF(SB5->(FieldPos(aINDEAB5[2]))>0,SB5->&(aINDEAB5[2]),"") + "-"
						cReferencia +=	IIF(SB5->(FieldPos(aINDEAB5[3]))>0,ALLTRIM(REPLACE(TRANSFORM(SB5->&(aINDEAB5[3]),"@R 99999.999"),".",",")),"") + "-"
						cReferencia +=	ALLTRIM(SB1->B1_UM) + "-"
						cReferencia +=	IIF(SB5->(FieldPos(aINDEAB5[4]))>0,SB5->&(aINDEAB5[4]),"")
			 		
				 		//Mov_Prod.txt - Cadastro de Produtos
					 	RecLock("MPX",.T.)
						MPX->MP_CODEMP   := cCGC
						MPX->MP_NUMREG   := IIF(SB5->(FieldPos(aINDEAB5[1]))>0,ALLTRIM(SB5->&(aINDEAB5[1])),"")
						MPX->MP_NOMECOM  := ALLTRIM(SUBSTR(SB1->B1_DESC,1,35))
						MPX->MP_SGEMB    := IIF(SB5->(FieldPos(aINDEAB5[2]))>0,SB5->&(aINDEAB5[2]),"")
						MPX->MP_TIPOEMB  := IIF(SB5->(FieldPos(aINDEAB5[4]))>0,SB5->&(aINDEAB5[4]),"")
						MPX->MP_VOLUME   := IIF(SB5->(FieldPos(aINDEAB5[3]))>0,SB5->&(aINDEAB5[3]),0)
						MPX->MP_SGUNID   := ALLTRIM(SB1->B1_UM)
						MPX->MP_REFREV   := ALLTRIM(cReferencia)
						MPX->MP_DATA     := STRZERO(DAY(SB1->B1_DATREF),2) + "/" + STRZERO(MONTH(SB1->B1_DATREF),2) + "/" + STR(YEAR(SB1->B1_DATREF),4)
						MPX->MP_SDINI    := STRZERO(aSdINI[1],9)
						MPX->MP_SDFIN    := STRZERO(aSdATU[1],9)
						MsUnlock()
						
						//Est_Ini.txt - Estoque Inicial
						RecLock("EIX",.T.)
						EIX->EI_CODEMP   := cCGC
						EIX->EI_REFREV   := ALLTRIM(cReferencia)
						EIX->EI_NOMECOM  := ALLTRIM(SUBSTR(SB1->B1_DESC,1,35))
						EIX->EI_SDINI    := STRZERO(aSdINI[1],9)
						EIX->EI_DATA     := STRZERO(DAY(SB1->B1_DATREF),2) + "/" + STRZERO(MONTH(SB1->B1_DATREF),2) + "/" + STR(YEAR(SB1->B1_DATREF),4)
						MsUnlock()
					EndIf
				EndIf
			EndIf
			
			(cAliasSFT)->(DbSkip())
		EndDo
		
	EndDo
EndIf
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao   ณINDEAMTDel บ Autor ณ Murilo Alves       บ Data ณ 09/10/2008  บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณ Apaga arquivos temporarios criados para gerar o arquivo     บฑฑ
ฑฑบ         ณ Magnetico                                                   บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ INDEAMT                                                     บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function INDEAMTDel(aDelArqs)

	Local aAreaDel 	:= GetArea()
	Local nI 		:= 0
	
	For nI:= 1 To Len(aDelArqs)
		If File(aDelArqs[ni,1]+GetDBExtension())
			dbSelectArea(aDelArqs[ni,2])
			dbCloseArea()
			Ferase(aDelArqs[ni,1]+GetDBExtension())
			Ferase(aDelArqs[ni,1]+OrdBagExt())
		Endif	
	Next
	
	RestArea(aAreaDel)
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษอออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuncao   ณ RetCodUF  บ Autor ณ Murilo Alves       บ Data ณ 15/10/2008  บฑฑ
ฑฑฬอออออออออุอออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.    ณ Apaga arquivos temporarios criados para gerar o arquivo     บฑฑ
ฑฑบ         ณ Magnetico                                                   บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso      ณ INDEAMT                                                     บฑฑ
ฑฑฬอออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParam.   ณ ExpC1: Codigo do Estado ou UF                               บฑฑ
ฑฑบ         ณ ExpC2: lForceUf                                             บฑฑ
ฑฑศอออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RetCodUF(cUF,lForceUF)

Local nX         := 0
Local cRetorno   := ""
Local aUF        := {}
DEFAULT lForceUF := .F.

aadd(aUF,{"RO","11"})
aadd(aUF,{"AC","12"})
aadd(aUF,{"AM","13"})
aadd(aUF,{"RR","14"})
aadd(aUF,{"PA","15"})
aadd(aUF,{"AP","16"})
aadd(aUF,{"TO","17"})
aadd(aUF,{"MA","21"})
aadd(aUF,{"PI","22"})
aadd(aUF,{"CE","23"})
aadd(aUF,{"RN","24"})
aadd(aUF,{"PB","25"})
aadd(aUF,{"PE","26"})
aadd(aUF,{"AL","27"})
aadd(aUF,{"SE","28"})
aadd(aUF,{"BA","29"})
aadd(aUF,{"MG","31"})
aadd(aUF,{"ES","32"})
aadd(aUF,{"RJ","33"})
aadd(aUF,{"SP","35"})
aadd(aUF,{"PR","41"})
aadd(aUF,{"SC","42"})
aadd(aUF,{"RS","43"})
aadd(aUF,{"MS","50"})
aadd(aUF,{"MT","51"})
aadd(aUF,{"GO","52"})
aadd(aUF,{"DF","53"})

If !Empty(cUF)
	nX := aScan(aUF,{|x| x[1] == cUF})
	If nX == 0
		nX := aScan(aUF,{|x| x[2] == cUF})
		If nX <> 0
			cRetorno := aUF[nX][1]
		EndIf
	Else
		cRetorno := aUF[nX][IIF(lForceUF,1,2)]
	EndIf
Else
	cRetorno := aUF
EndIf
Return(cRetorno)
