#INCLUDE "TOTVS.ch"
#INCLUDE "GTPXENCEXP.ch"

Static aUF := GetListUFs()
Static cGTPAgRet 
Static cGTPRetSer

//------------------------------------------------------------------------------
/*/{Protheus.doc} GxVldAgEnc

@type Function
@author jacomo.fernandes
@since 18/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, retorna o filtro do campo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GxVldAgEnc(cCodigo,lTransbordo)
Local lRet          := .T.
Local aArea         := GI6->(GetArea())

Default cCodigo     := Space(TamSx3('GI6_CODIGO')[1])
Default lTransbordo := .F.

cCodigo := Padr(cCodigo,TamSx3('GI6_CODIGO')[1])

GI6->(DbSetOrder(1))// filial+codigo

If GI6->(DbSeek(xFilial('GI6')+cCodigo))
    If GI6->GI6_ENCEXP <> "1"
        lRet := .F.
    Endif

    If lRet .and. lTransbordo .and. GI6->GI6_ENCTRA <> "1"
        lRet := .F.
    Endif

Endif

RestArea(aArea)
GtpDestroy(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GxVldAgEnc

@type Function
@author jacomo.fernandes
@since 18/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, retorna o filtro do campo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GxEncF3(nTipo)
Local oModel    := FwModelActive()
Local lModel    := ValType(oModel) == "O" .and. oModel:IsActive()
Local cFiltro   := "@# @#"

Do Case
    Case nTipo == 1
        cFiltro   := "@# GI6->GI6_ENCEXP = '1'@#"
    Case nTipo == 2 .and. lModel
        cFiltro   :=  "@# GID->GID_LINHA == '"+oModel:GetModel('DETAILG9Q'):GetValue("G9Q_CODLIN")+"' .And. GID->GID_HIST == '2' @#"
    Case nTipo == 3 .and. lModel
        cFiltro   := "@# G5I->G5I_CODLIN == '"+oModel:GetModel('DETAILG9Q'):GetValue("G9Q_CODLIN")+"' .and. G5I->G5I_HIST == '2' @#"
EndCase

Return cFiltro


//------------------------------------------------------------------------------
/*/{Protheus.doc} GxGetMunAg

@type Function
@author jacomo.fernandes
@since 18/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, retorna o filtro do campo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GxAgMunDif(cCodIni,cCodFim)
Local lRet      := .T.
Local aMunIni   := GxGetMunAg(cCodIni)
Local aMunFim   := GxGetMunAg(cCodFim)

If aMunIni[1]+aMunIni[2] == aMunFim[1]+aMunFim[2]
    lRet := .F.
Endif

GtpDestroy(aMunIni)
GtpDestroy(aMunFim)

Return lRet



//------------------------------------------------------------------------------
/*/{Protheus.doc} GxVldLocAg

@type Function
@author jacomo.fernandes
@since 18/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)gtpa
@return cRet, retorna o filtro do campo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GxVldLocAg(cCodAge,cCodLoc)
Local lRet  := .T.
Local cLocalidade   := Posicione("GI6",1,xFilial('GI6')+cCodAge,'GI6_LOCALI')

If cLocalidade <> cCodLoc
    lRet    := .F.
Endif

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GxGetMunAg

@type Function
@author jacomo.fernandes
@since 18/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, retorna o filtro do campo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GxGetMunAg(cCodigo,nTpRetUF)
Local aRet          := {"","","",""}
Local cLocalidade   := Posicione("GI6",1,xFilial('GI6')+cCodigo,'GI6_LOCALI')

Default nTpRetUF    := 1

If !Empty(cLocalidade) 
    GI1->(DbSetOrder(1))//Filial+Codigo
    DbSelectArea('CC2')
    If GI1->(DbSeek(xFilial("GI1")+PadR(cLocalidade,TamSx3('GI1_COD')[1])))
        aRet[1] := GI1->GI1_UF
        aRet[2] := GI1->GI1_CDMUNI
        aRet[3] := Posicione('CC2',1,xFilial('CC2')+GI1->GI1_UF+GI1->GI1_CDMUNI,"CC2_MUN") 
        aRet[4] := GetDadosUf(GI1->GI1_UF,1,nTpRetUF)
    Endif
Endif

Return aRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} GetDadosUf

@type Function
@author jacomo.fernandes
@since 18/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, retorna o filtro do campo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GetDadosUf(cUf,nTpBusca,nTpRetUF)
Local cRet  := ""
Local aUF   := GetListUFs()
Local nPos  := 0

If (nPos :=  aScan(aUf,{|x| x[nTpBusca] == cUF }) ) >0
    cRet := aUf[nPos][nTpRetUf]
Endif

GtpDestroy(aUF)

Return cRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} GetListUFs

@type Function
@author jacomo.fernandes
@since 18/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, retorna o filtro do campo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GetListUFs()
Local aRet  := {}
aAdd(aRet,{"RO" ,"11"   ,"RONDONIA"             })
aAdd(aRet,{"AC" ,"12"   ,"ACRE"                 })
aAdd(aRet,{"AM" ,"13"   ,"AMAZONAS"             })
aAdd(aRet,{"RR" ,"14"   ,"RORAIMA"              })
aAdd(aRet,{"PA" ,"15"   ,"PARA"                 })
aAdd(aRet,{"AP" ,"16"   ,"AMAPA"                })
aAdd(aRet,{"TO" ,"17"   ,"TOCANTINS"            })
aAdd(aRet,{"MA" ,"21"   ,"MARANHAO"             })
aAdd(aRet,{"PI" ,"22"   ,"PIAUI"                })
aAdd(aRet,{"CE" ,"23"   ,"CEARA"                })
aAdd(aRet,{"RN" ,"24"   ,"RIO GRANDE DO NORTE"  })
aAdd(aRet,{"PB" ,"25"   ,"PARAIBA"              })
aAdd(aRet,{"PE" ,"26"   ,"PERNAMBUCO"           })
aAdd(aRet,{"AL" ,"27"   ,"ALAGOAS"              })
aAdd(aRet,{"SE" ,"28"   ,"SERGIPE"              })
aAdd(aRet,{"BA" ,"29"   ,"BAHIA"                })
aAdd(aRet,{"MG" ,"31"   ,"MINAS GERAIS"         })
aAdd(aRet,{"ES" ,"32"   ,"ESPIRITO SANTO"       })
aAdd(aRet,{"RJ" ,"33"   ,"RIO DE JANEIRO"       })
aAdd(aRet,{"SP" ,"35"   ,"SAO PAULO"            })
aAdd(aRet,{"PR" ,"41"   ,"PARANA"               })
aAdd(aRet,{"SC" ,"42"   ,"SANTA CATARINA"       })
aAdd(aRet,{"RS" ,"43"   ,"RIO GRANDE DO SUL"    })
aAdd(aRet,{"MS" ,"50"   ,"MATO GROSSO DO SUL"   })
aAdd(aRet,{"MT" ,"51"   ,"MATO GROSSO"          })
aAdd(aRet,{"GO" ,"52"   ,"GOIAS"                })
aAdd(aRet,{"DF" ,"53"   ,"DISTRITO FEDERAL"     })
aAdd(aRet,{"EX" ,"99"   ,"EXTRANGEIRO"          })

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} GetListUFs

@type Function
@author jacomo.fernandes
@since 18/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, retorna o filtro do campo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GxGetUFLin(cCodLinha,cLocOri,cLocDes)
Local aRet      := {}
Local cAliasTmp := GetNextAlias()

BeginSql Alias cAliasTmp
        
    Select 
        MIN(G5I_SEQ) G5I_SEQ, 
        GI1_UF
    From %Table:G5I% G5I
        INNER JOIN (
                Select
                    Min(G5I_SEQ) G5IMIN,
                    Max(G5I_SEQ) G5IMAX
                From %Table:G5I% G5I
                Where
                    G5I.G5I_FILIAL = %xFilial:G5I%
                    And G5I.G5I_CODLIN = %Exp:cCodLinha%
                    And G5I.G5I_HIST = '2'
                    And G5I.%NotDel%
                    And (G5I.G5I_LOCALI = %Exp:cLocOri%
                        Or G5I.G5I_LOCALI = %Exp:cLocDes%)

        ) MINMAX ON
            G5I.G5I_SEQ BETWEEN MINMAX.G5IMIN AND MINMAX.G5IMAX
        INNER JOIN %Table:GI1% GI1 ON
            GI1.GI1_FILIAL = %xFilial:GI1%
            AND GI1.GI1_COD = G5I.G5I_LOCALI
            AND GI1.%NotDel%
    Where
        G5I.G5I_FILIAL = %xFilial:G5I%
        And G5I.G5I_CODLIN = %Exp:cCodLinha%
        And G5I.G5I_HIST = '2'
        And G5I.%NotDel%
    GROUP BY GI1_UF
    ORDER BY G5I_SEQ
EndSql

While (cAliasTmp)->(!Eof())
    aAdd(aRet,(cAliasTmp)->GI1_UF)
    (cAliasTmp)->(DbSkip())
End

(cAliasTmp)->(DbCloseArea())

Return aRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} AgFilter

@type Function
@author gustavo.silva2
@since 18/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, retorna o filtro do campo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function AgFilter()

Local aRetorno 		:= {}
Local cQuery   		:= ""         
Local lRet     		:= .F.
Local oLookUp  		:= Nil
Local cUserAtual    := RetCodUsr()

cQuery:=		"SELECT GI6.GI6_CODIGO, GI6.GI6_DESCRI  " 
cQuery+=		" FROM " + RetSqlName("GI6") + " GI6 "
cQuery+=		" INNER JOIN " + RetSqlName("G9X") + " G9X "
cQuery+=		" ON G9X.G9X_CODGI6 = GI6.GI6_CODIGO  "
cQuery+=        " AND G9X.G9X_FILIAL = GI6.GI6_FILIAL  "
cQuery+=		" AND G9X.G9X_CODUSR = '" + cUserAtual + "'"
cQuery+=		" AND G9X.D_E_L_E_T_ = ' '  "
cQuery+=		" WHERE GI6.GI6_ENCEXP = '1'  "
cQuery+=		" AND GI6.GI6_FILIAL = '"+xFilial('GI6')+"' "
cQuery+=		" AND GI6.D_E_L_E_T_ = ' '  "

oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"GI6_CODIGO","GI6_DESCRI"})

oLookUp:AddIndice("Código"		, "GI6_CODIGO")
oLookUp:AddIndice("Descrição"	, "GI6_DESCRI")

If !IsBlind() .AND. oLookUp:Execute()
	lRet       := .T.
	aRetorno   := oLookUp:GetReturn()
	cGTPAgRet := aRetorno[1]
EndIf  

FreeObj(oLookUp)

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} RetEnc

@type Function
@author gustavo.silva2
@since 18/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, retorna o filtro do campo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function RetAgen()
Local cRet :=''
cRet:=	cGTPAgRet
Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} SerCteFilt

@type Function
@author gustavo.silva2
@since 18/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, retorna o filtro do campo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function SerCteFilt(cEspecie)
Local cSerie := SuperGetMV("MV_ESPECIE")
Local aSerie:=  {}
Local aRet:= {}
Local nI:= 0
Local lRet:= .F.
Local cRet:= ""
Local cQuery:=""

Default cEspecie := 'CTE'

If !Empty(cSerie) .and. cEspecie $ cSerie
    aSerie:= StrTokArr2( cSerie, ';' )
    If !('CTEOS' $ Upper(cEspecie))
        For nI:= 1 to Len(aSerie)
            If 'CTE' $ Upper(aSerie[nI]) .And. !('CTEOS' $ Upper(aSerie[nI])) 
                Aadd(aRet, StrTokArr2( aSerie[nI], '=' ))
            EndIf
        Next
    Else
        For nI:= 1 to Len(aSerie)
            If 'CTEOS' $ Upper(aSerie[nI])
                Aadd(aRet, StrTokArr2( aSerie[nI], '=' ))
            EndIf
        Next
    EndIf
    
    cRet:= "X5_CHAVE IN( "
    If Len(aRet) > 0
        For nI:= 1 to Len(aRet)
            cRet += "'" + aRet[nI][1] + "'"
            If nI < Len(aRet)
                cRet+=","
            EndIf
        Next
    Else
        cRet += " '' "
    EndIf

    cRet+= " )"

    cQuery:= "SELECT X5_CHAVE, X5_DESCRI "
    cQuery+= " FROM " + RetSqlName("SX5") + " SX5 " 
    cQuery+= " WHERE "
    cQuery+= cRet
    cQuery+= " AND X5_TABELA = '01'" 

    oLookUp := GTPXLookUp():New(StrTran(cQuery, '#', '"'), {"X5_CHAVE","X5_DESCRI"})

    oLookUp:AddIndice("Código"		, "X5_CHAVE")
    oLookUp:AddIndice("Descrição"	, "X5_DESCRI")

    If !IsBlind() .AND. oLookUp:Execute()
        lRet       := .T.
        aRetorno   := oLookUp:GetReturn()
        cGTPRetSer := aRetorno[1]
    EndIf   
Else 
    FwAlertWarning('Parametro MV_ESPECIE não cadastrado para ' + cEspecie + '', "Atenção") //
EndIf  
Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} RetSerie

@type Function
@author gustavo.silva2
@since 18/09/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, retorna o filtro do campo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function RetSerie()
Local cRet :=''

DbSelectArea("G99")

cRet:=	Alltrim(cGTPRetSer)

Return cRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} VldFilAge()

@type Function
@author flavio.martins
@since 26/07/2022
@version 1.0
@param , character, (Descrição do parâmetro)
@return cRet, retorna o filtro do campo
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function VldFilAge(cCodAge, cMsgErro, cMsgSol)
Local lRet  := .T.
Local aArea := GI6->(GetArea())

Default cCodAge  := ''
Default cMsgErro := ''
Default cMsgSol  := ''

GI6->(dbSetOrder(1))

If GI6->(dbSeek(xFilial('GI6')+cCodAge))

    If Empty(GI6->GI6_FILRES)
        lRet := .F.
        cMsgErro := STR0001 // 'Agência emissora sem filial responsável informada'
        cMsgSol  := STR0002 // 'Atualize o cadastro da agência emissora com uma filial responsável'
    ElseIf GI6->GI6_FILRES != cFilAnt
        lRet := .F.
        cMsgErro := STR0003 // 'Filial responsável da agência emissora difere da filial selecionada no momento'
        cMsgSol  := STR0004 // 'A filial selecionada deve ser a mesma da filial responsável da agência emissora'
    Endif
   
Endif

RestArea(aArea)
GtpDestroy(aArea)

Return lRet
