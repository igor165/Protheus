#include "protheus.ch"

/** {Protheus.doc} OGB002
Ajusta Cópia de Tabelas

@param:     Nil
@author:    Equipe Agroindustria
@since:     19/08/2015
@Uso:       SIGAAGR - Originação de Grãos
*/

Function OGB004()
    Local aAreaAtu    := GetArea()
    Local oReport     := Nil
    Private vVetRom, vRetRom
    Private cNoT1, cAlT1, aAlT1
    
    Private cPergunta := "OGB004001"
   

    If TRepInUse()

        oReport := ReportDef()
        oReport:PrintDialog()

    EndIf

    RestArea( aAreaAtu )


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
    
    oReport := TReport():New("OGB004", "Cópia de dados das tabelas SB1 para SB5", cPergunta, {| oReport | PrintReport( oReport ) }, "Cópia de dados das tabelas NKH e NKG")
    oReport:lParamPage := .f.
    oReport:SetTotalInLine( .f. )
    oReport:SetLandScape()  
    
    /*Monta as Colunas*/
    
    oSection1 := TRSection():New( oReport, "Mensagem", {} ) 
    TRCell():New( oSection1, "ATUALIZADO"   , , "Mensagem",'@!',100)   
    
   

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
    Private cAliasNew  := "SB5"
    Private cAliasAnt  := "SB1"   
             
    If oReport:Cancel()
        Return( Nil )
    EndIf
         
    oS1:Init()
    
    DbSelectArea(  cAliasNew )
    DbSelectArea(  cAliasAnt )
    (cAliasAnt)->( dBGotop() )
    
    BEGIN TRANSACTION
    
        While ! (cAliasAnt)->( Eof() ) //lista todos os sb1
           
        	If .not. empty ((cAliasAnt)->( B1_UMPRC ))
           
	           (cAliasNew)->( dbSetOrder( 1 ))
	           if (cAliasNew)->( dbSeek( xFilial( "SB5" ) + (cAliasAnt)->( B1_COD )))
	           
	              IF ! RecLock(cAliasNew,.F.)
	                DisarmTransaction()
	                Final ('Erro Produto :' + (cAliasAnt)->( B1_COD ) )
	              Endif   
	               
	              (cAliasNew)->( B5_UMPRC ) := (cAliasAnt)->( B1_UMPRC )
	
	              (cAliasNew)->( MsUnlock() )
	              
	              QtdRegEdit += 1 //quantidade de registros atualizados 
	           else
	              oS1:Cell("ATUALIZADO"):SetValue("Não existe complemento cadastrado para o produto: " + ALLTRIM((cAliasAnt)->( B1_COD )))
	              oS1:PrintLine( )
	           endif   
	      EndIf
          (cAliasAnt)->( DbSkip() )
        EndDo  
    END TRANSACTION
    
    if QtdRegEdit > 0
        oS1:Cell("ATUALIZADO"):SetValue( "A tabela SB5 teve " + CVALTOCHAR(QtdRegEdit) + " registros atualizados.")
        oS1:PrintLine( )
    endif     
    
    oS1:Finish()       
        
Return( )


