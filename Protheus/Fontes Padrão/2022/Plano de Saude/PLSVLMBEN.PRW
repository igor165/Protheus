#include "PROTHEUS.CH"

/*/{Protheus.doc} PLSVLMBEN
Função para pré-validação de inclusao de beneficiários pelo portal para atender normas ANS, SIB.
@author francisco.edcarlo
@since 22/12/2017
/*/
Function PLSVLMBEN(aDados)
    local lRet := .T.
    local cMsg := ""
    local aCritben := {}
    local nI := 1
    local nIndex := 0
    default aDados := {}

    //Criticas extraídas da Central de obrigações. Mantive a mesma estrutura para que alteraçoes futuras possam seguir o mesmo padrão da Central.
    aAdd(aCritBen,{"B013","0102","SIBVLDB013"	,"Nome de beneficiário inválido"															,"Preencher o nome conforme regras estabelecidas pela ANS->O Nome NÃO pode: Conter apenas uma palavra. Primeiro nome com apenas uma letra, exceto quando o primeiro nome for: D,I,O,U,Y (com ou sem acento). Último nome com apenas uma letra, exceto quando o último nome for: I, O, U,Y (com ou sem acento). Nomes que contenham um ou mais números: 1, 2, 3, 4, 5, 6, 7, 8, 9 e 0. Nomes que contenham um ou mais caracteres especiais: @ (arroba),“ ” (aspas),* (asterisco),/ (barra),{ } (chaves),$ (cifrão),^ (circunflexo),[ ] (colchetes),\ (contra barra),& (E comercial),! (exclamação) ,= (igual) ,? (interrogação),+ (mais) ,< (menor que) ,> (maior que) ,( ) (parênteses),% (percentual),. (ponto), (ponto e vírgula),# (sustenido) ,~ (til) , (vírgula).Serão validados nomes com as letras “ e “ e “ y “ entre nomes, por se tratarem de conectivos"	,.F.,"B2N_NOMUSR"})
	aAdd(aCritBen,{"B015","0203","SIBVLDB015"	,"Data de nascimento deve ser posterior ou igual a 01/01/1890"								,"Preencher a data de nascimento do beneficiário conforme regra estabelecida pela ANS."	,.F.,"B2N_DATNAS"})
	aAdd(aCritBen,{"B019","0402","SIBVLDB019"	,"CPF é obrigatório para beneficiário titular (independentemente de idade)."				,"Preencher CPF do beneficiário conforme regras da ANS"	,.F.,"B2N_CPFUSR"})
	aAdd(aCritBen,{"B020","0403","SIBVLDB020"	,"CPF é obrigatório para beneficiário dependente com idade igual ou superior a 18 anos."	,"Preencher CPF do beneficiário conforme regras da ANS"	,.F.,"B2N_CPFUSR"})
	aAdd(aCritBen,{"B025","0601","SIBVLDB025"	,"Nome da Mãe Inválido"																		,"Preencher o nome conforme regras estabelecidas pela ANS->O Nome NÃO pode: Conter apenas uma palavra. Primeiro nome com apenas uma letra, exceto quando o primeiro nome for: D,I,O,U,Y (com ou sem acento). Último nome com apenas uma letra, exceto quando o último nome for: I, O, U,Y (com ou sem acento). Nomes que contenham um ou mais números: 1, 2, 3, 4, 5, 6, 7, 8, 9 e 0. Nomes que contenham um ou mais caracteres especiais: @ (arroba),“ ” (aspas),* (asterisco),/ (barra),{ } (chaves),$ (cifrão),^ (circunflexo),[ ] (colchetes),\ (contra barra),& (E comercial),! (exclamação) ,= (igual) ,? (interrogação),+ (mais) ,< (menor que) ,> (maior que) ,( ) (parênteses),% (percentual),. (ponto),. (ponto e vírgula),# (sustenido) ,~ (til) , (vírgula).Serão validados nomes com as letras “ e “ e “ y “ entre nomes, por se tratarem de conectivos"	,.F.,"B2N_MAE"})
	aAdd(aCritBen,{"B026","0701","SIBVLDB026"	,"CNS inválido"																				,"Preencher o CNS conforme regras da ANS"	,.F.,"B2N_NRCRNA"})
	
    For nI := 1 To Len(aCritBen)
        nIndex := ascan(aDados, {|x| x[6] == aCritben[nI][7]})
        if (nIndex > 0)
            xDado := aDados[nIndex][3]
            if !&(aCritben[nI][3]+ "(xDado, aDados)")
                lRet := .F.
                cMsg += aCritben[nI][4] + "<br>"
            endif
        endif
        nIndex := 0
    Next nI

Return {lRet, cMsg}

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB013

Funcao criada para validar Critica B013
Nome de beneficiário inválido

@return lRetorno	.F. registro critica ou .T. registro nao critica

@author francisco.edcarlo
@since 22/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB013(xDado)
local lRet := .F.
local cNome := ""

lRet := PLVlANSNome(xDado)

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB015

Funcao criada para validar Critica B015
Data de nascimento deve ser posterior ou igual a 01/01/1890

@return lRetorno	.F. registro critica ou .T. registro nao critica

@author francisco.edcarlo
@since 22/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB015(xDado)
Local lRet := .T.

Local dData := STOD(xDado)

lRet := dData >= STOD("18900101")

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB019

Funcao criada para validar Critica B019
CPF é obrigatório para beneficiario titular (independentemente de idade).

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author francisco.edcarlo
@since 22/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB019(xDado, aDados)
Local lRet := .T.

Local cCPF := ""
Local cTipoDep := ""
Local nIndTipUsu := 0
local cCodTit := getNewPar("MV_PLCDTIT", "T")

nIndTipUsu := ascan(aDados, {|x| x[6] == "B2N_TIPUSU"})
if (nIndTipUsu > 0)
    cCPF := xDado
    cTipoDep := aDados[nIndTipUsu][3]
    lRet := cTipoDep != cCodTit .OR. !Empty(cCPF)
endif

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB020

Funcao criada para validar Critica B020
CPF é obrigatório para beneficiario dependente com idade igual ou superior a 18 anos.

@return lRetorno	.F. registro criticado ou .T. registro nao criticado

@author francisco.edcarlo
@since 22/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB020(xDado, aDados)
Local lRet := .T.
Local cCPF := ""
Local nIdade := 0
Local nIndTipUsu := 0
Local dDatNas 
local cCodDep := getNewPar("MV_PLCDDEP", "D")

nIndTipUsu := ascan(aDados, {|x| x[6] == "B2N_TIPUSU"})
nIndDtNasc := ascan(aDados, {|x| x[6] == "B2N_DATNAS"})
if (nIndTipUsu > 0)
    cCPF := xDado
    cTipoDep := aDados[nIndTipUsu][3]
    dDatNas := ctod(aDados[nIndDtNasc][3])
    nIdade	:= DateDiffYear(dDataBase,dDatNas) 
    lRet := cTipoDep != cCodDep .OR. nIdade < 18 .OR. !Empty(cCPF)
endif

Return lRet


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB025

Funcao criada para validar Critica B025
Nome da Mãe Invalido

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author francisco.edcarlo
@since 22/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB025(xDado)
local lRet := .F.
local cNome := ""

lRet := PLVlANSNome(xDado)

Return lRet
//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} SIBVLDB026

Funcao criada para validar Critica B026
CNS invalido

@return lRetorno	.F. registro criticao ou .T. registro nao criticao

@author francisco.edcarlo
@since 22/12/2017
/*/
//--------------------------------------------------------------------------------------------------
Static Function SIBVLDB026(xDado)
Local lRet := .T.
Local cCNS := ""

cCNS := xDado

lRet := Empty(cCNS) .OR. HS_VldCns(cCNS)

Return lRet