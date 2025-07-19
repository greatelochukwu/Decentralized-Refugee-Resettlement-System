# Decentralized Refugee Resettlement System

A blockchain-based platform for coordinating refugee resettlement through smart contracts, ensuring transparency, accountability, and efficient resource allocation.

## System Overview

This system consists of five interconnected smart contracts that manage the entire refugee resettlement process:

### 1. Sponsor Matching Contract (`sponsor-matching.clar`)
- Connects refugees with host families and communities
- Manages sponsor registration and verification
- Handles matching algorithms based on preferences and capacity
- Tracks sponsor-refugee relationships

### 2. Service Coordination Contract (`service-coordination.clar`)
- Provides language training program management
- Handles job placement assistance coordination
- Manages service provider registration
- Tracks service delivery and outcomes

### 3. Housing Allocation Contract (`housing-allocation.clar`)
- Manages temporary and permanent accommodation
- Handles housing inventory and availability
- Coordinates housing assignments
- Tracks housing status and transitions

### 4. Legal Status Tracking Contract (`legal-status-tracking.clar`)
- Monitors immigration status changes
- Tracks citizenship application processes
- Manages document verification
- Records legal milestones and deadlines

### 5. Integration Success Contract (`integration-success.clar`)
- Measures resettlement outcomes
- Tracks community adaptation metrics
- Generates success reports
- Manages feedback and evaluation systems

## Key Features

- **Transparency**: All processes recorded on blockchain
- **Accountability**: Immutable audit trails for all actions
- **Efficiency**: Automated matching and coordination
- **Privacy**: Sensitive data handled with appropriate access controls
- **Scalability**: Modular design supports growth

## Data Structures

### Refugee Profile
- Personal information (encrypted)
- Skills and qualifications
- Language proficiency
- Family composition
- Special needs

### Sponsor Profile
- Contact information
- Housing capacity
- Support capabilities
- Preferences and requirements
- Verification status

### Service Provider
- Organization details
- Service types offered
- Capacity and availability
- Performance metrics
- Certification status

## Contract Interactions

1. **Registration Phase**: Refugees, sponsors, and service providers register
2. **Matching Phase**: System matches refugees with appropriate sponsors
3. **Service Coordination**: Language training and job placement services assigned
4. **Housing Assignment**: Temporary and permanent housing allocated
5. **Legal Processing**: Immigration status tracked and updated
6. **Integration Monitoring**: Success metrics collected and analyzed

## Security Considerations

- Access control through principal verification
- Data validation on all inputs
- Error handling for edge cases
- Audit trails for all state changes

## Getting Started

1. Deploy contracts in order of dependencies
2. Register system administrators
3. Initialize service providers and sponsors
4. Begin refugee registration and matching process

## Testing

Comprehensive test suite covers:
- Contract deployment and initialization
- User registration and verification
- Matching algorithms
- Service coordination workflows
- Housing allocation processes
- Legal status updates
- Integration success tracking
