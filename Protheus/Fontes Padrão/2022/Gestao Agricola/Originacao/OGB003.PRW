#include "protheus.ch"

/** {Protheus.doc} OGB002
Ajusta Cópia de Tabelas

@param:     Nil
@author:    Equipe Agroindustria
@since:     19/08/2015
@Uso:       SIGAAGR - Originação de Grãos
*/

Function OGB003()
    Local aAreaAtu    := GetArea()
    Local oReport     := Nil
    Private vVetRom, vRetRom
    Private cNoT1, cAlT1, aAlT1
    
    Private cPergunta := "OGB003001"
   

    If TRepInUse()

        oReport := ReportDef()
        oReport:PrintDialog()

    EndIf

    RestArea( aAreaAtu )

    //destroi tabela temporária
    AGRDELETRB( cAlT1, cNoT1 )  
Return( Nil )

/** {Protheus.doc} PrintReport
Constroi o layout do relatório.
@param:     oReport
@author:    Equipe Agroindustria
@since:     19/08/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Static Function ReportDef()
    Local oReport       := Nil
    Local oSection1 := Nil
    
    oReport := TReport():New("OGB003", "Cópia de dados das tabelas NKH e NKG", cPergunta, {| oReport | PrintReport( oReport ) }, "Cópia de dados das tabelas NKH e NKG")
    oReport:lParamPage := .f.
    oReport:SetTotalInLine( .f. )
    oReport:SetLandScape()  
    
    /*Monta as Colunas*/
    
    oSection1 := TRSection():New( oReport, "Mensagem", {} ) 
    TRCell():New( oSection1, "ATUALIZADO"   , , "Mensagem",'@!',50)   
    
   

Return( oReport )

/** {Protheus.doc} PrintReport
Gerar o relatório.
@param:     oReport
@author:    Equipe Agroindustria
@since:     19/08/2015
@Uso:       SIGAAGR - Originação de Grãos
*/
Static Function PrintReport( oReport ) 
    Local oS1          := oReport:Section( 1 )
    Private QtdRegEdit := 0 
                
    If oReport:Cancel()
        Return( Nil )
    EndIf
         
    oS1:Init()
    
    CPTABDATA("NNT", "NKG")
    
    if QtdRegEdit > 0
        oS1:Cell("ATUALIZADO"):SetValue( "A tabela NKG teve " + CVALTOCHAR(QtdRegEdit) + " registros copiados.")
        oS1:PrintLine( )
    endif
         
    CPTABDATA("NNU", "NKH")  
        
    if QtdRegEdit > 0
        oS1:Cell("ATUALIZADO"):SetValue( "A tabela NKH teve " + CVALTOCHAR(QtdRegEdit) + " registros copiados.")
        oS1:PrintLine( )
    endif      
    
    oS1:Finish()       
        
Return( )


/** {Protheus.doc} CriaTT
Atualiza base e cria lista de dados.
@param:     nil
@author:    Equipe Agroindustria
@since:     19/08/2015
@Uso:       SIGAAGR - Originação de Grãos
*/

static Function CPTABDATA(oldTab, newTab)

Local cAliasAnt  := oldTab
Local cAliasNew  := newTab
Local nI   := 0

QtdRegEdit := 0

DbSelectArea(  cAliasNew )
DbSelectArea(  cAliasAnt )
(cAliasNew)->( dBGotop() )

if  (cAliasNew)->( Eof() ) //não tem registros grava as tabelas
    (cAliasAnt)->( dBGotop() )
    BEGIN TRANSACTION
        While ! (cAliasAnt)->( Eof() )
          IF ! RecLock(cAliasNew,.T.)
            DisarmTransaction()
            Final ('Erro Campo :' + (cAliasAnt)->(FIELDNAME(nI)) + ", Contem:" + (cAlias)->(FieldGet( nI )) )
          Endif   
           
          For nI := 1 TO (cAliasAnt)->(FCount())
           cPoNovo := cAliasnew+Substr( (cAliasAnt)->(FIELDNAME(nI)), At("_",(cAliasAnt)->(FIELDNAME(nI))),len((cAliasAnt)->(FIELDNAME(nI))))
           (cAliasNew)->&(CPONOVO) := (cAliasAnt)->(FieldGet( nI ))
          Next nI
          (cAliasNew)->( MsUnlock() )
          
          QtdRegEdit += 1 //quantidade de registros atualizados 
          (cAliasAnt)->( DbSkip() )
        EndDo  
    END TRANSACTION
endif    

return()