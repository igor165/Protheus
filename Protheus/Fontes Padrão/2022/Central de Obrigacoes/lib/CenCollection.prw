#include "TOTVS.CH"
#INCLUDE 'FWMVCDEF.CH'

#DEFINE COLLECTION 2

#DEFINE NIVEL 1
#DEFINE SUBNIVEL 2

#DEFINE RELFIELD 1
#DEFINE FIELD 2

#Define DBFIELD 1
#Define JSONFIELD 2

#DEFINE N_TO_N 1    // Relação N para N
#DEFINE ONE_TO_N 2  // Relação 1 para N
#DEFINE N_TO_ONE 3  // Relação N para 1
#DEFINE ZERO_TO 4   // Relação 0 para 1 ou N
#DEFINE TO_ZERO 5   // Relação N ou 1 para 0

#DEFINE NONE 0    // Behavior Atribui alterações somente a colação principal
#DEFINE CASCADE 1 // Behavior Realiza todas as operações em cascata

/*/{Protheus.doc}
    Collection
    Classe abstrata de uma Coleção de registros de uma entifade.
    Esta classe deve orquestrar as operações feitas em coleções de registros.
    Isso envolve:
        - Buscas de registros específicos
        - Buscas de coleções de registros
        - Iterações sobre cada registro retornado
        - Deleção ou atualização de coleções de registros

    @type  Class
    @author everton.mateus
    @since 20190222
/*/

Class CenCollection

    Data oDao
    Data oMapper
    Data hMap
    Data lFound
    Data nRecno
    Data cError
    Data lFault
    Data hChildren

    Method New() Constructor
    Method destroy()
    Method found()
    Method setError(cMsg)
    Method getError()
    Method hasNext()
    Method getNext()
    Method mapFromJson(oJson)
    Method mapFromDao()
    Method mapDaoJson(oJson)
    Method goTop()
    Method applyPageSize(cPage,cPageSize)
    Method getPageSize()
    Method getDao()
    Method getQuery()
    Method getAlias()
    Method applyOrder(cOrder)
    Method setValue(cProperty,xData)
    Method getValue(cProperty)
    Method commit()
    Method insert()
    Method update()
    Method delete()
    Method superDel()
    Method buscar()
    Method bscChaPrim()
    Method setEntity(oEntity)
    Method atuStatGrp(cStatus,cAlias,cWhere)
    Method atuStatusByRecno(cStatus,nRecno)
    Method getDbRecno()
    Method changeFields(aFields)
    Method setRelation(oRelation)
    Method getRelation(cName)
    Method setKeyRelation()
    Method listRelations()
    Method delRelation()
    Method sethMap(hMap)
    Method isRelation(cName)
    Method applySearch(cSearch)
    Method applyExpand(aExpand)
    Method getAFields()
    Method setFields(aFields)

EndClass

Method New() Class CenCollection
    self:lFound := .F.
    self:lFault := .F.
    self:cError := ""
    self:hMap := THashMap():New()
    self:hChildren := THashMap():New()
return self

Method destroy() Class CenCollection

    if !empty(self:getDao())
        self:getDao():destroy()
        FreeObj(self:oDao)
        self:oDao := nil
    endif

    if !empty(self:oMapper)
        FreeObj(self:oMapper)
        self:oMapper := nil
    endif

    if !empty(self:hMap)
        self:hMap:clean()
        FreeObj(self:hMap)
        self:hMap := nil
    endif

return

Method sethMap(hMap) Class CenCollection
    self:hMap := hMap
    self:oDao:setHMap(hMap)
return

Method found() Class CenCollection
return self:lFound

Method setError(cMsg) Class CenCollection
    self:cError := cMsg
    self:lFault := .T.
return

Method getError() Class CenCollection
return self:cError

Method hasNext() Class CenCollection
return self:getDao():hasNext(self:nRecno)

Method getNext() Class CenCollection
    self:oMapper:setEntity(self:initEntity())
    self:oMapper:mapFromDao(self:getDao())
    self:hMap := self:oMapper:getEntity():getHMap()
    self:setKeyRelation()
    self:nRecno++
return self:oMapper:getEntity()

Method mapFromJson(oJson) Class CenCollection
    self:oMapper:setEntity(self)
    self:oMapper:mapFromJson(oJson)
return self:oMapper:getEntity()

Method mapFromDao() Class CenCollection
    self:oMapper:setEntity(self)
    self:oMapper:mapFromDao(self:getDao())
return self:oMapper:getEntity()

Method mapDaoJson(oJson) Class CenCollection
    self:mapFromDao()
    self:mapFromJson(oJson)
return self:oMapper:getEntity()

Method goTop() Class CenCollection
    self:nRecno := 1
    self:getDao():posReg(self:nRecno)
return

Method applyPageSize(cPage,cPageSize) Class CenCollection
    self:getDao():setNumPage(cPage)
    self:getDao():setPageSize(cPageSize)
return

Method getPageSize() Class CenCollection
return self:getDao():getPageSize()

Method getDao() Class CenCollection
Return self:oDao

Method getQuery() Class CenCollection
Return self:getDao():getQuery()

Method getAlias() Class CenCollection
Return self:getDao():getAlias()

Method applyOrder(cOrder) Class CenCollection
    self:getDao():setOrder(cOrder)
return

Method setValue(cProperty,xData) Class CenCollection
    Local nPos := 0
    nPos := aScan(self:getAFields(),{ |aFields| aFields[DBFIELD] == cProperty })
    If nPos > 0
        cProperty := self:getAFields()[nPos][JSONFIELD]
    EndIf
    self:getDao():setValue(cProperty,xData)
Return self:hMap:set(cProperty,xData)

Method getValue(cProperty) Class CenCollection
    Local anyValue := ""
    Local xDbValue := ""
    Local nPos := 0
    self:hMap:get(cProperty,@anyValue)
    If Empty(anyValue)
        nPos := aScan(self:getAFields(),{ |aFields| aFields[DBFIELD] == cProperty })
        If nPos > 0
            xDbValue := self:getValue(self:getAFields()[nPos][JSONFIELD])
            If !Empty(xDbValue)
                anyValue := xDbValue
            EndIf
        EndIf
    EndIf
Return anyValue

Method getAFields() Class CenCollection
Return self:oMapper:getAFields()

Method setFields(aFields) Class CenCollection
Return self:oMapper:setFields(aFields)

Method insert() Class CenCollection
Return self:oDao:insert()

Method commit(lInclui,lSub) Class CenCollection
    Default lInclui := .F.
    Default lSub    := .F.
    self:lFound := self:getDao():commit(lInclui,lSub)
    If !self:found()
        self:setError("Não conseguiu incluir o registro. " + self:getDao():getError() )
    EndIf
Return self:found()

Method update() Class CenCollection
Return self:commit()

Method delete() Class CenCollection
    self:lFound := self:getDao():delete()
    If !self:found()
        self:setError("Não conseguiu deletar o registro. " + self:getDao():getError())
    EndIf
Return self:found()

Method superDel() Class CenCollection
    self:lFound := self:getDao():superDel()
    If !self:found()
        self:setError("Não conseguiu deletar o registro. " + self:getDao():getError())
    EndIf
Return self:found()

Method delRelation() Class CenCollection
    self:lFound := self:getDao():delRelation()
    If !self:found()
        self:setError("Não conseguiu deletar o registro. " + self:getDao():getError())
    EndIf
Return self:found()

Method buscar() Class CenCollection
    self:lFound := self:getDao():buscar()
    self:goTop()
Return self:found()

Method bscChaPrim() Class CenCollection
    self:lFound := self:getDao():bscChaPrim()
    self:goTop()
Return self:found()

Method setEntity(oEntity) Class CenCollection
    self:oMapper:setEntity(oEntity)
    self:oDao:setHMap(oEntity:getHMap())
return

Method atuStatGrp(cStatus,cAlias,cWhere) Class CenCollection
    self:lFound := self:getDao():atuStatGrp(cStatus, cAlias , cWhere)
    self:goTop()
Return self:found()

Method atuStatusByRecno(cStatus,nRecno) Class CenCollection
    self:lFound := self:getDao():atuStatusByRecno(cStatus, nRecno)
    self:goTop()
Return self:found()

Method getDbRecno() Class CenCollection
Return self:getDao():getDbRecno()

Method changeFields(aFields) Class CenCollection
    self:oMapper:setFields(aFields)
    self:oDao:setFields(aFields)
Return

Method setRelation(oRelation) Class CenCollection
    self:hChildren:set(oRelation:getName(),oRelation)
Return

/*/
    Seta as chaves de busca dos filhos
/*/
Method setKeyRelation() Class CenCollection

    Local nChild := 0
    Local nFrTo := 0
    Local aRelList := Nil
    Local aFromTo := Nil

    self:hChildren:list(@aRelList)

    For nChild := 1 to Len(aRelList)

        oRelation := aRelList[nChild][COLLECTION]
        aFromTo   := oRelation:getKey()

        /*/
            Limpa variáveis, em POST, faz o insert e depos a busca,
            variaveis ficam sujas para montar o Json de resposta
        /*/
        oRelation:getCollection():setHMap(THashMap():New())

        For nFrTo := 1 to len(aFromTo)
            oRelation:getCollection():setValue(;
                aFromTo[nFrTo][FIELD],self:getValue(aFromTo[nFrTo][RELFIELD]);
                )
        Next
        self:setRelation(oRelation)
    Next

return

Method listRelations() Class CenCollection
    Local aRelList := {}
    self:hChildren:list(@aRelList)
return aRelList

Method isRelation(cName) Class CenCollection
Return self:hChildren:get(cName)

Method getRelation(cName) Class CenCollection
    Local oRelation := Nil
    self:hChildren:get(cName,@oRelation)
Return oRelation:getCollection()

Method applySearch(cSearch) Class CenCollection
    self:lFound := self:getDao():applySearch(cSearch)
    self:goTop()
Return self:found()

Method applyExpand(aExpand) Class CenCollection

    Local lOk := .T.
    Local nExp := 1
    Local aExpands := {}
    Default aExpand := {}

    self:initRelation()

    For nExp := 1 to len(aExpand)
        aExpands := StrTokArr2(aExpand[nExp], ".")
        If self:isRelation(aExpands[NIVEL])
            If len(aExpands) > 1
                self:getRelation(aExpands[NIVEL]):initRelation()
                If !self:getRelation(aExpands[NIVEL]):isRelation(aExpands[SUBNIVEL])
                    //Não é um relacionamento
                    lOk := .F.
                EndIf
            EndIf
        Else
            //Não é um relacionamento
            lOk := .F.
        EndIf
    Next

return lOk