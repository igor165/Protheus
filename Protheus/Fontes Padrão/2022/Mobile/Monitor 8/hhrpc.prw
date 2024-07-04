#INCLUDE "hhrpc.ch"
User Function HHESTON(cSerie, cCodProd)
Local nSaldo     := 0
Local cSaldo     := ""
Local cEnv       := GetEnvServer()
//Local cAliasUser := POpenUser()  // Abre arquivo de usuarios do Palm
//Local cAliasServ := POpenServ()  // Abre arquivo de servicos dos usuarios do Palm
//Local aAlias     := {} // Arquivos que serao abertos 
/*
// Posiciona Usuario
(cAliasUser)->(dbSetOrder(1))
(cAliasUser)->(dbSeek(cSerie))

//Posiciona Servico
(cAliasServ)->(dbSetOrder(2))
(cAliasServ)->(dbSeek(cSerie))
*/
//aAdd(aAlias, {"SB1", "SB2", "SC2", "SD4", "SDC"}) // Arquivo abertos

ConOut(STR0001 + cSerie + " - " + Time()) //"Handheld conectado: "
//ConOut("Vendedor..........: " + (cAliasUser)->P_VEND)
//ConOut("Diretorio.........: " + "P" + (cAliasUser)->P_DIR)

//RpcSetType(3) // Nao utiliza licensa do protheus
//RpcSetEnv(Subs((PSALIAS)->P_EMPFI,1,2),Subs((PSALIAS)->P_EMPFI,3,2),,,cEnv,,aAlias)  // Abre Ambiente
ConOut(STR0002 + cEnv + STR0003 + cEmpAnt + STR0004 + cFilAnt) //"Ambiente Utilizado: "###" - Empresa: "###" - Filial: "
ConOut(STR0005 + cCodProd) //"Produto: "
dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial("SB1") + cCodProd)
	nSaldo := SaldoSB2()
	cSaldo := Str(nSaldo, 10,4)
Else
	cSaldo := STR0006 //"Produto nao encontrado"
EndIf

ConOut(STR0007 + cSaldo) //"Retorno...........: "
ConOut(STR0008 + cSerie + " - " + Time()) //"Handheld desconectado: "
Return cSaldo