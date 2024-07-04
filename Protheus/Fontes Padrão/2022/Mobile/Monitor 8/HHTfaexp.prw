/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±±      			  TFA - Technical Force Automation        			  ±±±
±±±								Versao eADVPL							  ±±±	
±±±         		     Microsiga Software - S/A             			  ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PTecnico  ºAutor  ³Cleber Martinez     º Data ³  03/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Arquivo espelho do Tecnico                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integracao Palm                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function PTecnico()

Local aTecnico 	  := {}  // Contem os dados do arquivo de tecnicos
Local cFileTec 	  := "AA1" + cEmpAnt + "0"
Local cFileEmp    :="HEMP"
Local aEmp        := {}, i:=1
Local nRecnoSM0   := SM0->(Recno())

cTecnico := PALMUSER->P_CODVEND //Cod. do vendedor (arq. PALMUSER)

aadd(aEmp,{"EMP_COD"     , "C",  2, 0}) // Codigo da Empresa
aadd(aEmp,{"EMP_FILIAL"  , "C",  2, 0}) // Codigo da Filial
aadd(aEmp,{"EMP_NOME"    , "C", 15, 0}) // Nome
aadd(aEmp,{"EMP_NOMCOM"  , "C", 40, 0}) // Nome Comercial
aadd(aEmp,{"EMP_ENDCOB"  , "C", 30, 0}) // Endereco de Cobranca
aadd(aEmp,{"EMP_BAICOB"  , "C", 20, 0}) // Bairro de Cobranca
aadd(aEmp,{"EMP_CIDCOB"  , "C", 20, 0}) // Cidade de Cobranca
aadd(aEmp,{"EMP_ESTCOB"  , "C",  2, 0}) // Estado de Cobranca
aadd(aEmp,{"EMP_CEPCOB"  , "C",  8, 0}) // CEP de Cobranca
aadd(aEmp,{"EMP_CGC"     , "C", 14, 0}) // CGC da Empresa
aadd(aEmp,{"EMP_INSC"    , "C", 14, 0}) // Inscricao
aadd(aEmp,{"EMP_TEL"     , "C", 14, 0}) // Telefone da Empresa      

//Preenche o array com os campos a serem enviados
aadd(aTecnico,{"AA1_CODTEC", "C",    6, 0}) // Codigo do Tecnico
aadd(aTecnico,{"AA1_NOMTEC", "C",   30, 0}) // Nome do Tecnico	
aadd(aTecnico,{"AA1_SENHA",  "C",    4, 0}) // Senha do Tecnico (?)
aadd(aTecnico,{"AA1_PROXOS", "C",    6, 0}) // Prox. OS do tecnico

//PAcertaSx3(@aTecnico)

ConOut("PALMJOB: Criando arquivo de Tecnico (AA1"+cEmpAnt+"0"+") para " + Trim(PALMUSER->P_USER) + " - " + Time())
PalmCreate(aTecnico, cFileTec,"TEC")
PalmCreate(aEmp    , cFileEmp,"HEMP")

dbSelectArea("AA1")
dbSeek(xFilial("AA1"))
While !Eof() .And. AA1_FILIAL == xFilial("AA1") //.And.
	If AA1->AA1_CODTEC == cTecnico
		dbSelectArea("TEC")
		RecLock("TEC",.T.)
		For i:=1 to Len(aTecnico)
			SX3->( dbSetorder(2) )
	    	If SX3->( dbSeek( aTecnico[i,1] ) ) 
 		    	Replace &(aTecnico[i,1]) With &("AA1->" + aTecnico[i,1])
 			Else 
 				ConOut( "Alerta! Crie o campo " + aTecnico[i,1]+" "+aTecnico[i,2]+"("+ StrZero(aTecnico[i,3],2)+ ") pelo configurador..." )
 		    Endif  
		Next
		MsUnlock()
	EndIf
	dbSelectArea("AA1")
	dbSkip()
EndDo

//Grava arquivo de Empresas
dbSelectArea("SM0")
dbSetOrder(1)
If dbSeek(PALMSERV->P_EMPFI)
	RecLock("HEMP", .T.)
	HEMP->EMP_COD     := SM0->M0_CODIGO
	HEMP->EMP_FILIAL  := SM0->M0_CODFIL
	HEMP->EMP_NOME    := SM0->M0_NOME
	HEMP->EMP_NOMCOM  := SM0->M0_NOMECOM
	HEMP->EMP_ENDCOB  := SM0->M0_ENDCOB
	HEMP->EMP_BAICOB  := SM0->M0_BAIRCOB
	HEMP->EMP_CIDCOB  := SM0->M0_CIDCOB
	HEMP->EMP_ESTCOB  := SM0->M0_ESTCOB
	HEMP->EMP_CEPCOB  := SM0->M0_CEPCOB
	HEMP->EMP_CGC     := SM0->M0_CGC
	HEMP->EMP_INSC    := SM0->M0_INSC
	HEMP->EMP_TEL     := SM0->M0_TEL
	HEMP->(MsUnlock())
EndIf

TEC->(dbCloseArea())
HEMP->(dbCloseArea())

Return

//retorna alias usado pelo servico
Function PTecTab( )
Return {"AA1"}

//retorna nome fisico do arquivo espelho
Function PTecArq( )
Local cFileTec := "AA1" + Left(PALMSERV->P_EMPFI,2) + "0"
Return {cFileTec,"HEMP"}

//retorna indice usado pelo arquivo espelho
Function PTecInd()
Return {"AA1_CODTEC","EMP_COD+EMP_FILIAL"}


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PFabric  ³ Autor ³ Cleber Martinez       ³ Data ³ 03/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho dos Clientes                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PFabric()

Local aCliente  := {}  // Contem os dados do arquivo de CLIENTES
Local aFabric   := {} // Contem os dados do arquivo de FABRICANTES
Local i			:= 0
Local ind		:= 0
Local cFileCli	:= "SA1" + cEmpAnt + "0"
Local cFileFab  := "SA2" + cEmpAnt + "0"
Local cFiltro	:= ""

//Preenche o array com os campos do cliente a serem enviados
aadd(aCliente,{"A1_COD",     "C", 06, 0})  // Nome do Cliente
aadd(aCliente,{"A1_LOJA",    "C", 02, 0})  // Loja do Cliente
aadd(aCliente,{"A1_NOME",    "C", 40, 0})  // Nome do Cliente/Empresa
aadd(aCliente,{"A1_END",     "C", 40, 0})  // Endereco do Cliente
aadd(aCliente,{"A1_CONTATO", "C", 40, 0})  // Contato no Cliente
aadd(aCliente,{"A1_TEL",     "C", 15, 0})  // Telefone do Cliente
aadd(aCliente,{"A1_TMPSTD",  "C",  5, 0})  // Tempo de translado padrao
//PAcertaSx3(@aCliente)

//Arquivo de Fabricantes
aadd(aFabric,{"A2_COD",       "C", 06, 0}) 
aadd(aFabric,{"A2_LOJA",      "C", 02, 0}) 
aadd(aFabric,{"A2_NREDUZ",    "C", 20, 0})
//PAcertaSx3(@aFabric)                    

ConOut("PALMJOB: Criando arquivos de Cliente/Fabricantes para " + Trim(PALMUSER->P_USER))

PalmCreate(aCliente,  cFileCli, "CLI") 
PalmCreate(aFabric,   cFileFab, "FAB") 

//Grava arquivo temporario de Clientes
dbSelectArea("SA1")
dbSetOrder(1)
If ((ExistBlock("PLMCLI01")))
	cFiltro := ExecBlock("PLMCLI01",.F.,.F.)
EndIf
If cFiltro <> ""
	Set Filter to &cFiltro
Endif
dbSeek(xFilial("SA1"))

While !Eof() .And. SA1->A1_FILIAL == xFilial("SA1")
	dbSelectArea("CLI")
	RecLock("CLI",.T.)
	For i:=1 to Len(aCliente)
		Replace &(aCliente[i,1]) With &("SA1->" + aCliente[i,1])
	Next
	MsUnlock()           
	dbSelectArea("SA1")
	dbSkip()
EndDo

//Grava arquivo temporario de Fabricantes (verificar se tem P.Entrada)
dbSelectArea("SA2")
dbSetOrder(1)
dbSeek(xFilial("SA2"))
While !Eof() .And. SA2->A2_FILIAL == xFilial("SA2")
	dbSelectArea("FAB")
	RecLock("FAB",.T.)   
	For i:=1 to Len(aFabric)
		Replace &(aFabric[i,1]) With &("SA2->" + aFabric[i,1])
	Next
	MsUnlock()
	dbSelectArea("SA2")
	dbSkip()
EndDo

CLI->(dbCloseArea())
FAB->(dbCloseArea())

Return

//retorna alias usado pelo servico
Function PFabTab( )	
Return {"SA1", "SA2"}

//retorna nome fisico do arquivo espelho
Function PFabArq( )
Local cFileCli := "SA1" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileFab := "SA2" + Left(PALMSERV->P_EMPFI,2) + "0"
Return {cFileCli,cFileFab}

//retorna indice usado pelo arquivo espelho
Function PFabInd( )
Return {"A1_COD+A1_LOJA", "A2_COD+A2_LOJA"}
   
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PProd    ³ Autor ³ Cleber Martinez       ³ Data ³ 10/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho dos Produtos.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/  
Function PProd()

Local aProdutos  := {}  // Contem os dados do arquivo de PRODUTOS
Local cFileProd  := "SB1"+cEmpAnt+"0"
Local cTipProd   := GetMv("MV_PLMTPPR",,"PA")//Tipos de produto a serem exportados
Local i := 0, cFiltro := ""

//Arquivo de Produtos
aadd(aProdutos,{"B1_COD",  "C", 15, 0}) // Codigo do Produto
aadd(aProdutos,{"B1_DESC", "C", 30, 0}) // Descr. do Produto (SB1->B1_DESC)
aadd(aProdutos,{"B1_TIPO", "C", 05, 0}) // Tipo do Produto
//PAcertaSx3(@aProdutos)                  

ConOut("PALMJOB: Criando arquivo de Produtos para " + Trim(PALMUSER->P_USER))

PalmCreate(aProdutos, cFileProd, "PRD")
                      
//Grava arquivo temporario de Produtos
dbSelectArea("SB1")
dbSetOrder(1)
cFiltro := "B1_TIPO $ '" + cTipProd + "'"
// Ponto de Entrada deve retornar um complemento para o Filtro
If ((ExistBlock("PLMPRD01")))
	cFiltro += ExecBlock("PLMPRD01",.F.,.F.)
EndIf
Set Filter to &cFiltro
dbSeek(xFilial("SB1"))

While !Eof() .And. SB1->B1_FILIAL == xFilial("SB1")
	dbSelectArea("PRD")
	RecLock("PRD", .T.)
	For i:=1 to Len(aProdutos)
		Replace &(aProdutos[i,1]) With &("SB1->" + aProdutos[i,1])
	Next
	MsUnlock()
	dbSelectArea("SB1")
	dbSkip()
EndDo

PRD->(dbCloseArea())
Return                               

//retorna alias usados pelo servico
Function PProTab( )	
Return {"SB1"}

//retorna nome fisico do arquivo espelho
Function PProArq( )  
Local cFileProd := "SB1" + Left(PALMSERV->P_EMPFI,2) + "0"
Return {cFileProd}

//retorna indice usado pelo arquivo espelho
Function PProInd( )
Return {"B1_COD"}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ PServico ³ Autor ³ Cleber Martinez       ³ Data ³ 03/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho dos Servicos.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PServico()

Local aServico := {}  //Contem os dados do arquivo de Servicos
Local cFileSer := "AA5"+cEmpAnt+"0"
Local i := 0

//Preenche o array com os campos a serem enviados
aadd(aServico,{"AA5_CODSER"   , "C", 06, 0}) // Codigo do Servico
aadd(aServico,{"AA5_DESCRI"   , "C", 30, 0}) // Descr. do Servico
aadd(aServico,{"AA5_TES"      , "C", 03, 0}) // TES - Tipo Ent./Saida
aadd(aServico,{"AA5_PRCCLI"   , "N", 06, 2}) // Porc. do cliente
aadd(aServico,{"AA5_PRCFAB"   , "N", 06, 2}) // Porc. do fabricante
aadd(aServico,{"AA5_ATUOS"    , "C", 01, 0}) // Atualiza OS?
aadd(aServico,{"AA5_ATUEST"   , "C", 01, 0}) // Atualiza Estoque?
aadd(aServico,{"AA5_ATUORC"   , "C", 01, 0}) // Atualiza Orcamento?
//PAcertaSx3(@aServico)                  

ConOut("PALMJOB: Criando arquivo de Servicos para " + Trim(PALMUSER->P_USER))
PalmCreate(aServico, cFileSer, "SER")

//Grava arquivo temporario de Servicos
dbSelectArea("AA5")
dbSetOrder(1)
dbGoTop()
While !Eof() .And. AA5->AA5_FILIAL == xFilial("AA5")
	dbSelectArea("SER")
	RecLock("SER",.T.)
	For i:=1 to Len(aServico)
		Replace &(aServico[i,1]) With &("AA5->" + aServico[i,1])
	Next
	MsUnlock()
	dbSelectArea("AA5")
	dbSkip()
EndDo

SER->(dbCloseArea())
Return

//retorna alias usado pelo servico
Function PSerTab( )
Return {"AA5"}

//retorna nome fisico do arquivo espelho
Function PSerArq( )
Local cFileSer := "AA5" + Left(PALMSERV->P_EMPFI,2) + "0"
Return {cFileSer}

//retorna indice usado pelo arquivo espelho
Function PSerInd( )
Return {"AA5_CODSER"}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³POcorr    ³ Autor ³ Cleber Martinez       ³ Data ³ 04/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Arquivo Espelho das Ocorrencias                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function POcorr()

Local aOcorr 		:= {}  //Contem os dados do arquivo de Ocorrencias
Local cFileOcorr	:= "AAG"+cEmpAnt+"0"
Local i := 0

//preenche o array com os campos a serem enviados
aadd(aOcorr, {"AAG_CODPRB", "C" , 06, 0})  //Codigo da Ocorrencia
aadd(aOcorr, {"AAG_DESCRI", "C" , 30, 0})  //Descr. da Ocorrencia
//PAcertaSx3(@aOcorr)                  

ConOut("PALMJOB: Criando arquivo de Ocorrencias para " + Trim(PALMUSER->P_USER))
PalmCreate(aOcorr, cFileOcorr, "OCO")

//Grava arquivo temporario de Ocorrencias
dbSelectArea("AAG")
dbSetOrder(1)
dbGoTop()
While !Eof() .And. AAG->AAG_FILIAL == xFilial("AAG")
	dbSelectArea("OCO")
	RecLock("OCO",.T.)
	For i:=1 to Len(aOcorr)
		Replace &(aOcorr[i,1]) With &("AAG->" + aOcorr[i,1])
	Next
	MsUnlock()

	dbSelectArea("AAG")
	dbSkip()
EndDo

OCO->(dbCloseArea())
Return

//retorna alias usado pelo servico
Function POcoTab( )
Return {"AAG"}

//retorna nome fisico do arquivo espelho
Function POcoArq()
Local cFileOcorr := "AAG" + Left(PALMSERV->P_EMPFI,2) + "0"
Return {cFileOcorr}

//retorna indice usado pelo arquivo espelho
Function POcoInd( )
Return {"AAG_CODPRB"}

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³POS       ³ Autor ³ Cleber Martinez       ³ Data ³ 04/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Geracao dos arquivos de Ordem de Servico                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Integracao Palm                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function POS()                                                                

Local aDatas    := {}  
Local aAgenda   := {}
Local aOS       := {}
Local aItensOS  := {}
Local aSubItens := {}
Local i         := 0
Local cFileDta  := "DTA"+cEmpAnt+"0"
Local cFileAge  := "ABB"+cEmpAnt+"0"
Local cFileOS   := "AB6"+cEmpAnt+"0"
Local cFileItOS := "AB7"+cEmpAnt+"0"
Local cFileSub  := "AB8"+cEmpAnt+"0"
Local cNumos    := ""
Local cUltima   := ""
Local lContinua := .f.
cTecnico := PALMUSER->P_CODVEND
cStatAgenda := "OS INCLUIDA EM CAMPO" //variav. usada para diferenciar as OS

//Preenche o array com os campos a serem enviados
aadd(aAgenda,{"ABB_CODTEC", "C",  6, 0}) // Codigo do tecnico
//aadd(aAgenda,{"ABB_NOMTEC", "C", 30, 0}) // Nome do tecnico
aadd(aAgenda,{"ABB_NUMOS",  "C",  6, 0}) // Numero da OS
aadd(aAgenda,{"ABB_DTINI",  "C",  8, 0}) // Data de Inicio
aadd(aAgenda,{"ABB_HRINI",  "C",  5, 0}) // Hora Inicio
aadd(aAgenda,{"ABB_DTFIM",  "C",  8, 0}) // Data Termino
aadd(aAgenda,{"ABB_HRFIM",  "C",  5, 0}) // Hora Termino
aadd(aAgenda,{"ABB_HRTOT",  "C",  5, 0}) // Horas totais
aadd(aAgenda,{"ABB_OBSERV", "C", 30, 0}) // Observacoes
//PAcertaSx3(@aAgenda)                 

//Preenche o array com os campos a serem enviados
aadd(aDatas,{"DT_INI",       "C", 8, 0}) //Data inicio (atendimento)
aadd(aDatas,{"NUMERO_OS",    "C", 6, 0}) //Numero da OS

// Preenche o array com os campos a serem enviados
aadd(aOS,{"AB6_NUMOS"      , "C",  6, 0}) // Numero da OS
aadd(aOS,{"AB6_CODCLI"     , "C",  6, 0}) // Codigo do cliente
aadd(aOS,{"AB6_LOJA"       , "C",  2, 0}) // Loja do cliente
aadd(aOS,{"AB6_EMISSA"     , "D", 10, 0}) // Data de Emissao da OS
aadd(aOS,{"AB6_ATEND"      , "C", 20, 0}) // Atendente
aadd(aOS,{"AB6_STATUS"     , "C",  1, 0}) // Status (?)
aadd(aOs,{"AB6_CONPAG"     , "C",  3, 0})  // Cond. Pgto.
aadd(aOS,{"AB6_DESC1"	    , "N",  5, 2}) // Descto. 1
aadd(aOS,{"AB6_DESC2"		, "N",  5, 2}) // Descto. 2
aadd(aOS,{"AB6_DESC3"		, "N",  5, 2}) // Descto. 3
aadd(aOS,{"AB6_DESC4"		, "N",  5, 2}) // Descto. 4
aadd(aOS,{"AB6_TABELA"		, "C",  1, 0}) // Tabela
aadd(aOS,{"AB6_PARC1"		, "N", 12, 2}) // Parcela 1
aadd(aOS,{"AB6_DATA1"		, "D", 10, 0}) // Data 1
aadd(aOS,{"AB6_PARC2"		, "N", 12, 2}) // Parcela 2
aadd(aOS,{"AB6_DATA2"		, "D", 10, 0}) // Data 2
aadd(aOS,{"AB6_PARC3"		, "N", 12, 2}) // Parcela 3
aadd(aOS,{"AB6_DATA3"		, "D", 10, 0}) // Data 3
aadd(aOS,{"AB6_PARC4"		, "N", 12, 2}) // Parcela 4
aadd(aOS,{"AB6_DATA4"		, "D", 10, 0}) // Data 4
aadd(aOS,{"AB6_OK"			, "C",  2, 0})
aadd(aOS,{"AB6_HORA"		, "C",  5, 0}) // Hora de emissao
aadd(aOS,{"AB6_REGIAO"		, "C",  3, 0}) // Regiao de atend.
aadd(aOS,{"AB6_MSG"			, "C", 60, 0}) // Mensagem (campo usado como flag de novas OS)
//PAcertaSx3(@aOS)                  

// Preenche o array com os campos a serem enviados
aadd(aItensOS,{"AB7_NUMOS"  , "C",  6, 0}) // Numero da OS
aadd(aItensOS,{"AB7_ITEM"   , "C",  2, 0}) // Item da OS
aadd(aItensOS,{"AB7_TIPO"   , "C",  1, 0}) // Situacao da OS (1-OS, 2-Pedido Gerado, 3-Em atendimento, 4-Atendida)
aadd(aItensOS,{"AB7_CODPRO" , "C", 15, 0}) // Codigo do Prod./Eqpto 
aadd(aItensOS,{"AB7_NUMSER" , "C", 20, 0}) // Numero de Serie
aadd(aItensOS,{"AB7_CODPRB" , "C",  6, 0}) // Cod. da Ocorrenc./Problema
aadd(aItensOS,{"AB7_NRCHAM" , "C", 10, 0}) // Numero do chamado
aadd(aItensOS,{"AB7_NUMORC" , "C",  8, 0}) // Numero do Orcamento
aadd(aItensOS,{"AB7_MEMO1"  , "C",  6, 0}) // Codigo Memo
//aadd(aItensOS,{"AB7_MEMO2"  , "C", 80, 0}) // Ocorrencia - Observacoes (cpo. vitual)
aadd(aItensOS,{"AB7_MEMO3"  , "C",  6, 0}) // Cod. da Solucao
//aadd(aItensOS,{"AB7_MEMO4"  , "C", 80, 0}) // Descr. da Solucao (cpo. virtual)
aadd(aItensOS,{"AB7_CODFAB" , "C",  6, 0}) // Cod. do Fabricante
aadd(aItensOS,{"AB7_LOJAFA" , "C",  2, 0}) // Loja do Fabricante
aadd(aItensOS,{"AB7_CODCLI" , "C",  6, 0}) // Cod. do Cliente
aadd(aItensOS,{"AB7_LOJA"   , "C",  2, 0}) // Loja do Cliente
aadd(aItensOS,{"AB7_EMISSA" , "D",  8, 0}) // Emissao da OS
aadd(aItensOS,{"AB7_NUMHDE" , "C", 10, 0}) // Numero do Help Desk
//PAcertaSx3(@aItensOS)                  

// Preenche o array com os campos a serem enviados
aadd(aSubItens,{"AB8_NUMOS"   , "C",  6, 0}) // Numero da OS 
aadd(aSubItens,{"AB8_ITEM"    , "C",  2, 0}) // Item da OS 
aadd(aSubItens,{"AB8_SUBITE"  , "C",  2, 0}) // Sub-Item da OS
aadd(aSubItens,{"AB8_CODPRO"  , "C", 15, 0}) // Cod. do Produto/Eqpto.
aadd(aSubItens,{"AB8_DESPRO"  , "C", 30, 0}) // Descricao
aadd(aSubItens,{"AB8_CODSER"  , "C",  6, 0}) // Cod. do Servico
aadd(aSubItens,{"AB8_QUANT"   , "N", 12, 2}) // Quantidade
aadd(aSubItens,{"AB8_VUNIT"   , "N", 12, 2}) // Valor Unit.
aadd(aSubItens,{"AB8_TOTAL"   , "N", 12, 2}) // Valor Total
aadd(aSubItens,{"AB8_ENTREG"  , "D",  8, 0}) // Data de Entrega
aadd(aSubItens,{"AB8_DTGAR"   , "D",  8, 0}) // Data de Garantia
aadd(aSubItens,{"AB8_NUMPV"   , "C",  8, 0}) // Pedido de Venda
aadd(aSubItens,{"AB8_PRCLIS"  , "N", 12, 2}) // Preco de Lista
aadd(aSubItens,{"AB8_CODCLI"  , "C",  6, 0}) // Cod. do Cliente
aadd(aSubItens,{"AB8_LOJA"    , "C",  2, 0}) // Loja do Cliente
aadd(aSubItens,{"AB8_CODPRD"  , "C", 15, 0}) // Produto
aadd(aSubItens,{"AB8_NUMSER"  , "C", 20, 0}) // Num. de Serie
aadd(aSubItens,{"AB8_TIPO"    , "C",  1, 0}) // Tipo da OS (1=OS, 2=P. de Venda)
aadd(aSubItens,{"AB8_NUMPVF"  , "C",  8, 0}) // Pedido do Fabricante
aadd(aSubItens,{"AB8_LOCAL"   , "C",  2, 0}) // Cod. do Almoxarifado
aadd(aSubItens,{"AB8_LOCALI"  , "C", 15, 0}) // Cod. da localizacao fisica do prod. referencia
//PAcertaSx3(@aSubItens)                  

ConOut("PALMJOB: Criando arquivos de Agenda/OS para " + Trim(PALMUSER->P_USER))
PalmCreate(aAgenda,     cFileAge,  "AGE") // Arquivo de Agenda - ABB
PalmCreate(aDatas,      cFileDta,  "DTA") // Arquivo de datas - ABB
PalmCreate(aOS,         cFileOS,   "ORD") // Arquivo de OS - AB6
PalmCreate(aItensOS,    cFileItOS, "ITE") // Arquivo de Itens da OS - AB7
PalmCreate(aSubItens,   cFileSub,  "SUB") // Arquivo de Sub-itens da OS - AB8

dbSelectArea("ABB")
dbSetOrder(1)
dbSeek(xFilial("ABB"), .t.)
While !Eof() .and. ABB->ABB_FILIAL == xFilial("ABB") 
	If ABB->ABB_CODTEC == cTecnico .And. ABB->ABB_OBSERV <> cStatAgenda
		cNumos 	  := ABB->ABB_NUMOS
		cDataIni  := dtos(ABB->ABB_DTINI)
		lContinua := .f.
		
		dbSelectArea("AB7")
		dbSetOrder(1)
		//Selecionar todos os itens desta OS
		dbSeek(xFilial("AB7") + cNumos, .t.)
		While !Eof() .And. AB7->AB7_FILIAL == xFilial("AB7") .And. AB7->AB7_NUMOS == cNumos
		  If AB7->AB7_TIPO = "1" .Or. AB7->AB7_TIPO = "3"
		  	//ConOut("Export. item: " + AB7->AB7_NUMOS + AB7->AB7_ITEM)
			dbSelectArea("ITE")
			RecLock("ITE", .T.)
			For i:=1 To Len(aItensOS)
				If aItensOS[i,1] = "AB7_NUMOS"
					Replace &(aItensOS[i,1]) With AB7->AB7_NUMOS
			//	ElseIf aItensOS[i,1] = "AB7_MEMO2"
			//		Replace &(aItensOS[i,1]) With If(!INCLUI, MSMM(AB7->AB7_MEMO1),"")
			//	ElseIf aItensOS[i,1] = "AB7_MEMO4"
			//		Replace &(aItensOS[i,1]) With If(!INCLUI, MSMM(AB7->AB7_MEMO3),"")				
				Else
					Replace &(aItensOS[i,1]) With &("AB7->" + aItensOS[i,1])
				EndIf	
			Next
			MsUnlock()
			lContinua := .t.
		  EndIf
		  dbSelectArea("AB7")
		  dbSkip()
		Enddo 
		
		If lContinua //Indica que foi encontrado item de OS em aberto no AB7
			dbSelectArea("AGE")
			RecLock("AGE", .T.)
			//ConOut("Export. agenda: " + ABB->ABB_CODTEC + ABB->ABB_NUMOS)
			For i:=1 to len(aAgenda)
				If aAgenda[i,1] = "ABB_HRTOT"
					Replace &(aAgenda[i,1]) With space(5)//AllTrim(ABB->ABB_HRTOT)
				ElseIf aAgenda[i,1] = "ABB_DTINI"
					Replace &(aAgenda[i,1]) With dtos(ABB->ABB_DTINI)
				ElseIf aAgenda[i,1] = "ABB_DTFIM"
					Replace &(aAgenda[i,1])	 With dtos(ABB->ABB_DTFIM)			
				Else
					Replace &(aAgenda[i,1]) With &("ABB->" + aAgenda[i,1])	
		 		EndIf
			Next
			MsUnlock()
				
			dbSelectArea("DTA")
			If cDataIni <> cUltima
				//ConOut("Export. data: " + dtos(ABB->ABB_DTINI))
				RecLock("DTA", .T.)
				Replace &(aDatas[1,1]) With dtos(ABB->ABB_DTINI)
				Replace &(aDatas[2,1]) With	 ABB->ABB_NUMOS
				MsUnlock()
				cUltima := DTA->DT_INI
			EndIf
				
			dbSelectArea("AB6")
			dbSetOrder(1)
			If dbSeek(xFilial("AB6") + cNumos)
				//ConOut("Export. OS: " + AB6->AB6_NUMOS)
				dbSelectArea("ORD")
				RecLock("ORD",.T.)
				For i:=1 To Len(aOS)
				    Replace &(aOS[i,1]) With &("AB6->"	+ aOS[i,1])
				Next
				MsUnlock()
			EndIf
					
			dbSelectArea("AB8")
			dbSetOrder(1)
			If dbSeek(xFilial("AB8") + cNumos)
				//ConOut("Export. Subitem: " + AB8->AB8_NUMOS)
				dbSelectArea("SUB")
				RecLock("SUB", .T.)
				For i:=1 To Len(aSubItens)
					Replace &(aSubItens[i,1]) With &("AB8->" + aSubItens[i,1])
				Next
				MsUnlock()
			EndIf 
		EndIf
  EndIf
  dbSelectArea("ABB")
  dbSkip()
EndDo   

//Grava arquivos espelho de OS, Itens e Subitens de OS
AGE->(dbCloseArea())
DTA->(dbCloseArea())
ORD->(dbCloseArea())
ITE->(dbCloseArea())
SUB->(dbCloseArea())

Return

//retorna alias usados pelos servicos
Function POSTab()
Return {"ABB", "ABB", "AB6", "AB7", "AB8"}

//retorna nome fisico do arquivo espelho
Function POSArq()
Local cFileAge := "ABB" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileDta := "DTA" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileOS  := "AB6" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileItOs:= "AB7" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileSub := "AB8" + Left(PALMSERV->P_EMPFI,2) + "0"
Return {cFileAge, cFileDta, cFileOS, cFileItOs, cFileSub}

//retorna indice usado pelo arquivo espelho
Function POSInd()
Return {"ABB_CODTEC+ABB_NUMOS", "DT_INI", "AB6_NUMOS", "AB7_NUMOS+AB7_ITEM", "AB8_NUMOS+AB8_ITEM+AB8_SUBITE"}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PApontar  ºAutor  ³Cleber Martinez     º Data ³  24/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Arquivos espelho de Apontamento (AB9, ABA e ABC)            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integracao Palm                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function PApontar()
Local aAponta     := {}
Local aItens      := {}
Local aDespesas   := {}
Local cFileAponta := "AB9"+cEmpAnt+"0"
Local cFileItens  := "ABA"+cEmpAnt+"0"
Local cFileDesp	  := "ABC"+cEmpAnt+"0"


//preenche o array com os campos a serem enviados (Apontamento)
aAdd(aAponta, {"AB9_NUMOS"       , "C", 08, 0}) // Nr. da OS + Item OS
aAdd(aAponta, {"AB9_CODTEC"      , "C", 06, 0}) // Cod. do tecnico
aAdd(aAponta, {"AB9_SEQ"         , "C", 02, 0}) // Sequencia
aAdd(aAponta, {"AB9_DTCHEG"      , "D", 08, 0}) // Data de Chegada
aAdd(aAponta, {"AB9_HRCHEG"      , "C", 05, 0}) // Hora de Chegada
aAdd(aAponta, {"AB9_DTSAID"      , "D", 08, 0}) // Data de Saida
aAdd(aAponta, {"AB9_HRSAID"      , "C", 05, 0}) // Hora de Saida
aAdd(aAponta, {"AB9_DTINI"       , "D", 08, 0}) // Data Inicio
aAdd(aAponta, {"AB9_HRINI"       , "C", 05, 0}) // Hora Inicio
aAdd(aAponta, {"AB9_DTFIM"       , "D", 08, 0}) // Data Fim
aAdd(aAponta, {"AB9_HRFIM"       , "C", 05, 0}) // Hora Fim
aAdd(aAponta, {"AB9_TRASLA"      , "C", 05, 0}) // Traslado
//aAdd(aAponta, {"AB9_RATEIO"      , "C", 01, 0}) // Rateio = S p/ Atrium Telecom
aAdd(aAponta, {"AB9_CODPRB"      , "C", 06, 0}) // Codigo da Ocor./Prob.
aAdd(aAponta, {"AB9_GARANT"      , "C", 01, 0}) // Garantia
aAdd(aAponta, {"AB9_OBSOL"       , "C", 01, 0}) // Obsolescencia
aAdd(aAponta, {"AB9_ACUMUL"      , "N", 12, 2}) // Acumulador (?)
aAdd(aAponta, {"AB9_TIPO"        , "C", 01, 0}) // Status do atendimento (em aberto/encerrada)
aAdd(aAponta, {"AB9_ATUPRE"      , "C", 01, 0}) // Atualizar preventiva
aAdd(aAponta, {"AB9_ATUOBS"      , "C", 01, 0}) // Atualizar obsolescencia
aAdd(aAponta, {"AB9_NUMSER"      , "C", 20, 0}) // Nr. de serie
aAdd(aAponta, {"AB9_CODCLI"      , "C", 06, 0}) // Cod. do Cliente
aAdd(aAponta, {"AB9_LOJA"        , "C", 02, 0}) // Loja do Cliente
aAdd(aAponta, {"AB9_CODPRO"      , "C", 15, 0}) // Cod. do Produto
aAdd(aAponta, {"AB9_MEMO1"       , "C", 06, 0}) // Laudo
aAdd(aAponta, {"AB9_MEMO2"       , "C", 80, 0}) // Laudo do Tecnico
aAdd(aAponta, {"AB9_TOTFAT"      , "C", 05, 0}) // Horas Faturadas
aAdd(aAponta, {"AB9_NUMORC"      , "C", 06, 0}) // Nr. do Orcamento
aAdd(aAponta, {"AB9_CUSTO"       , "N", 12, 2}) // Custo da mao-de-obra

//preenche o array com os campos a serem enviados (Itens)
aAdd(aItens, {"ABA_ITEM"        , "C", 02, 0}) // Item
aAdd(aItens, {"ABA_CODFAB"      , "C", 06, 0}) // Cod. do Fabricante
aAdd(aItens, {"ABA_LOJAFA"      , "C", 02, 0}) // Loja do Fabricante
aAdd(aItens, {"ABA_CODPRO"      , "C", 15, 0}) // Cod. do Produto
aAdd(aItens, {"ABA_NUMSER"      , "C", 20, 0}) // Num. de Serie
aAdd(aItens, {"ABA_QUANT"       , "N", 12, 2}) // Quantidade usada
aAdd(aItens, {"ABA_LOCAL"       , "C", 02, 0}) // Cod. do almoxarifado
aAdd(aItens, {"ABA_LOCALI"      , "C", 15, 0}) // Cod. da localizacao fisica do produto
aAdd(aItens, {"ABA_CODSER"      , "C", 06, 0}) // Cod. do servico
aAdd(aItens, {"ABA_FABANT"      , "C", 06, 0}) // Cod. do fabricante anterior (trocas) 
aAdd(aItens, {"ABA_LOJANT"      , "C", 02, 0}) // Loja do fabric. anterior
aAdd(aItens, {"ABA_ANTPRO"      , "C", 15, 0}) // Cod. do produto anterior
aAdd(aItens, {"ABA_ANTSER"      , "C", 20, 0}) // Nr. de serie do prod. anterior
aAdd(aItens, {"ABA_NUMOS"       , "C", 08, 0}) // Nr. OS + Item OS
aAdd(aItens, {"ABA_CUSTO"       , "N", 12, 2}) // Custo
aAdd(aItens, {"ABA_CODTEC"      , "C", 06, 0}) // Cod. do tecnico
aAdd(aItens, {"ABA_SEQ"         , "C", 02, 0}) // Sequencia
aAdd(aItens, {"ABA_SUBOS"       , "C", 02, 0}) // Sub-item da OS
aAdd(aItens, {"ABA_DESCRI"      , "C", 30, 0}) // Descr. do produto
aAdd(aItens, {"ABA_LOCALD"      , "C", 02, 0}) // Cod. do almoxarifado destino
aAdd(aItens, {"ABA_LOCLZD"      , "C", 15, 0}) // Localizacao fisica destino
aAdd(aItens, {"ABA_SEQRC"       , "C", 02, 0}) // Seq. da solicitacao ao almoxarifado
aAdd(aItens, {"ABA_ITEMRC"      , "C", 02, 0}) // Item da solicitacao ao almoxarifado

//preenche o array com os campos a serem enviados (Despesas)
aAdd(aDespesas, {"ABC_NUMOS"         , "C", 08, 0}) // Nr. da OS + Item OS
aAdd(aDespesas, {"ABC_SUBOS"         , "C", 02, 0}) // Sub-item da OS
aAdd(aDespesas, {"ABC_CODTEC"        , "C", 06, 0}) // Cod. do tecnico
aAdd(aDespesas, {"ABC_SEQ"           , "C", 02, 0}) // Seq. do atendimento
aAdd(aDespesas, {"ABC_ITEM"          , "C", 02, 0}) // Item da despesa 
aAdd(aDespesas, {"ABC_CODPRO"        , "C", 15, 0}) // Cod. do produto
aAdd(aDespesas, {"ABC_DESCRI"        , "C", 30, 0}) // Descr. do produto
aAdd(aDespesas, {"ABC_QUANT"         , "N", 12, 0}) // Quantidade
aAdd(aDespesas, {"ABC_VLUNIT"        , "N", 12, 2}) // Valor unit. da despesa
aAdd(aDespesas, {"ABC_VALOR"         , "N", 12, 2}) // Valor total da despesa
aAdd(aDespesas, {"ABC_CODSER"        , "C", 06, 0}) // Cod. de servico
aAdd(aDespesas, {"ABC_CUSTO"         , "N", 12, 2}) // Custo da despesa financeira de atendimento

ConOut("PALMJOB: Criando arquivo de Apontamento para " + Trim(PALMUSER->P_USER))
PalmCreate(aAponta,   cFileAponta,  "APO")
PalmCreate(aItens,    cFileItens,   "ITS")
PalmCreate(aDespesas, cFileDesp,    "DES")

APO->(dbCloseArea())
ITS->(dbCloseArea())
DES->(dbCloseArea())
Return

//Retorna alias usado pelo servico
Function PApoTab()
Return{"AB9","ABA","ABC"}

//retorna nome fisico do arquivo espelho
Function PApoArq()
Local cFileAponta := "AB9" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileItens  := "ABA" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileDesp   := "ABC" + Left(PALMSERV->P_EMPFI,2) + "0"
Return{cFileAponta,cFileItens,cFileDesp}

//retorna indice usado pelo arquivo espelho
Function PApoInd()
Return{"AB9_NUMOS","ABA_NUMOS+ABA_ITEM","ABC_NUMOS+ABC_ITEM"}

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³PReq      ºAutor  ³Cleber Martinez     º Data ³  24/05/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Arquivos espelho de Requisicoes e pendencias                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Integracao Palm                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Function PReq()

Local aRequisicoes := {}
Local aItensReq    := {}
Local cFileReq	   := "ABF"+cEmpAnt+"0"
Local cFileItReq   := "ABG"+cEmpAnt+"0"


//preenche o array com os campos a serem enviados (requisicoes)
aAdd(aRequisicoes, {"ABF_EMISSA"  , "C", 08, 0}) // Data de emissao da req.
aAdd(aRequisicoes, {"ABF_NUMOS"   , "C", 06, 0}) // Nr. da OS
aAdd(aRequisicoes, {"ABF_ITEMOS"  , "C", 02, 0}) // Item da OS
aAdd(aRequisicoes, {"ABF_SEQRC"   , "C", 02, 0}) // Sequencia da solicitacao
aAdd(aRequisicoes, {"ABF_CODTEC"  , "C", 06, 0}) // Tecnico
aAdd(aRequisicoes, {"ABF_SOLIC"   , "C", 10, 0}) // Solicitante

//preenche o array com os campos a serem enviados (itens req.)
aAdd(aItensReq, {"ABG_NUMOS"   , "C", 06, 0}) // Nr. da OS
aAdd(aItensReq, {"ABG_ITEMOS"  , "C", 02, 0}) // Item da OS
aAdd(aItensReq, {"ABG_ITEM"    , "C", 02, 0}) // Item requisitado
aAdd(aItensReq, {"ABG_SEQRC"   , "C", 02, 0}) // Seq. da solicitacao ao almoxarifado
aAdd(aItensReq, {"ABG_CODPRO"  , "C", 15, 0}) // Cod. do produto
aAdd(aItensReq, {"ABG_DESCRI"  , "C", 30, 0}) // Descricao do produto
aAdd(aItensReq, {"ABG_QUANT"   , "N", 09, 0}) // Quantidade
aAdd(aItensReq, {"ABG_CODSER"  , "C", 06, 0}) // Cod. de servico
aAdd(aItensReq, {"ABG_CODTEC"  , "C", 06, 0}) // Cod. do tecnico

ConOut("PALMJOB: Criando arquivos de Requisicoes para " + Trim(PALMUSER->P_USER))
PalmCreate(aRequisicoes,   cFileReq, "REQ")
PalmCreate(aItensReq,    cFileItReq, "IRQ")

REQ->(dbCloseArea())
IRQ->(dbCloseArea())

Return

//Retorna alias usado pelo servico
Function PReqTab()
Return{"ABF","ABG"}

//retorna nome fisico do arquivo espelho
Function PReqArq()
Local cFileReq	:= "ABF" + Left(PALMSERV->P_EMPFI,2) + "0"
Local cFileItReq:= "ABG" + Left(PALMSERV->P_EMPFI,2) + "0"
Return{cFileReq,cFileItReq}

//retorna indice usado pelo arquivo espelho
Function PReqInd()
Return{"ABF_NUMOS+ABF_ITEMOS","ABG_NUMOS+ABG_ITEMOS+ABG_ITEM"}
