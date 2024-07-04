#INCLUDE "TOTVS.CH"

#define INSERTED        '1'
#define PROCESSING      '2'
#define FINISHED        '3'
#define MSSQL           "MSSQL"
#define POSTGRES        "POSTGRES"
#define ORACLE          "ORACLE"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Fila PLS
Classe da engine de fila do processamento 

@author    Hermiro Jr
@version   V12
@since     11/07/2019
/*/
class CenFila
    
    Data cToken
    Data cCampo
    Data cError
    Data cStatus
    Data cObs
    Data IniProc
	Data cTable

    Method New() Constructor
    Method CriaFila()
    Method addMsg()
    Method DeletaFila()
    Method getMsg()
    Method SetStatus()
    Method Commit()
    Method DestroyBS()
    Method Lock()
    Method checkQueue()
    Method setupQueue()

endClass

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Inicialização da classe

@author    Hermiro Jr
@version   V12
@since     11/07/2019
/*/
method New(cTable) class CenFila

    self:cToken		:= ""
	self:cCampo    	:= ""
    self:cError		:= ""
	self:cStatus		:= ""
    self:cObs  		:= ""
    self:IniProc       := ""
    self:cTable       := cTable

return self
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} Lock
Locka a Tabela para que não haja processamento igual entre os JOBS
@author    Hermiro Jr
@version   V12
@since     11/07/2019
/*/
//------------------------------------------------------------------------------------------
Method Lock(lLibera) Class CenFila

    Local lOk   := .T.

    If lLibera
        UnlockByName(self:cTable, .T., .T.)
    Else
        while lOk 
            If LockByName(self:cTable, .T., .T.)
                lOk := .F.
            EndIf
        enddo
    EndIf

return .T.
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} DeletaFila
Deleta o item na Fila de Processamento.

@author    Hermiro Jr
@version   V12
@since     11/07/2019
/*/
//------------------------------------------------------------------------------------------
Method DeletaFila(cToken,cCampo) Class CenFila

    Local lRet  := .T.
    Local cSql  := ""

    cSql    := "DELETE FROM " + self:cTable
    cSql    += "WHERE TOKEN='"+cToken+"' AND CAMPO='"+cCampo+"'"

    If !self:Commit(cSql)
        lRet:= .F.
        self:cError := "### ERRO ### " + "Erro ao Deletar o item na Fila" + " Erro: " + TCSqlError()
    EndIf    

Return lRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} SetStatus
Atualiza o status do item na fila

@author    Hermiro Jr
@version   V12
@since     11/07/2019
/*/
//------------------------------------------------------------------------------------------
Method SetStatus(cRoboId) Class CenFila

    Local lRet  := .T.
    Local cSql  := ""
	Local cDB	  := TCGetDB()

    If cDB == MSSQL
        cSql    := "UPDATE TOP(1) " + self:cTable + " SET STATUS='" + PROCESSING + "', OBS='PROCESSING', INIPROC='"+Time()+"', ROBOPROC='"+cRoboId+"'"
    ElseIf cDB == ORACLE
        cSql    := "UPDATE " + self:cTable + " SET STATUS='" + PROCESSING + "', OBS='PROCESSING', INIPROC='"+Time()+"', ROBOPROC='"+cRoboId+"'	AND ROWNUM = 1 "
    ElseIf cDB == POSTGRES
        cSql    := "UPDATE " + self:cTable + " SET STATUS='" + PROCESSING + "', OBS='PROCESSING', INIPROC='"+Time()+"', ROBOPROC='"+cRoboId+"'"
        cSql    += " WHERE R_E_C_N_O_ = (SELECT R_E_C_N_O_ FROM " + self:cTable + " WHERE LIMIT 1 )  "  
    EndIf

    If !self:Commit(cSql)
        lRet:= .F.
        self:cError := "### ERRO ### " + "Erro ao Adicionar na Fila" + " Erro: " + TCSqlError()
    EndIf    

Return lRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getMsg
Busca o proximo item da Fila a Processar 

@author    Hermiro Jr
@version   V12
@since     11/07/2019
/*/
//------------------------------------------------------------------------------------------
Method getMsg(cRobo) Class CenFila

    Local cSql      := ""
    Local aInfo     := {}
    Local cQry      := GetNextAlias()
    Local cRoboID   := cRobo+'-'+AllTrim(Str(ThreadId()))


    //Trava a tabela para que jobs diferentes não pegue o mesmo item da Fila
    self:Lock(.F.)

    If !self:SetStatus(cRoboId)
        // Se não mudou o status não deixa prosseguir.
        // Retorna a Array em Branco, para que não mude o status do Item a processar da Fila.
        aInfo:= {}
    EndIf

    cSql    := "SELECT * FROM " + self:cTable + " WHERE STATUS = '" + PROCESSING + "' AND ROBOPROC='"+cRoboID+"' "

    dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),cQry,.F.,.T.)

    If !(cQry)->(Eof())
        aAdd (aInfo, {(cQry)->TOKEN, (cQry)->CAMPO })
    EndIf
    //Destrava a Tabela
    self:Lock(.T.)
    (cQry)->(dbCloseArea())

Return aInfo

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} addMsg
Adiciona Itens na Fila de Processamento.

@author    Hermiro Jr
@version   V12
@since     11/07/2019
/*/
//------------------------------------------------------------------------------------------
Method addMsg(aFila) Class CenFila

    Local lRet          := .T.
    Local cSql          := ""

    cSql := "INSERT INTO " + self:cTable 
    cSql += " (TOKEN,CAMPO,STATUS,OBS,INIPROC,ROBOPROC) VALUES ("
    cSql += "'" + AllTrim(Str(aFila[1])) + "', "  
    cSql += "'" + AllTrim(aFila[2]) + "', "  
    cSql += "'1', "
    cSql += "'INSERTED', "
    cSql += "'', "
    cSql += "'' )"

    If !self:Commit(cSql)
        lRet:= .F.
        self:cError := "### ERRO ### " + "Erro ao Adicionar na Fila" + " Erro: " + TCSqlError()
    EndIf 

Return lRet
/*/{Protheus.doc} criaFila
Cria a tabela temporaria 

@author    Hermiro Jr
@version   V12
@since     11/07/2019
/*/
method CriaFila() Class CenFila

    Local cSql      := ''
    Local lRet      := .T.

    cSql := " CREATE TABLE " + self:cTable + " ( "
    cSql += "     TOKEN      	varchar(64) ,
    cSql += "     CAMPO 		varchar(64) ,
    cSql += "     STATUS		varchar(1)	,
    cSql += "     OBS		    varchar(64)	,
    cSql += "     INIPROC		varchar(64)	,
    cSql += "     ROBOPROC		varchar(64)	,
    cSql += " ) "

    lRet := (self:Commit(cSql))

Return lRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} DestroyBS
Destroi a tabela temporaria 

@author    Hermiro Jr
@version   V12  
@since     11/07/2019
/*/
Method DestroyBS() Class CenFila

    Local cSql      := ''
    Local lRet      := .T.

    cSql := "DROP TABLE "+ self:cTable

    lRet    :=  self:Commit(cSql)
    
Return lRet
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} commit
Executa query 

@author    Hermiro Jr
@version   V12
@since     11/07/2019
/*/
Method Commit(cSql) class CenFila

    Local lRet  := .F.

    If !Empty(cSql)    
        lRet := TcSqlEXEC(cSql) >= 0
    Endif

Return lRet
