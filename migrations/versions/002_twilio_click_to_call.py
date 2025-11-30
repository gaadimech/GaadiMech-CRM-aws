"""Add Twilio Click-to-Call support to CallLog

Revision ID: 002_twilio_click_to_call
Revises: 001_add_security_and_features
Create Date: 2025-11-30 12:00:00.000000

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

# revision identifiers, used by Alembic.
revision = '002_twilio_click_to_call'
down_revision = '001_add_security_and_features'
branch_labels = None
depends_on = None


def upgrade():
    """
    Upgrade CallLog table to support Twilio integration
    """
    # Add new Twilio-specific columns
    with op.batch_alter_table('call_log', schema=None) as batch_op:
        # Check if columns exist before adding
        batch_op.add_column(sa.Column('call_sid', sa.String(length=100), nullable=True))
        batch_op.add_column(sa.Column('from_number', sa.String(length=20), nullable=True))
        batch_op.add_column(sa.Column('to_number', sa.String(length=20), nullable=True))
        batch_op.add_column(sa.Column('customer_number', sa.String(length=20), nullable=True))
        batch_op.add_column(sa.Column('direction', sa.String(length=20), nullable=True, server_default='outbound'))
        batch_op.add_column(sa.Column('status', sa.String(length=30), nullable=True, server_default='initiated'))
        batch_op.add_column(sa.Column('created_at', sa.DateTime(), nullable=True))
        batch_op.add_column(sa.Column('updated_at', sa.DateTime(), nullable=True))
        
        # Create unique constraint on call_sid
        batch_op.create_unique_constraint('uq_call_log_call_sid', ['call_sid'])
        
        # Create indexes for performance
        batch_op.create_index('idx_call_log_sid', ['call_sid'], unique=False)
        batch_op.create_index('idx_call_log_status', ['status'], unique=False)
        batch_op.create_index('idx_call_log_lead', ['lead_id'], unique=False)
    
    # Update existing records to have default values
    op.execute("""
        UPDATE call_log 
        SET 
            direction = COALESCE(call_type, 'outbound'),
            status = COALESCE(call_status, 'completed'),
            created_at = COALESCE(call_started_at, NOW()),
            updated_at = COALESCE(call_ended_at, call_started_at, NOW())
        WHERE direction IS NULL OR status IS NULL OR created_at IS NULL OR updated_at IS NULL
    """)
    
    # Make nullable fields nullable=True for lead_id (to support non-lead calls)
    with op.batch_alter_table('call_log', schema=None) as batch_op:
        batch_op.alter_column('lead_id', nullable=True)


def downgrade():
    """
    Downgrade by removing Twilio-specific columns
    """
    with op.batch_alter_table('call_log', schema=None) as batch_op:
        # Drop indexes
        batch_op.drop_index('idx_call_log_sid')
        batch_op.drop_index('idx_call_log_status')
        batch_op.drop_index('idx_call_log_lead')
        
        # Drop unique constraint
        batch_op.drop_constraint('uq_call_log_call_sid', type_='unique')
        
        # Drop columns
        batch_op.drop_column('updated_at')
        batch_op.drop_column('created_at')
        batch_op.drop_column('status')
        batch_op.drop_column('direction')
        batch_op.drop_column('customer_number')
        batch_op.drop_column('to_number')
        batch_op.drop_column('from_number')
        batch_op.drop_column('call_sid')
        
        # Restore lead_id as non-nullable
        batch_op.alter_column('lead_id', nullable=False)
